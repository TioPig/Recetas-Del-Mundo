package cl.duoc.api.controller.admin;

import cl.duoc.api.model.entities.MeGusta;
import cl.duoc.api.service.MeGustaService;
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
@RequestMapping("/admin/megusta")
@Tag(name = "👍 Admin - Me Gusta", description = "API administrativa para gestión de likes")
public class MeGustaController {

    @Autowired
    private MeGustaService meGustaService;

    @GetMapping
    @Operation(summary = "Obtener todos los likes")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Lista de likes obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<List<MeGusta>> getAllMeGusta() {
        try {
            List<MeGusta> meGustas = meGustaService.getAllMeGusta();
            return new ResponseEntity<>(meGustas, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener like por ID")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Like encontrado"),
        @ApiResponse(responseCode = "404", description = "Like no encontrado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<MeGusta> getMeGustaById(@PathVariable Integer id) {
        try {
            Optional<MeGusta> meGusta = meGustaService.getMeGustaById(id);
            if (meGusta.isPresent()) {
                return new ResponseEntity<>(meGusta.get(), HttpStatus.OK);
            } else {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/receta/{recetaId}/count")
    @Operation(summary = "Contar likes por receta")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Conteo exitoso"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Long> countMeGustaByReceta(@PathVariable Integer recetaId) {
        try {
            Long count = meGustaService.countByReceta(recetaId);
            return new ResponseEntity<>(count, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping
    @Operation(summary = "Crear un nuevo like")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Like creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos de entrada inválidos"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<MeGusta> createMeGusta(@RequestBody MeGusta meGusta) {
        try {
            // Forzar fecha de creación en servidor
            meGusta.setFechaCreacion(java.time.LocalDateTime.now());
            MeGusta newMeGusta = meGustaService.save(meGusta);
            return new ResponseEntity<>(newMeGusta, HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/toggle")
    @Operation(summary = "Alternar like (dar/quitar like)")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Toggle exitoso"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<String> toggleMeGusta(@RequestParam Integer usuarioId, @RequestParam Integer recetaId) {
        try {
            boolean result = meGustaService.toggleMeGusta(usuarioId, recetaId);
            String message = result ? "Like agregado" : "Like removido";
            return new ResponseEntity<>(message, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>("Error en toggle", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PutMapping("/{id}")
    @Operation(summary = "Actualizar like existente")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Like actualizado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Like no encontrado"),
        @ApiResponse(responseCode = "400", description = "Datos de entrada inválidos"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<MeGusta> updateMeGusta(@PathVariable Integer id, @RequestBody MeGusta meGusta) {
        try {
            Optional<MeGusta> existingMeGusta = meGustaService.getMeGustaById(id);
            if (existingMeGusta.isPresent()) {
                MeGusta base = existingMeGusta.get();
                meGusta.setIdMeGusta(id);
                // preservar fechaCreacion si no viene
                if (meGusta.getFechaCreacion() == null) {
                    meGusta.setFechaCreacion(base.getFechaCreacion());
                } else {
                    // Siempre preservar la fecha original, no confiar en el cliente
                    meGusta.setFechaCreacion(base.getFechaCreacion());
                }
                // preservar receta/usuario si no vienen en body
                if (meGusta.getReceta() == null) {
                    meGusta.setReceta(base.getReceta());
                }
                if (meGusta.getUsuario() == null) {
                    meGusta.setUsuario(base.getUsuario());
                }
                MeGusta updatedMeGusta = meGustaService.save(meGusta);
                return new ResponseEntity<>(updatedMeGusta, HttpStatus.OK);
            } else {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar like")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Like eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Like no encontrado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Void> deleteMeGusta(@PathVariable Integer id) {
        try {
            Optional<MeGusta> meGusta = meGustaService.getMeGustaById(id);
            if (meGusta.isPresent()) {
                meGustaService.delete(id);
                return new ResponseEntity<>(HttpStatus.NO_CONTENT);
            } else {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}