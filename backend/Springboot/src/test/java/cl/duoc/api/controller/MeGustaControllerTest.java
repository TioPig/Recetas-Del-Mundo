package cl.duoc.api.controller;

import cl.duoc.api.model.entities.MeGusta;
import cl.duoc.api.model.entities.Receta;
import cl.duoc.api.model.entities.Usuario;
import cl.duoc.api.service.MeGustaService;
import cl.duoc.api.util.JwtUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

public class MeGustaControllerTest {

    private MockMvc mockMvc;
    private MeGustaService meGustaService;
    private JwtUtil jwtUtil;
    private RecetaController controller;

    @BeforeEach
    public void setup() {
        meGustaService = mock(MeGustaService.class);
        jwtUtil = mock(JwtUtil.class);
        controller = new RecetaController();
        // inject mocks
        org.springframework.test.util.ReflectionTestUtils.setField(controller, "meGustaService", meGustaService);
        org.springframework.test.util.ReflectionTestUtils.setField(controller, "jwtUtil", jwtUtil);
        // other dependencies the controller expects can be left null for these tests
        mockMvc = MockMvcBuilders.standaloneSetup(controller).build();
    }

    @Test
    public void darMeGusta_withToken_shouldCreateMeGusta() throws Exception {
        when(jwtUtil.extractUserId("token123")).thenReturn(42);

        MeGusta mg = new MeGusta();
        mg.setIdMeGusta(1);
        mg.setUsuario(new Usuario(42));
        mg.setReceta(new Receta(100));

        when(meGustaService.save(any(MeGusta.class))).thenReturn(mg);

        mockMvc.perform(post("/recetas/megusta")
                .header("Authorization", "Bearer token123")
                .param("idReceta", "100")
        )
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.exito").value(true));
    }

    @Test
    public void darMeGusta_withoutTokenAndNoIdUsuario_shouldReturnBadRequest() throws Exception {
        mockMvc.perform(post("/recetas/megusta")
                .param("idReceta", "200")
        )
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.exito").value(false));
    }
}
