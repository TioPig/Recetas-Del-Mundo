package cl.duoc.api.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.mindrot.jbcrypt.BCrypt;

@Configuration
public class PasswordConfig {

    /**
     * Configuración del encoder de passwords usando BCrypt independiente
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new PasswordEncoder();
    }

    /**
     * Implementación simple de BCrypt sin Spring Security
     */
    public static class PasswordEncoder {
        
        public String encode(String rawPassword) {
            return BCrypt.hashpw(rawPassword, BCrypt.gensalt());
        }
        
        public boolean matches(String rawPassword, String encodedPassword) {
            return BCrypt.checkpw(rawPassword, encodedPassword);
        }
    }
}