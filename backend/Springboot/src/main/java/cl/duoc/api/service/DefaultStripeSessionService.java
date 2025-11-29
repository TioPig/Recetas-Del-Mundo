package cl.duoc.api.service;

import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;
import org.springframework.stereotype.Service;

@Service
public class DefaultStripeSessionService implements StripeSessionService {
    @Override
    public Session retrieve(String sessionId) throws StripeException {
        return Session.retrieve(sessionId);
    }
}
