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
import java.time.LocalDateTime;
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;

@RestController
    @RequestMapping("/admin/comentarios")
@Tag(name = "💬 Admin - Comentarios", description = "API administrativa para gestión de comentarios")
public class ComentarioController {

    @Autowired
    private ComentarioService comentarioService;
    
    @Autowired
    private cl.duoc.api.service.RecetaService recetaService;

    @Autowired
    private cl.duoc.api.service.UsuarioService usuarioService;

    @GetMapping
    @Operation(summary = "Obtener todos los comentarios")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Lista de comentarios obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<List<Map<String,Object>>> getAllComentarios() {
        try {
            List<Comentario> comentarios = comentarioService.getAllComentarios();
            List<Map<String,Object>> out = new ArrayList<>();
            for (Comentario c : comentarios) {
                out.add(sanitizeComentario(c));
            }
            return new ResponseEntity<>(out, HttpStatus.OK);
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
    public ResponseEntity<Map<String,Object>> getComentarioById(@PathVariable Integer id) {
        try {
            Optional<Comentario> comentario = comentarioService.getComentarioById(id);
            if (comentario.isPresent()) {
                return new ResponseEntity<>(sanitizeComentario(comentario.get()), HttpStatus.OK);
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
    public ResponseEntity<Map<String,Object>> createComentario(@RequestBody Comentario comentario) {
        try {
            // Validar que venga receta y usuario con ids
            if (comentario.getReceta() == null || comentario.getReceta().getIdReceta() == null) {
                return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
            }
            if (comentario.getUsuario() == null || comentario.getUsuario().getIdUsr() == null) {
                return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
            }

            // Cargar entidades reales desde servicios para asegurar integridad
            Integer idReceta = comentario.getReceta().getIdReceta();
            Integer idUsuario = comentario.getUsuario().getIdUsr();

            Optional<cl.duoc.api.model.entities.Receta> recetaOpt = recetaService.findById(idReceta);
            Optional<cl.duoc.api.model.entities.Usuario> usuarioOpt = usuarioService.findById(idUsuario);

            if (recetaOpt.isEmpty() || usuarioOpt.isEmpty()) {
                return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
            }

            comentario.setReceta(recetaOpt.get());
            comentario.setUsuario(usuarioOpt.get());

            // Asegurar fecha de creacion (DB exige NOT NULL)
            if (comentario.getFechaCreacion() == null) {
                comentario.setFechaCreacion(LocalDateTime.now());
            }

            Comentario newComentario = comentarioService.save(comentario);
            return new ResponseEntity<>(sanitizeComentario(newComentario), HttpStatus.CREATED);
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
    public ResponseEntity<Map<String,Object>> updateComentario(@PathVariable Integer id, @RequestBody Comentario comentario) {
        try {
            Optional<Comentario> existingComentario = comentarioService.getComentarioById(id);
            if (existingComentario.isPresent()) {
                Comentario base = existingComentario.get();
                comentario.setIdComentario(id);
                // preservar fechaCreacion si no viene en el body
                if (comentario.getFechaCreacion() == null) {
                    comentario.setFechaCreacion(base.getFechaCreacion());
                }
                // preservar receta/usuario si no vienen en el body para evitar campos nulos en BD
                if (comentario.getReceta() == null) {
                    comentario.setReceta(base.getReceta());
                }
                if (comentario.getUsuario() == null) {
                    comentario.setUsuario(base.getUsuario());
                }
                Comentario updatedComentario = comentarioService.save(comentario);
                return new ResponseEntity<>(sanitizeComentario(updatedComentario), HttpStatus.OK);
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

    // --- Helpers to sanitize entities for admin responses (minimal, avoids exposing password)
    private Map<String,Object> sanitizeComentario(Comentario c) {
        Map<String,Object> m = new HashMap<>();
        m.put("idComentario", c.getIdComentario());
        m.put("texto", c.getTexto());
        m.put("fechaCreacion", c.getFechaCreacion());
        m.put("receta", sanitizeReceta(c.getReceta()));
        m.put("usuario", sanitizeUsuario(c.getUsuario()));
        return m;
    }

    private Map<String,Object> sanitizeUsuario(cl.duoc.api.model.entities.Usuario u) {
        if (u == null) return null;
        Map<String,Object> mu = new HashMap<>();
        mu.put("idUsr", u.getIdUsr());
        return mu;
    }

    private Map<String,Object> sanitizeReceta(cl.duoc.api.model.entities.Receta r) {
        if (r == null) return null;
        Map<String,Object> mr = new HashMap<>();
        mr.put("idReceta", r.getIdReceta());
        // include owner id_usr only
        if (r.getIdUsr() != null) {
            mr.put("idUsr", r.getIdUsr());
        } else if (r.getIdUsr() == null && r.getIdUsr() == null) {
            // no-op, keep minimal
        }
        return mr;
    }
}