package cl.duoc.api.config;

import io.swagger.v3.oas.models.ExternalDocumentation;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

    @Value("${spring.profiles.active:dev}")
    private String activeProfile;

    @Bean
    public OpenAPI customOpenAPI() {
        final String securitySchemeName = "bearerAuth";

        OpenAPI openAPI = new OpenAPI()
                .components(new Components().addSecuritySchemes(securitySchemeName,
                        new SecurityScheme()
                                .name(securitySchemeName)
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")
                                .description("JWT token de autenticación. Incluye 'Bearer ' antes del token.")
                ))
                .addSecurityItem(new SecurityRequirement().addList(securitySchemeName))
                .info(new Info()
                        .title("MS-Recetas API - Recetas del Mundo")
                        .version("v1.0.0")
                        .description("API REST para el sistema de gestión de recetas culinarias. " +
                                "Incluye funcionalidades de usuarios, recetas, categorías, países, " +
                                "sistema de likes/comentarios/valoraciones y pagos.\n\n" +
                                "**Perfil activo:** " + activeProfile + "\n\n" +
                                "**Características:**\n" +
                                "- Autenticación JWT\n" +
                                "- Paginación en listas\n" +
                                "- Documentación OpenAPI 3.0\n" +
                                "- Base de datos PostgreSQL + MongoDB")
                        .contact(new Contact()
                                .name("Equipo de Desarrollo")
                                .email("dev@recetasdelmundo.cl")
                                .url("https://github.com/recetas-del-mundo"))
                        .license(new License()
                                .name("MIT License")
                                .url("https://opensource.org/licenses/MIT"))
                )
                .externalDocs(new ExternalDocumentation()
                        .description("Repositorio del Proyecto")
                        .url("https://github.com/recetas-del-mundo/api-recetas"));

        // Configurar servidores según el perfil
        if ("dev".equals(activeProfile)) {
            openAPI.servers(List.of(
                    new Server().url("http://localhost:8081").description("Servidor de Desarrollo"),
                    new Server().url("http://localhost:8080").description("Servidor Local Alternativo")
            ));
        } else if ("prod".equals(activeProfile)) {
            openAPI.servers(List.of(
                    new Server().url("https://api.recetasdelmundo.cl").description("Servidor de Producción")
            ));
        }

        return openAPI;
    }
}
