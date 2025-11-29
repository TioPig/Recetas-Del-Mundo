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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.UUID;

@RestController
public class StripeDonacionController {

    @Autowired
    private DonacionRepository donacionRepository;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private cl.duoc.api.service.SesionPagoService sesionPagoService;
    @Autowired
    private cl.duoc.api.service.StripeSessionService stripeSessionService;
    private static final Logger logger = LoggerFactory.getLogger(StripeDonacionController.class);

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
            // Parse amount as BigDecimal (accept Number or String)
            Object rawAmount = body.get("amount");
            BigDecimal amount = null;
            if (rawAmount != null) {
                if (rawAmount instanceof Number) {
                    amount = new BigDecimal(((Number) rawAmount).toString());
                } else {
                    try {
                        amount = new BigDecimal(rawAmount.toString());
                    } catch (NumberFormatException nfe) {
                        return ResponseEntity.badRequest().body("amount is invalid");
                    }
                }
            }

            // Normalize amount for backward compatibility: if client sent cents as integer
            // (e.g. 500) we convert to units dividing by 100. Store units in DB (e.g. 5.00).
            if (amount != null) {
                if (amount.scale() == 0 && amount.compareTo(new BigDecimal(100)) >= 0) {
                    amount = amount.divide(new BigDecimal(100));
                }
            }

            String currency = body.get("currency") == null ? "usd" : ((String) body.get("currency")).toLowerCase();

