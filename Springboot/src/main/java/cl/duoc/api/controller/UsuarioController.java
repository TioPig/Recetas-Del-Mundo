package cl.duoc.api.controller;

import cl.duoc.api.model.entities.Usuario;
import cl.duoc.api.service.UsuarioService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/usuarios")
@CrossOrigin(origins = "*")
@Tag(name = "👥 Usuarios", description = "API para gestión de usuarios del sistema")
public class UsuarioController {

    @Autowired
    private UsuarioService usuarioService;

    @GetMapping
    @Operation(summary = "Obtener todos los usuarios", description = "Retorna la lista completa de usuarios del sistema")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Lista de usuarios obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> obtenerUsuarios() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<Usuario> usuarios = usuarioService.getAllUsuarios();
            response.put("exito", true);
            response.put("data", usuarios);
            response.put("total", usuarios.size());
            response.put("mensaje", "Usuarios obtenidos correctamente");
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al obtener usuarios: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @PostMapping
    @Operation(summary = "Crear nuevo usuario", description = "Crea un nuevo usuario en el sistema")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Usuario creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Email ya registrado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> crearUsuario(@RequestBody Usuario usuario) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (usuarioService.findByEmail(usuario.getEmail()) != null) {
                response.put("exito", false);
                response.put("mensaje", "El email ya está registrado");
                return ResponseEntity.ok(response);
            }
            
            Usuario nuevoUsuario = usuarioService.save(usuario);
            response.put("exito", true);
            response.put("mensaje", "Usuario creado correctamente");
            response.put("data", nuevoUsuario);
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al crear usuario: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Actualizar usuario", description = "Actualiza los datos de un usuario existente")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Usuario actualizado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Usuario no encontrado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> actualizarUsuario(
            @Parameter(description = "ID del usuario a actualizar", required = true) @PathVariable Long id, 
            @RequestBody Usuario usuario) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Usuario> usuarioExistente = usuarioService.findById(id.intValue());
            
            if (usuarioExistente.isPresent()) {
                usuario.setIdUsr(id.intValue());
                Usuario usuarioActualizado = usuarioService.save(usuario);
                response.put("exito", true);
                response.put("mensaje", "Usuario actualizado correctamente");
                response.put("data", usuarioActualizado);
            } else {
                response.put("exito", false);
                response.put("mensaje", "Usuario no encontrado");
            }
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al actualizar usuario: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar usuario", description = "Realiza eliminación lógica (soft delete) de un usuario")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Usuario eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Usuario no encontrado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> eliminarUsuario(
            @Parameter(description = "ID del usuario a eliminar", required = true) @PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Usuario> usuario = usuarioService.findById(id.intValue());
            
            if (usuario.isPresent()) {
                // Soft delete: cambiar estado en lugar de eliminar  
                Usuario usuarioExistente = usuario.get();
                usuarioExistente.setEstado((short) 0); // 0 = INACTIVO
                usuarioService.save(usuarioExistente);
                response.put("exito", true);
                response.put("mensaje", "Usuario eliminado correctamente");
            } else {
                response.put("exito", false);
                response.put("mensaje", "Usuario no encontrado");
            }
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al eliminar usuario: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener usuario por ID", description = "Retorna los datos de un usuario específico")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Usuario encontrado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Usuario no encontrado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> obtenerUsuarioPorId(
            @Parameter(description = "ID del usuario a consultar", required = true) @PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Usuario> usuario = usuarioService.findById(id.intValue());
            
            if (usuario.isPresent()) {
                response.put("exito", true);
                response.put("data", usuario.get());
            } else {
                response.put("exito", false);
                response.put("mensaje", "Usuario no encontrado");
            }
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al buscar usuario: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
}