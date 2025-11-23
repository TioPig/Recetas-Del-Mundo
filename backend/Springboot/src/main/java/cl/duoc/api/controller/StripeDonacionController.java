package cl.duoc.api.controller;

import cl.duoc.api.model.entities.Donacion;
import cl.duoc.api.model.repositories.DonacionRepository;
import cl.duoc.api.util.JwtUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import com.stripe.Stripe;
import com.stripe.model.checkout.Session;
import com.stripe.param.checkout.SessionCreateParams;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
public class StripeDonacionController {

    @Autowired
    private DonacionRepository donacionRepository;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private final ObjectMapper mapper = new ObjectMapper();

    // POST /donaciones/create-session
    @PostMapping("/donaciones/create-session")
    public ResponseEntity<?> createSession(@RequestHeader HttpHeaders headers, @RequestBody Map<String, Object> body) {
        try {
            String auth = headers.getFirst(HttpHeaders.AUTHORIZATION);
            if (auth == null || !auth.startsWith("Bearer ")) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Authorization header missing or invalid");
            }
            String token = auth.substring(7);
            Integer tokenUserId;
            try {
                tokenUserId = jwtUtil.extractUserId(token);
            } catch (Exception e) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid token");
            }

            Integer idReceta = body.get("idReceta") == null ? null : (Integer) body.get("idReceta");
            Integer amount = body.get("amount") == null ? null : (Integer) body.get("amount");
            String currency = body.get("currency") == null ? "usd" : ((String) body.get("currency")).toLowerCase();

            if (amount == null || amount <= 0) {
                return ResponseEntity.badRequest().body("amount (in cents) is required and must be > 0");
            }

            // Create Donacion record with PENDING status
            Donacion d = new Donacion();
            d.setIdUsr(tokenUserId);
            d.setIdReceta(idReceta);
            d.setAmount(amount);
            d.setCurrency(currency.toUpperCase());
            d.setStatus("PENDING");
            Donacion saved = donacionRepository.save(d);

            // If STRIPE_SECRET_KEY is provided, create a real Checkout Session
            String stripeKey = System.getenv("STRIPE_SECRET_KEY");
            if (stripeKey == null || stripeKey.isEmpty()) {
                Map<String, Object> resp = new HashMap<>();
                resp.put("donacion", saved);
                resp.put("note", "STRIPE_SECRET_KEY not set; created local PENDING donacion. Set STRIPE_SECRET_KEY to create real sessions.");
                return ResponseEntity.status(HttpStatus.CREATED).body(resp);
            }

            Stripe.apiKey = stripeKey;

            SessionCreateParams.LineItem.PriceData.ProductData product = SessionCreateParams.LineItem.PriceData.ProductData.builder()
                    .setName("Donación Receta" + (idReceta != null ? (" #" + idReceta) : ""))
                    .build();

            SessionCreateParams.LineItem.PriceData priceData = SessionCreateParams.LineItem.PriceData.builder()
                    .setCurrency(currency)
                    .setUnitAmount(Long.valueOf(amount))
                    .setProductData(product)
                    .build();

            SessionCreateParams.LineItem item = SessionCreateParams.LineItem.builder()
                    .setPriceData(priceData)
                    .setQuantity(1L)
                    .build();

            String successUrl = System.getenv("DONATION_SUCCESS_URL");
            if (successUrl == null) successUrl = "https://example.com/success";
            String cancelUrl = System.getenv("DONATION_CANCEL_URL");
            if (cancelUrl == null) cancelUrl = "https://example.com/cancel";

            SessionCreateParams params = SessionCreateParams.builder()
                    .addPaymentMethodType(SessionCreateParams.PaymentMethodType.CARD)
                    .setMode(SessionCreateParams.Mode.PAYMENT)
                    .setSuccessUrl(successUrl + "?session_id={CHECKOUT_SESSION_ID}")
                    .setCancelUrl(cancelUrl)
                    .addLineItem(item)
                    .putMetadata("donacion_id", String.valueOf(saved.getIdDonacion()))
                    .build();

            Session session = Session.create(params);

            // Save session id on Donacion
            saved.setStripeSessionId(session.getId());
            donacionRepository.save(saved);

            // Persist a sesion_pago row including metadata (jsonb)
            try {
                String metadataJson = null;
                if (session.getMetadata() != null && !session.getMetadata().isEmpty()) {
                    metadataJson = mapper.writeValueAsString(session.getMetadata());
                }
                String status = (session.getPaymentStatus() != null && session.getPaymentStatus().equalsIgnoreCase("paid")) ? "PAID" : "PENDING";
                // Insert with explicit cast to jsonb so Postgres stores it correctly
                String sql = "INSERT INTO sesion_pago (session_id, provider, status, id_donacion, metadata) VALUES (?,'stripe',?,?::jsonb)";
                jdbcTemplate.update(sql, session.getId(), status, saved.getIdDonacion(), metadataJson);
            } catch (Exception e) {
                // Don't fail the whole request if DB write for sesion_pago fails; log to stdout for now
                System.out.println("Warning: could not insert sesion_pago metadata: " + e.getMessage());
            }