            if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
                return ResponseEntity.badRequest().body("amount (units, e.g. 5.00) is required and must be > 0");
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
                // No Stripe key: create a local sesion_pago row so every Donacion has a payment session record
                Map<String, Object> resp = new HashMap<>();
                String localSessionId = "local-" + UUID.randomUUID().toString();
                try {
                    String metadataJson = mapper.writeValueAsString(java.util.Collections.singletonMap("donacion_id", String.valueOf(saved.getIdDonacion())));
                    String status = "PENDING";
                    String sqlLocal = "INSERT INTO sesion_pago (session_id, provider, status, id_donacion, metadata) VALUES (?,'local',?,?,?::jsonb)";
                    jdbcTemplate.update(sqlLocal, localSessionId, status, saved.getIdDonacion(), metadataJson);
                    // Save local session id on Donacion for easier tracing
                    saved.setStripeSessionId(localSessionId);
                    donacionRepository.save(saved);
                    resp.put("sessionId", localSessionId);
                } catch (Exception e) {
                    logger.warn("Could not insert local sesion_pago: {}", e.getMessage());
                    logger.debug("Exception inserting local sesion_pago", e);
                }
                resp.put("donacion", saved);
                resp.put("note", "STRIPE_SECRET_KEY not set; created local PENDING donacion and local sesion_pago.");
                return ResponseEntity.status(HttpStatus.CREATED).body(resp);
            }

            Stripe.apiKey = stripeKey;

            SessionCreateParams.LineItem.PriceData.ProductData product = SessionCreateParams.LineItem.PriceData.ProductData.builder()
                    .setName("Donación Receta" + (idReceta != null ? (" #" + idReceta) : ""))
                    .build();

                // Stripe expects amount in smallest currency unit (cents). Convert BigDecimal units -> cents
                long cents = amount.setScale(2, RoundingMode.HALF_UP).multiply(new BigDecimal(100)).longValueExact();

                // Validation: Stripe requires at least $0.50 (50 cents)
                if (cents < 50) {
                    return ResponseEntity.badRequest().body("amount too small: minimum is 0.50 " + currency.toUpperCase());
                }

                SessionCreateParams.LineItem.PriceData priceData = SessionCreateParams.LineItem.PriceData.builder()
                    .setCurrency(currency)
                    .setUnitAmount(Long.valueOf(cents))
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

            // Insert a preliminary sesion_pago row so every donacion has a payment session record
            String creatingSessionId = "creating-" + UUID.randomUUID().toString();
            try {
                Map<String,Object> preMeta = new HashMap<>();
                preMeta.put("donacion_id", String.valueOf(saved.getIdDonacion()));
                preMeta.put("amount", cents);
                preMeta.put("currency", currency);
                if (idReceta != null) preMeta.put("idReceta", idReceta);
                String preMetaJson = mapper.writeValueAsString(preMeta);
                String sqlPre = "INSERT INTO sesion_pago (session_id, provider, status, id_donacion, metadata) VALUES (?,'stripe','CREATING',?,?::jsonb)";
                jdbcTemplate.update(sqlPre, creatingSessionId, saved.getIdDonacion(), preMetaJson);
                // Save the temporary session id on Donacion for tracing
                saved.setStripeSessionId(creatingSessionId);
                donacionRepository.save(saved);
                } catch (Exception e) {
                    logger.warn("Could not insert preliminary sesion_pago: {}", e.getMessage());
                    logger.debug("Exception inserting preliminary sesion_pago", e);
                }

            Session session = null;
            try {
                session = Session.create(params);
                // On success, update sesion_pago row replacing temporary id with real session id
                try {
                    String metadataJson = null;
                    if (session.getMetadata() != null && !session.getMetadata().isEmpty()) {
                        metadataJson = mapper.writeValueAsString(session.getMetadata());
                    }
                    String status = (session.getPaymentStatus() != null && session.getPaymentStatus().equalsIgnoreCase("paid")) ? "PAID" : "PENDING";
                    String sqlUpd = "UPDATE sesion_pago SET session_id = ?, status = ?, metadata = ?::jsonb WHERE session_id = ?";
                    jdbcTemplate.update(sqlUpd, session.getId(), status, metadataJson, creatingSessionId);
                } catch (Exception e) {
                    logger.warn("Could not update sesion_pago after Stripe create: {}", e.getMessage());
                    logger.debug("Exception updating sesion_pago after Stripe create", e);
                }

                // Save session id on Donacion
                saved.setStripeSessionId(session.getId());
                donacionRepository.save(saved);

                Map<String, Object> result = new HashMap<>();
                result.put("sessionId", session.getId());
                result.put("url", session.getUrl());
                result.put("donacion", saved);

                return ResponseEntity.status(HttpStatus.CREATED).body(result);
            } catch (com.stripe.exception.StripeException se) {
                // If Stripe fails, mark the preliminary sesion_pago as ERROR with metadata
                try {
                    Map<String,Object> errMeta = new HashMap<>();
                    errMeta.put("error", se.getMessage());
                    errMeta.put("donacion_id", String.valueOf(saved.getIdDonacion()));
                    String errJson = mapper.writeValueAsString(errMeta);
                    String sqlErr = "UPDATE sesion_pago SET status = ?, metadata = ?::jsonb WHERE session_id = ?";
                    jdbcTemplate.update(sqlErr, "ERROR", errJson, creatingSessionId);
                } catch (Exception e2) {
                    logger.warn("Could not update sesion_pago with Stripe error: {}", e2.getMessage());
                    logger.debug("Exception updating sesion_pago with Stripe error", e2);
                }
                throw se;
            }

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
            // First, attempt to retrieve Stripe session (this allows tests to mock Session.retrieve even
            // when STRIPE_SECRET_KEY is not set). If retrieval succeeds we'll use that info; otherwise
            // fall back to DB lookup (including `sesion_pago`).
            // Use injectable StripeSessionService so tests can mock retrieval cleanly
            com.stripe.model.checkout.Session session = null;
            try {
                session = stripeSessionService.retrieve(sessionId);
            } catch (Exception ex) {
                logger.warn("Could not retrieve Stripe session for {}: {}", sessionId, ex.getMessage());
                logger.debug("Exception retrieving Stripe session", ex);
                // Ignore: could be no API key, network, or mock not visible across classloaders; we'll fallback to DB-based resolution
                session = null;
            }

            if (session != null) {
                String paymentStatus = session.getPaymentStatus();
                String paymentIntent = session.getPaymentIntent();
                try {
                    logger.info("Stripe session retrieved id={}, paymentStatus={}, paymentIntent={}, metadata={}", session.getId(), paymentStatus, paymentIntent, session.getMetadata());
                } catch (Exception logEx) {
                    logger.debug("Could not log Stripe session details", logEx);
                }

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
                    boolean updated = sesionPagoService.updateSesionPago(session.getId(), d.getStatus(), session.getMetadata());
                    logger.info("Updated donacion id={} status={} and sesion_pago updated={}", d.getIdDonacion(), d.getStatus(), updated);
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
                            boolean updated2 = sesionPagoService.updateSesionPago(sessionId, d2.getStatus(), session.getMetadata());
                            logger.info("Updated donacion id={} status={} and sesion_pago updated={}", d2.getIdDonacion(), d2.getStatus(), updated2);
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
            }

            // Fallback: no Stripe session available => inspect DB (donacion.stripe_session_id or sesion_pago)
            java.util.Optional<Donacion> od = donacionRepository.findByStripeSessionId(sessionId);
            if (od.isPresent()) {
                Donacion d = od.get();
                Map<String,Object> resp = new HashMap<>();
                resp.put("status", d.getStatus());
                resp.put("donacion", d);
                return ResponseEntity.ok(resp);
            }

            // Try to resolve via sesion_pago table
            try {
                Integer did = jdbcTemplate.queryForObject("SELECT id_donacion FROM sesion_pago WHERE session_id = ? LIMIT 1", new Object[]{sessionId}, Integer.class);
                if (did != null) {
                    java.util.Optional<Donacion> od2 = donacionRepository.findById(did);
                    if (od2.isPresent()) {
                        Donacion d2 = od2.get();
                        Map<String,Object> resp = new HashMap<>();
                        resp.put("status", d2.getStatus());
                        resp.put("donacion", d2);
                        return ResponseEntity.ok(resp);
                    }
                }
            } catch (Exception e) {
                // ignore and fall through to not found
            }

            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("No donacion found for sessionId");

        } catch (ClassCastException cce) {
            return ResponseEntity.badRequest().body("Invalid request payload types");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

}
