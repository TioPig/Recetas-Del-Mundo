package cl.duoc.api.controller;

import cl.duoc.api.model.entities.Donacion;
import cl.duoc.api.model.repositories.DonacionRepository;
import cl.duoc.api.util.JwtUtil;
import io.jsonwebtoken.Claims;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
public class DonacionController {

    @Autowired
    private DonacionRepository donacionRepository;

    @Autowired
    private JwtUtil jwtUtil;

    @PostMapping("/admin/donaciones")
    public ResponseEntity<?> createAdminDonacion(@RequestHeader HttpHeaders headers, @RequestBody Donacion payload) {
        return createTestDonacion(headers, payload);
    }

    @PostMapping("/recetas/donaciones")
    public ResponseEntity<?> createRecetaDonacion(@RequestHeader HttpHeaders headers, @RequestBody Donacion payload) {
        return createTestDonacion(headers, payload);
    }

    // Reutilizado internamente: crea la donacion con status TEST
    private ResponseEntity<?> createTestDonacion(HttpHeaders headers, Donacion payload) {
        try {
            // Extraer token de Authorization header
            String auth = headers.getFirst(HttpHeaders.AUTHORIZATION);
            if (auth == null || !auth.startsWith("Bearer ")) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Authorization header missing or invalid");
            }
            String token = auth.substring(7);

            Integer tokenUserId;
            try {
                tokenUserId = jwtUtil.extractUserId(token);
            } catch (Exception e) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid token");
            }

            // Si el cliente envía idUsr, validar que coincida con el token; si no lo envía, inferirlo
            if (payload.getIdUsr() != null) {
                if (!payload.getIdUsr().equals(tokenUserId)) {
                    return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("idUsr does not match authenticated user");
                }
            } else {
                payload.setIdUsr(tokenUserId);
            }

            Donacion d = new Donacion();
            d.setIdUsr(payload.getIdUsr());
            d.setIdReceta(payload.getIdReceta());
            // Normalize amount: the DB now stores units (e.g. 5.00).
            // For backward compatibility, if the client sent an integer amount
            // that looks like cents (e.g. 500) we convert to units dividing by 100.
            java.math.BigDecimal incomingAmount = payload.getAmount();
            if (incomingAmount != null) {
                // If no fractional part and value >= 100, assume it's cents and convert.
                if (incomingAmount.scale() == 0 && incomingAmount.compareTo(new java.math.BigDecimal(100)) >= 0) {
                    incomingAmount = incomingAmount.divide(new java.math.BigDecimal(100));
                }
            }
            d.setAmount(incomingAmount);
            d.setCurrency(payload.getCurrency() == null ? "CLP" : payload.getCurrency());
            d.setStatus("TEST");
            // Forzar fecha de creación en servidor (aunque la entidad tiene @PrePersist, hacemos explícito)
            d.setFechaCreacion(java.time.LocalDateTime.now());
            Donacion saved = donacionRepository.save(d);
            return new ResponseEntity<>(saved, HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