            Map<String, Object> result = new HashMap<>();
            result.put("sessionId", session.getId());
            result.put("url", session.getUrl());
            result.put("donacion", saved);

            return ResponseEntity.status(HttpStatus.CREATED).body(result);

        } catch (com.stripe.exception.StripeException se) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Stripe error: " + se.getMessage());
        } catch (ClassCastException cce) {
            return ResponseEntity.badRequest().body("Invalid request payload types");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    // POST /donaciones/verify-session
    @PostMapping("/donaciones/verify-session")
    public ResponseEntity<?> verifySession(@RequestHeader HttpHeaders headers, @RequestBody Map<String, Object> body) {
        try {
            String auth = headers.getFirst(HttpHeaders.AUTHORIZATION);
            if (auth == null || !auth.startsWith("Bearer ")) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Authorization header missing or invalid");
            }
            String token = auth.substring(7);
            Integer tokenUserId;
            try {
                tokenUserId = jwtUtil.extractUserId(token);
            } catch (Exception e) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid token");
            }

            String sessionId = body.get("sessionId") == null ? null : body.get("sessionId").toString();
            if (sessionId == null || sessionId.isEmpty()) {
                return ResponseEntity.badRequest().body("sessionId is required");
            }

            // If STRIPE_SECRET_KEY present, ask Stripe for session info
            String stripeKey = System.getenv("STRIPE_SECRET_KEY");
            if (stripeKey != null && !stripeKey.isEmpty()) {
                Stripe.apiKey = stripeKey;
                try {
                    Session session = Session.retrieve(sessionId);
                    String paymentStatus = session.getPaymentStatus();
                    String paymentIntent = session.getPaymentIntent();

                    // Try find existing Donacion by session id
                    java.util.Optional<Donacion> od = donacionRepository.findByStripeSessionId(sessionId);
                    if (od.isPresent()) {
                        Donacion d = od.get();
                        if ("paid".equalsIgnoreCase(paymentStatus) || (paymentIntent != null && !paymentIntent.isEmpty())) {
                            d.setStatus("PAID");
                            d.setStripePaymentIntent(paymentIntent);
                        } else {
                            d.setStatus("PENDING");
                        }
                        donacionRepository.save(d);
                        Map<String,Object> resp = new HashMap<>();
                        resp.put("status", d.getStatus());
                        resp.put("donacion", d);
                        return ResponseEntity.ok(resp);
                    }

                    // Not found by sessionId — try metadata
                    java.util.Map<String,String> meta = session.getMetadata();
                    if (meta != null && meta.containsKey("donacion_id")) {
                        try {
                            Integer did = Integer.valueOf(meta.get("donacion_id"));
                            java.util.Optional<Donacion> od2 = donacionRepository.findById(did);
                            if (od2.isPresent()) {
                                Donacion d2 = od2.get();
                                if ("paid".equalsIgnoreCase(paymentStatus) || (paymentIntent != null && !paymentIntent.isEmpty())) {
                                    d2.setStatus("PAID");
                                    d2.setStripePaymentIntent(paymentIntent);
                                    d2.setStripeSessionId(sessionId);
                                } else {
                                    d2.setStatus("PENDING");
                                }
                                donacionRepository.save(d2);
                                Map<String,Object> resp = new HashMap<>();
                                resp.put("status", d2.getStatus());
                                resp.put("donacion", d2);
                                return ResponseEntity.ok(resp);
                            }
                        } catch (NumberFormatException nfe) {
                            // fall through
                        }
                    }

                    // Nothing updated — return Stripe session info
                    Map<String,Object> resp2 = new HashMap<>();
                    resp2.put("stripePaymentStatus", paymentStatus);
                    resp2.put("stripePaymentIntent", paymentIntent);
                    resp2.put("session", session.getId());
                    return ResponseEntity.ok(resp2);
                } catch (com.stripe.exception.StripeException se) {
                    return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Stripe error: " + se.getMessage());
                }
            } else {
                // No stripe key — just inspect DB
                java.util.Optional<Donacion> od = donacionRepository.findByStripeSessionId(sessionId);
                if (od.isPresent()) {
                    Donacion d = od.get();
                    Map<String,Object> resp = new HashMap<>();
                    resp.put("status", d.getStatus());
                    resp.put("donacion", d);
                    return ResponseEntity.ok(resp);
                } else {
                    return ResponseEntity.status(HttpStatus.NOT_FOUND).body("No donacion found for sessionId");
                }
            }

        } catch (ClassCastException cce) {
            return ResponseEntity.badRequest().body("Invalid request payload types");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

}
