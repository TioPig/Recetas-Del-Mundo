package cl.duoc.api.controller;

import cl.duoc.api.model.entities.Donacion;
import cl.duoc.api.model.repositories.DonacionRepository;
import cl.duoc.api.util.JwtUtil;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpHeaders;
import org.springframework.jdbc.core.JdbcTemplate;

import java.math.BigDecimal;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class StripeDonacionControllerTest {

    @InjectMocks
    private StripeDonacionController controller;

    @Mock
    private DonacionRepository donacionRepository;

    @Mock
    private JwtUtil jwtUtil;

    @Mock
    private JdbcTemplate jdbcTemplate;

    @Test
    public void createSession_withCentsInteger_createsDonacionWithUnitsAndInsertsLocalSession() throws Exception {
        when(jwtUtil.extractUserId(any())).thenReturn(1);

        when(donacionRepository.save(any(Donacion.class))).thenAnswer(inv -> {
            Donacion d = inv.getArgument(0);
            d.setIdDonacion(200);
            return d;
        });

        when(jdbcTemplate.update(any(String.class), any(Object[].class))).thenReturn(1);

        Map<String, Object> body = Map.of("amount", 1235, "currency", "usd");

        HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.AUTHORIZATION, "Bearer token");

        var resp = controller.createSession(headers, body);
        // Expect created (201)
        assertEquals(201, resp.getStatusCodeValue());

        ArgumentCaptor<Donacion> cap = ArgumentCaptor.forClass(Donacion.class);
        verify(donacionRepository, atLeastOnce()).save(cap.capture());
        Donacion saved = cap.getValue();
        // 1235 cents -> 12.35 units; compare numerically to avoid scale mismatch
        assertEquals(0, saved.getAmount().compareTo(new BigDecimal("12.35")));

        verify(jdbcTemplate, atLeastOnce()).update(any(String.class), any(Object[].class));
    }
}
