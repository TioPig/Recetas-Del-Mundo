package cl.duoc.api.controller;

import cl.duoc.api.model.entities.Usuario;
import cl.duoc.api.service.UsuarioService;
import cl.duoc.api.util.JwtUtil;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/auth")
@CrossOrigin(origins = "*")
@Tag(name = "🔐 Autenticación", description = "Endpoints para login y registro de usuarios")
public class AuthController {

    @Autowired
    private UsuarioService usuarioService;
    
    @Autowired
    private JwtUtil jwtUtil;

    @PostMapping("/login")
    @Operation(summary = "Iniciar sesión", description = "Autentica usuario con email y contraseña, retorna token JWT")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Login exitoso, token JWT generado"),
        @ApiResponse(responseCode = "401", description = "Credenciales inválidas"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> login(
            @Parameter(description = "Credenciales de usuario (email y password)") 
            @RequestBody Map<String, String> loginRequest) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String email = loginRequest.get("email");
            String password = loginRequest.get("password");
            
            // Usar el método login del servicio que maneja BCrypt correctamente
            Usuario usuarioOpt = usuarioService.login(email, password);
            
            if (usuarioOpt != null) {
                // Generar JWT token
                Integer perfilId = usuarioOpt.getPerfil() != null ? usuarioOpt.getPerfil().getIdPerfil() : null;
                String perfilNombre = usuarioOpt.getPerfil() != null ? usuarioOpt.getPerfil().getNombre() : null;
                String token = jwtUtil.generateToken(
                    usuarioOpt.getIdUsr(),
                    usuarioOpt.getEmail(),
                    usuarioOpt.getNombre(),
                    usuarioOpt.getApellido(),
                    perfilId,
                    perfilNombre,
                    usuarioOpt.getEstado()
                );
                
                // Crear objeto con datos del usuario
                Map<String, Object> userData = new HashMap<>();
                userData.put("id_usr", usuarioOpt.getIdUsr());
                userData.put("nombre", usuarioOpt.getNombre());
                userData.put("apellido", usuarioOpt.getApellido());
                userData.put("correo", usuarioOpt.getEmail());
                userData.put("id_perfil", perfilId);
                userData.put("estado", usuarioOpt.getEstado());
                if (perfilNombre != null) {
                    userData.put("rol", perfilNombre);
                }
                
                response.put("exito", true);
                response.put("mensaje", "Login exitoso");
                response.put("token", token);
                response.put("usuario", userData);
            } else {
                response.put("exito", false);
                response.put("mensaje", "Credenciales invalidas");
            }
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error en login: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/register")
    @Operation(summary = "Registrar nuevo usuario", description = "Crea una nueva cuenta de usuario en el sistema")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Usuario registrado correctamente"),
        @ApiResponse(responseCode = "400", description = "Email ya registrado o datos inválidos"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> register(
            @Parameter(description = "Datos del nuevo usuario") 
            @RequestBody Usuario usuario) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Validación mínima: evitar intentar guardar NULL en password
            if (usuario.getPassword() == null || usuario.getPassword().trim().isEmpty()) {
                response.put("exito", false);
                response.put("mensaje", "La contraseña es obligatoria");
                return ResponseEntity.ok(response);
            }
            if (usuarioService.findByEmail(usuario.getEmail()) != null) {
                response.put("exito", false);
                response.put("mensaje", "El email ya esta registrado");
                return ResponseEntity.ok(response);
            }
            
            // El UsuarioService.save() ya maneja automáticamente el hasheo BCrypt
            Usuario nuevoUsuario = usuarioService.save(usuario);
            response.put("exito", true);
            response.put("mensaje", "Usuario registrado correctamente");
            response.put("usuario", nuevoUsuario);
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error en registro: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
}