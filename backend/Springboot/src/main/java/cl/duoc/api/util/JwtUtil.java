package cl.duoc.api.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Component
public class JwtUtil {

    @Value("${jwt.secret:}")
    private String secretProp;

    @Value("${jwt.expirationMs:86400000}")
    private long jwtExpirationMs;

    private Key getSigningKey() {
        String secret = secretProp;
        if (secret == null || secret.isEmpty()) {
            secret = System.getenv("JWT_SECRET");
        }
        if (secret == null || secret.isEmpty()) {
            throw new IllegalStateException("JWT secret not configured");
        }
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    public String generateToken(Integer userId, String email, String nombre, String apellido, Integer perfilId, String perfilNombre, Short estado) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("id_usr", userId);
        claims.put("email", email);
        claims.put("nombre", nombre);
        claims.put("apellido", apellido);
        claims.put("id_perfil", perfilId);
        if (perfilNombre != null) {
            claims.put("rol", perfilNombre);
        }
        claims.put("estado", estado);

        return Jwts.builder()
                .setClaims(claims)
                .setSubject(email)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + jwtExpirationMs))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    public Claims extractAllClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    public String extractEmail(String token) {
        return extractAllClaims(token).getSubject();
    }

    public Integer extractUserId(String token) {
        return (Integer) extractAllClaims(token).get("id_usr");
    }

    public Boolean isTokenExpired(String token) {
        return extractAllClaims(token).getExpiration().before(new Date());
    }

    public Boolean validateToken(String token, String email) {
        final String tokenEmail = extractEmail(token);
        return (tokenEmail.equals(email) && !isTokenExpired(token));
    }
}