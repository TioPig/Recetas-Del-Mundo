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

import java.math.BigDecimal;
import org.springframework.http.HttpHeaders;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class DonacionAmountNormalizationTest {

    @InjectMocks
    private DonacionController controller;

    @Mock
    private DonacionRepository donacionRepository;

    @Mock
    private JwtUtil jwtUtil;

    @Test
    public void whenAmountIsCentsInteger_thenSavedAsUnits() throws Exception {
        when(jwtUtil.extractUserId(any())).thenReturn(1);

        when(donacionRepository.save(any(Donacion.class))).thenAnswer(inv -> {
            Donacion d = inv.getArgument(0);
            d.setIdDonacion(123);
            return d;
        });

        Donacion payload = new Donacion();
        payload.setAmount(new BigDecimal("500"));

        HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.AUTHORIZATION, "Bearer token");

        controller.createRecetaDonacion(headers, payload);

        ArgumentCaptor<Donacion> cap = ArgumentCaptor.forClass(Donacion.class);
        verify(donacionRepository, atLeastOnce()).save(cap.capture());
        Donacion saved = cap.getValue();
        // compare numerically (scale may differ)
        assertEquals(0, saved.getAmount().compareTo(new BigDecimal("5.00")));
    }

    @Test
    public void whenAmountIsUnits_thenSavedUnchanged() throws Exception {
        when(jwtUtil.extractUserId(any())).thenReturn(1);

        when(donacionRepository.save(any(Donacion.class))).thenAnswer(inv -> {
            Donacion d = inv.getArgument(0);
            d.setIdDonacion(124);
            return d;
        });

        Donacion payload = new Donacion();
        payload.setAmount(new BigDecimal("5.00"));

        HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.AUTHORIZATION, "Bearer token");

        controller.createRecetaDonacion(headers, payload);

        ArgumentCaptor<Donacion> cap = ArgumentCaptor.forClass(Donacion.class);
        verify(donacionRepository, atLeastOnce()).save(cap.capture());
        Donacion saved = cap.getValue();
        // compare numerically (scale may differ)
        assertEquals(0, saved.getAmount().compareTo(new BigDecimal("5.00")));
    }
}
