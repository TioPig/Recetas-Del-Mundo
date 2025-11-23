package cl.duoc.api.config;

import org.springframework.context.annotation.Configuration;

/**
 * Configuración sin Spring Security.
 * Dejamos esta clase como marcador para mantener compatibilidad
 * con cualquier import o escaneo de paquetes que espere una SecurityConfig,
 * pero no define ningún bean ni depende de spring-security.
 */
@Configuration
public class SecurityConfig {
    // Intencionalmente vacío
}