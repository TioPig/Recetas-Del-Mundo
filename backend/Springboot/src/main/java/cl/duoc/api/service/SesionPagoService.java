package cl.duoc.api.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
public class SesionPagoService {

    private static final Logger logger = LoggerFactory.getLogger(SesionPagoService.class);

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private final ObjectMapper mapper = new ObjectMapper();

    /**
     * Update sesion_pago status and metadata for a given session_id.
     * Returns true if update executed without exception.
     */
    public boolean updateSesionPago(String sessionId, String status, Map<String, ?> metadata) {
        try {
            String metadataJson = null;
            if (metadata != null && !metadata.isEmpty()) {
                metadataJson = mapper.writeValueAsString(metadata);
            }
            String sql = "UPDATE sesion_pago SET status = ?, metadata = ?::jsonb WHERE session_id = ?";
            jdbcTemplate.update(sql, status, metadataJson, sessionId);
            return true;
        } catch (Exception e) {
            logger.warn("Could not update sesion_pago for sessionId {}: {}", sessionId, e.getMessage());
            logger.debug("Exception updating sesion_pago", e);
            return false;
        }
    }
}
