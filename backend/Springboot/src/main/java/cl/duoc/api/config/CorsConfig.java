package cl.duoc.api.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.Arrays;
import java.util.List;

@Configuration
public class CorsConfig {

    @Bean
    public CorsFilter corsFilter() {
        CorsConfiguration config = new CorsConfiguration();
        
        // Permitir orígenes específicos desde variables de entorno
        String env = System.getenv("APP_CORS_ALLOWED_ORIGINS");
        if (env == null || env.trim().isEmpty()) {
            throw new IllegalStateException("APP_CORS_ALLOWED_ORIGINS debe estar configurada en las variables de entorno");
        }
        List<String> origins = Arrays.stream(env.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .toList();
        
        org.slf4j.LoggerFactory.getLogger(CorsConfig.class).info("🌐 CORS - Orígenes permitidos: {}", origins);
        config.setAllowedOrigins(origins);
        
        // Permitir todos los métodos HTTP
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));
        
        // Permitir todos los headers (incluyendo Authorization)
        config.setAllowedHeaders(List.of("*"));
        
        // Exponer headers específicos para que el frontend pueda leerlos
        config.setExposedHeaders(List.of("Authorization", "Content-Type", "X-Total-Count"));
        
        // Permitir credenciales (importante para JWT tokens)
        config.setAllowCredentials(true);
        
        // Configurar tiempo de caché para preflight OPTIONS requests
        config.setMaxAge(3600L);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        
        org.slf4j.LoggerFactory.getLogger(CorsConfig.class).info("✅ CORS configurado para endpoints: /**");
        
        return new CorsFilter(source);
    }
}