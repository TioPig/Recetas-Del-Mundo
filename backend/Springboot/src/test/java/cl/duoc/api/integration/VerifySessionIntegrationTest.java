package cl.duoc.api.integration;

import com.stripe.model.checkout.Session;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mockito;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

@Testcontainers
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class VerifySessionIntegrationTest {

    @Container
    public static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15")
            .withDatabaseName("api_recetas_postgres")
            .withUsername("postgres")
            .withPassword("postgres");

    @DynamicPropertySource
    static void properties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @Autowired
    private TestRestTemplate rest;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @MockBean
    private cl.duoc.api.service.StripeSessionService stripeSessionService;

    @Test
    public void verifySession_updatesSesionPagoAndDonacion() throws Exception {
        // Insert a donacion and a sesion_pago row (PENDING)
        jdbcTemplate.update("INSERT INTO donacion (id_usr, amount, currency, status) VALUES (?,?,?,?)", 1, 5.00, "USD", "PENDING");
        // Ensure sesion_pago table exists (this table is managed outside JPA in the real app)
        jdbcTemplate.execute("CREATE TABLE IF NOT EXISTS sesion_pago (session_id varchar(255) PRIMARY KEY, provider varchar(50), status varchar(50), id_donacion integer, metadata jsonb)");

        // Create a minimal 'perfil' and 'usuario' so /auth/login works against the in-memory Testcontainers DB
        jdbcTemplate.execute("CREATE TABLE IF NOT EXISTS perfil (id_perfil serial PRIMARY KEY, nombre varchar(50) NOT NULL)");
        jdbcTemplate.update("INSERT INTO perfil (nombre) VALUES (?)", "ADMIN");
        Integer perfilId = jdbcTemplate.queryForObject("SELECT id_perfil FROM perfil ORDER BY id_perfil DESC LIMIT 1", Integer.class);

        jdbcTemplate.execute("CREATE TABLE IF NOT EXISTS usuario (id_usr serial PRIMARY KEY, apellido varchar(100) not null, comentario varchar(255), email varchar(150) not null, estado smallint not null, fecha_creacion timestamp(6) not null, nombre varchar(100) not null, password varchar(255) not null, id_perfil integer not null)");
        // Insert admin user with plain password 'cast1301' — UsuarioService.login acepta comparación en texto plano y re-hasheará
        jdbcTemplate.update("INSERT INTO usuario (email, password, nombre, apellido, estado, fecha_creacion, id_perfil) VALUES (?,?,?,?,?,now(),?)",
            "admin@recetas.com", "cast1301", "Admin", "Recetas", 1, perfilId);
        Integer donId = jdbcTemplate.queryForObject("SELECT id_donacion FROM donacion ORDER BY id_donacion DESC LIMIT 1", Integer.class);
        String sessionId = "cs_test_integ_verify";
        String meta = "{\"donacion_id\": \"" + donId + "\"}";
        jdbcTemplate.update("INSERT INTO sesion_pago (session_id, provider, status, id_donacion, metadata) VALUES (?,'stripe','PENDING',?,?::jsonb)", sessionId, donId, meta);

        // Mock Stripe session retrieval via injectable StripeSessionService
        Session mockSession = Mockito.mock(Session.class);
        Mockito.when(mockSession.getPaymentStatus()).thenReturn("paid");
        Mockito.when(mockSession.getPaymentIntent()).thenReturn("pi_test_123");
        Mockito.when(mockSession.getMetadata()).thenReturn(Map.of("donacion_id", String.valueOf(donId)));
        Mockito.when(mockSession.getId()).thenReturn(sessionId);
        Mockito.when(stripeSessionService.retrieve(sessionId)).thenReturn(mockSession);

            // Prepare auth header (bypass security by using valid existing admin token via login)
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            // login to get token
            ResponseEntity<Map> loginResp = rest.postForEntity("/auth/login", Map.of("email", "admin@recetas.com", "password", "cast1301"), Map.class);
            assertThat(loginResp.getStatusCode().is2xxSuccessful()).isTrue();
            String token = (String) loginResp.getBody().get("token");
            headers.set("Authorization", "Bearer " + token);

            // Call verify-session
            HttpEntity<String> req = new HttpEntity<>("{\"sessionId\": \"" + sessionId + "\"}", headers);
            ResponseEntity<Map> verifyResp = rest.postForEntity("/donaciones/verify-session", req, Map.class);
            assertThat(verifyResp.getStatusCode().is2xxSuccessful()).isTrue();
            Map body = verifyResp.getBody();
            assertThat(body).containsKey("status");
            assertThat(body.get("status")).isEqualTo("PAID");

            // Check DB: sesion_pago status should be PAID
            String status = jdbcTemplate.queryForObject("SELECT status FROM sesion_pago WHERE session_id = ?", new Object[]{sessionId}, String.class);
            assertThat(status).isEqualTo("PAID");

            String donStatus = jdbcTemplate.queryForObject("SELECT status FROM donacion WHERE id_donacion = ?", new Object[]{donId}, String.class);
            assertThat(donStatus).isEqualTo("PAID");
        
    }
}
