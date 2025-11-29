package cl.duoc.api.config;

import com.fasterxml.jackson.databind.JsonMappingException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.util.ContentCachingRequestWrapper;

import jakarta.servlet.http.HttpServletRequest;
import java.io.UnsupportedEncodingException;
import java.util.HashMap;
import java.util.Map;

@ControllerAdvice
public class RestExceptionHandler {

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<Map<String, Object>> handleHttpMessageNotReadable(HttpMessageNotReadableException ex, HttpServletRequest request) {
        Map<String, Object> body = new HashMap<>();
        body.put("exito", false);
        body.put("mensaje", "JSON inválido o incompatible: " + ex.getMessage());

        // Try to extract request body if wrapped
        if (request instanceof ContentCachingRequestWrapper) {
            ContentCachingRequestWrapper wrapper = (ContentCachingRequestWrapper) request;
            try {
                String payload = new String(wrapper.getContentAsByteArray(), wrapper.getCharacterEncoding());
                body.put("rawBody", payload);
            } catch (UnsupportedEncodingException e) {
                // ignore
            }
        }

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(body);
    }
}
