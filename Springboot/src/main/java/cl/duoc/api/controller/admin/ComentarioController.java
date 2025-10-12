package cl.duoc.api.controller.admin;

import cl.duoc.api.model.entities.Comentario;
import cl.duoc.api.service.ComentarioService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/admin/comentarios")
@Tag(name = "💬 Admin - Comentarios", description = "API administrativa para gestión de comentarios")
public class ComentarioController {

    @Autowired
    private ComentarioService comentarioService;

    @GetMapping
    @Operation(summary = "Obtener todos los comentarios")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Lista de comentarios obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<List<Comentario>> getAllComentarios() {
        try {
            List<Comentario> comentarios = comentarioService.getAllComentarios();
            return new ResponseEntity<>(comentarios, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener comentario por ID")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Comentario encontrado"),
        @ApiResponse(responseCode = "404", description = "Comentario no encontrado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Comentario> getComentarioById(@PathVariable Integer id) {
        try {
            Optional<Comentario> comentario = comentarioService.getComentarioById(id);
            if (comentario.isPresent()) {
                return new ResponseEntity<>(comentario.get(), HttpStatus.OK);
            } else {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping
    @Operation(summary = "Crear un nuevo comentario")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Comentario creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos de entrada inválidos"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Comentario> createComentario(@RequestBody Comentario comentario) {
        try {
            Comentario newComentario = comentarioService.save(comentario);
            return new ResponseEntity<>(newComentario, HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PutMapping("/{id}")
    @Operation(summary = "Actualizar comentario existente")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Comentario actualizado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Comentario no encontrado"),
        @ApiResponse(responseCode = "400", description = "Datos de entrada inválidos"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Comentario> updateComentario(@PathVariable Integer id, @RequestBody Comentario comentario) {
        try {
            Optional<Comentario> existingComentario = comentarioService.getComentarioById(id);
            if (existingComentario.isPresent()) {
                comentario.setIdComentario(id);
                Comentario updatedComentario = comentarioService.save(comentario);
                return new ResponseEntity<>(updatedComentario, HttpStatus.OK);
            } else {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar comentario")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Comentario eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Comentario no encontrado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Void> deleteComentario(@PathVariable Integer id) {
        try {
            Optional<Comentario> comentario = comentarioService.getComentarioById(id);
            if (comentario.isPresent()) {
                comentarioService.delete(id);
                return new ResponseEntity<>(HttpStatus.NO_CONTENT);
            } else {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}