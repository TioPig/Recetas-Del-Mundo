package cl.duoc.api.controller;

import cl.duoc.api.model.entities.Donacion;
import cl.duoc.api.model.repositories.DonacionRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.stripe.exception.SignatureVerificationException;
import com.stripe.model.Event;
import com.stripe.model.checkout.Session;
import com.stripe.net.Webhook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

import java.util.Optional;

@RestController
public class StripeWebhookController {

    @Autowired
    private DonacionRepository donacionRepository;

    @Autowired
    private cl.duoc.api.service.SesionPagoService sesionPagoService;

    private final ObjectMapper mapper = new ObjectMapper();

    @PostMapping("/webhook/stripe")
    public ResponseEntity<String> handleWebhook(@RequestHeader(value = "Stripe-Signature", required = false) String sigHeader,
                                                @RequestBody String payload) {
        String webhookSecret = System.getenv("STRIPE_WEBHOOK_SECRET");
        // If no webhook secret is set, try to parse raw event (best-effort) but reject signature checks
        Event event = null;
        try {
            if (webhookSecret != null && !webhookSecret.isEmpty()) {
                event = Webhook.constructEvent(payload, sigHeader, webhookSecret);
            } else {
                // Parse without signature verification
                event = Event.GSON.fromJson(payload, Event.class);
            }
        } catch (SignatureVerificationException sve) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Signature verification failed: " + sve.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Invalid payload: " + e.getMessage());
        }

        if (event == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Event is null");
        }

        String type = event.getType();
        try {
            if ("checkout.session.completed".equals(type)) {
                Session session = Event.GSON.fromJson(mapper.writeValueAsString(event.getData().getObject()), Session.class);
                String sessionId = session.getId();
                Optional<Donacion> od = donacionRepository.findByStripeSessionId(sessionId);
                if (od.isPresent()) {
                    Donacion d = od.get();
                    d.setStatus("PAID");
                    d.setStripePaymentIntent(session.getPaymentIntent());
                    donacionRepository.save(d);
                    // update sesion_pago as well
                    sesionPagoService.updateSesionPago(sessionId, d.getStatus(), session.getMetadata());
                } else {
                    // Try metadata
                    String donacionIdStr = session.getMetadata() == null ? null : session.getMetadata().get("donacion_id");
                    if (donacionIdStr != null) {
                        try {
                            Integer did = Integer.valueOf(donacionIdStr);
                            Optional<Donacion> od2 = donacionRepository.findById(did);
                            if (od2.isPresent()) {
                                Donacion d2 = od2.get();
                                d2.setStatus("PAID");
                                d2.setStripePaymentIntent(session.getPaymentIntent());
                                d2.setStripeSessionId(sessionId);
                                donacionRepository.save(d2);
                                    // update sesion_pago as well
                                    sesionPagoService.updateSesionPago(sessionId, d2.getStatus(), session.getMetadata());
                            }
                        } catch (NumberFormatException nfe) {
                            // ignore
                        }
                    }
                }
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Webhook processing error: " + e.getMessage());
        }

        return ResponseEntity.ok("received");
    }
}
