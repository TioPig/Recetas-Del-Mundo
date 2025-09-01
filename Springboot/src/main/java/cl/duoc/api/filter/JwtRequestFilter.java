package cl.duoc.api.filter;

import cl.duoc.api.util.JwtUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@Component
public class JwtRequestFilter extends OncePerRequestFilter {

    @Autowired
    private JwtUtil jwtUtil;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        // Only enforce JWT validation for write methods (POST/PUT/PATCH/DELETE) and engagement endpoints.
        String path = request.getRequestURI();
        String method = request.getMethod();
    boolean isWrite = "POST".equalsIgnoreCase(method) || "PUT".equalsIgnoreCase(method)
        || "PATCH".equalsIgnoreCase(method) || "DELETE".equalsIgnoreCase(method);
    // allow unauthenticated access to login and user creation endpoints
    boolean isPublicAuthPath = path != null && (path.equals("/usuarios/login") || path.equals("/usuarios"));
    // enforce JWT for write operations except the public auth paths, and always for engagement endpoints
    boolean enforce = (isWrite && !isPublicAuthPath) || (path != null && path.startsWith("/engagement"));
        if (!enforce) {
            // Public endpoint or read operation, skip validation
            filterChain.doFilter(request, response);
            return;
        }

        String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            response.setStatus(HttpStatus.UNAUTHORIZED.value());
            return;
        }
        String token = authHeader.substring(7);
        org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(JwtRequestFilter.class);
        try {
            if (!jwtUtil.validateToken(token)) {
                log.warn("Token inválido o expirado");
                response.setStatus(HttpStatus.UNAUTHORIZED.value());
                return;
            }
            // Token valid -> populate SecurityContext with Authentication containing username and idUsr
            String username = jwtUtil.extractUsername(token);
            Integer idUsr = jwtUtil.extractIdUsr(token);
            org.springframework.security.authentication.UsernamePasswordAuthenticationToken auth =
                    new org.springframework.security.authentication.UsernamePasswordAuthenticationToken(username, null, java.util.List.of());
            // store idUsr in details for downstream checks
            auth.setDetails(idUsr);
            org.springframework.security.core.context.SecurityContextHolder.getContext().setAuthentication(auth);
        } catch (Exception e) {
            log.error("Error validando token: {}", e.getMessage());
            response.setStatus(HttpStatus.UNAUTHORIZED.value());
            return;
        }
        filterChain.doFilter(request, response);
    }
}
