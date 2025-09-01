package cl.duoc.api.controller;

import cl.duoc.api.service.PaymentService;
import cl.duoc.api.service.dto.FlowButtonRequest;
import cl.duoc.api.service.dto.FlowButtonResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/flow")
public class PaymentController {

    @Autowired
    private PaymentService paymentService;

    @PostMapping("/button")
    public ResponseEntity<FlowButtonResponse> createFlowButton(@RequestBody FlowButtonRequest req) {
        FlowButtonResponse resp = paymentService.createFlowButton(req);
        return ResponseEntity.ok(resp);
    }

    @PostMapping("/webhook")
    public ResponseEntity<String> webhook(@RequestBody String payload, @RequestHeader(value = "X-Flow-Signature", required = false) String sig) {
        // For now just log and acknowledge; PaymentService can validate signature later
        paymentService.handleWebhook(payload, sig);
        return ResponseEntity.ok("ok");
    }
}
