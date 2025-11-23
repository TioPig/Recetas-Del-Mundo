package cl.duoc.api.controller.admin;

import cl.duoc.api.model.entities.Ingrediente;
import cl.duoc.api.service.IngredienteService;
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
@RequestMapping("/admin/ingredientes")
@Tag(name = "🥬 Admin - Ingredientes", description = "API administrativa para gestión de ingredientes")
public class IngredienteController {

    @Autowired
    private IngredienteService ingredienteService;

    @GetMapping
    @Operation(summary = "Obtener todos los ingredientes")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Lista de ingredientes obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<List<Ingrediente>> getAllIngredientes() {
        try {
            List<Ingrediente> ingredientes = ingredienteService.listAll();
            return new ResponseEntity<>(ingredientes, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener ingrediente por ID")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Ingrediente encontrado"),
        @ApiResponse(responseCode = "404", description = "Ingrediente no encontrado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Ingrediente> getIngredienteById(@PathVariable Integer id) {
        try {
            Optional<Ingrediente> ingrediente = ingredienteService.getIngredienteById(id);
            if (ingrediente.isPresent()) {
                return new ResponseEntity<>(ingrediente.get(), HttpStatus.OK);
            } else {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }



    @PostMapping
    @Operation(summary = "Crear un nuevo ingrediente")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Ingrediente creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos de entrada inválidos"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Ingrediente> createIngrediente(@RequestBody Ingrediente ingrediente) {
        try {
            Ingrediente newIngrediente = ingredienteService.save(ingrediente);
            return new ResponseEntity<>(newIngrediente, HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PutMapping("/{id}")
    @Operation(summary = "Actualizar ingrediente existente")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Ingrediente actualizado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Ingrediente no encontrado"),
        @ApiResponse(responseCode = "400", description = "Datos de entrada inválidos"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Ingrediente> updateIngrediente(@PathVariable Integer id, @RequestBody Ingrediente ingrediente) {
        try {
            Optional<Ingrediente> existingIngrediente = ingredienteService.getIngredienteById(id);
            if (existingIngrediente.isPresent()) {
                ingrediente.setIdIngrediente(id);
                Ingrediente updatedIngrediente = ingredienteService.save(ingrediente);
                return new ResponseEntity<>(updatedIngrediente, HttpStatus.OK);
            } else {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar ingrediente")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Ingrediente eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Ingrediente no encontrado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Void> deleteIngrediente(@PathVariable Integer id) {
        try {
            Optional<Ingrediente> ingrediente = ingredienteService.getIngredienteById(id);
            if (ingrediente.isPresent()) {
                ingredienteService.deleteIngrediente(id);
                return new ResponseEntity<>(HttpStatus.NO_CONTENT);
            } else {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}