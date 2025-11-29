package cl.duoc.api.service;

import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.InjectMocks;
import org.mockito.junit.jupiter.MockitoExtension;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.jdbc.core.JdbcTemplate;

import java.util.Map;

import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class SesionPagoServiceTest {

    @Mock
    private JdbcTemplate jdbcTemplate;

    @InjectMocks
    private SesionPagoService service;

    @Test
    public void updateSesionPago_callsJdbcTemplateUpdate() throws Exception {
        String sessionId = "cs_test_123";
        String status = "PAID";
        Map<String, Object> meta = Map.of("donacion_id", "42");

        when(jdbcTemplate.update(anyString(), any(), any(), any())).thenReturn(1);

        boolean ok = service.updateSesionPago(sessionId, status, meta);

        assert(ok);
        verify(jdbcTemplate, atLeastOnce()).update(anyString(), eq(status), any(), eq(sessionId));
    }
}
