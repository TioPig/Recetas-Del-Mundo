package cl.duoc.api.service;

import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;

public interface StripeSessionService {
    Session retrieve(String sessionId) throws StripeException;
}
