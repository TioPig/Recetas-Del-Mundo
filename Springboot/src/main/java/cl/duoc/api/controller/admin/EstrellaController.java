package cl.duoc.api.controller.admin;

import cl.duoc.api.model.entities.Estrella;
import cl.duoc.api.service.EstrellaService;
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
@RequestMapping("/admin/estrellas")
@Tag(name = "⭐ Admin - Estrellas", description = "API administrativa para gestión de calificaciones")
public class EstrellaController {

    @Autowired
    private EstrellaService estrellaService;

    @GetMapping
    @Operation(summary = "Obtener todas las calificaciones")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Lista de calificaciones obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<List<Estrella>> getAllEstrellas() {
        try {
            List<Estrella> estrellas = estrellaService.getAllEstrellas();
            return new ResponseEntity<>(estrellas, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener calificación por ID")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Calificación encontrada"),
        @ApiResponse(responseCode = "404", description = "Calificación no encontrada"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Estrella> getEstrellaById(@PathVariable Integer id) {
        try {
            Optional<Estrella> estrella = estrellaService.getEstrellaById(id);
            if (estrella.isPresent()) {
                return new ResponseEntity<>(estrella.get(), HttpStatus.OK);
            } else {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/receta/{recetaId}")
    @Operation(summary = "Obtener calificaciones por ID de receta")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Calificaciones encontradas"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<List<Estrella>> getEstrellasByRecetaId(@PathVariable Integer recetaId) {
        try {
            List<Estrella> estrellas = estrellaService.getEstrellasByReceta(recetaId);
            return new ResponseEntity<>(estrellas, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/receta/{recetaId}/promedio")
    @Operation(summary = "Obtener promedio de calificaciones por receta")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Promedio calculado exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Double> getPromedioEstrellasByReceta(@PathVariable Integer recetaId) {
        try {
            Double promedio = estrellaService.getPromedioByReceta(recetaId);
            return new ResponseEntity<>(promedio, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping
    @Operation(summary = "Crear una nueva calificación")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Calificación creada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos de entrada inválidos"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Estrella> createEstrella(@RequestBody Estrella estrella) {
        try {
            Estrella newEstrella = estrellaService.save(estrella);
            return new ResponseEntity<>(newEstrella, HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PutMapping("/{id}")
    @Operation(summary = "Actualizar calificación existente")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Calificación actualizada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Calificación no encontrada"),
        @ApiResponse(responseCode = "400", description = "Datos de entrada inválidos"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Estrella> updateEstrella(@PathVariable Integer id, @RequestBody Estrella estrella) {
        try {
            Optional<Estrella> existingEstrella = estrellaService.getEstrellaById(id);
            if (existingEstrella.isPresent()) {
                estrella.setIdEstrella(id);
                Estrella updatedEstrella = estrellaService.save(estrella);
                return new ResponseEntity<>(updatedEstrella, HttpStatus.OK);
            } else {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar calificación")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Calificación eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Calificación no encontrada"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Void> deleteEstrella(@PathVariable Integer id) {
        try {
            Optional<Estrella> estrella = estrellaService.getEstrellaById(id);
            if (estrella.isPresent()) {
                estrellaService.delete(id);
                return new ResponseEntity<>(HttpStatus.NO_CONTENT);
            } else {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}