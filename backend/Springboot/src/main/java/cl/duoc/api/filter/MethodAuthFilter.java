package cl.duoc.api.filter;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Component;
import org.springframework.util.AntPathMatcher;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.List;

@Component
public class MethodAuthFilter extends OncePerRequestFilter {

    @Value("${jwt.secret:}")
    private String jwtSecret;

    private final AntPathMatcher matcher = new AntPathMatcher();

    // Rutas públicas (siempre permitidas)
    private static final List<String> PUBLIC_PATHS = List.of(
            "/actuator/health", "/actuator/info",
            "/swagger-ui/**", "/v3/api-docs/**",
            "/auth/**", // login/register públicos
            "/webhook/stripe", // webhook de Stripe debe ser público (firma en payload)
            "/usuarios/id/**" // obtener nombre de usuario (público)
    );

    // Rutas GET que requieren rol (excepción a GET público)
    private static final List<String> GET_ROLE_PROTECTED = List.of(
        "/usuarios",
        "/usuarios/**",
    "/admin/perfil",
    "/admin/perfil/**"
    );

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String method = request.getMethod();
        String path = request.getRequestURI();

        // Permitir preflight siempre
        if (HttpMethod.OPTIONS.matches(method) || isPublic(path)) {
            filterChain.doFilter(request, response);
            return;
        }

        // Para GET: solo exigir token si el path está protegido por rol
        if (HttpMethod.GET.matches(method)) {
            if (requiresRoleForGet(path)) {
                if (!authorizeWithRole(request, response)) return; // maneja 401 internamente
                // Autorizado por rol -> continuar y salir
                filterChain.doFilter(request, response);
                return;
            } else {
                filterChain.doFilter(request, response);
                return;
            }
        }

        // Para POST/PUT/DELETE en rutas no públicas: exigir Authorization: Bearer
        String authHeader = request.getHeader("Authorization");
        String token = null;
        if (StringUtils.hasText(authHeader) && authHeader.startsWith("Bearer ")) {
            token = authHeader.substring(7);
        } else {
            unauthorized(response, "Missing Bearer token");
            return;
        }
        if (!StringUtils.hasText(jwtSecret)) {
            unauthorized(response, "Server JWT secret not configured");
            return;
        }
        try {
            Key key = Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));
            Jws<Claims> jws = Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token);
            // Validación exitosa (firma/exp) => continuar
            // Si se requiere, aquí podrías extraer subject/roles para logging
            filterChain.doFilter(request, response);
        } catch (Exception ex) {
            unauthorized(response, "Invalid or expired token");
        }
    }

    private boolean requiresRoleForGet(String path) {
        for (String p : GET_ROLE_PROTECTED) {
            if (matcher.match(p, path)) return true;
        }
        return false;
    }

    private boolean authorizeWithRole(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // Require Authorization header for role-protected GETs
        String authHeader = request.getHeader("Authorization");
        if (!StringUtils.hasText(authHeader) || !authHeader.startsWith("Bearer ")) {
            unauthorized(response, "Missing Bearer token");
            return false;
        }
        String token = authHeader.substring(7);
        if (!StringUtils.hasText(jwtSecret)) {
            unauthorized(response, "Server JWT secret not configured");
            return false;
        }
        try {
            Key key = Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));
            Jws<Claims> jws = Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token);
            Claims claims = jws.getBody();
            String rol = null;
            Object r = claims.get("rol");
            if (r != null) rol = String.valueOf(r);
            if (rol == null && claims.get("id_perfil") != null) {
                // Como fallback, permitir por id_perfil si es conocido (ej: 2=ADMIN, 3=SUP), ajustar según datos reales
                try {
                    int idPerfil = Integer.parseInt(String.valueOf(claims.get("id_perfil")));
                    if (idPerfil == 2) rol = "ADMIN";
                    else if (idPerfil == 3) rol = "SUP";
                } catch (Exception ignore) {}
            }
            if (rol != null) rol = rol.toUpperCase();
            if (!"ADMIN".equals(rol) && !"SUP".equals(rol)) {
                unauthorized(response, "Insufficient role");
                return false;
            }
            return true;
        } catch (Exception ex) {
            unauthorized(response, "Invalid or expired token");
            return false;
        }
    }

    private boolean isPublic(String path) {
        for (String p : PUBLIC_PATHS) {
            if (matcher.match(p, path)) return true;
        }
        return false;
    }

    private void unauthorized(HttpServletResponse response, String message) throws IOException {
        // ✅ AGREGAR HEADERS CORS PARA RESPUESTAS DE ERROR - Solo variables de entorno
        String corsOrigins = System.getenv("APP_CORS_ALLOWED_ORIGINS");
        // Por simplicidad, usar * si hay múltiples orígenes (el CorsFilter real maneja esto mejor)
        String allowOrigin = "*"; // Usar * para mantener compatibilidad general
        if (corsOrigins != null && !corsOrigins.trim().isEmpty() && !corsOrigins.contains(",")) {
            allowOrigin = corsOrigins.trim();
        }
        
        response.setHeader("Access-Control-Allow-Origin", allowOrigin);
        response.setHeader("Access-Control-Allow-Credentials", "true");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, PATCH, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Authorization, Content-Type, X-Requested-With");
        response.setHeader("Vary", "Origin, Access-Control-Request-Method, Access-Control-Request-Headers");
        
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"success\":false,\"error\":\"" + escapeJson(message) + "\"}");
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
