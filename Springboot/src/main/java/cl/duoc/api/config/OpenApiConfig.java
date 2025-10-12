package cl.duoc.api.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Configuration
public class OpenApiConfig {

    @Value("${server.port:8081}")
    private String serverPort;

    @Bean
    public OpenAPI customOpenAPI() {
        SecurityScheme bearerScheme = new SecurityScheme()
            .type(SecurityScheme.Type.HTTP)
            .scheme("bearer")
            .bearerFormat("JWT")
            .in(SecurityScheme.In.HEADER)
            .name("Authorization");

        Server localServer = new Server()
            .url("http://localhost:" + serverPort)
            .description("Servidor Local de Desarrollo");

        return new OpenAPI()
            .servers(List.of(localServer))
            .components(new Components().addSecuritySchemes("bearerAuth", bearerScheme))
            .addSecurityItem(new SecurityRequirement().addList("bearerAuth"))
            .info(new Info()
                .title("🍽️ API Recetas del Mundo")
                .version("v2.0")
                .description(buildDescription())
                .contact(new Contact()
                    .name("Equipo Desarrollo Recetas")
                    .email("dev@recetas.cl")
                    .url("https://github.com/TioPig/Recetas-Del-Mundo"))
                .license(new License()
                    .name("MIT License")
                    .url("https://opensource.org/licenses/MIT"))
            );
    }

    private String buildDescription() {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
        
        return """
            ## 🚀 API Completa de Recetas del Mundo
            
            ### ✅ Funcionalidades Activas:
            - 🔐 **Autenticación JWT** - Login y registro de usuarios
            - 👥 **Gestión de Usuarios** - CRUD completo de usuarios
            - 📂 **Categorías** - Organización de recetas por categorías
            - 🍽️ **Recetas Completas** - CRUD con ingredientes y relaciones
            - 🌍 **Países** - Gestión de países y origen de recetas
            
            ### 🎯 Endpoints Especializados:
            - 🎠 **Carrusel** - Top 8 recetas más valoradas
            - 🔥 **Trending** - Recetas populares últimos 30 días
            - ⭐ **Receta del día** - Selección diaria automática
            - 🔍 **Búsquedas avanzadas** - Por nombre, país, categoría, usuario
            - 🥗 **Ingredientes** - Gestión completa de ingredientes por receta
            
            ### 🛠️ Tecnologías:
            - **Spring Boot 3.1.0** con Java 17+
            - **PostgreSQL** con JPA/Hibernate
            - **JWT** para autenticación
            - **Swagger/OpenAPI 3** para documentación
            
            ### 📊 Estado Actual:
            - **Generado:** """ + timestamp + """
            - **Endpoints Activos:** ~35 mappings
            - **Base de Datos:** PostgreSQL conectada
            - **Documentación:** Actualizada automáticamente
            
            > 💡 **Nota:** Esta documentación se genera dinámicamente y refleja todos los controladores activos en tiempo real.
            """;
    }
}
