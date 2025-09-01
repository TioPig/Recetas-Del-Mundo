package cl.duoc.api.service;

import cl.duoc.api.model.entities.Pago;
import cl.duoc.api.model.repositories.PagoRepository;
import cl.duoc.api.service.dto.FlowButtonRequest;
import cl.duoc.api.service.dto.FlowButtonResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;


@Service
public class PaymentService {

    @Value("${flow.api.url:}")
    private String flowApiUrl;

    @Value("${flow.public.key:}")
    private String flowPublicKey;

    @Value("${flow.private.key:}")
    private String flowPrivateKey;

    private final RestTemplate rest = new RestTemplate();

    private final PagoRepository pagoRepository;

    public PaymentService(PagoRepository pagoRepository) {
        this.pagoRepository = pagoRepository;
    }

    public FlowButtonResponse createFlowButton(FlowButtonRequest req) {
        FlowButtonResponse r = new FlowButtonResponse();

        // Simulated response if no Flow configured
        if (flowApiUrl == null || flowApiUrl.isBlank()) {
            r.setCheckoutUrl("https://sandbox.flow.cl/checkout/simulated?order=" + req.getOrderId());
            r.setStatus("simulated");
            r.setToken("simulated-token-" + req.getOrderId());
        } else {
            r.setCheckoutUrl(flowApiUrl + "/checkout/create?order=" + req.getOrderId());
            r.setStatus("created");
            r.setToken("token-from-flow-" + req.getOrderId());
        }

    // Persist payment record in DB
    Pago p = new Pago();
    p.setOrder_id(req.getOrderId());
    p.setAmount(req.getAmount());
    p.setStatus(r.getStatus());
    p.setFlow_token(r.getToken());
    p.setFecha_creacion(java.time.LocalDateTime.now());
    pagoRepository.save(p);

        return r;
    }

    public void handleWebhook(String payload, String signature) {
        // TODO: validate signature using flowPrivateKey and process notification
        System.out.println("Flow webhook received. signature=" + signature + " payload=" + payload);

        // For demo: create or update a Pago based on payload. Here we simply create a record.
    Pago p = new Pago();
    p.setOrder_id("webhook-unknown");
    p.setAmount(0);
    p.setStatus("webhook_received");
    p.setFlow_token(signature != null ? signature : "");
    p.setFecha_creacion(java.time.LocalDateTime.now());
    pagoRepository.save(p);
    }
}
