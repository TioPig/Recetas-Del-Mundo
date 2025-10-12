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
        
        // Permitir orígenes específicos
        String env = System.getenv().getOrDefault("APP_CORS_ALLOWED_ORIGINS", "http://localhost:5173");
        List<String> origins = Arrays.stream(env.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .toList();
        config.setAllowedOrigins(origins);
        
        // Permitir todos los métodos HTTP
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));
        
        // Permitir todos los headers
        config.setAllowedHeaders(List.of("*"));
        
        // Exponer headers específicos
        config.setExposedHeaders(List.of("Authorization", "Content-Type"));
        
        // Permitir credenciales
        config.setAllowCredentials(true);
        
        // Configurar tiempo de caché para OPTIONS
        config.setMaxAge(3600L);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        
        return new CorsFilter(source);
    }
}