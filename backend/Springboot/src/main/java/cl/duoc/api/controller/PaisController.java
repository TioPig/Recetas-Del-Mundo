package cl.duoc.api.controller;

import cl.duoc.api.model.entities.Pais;
import cl.duoc.api.service.PaisService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/paises")
@CrossOrigin(origins = "*")
@Tag(name = "🌍 Países", description = "API para gestión de países")
public class PaisController {

    @Autowired
    private PaisService paisService;

    @GetMapping
    @Operation(summary = "Obtener todos los países", description = "Retorna la lista de países activos")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Lista de países obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> obtenerPaises() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<Pais> paises = paisService.getActivePaises();
            response.put("exito", true);
            response.put("data", paises);
            response.put("total", paises.size());
            response.put("mensaje", "Países obtenidos correctamente");
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al obtener países: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @PostMapping
    @Operation(summary = "Crear nuevo país", description = "Crea un nuevo país en el sistema")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "País creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> crearPais(@RequestBody Pais pais) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (pais.getEstado() == null) {
                pais.setEstado((short) 1);
            }
            if (pais.getFechaCreacion() == null) {
                pais.setFechaCreacion(LocalDateTime.now());
            }
            
            Pais nuevoPais = paisService.savePais(pais);
            response.put("exito", true);
            response.put("mensaje", "País creado correctamente");
            response.put("data", nuevoPais);
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al crear país: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Actualizar país", description = "Actualiza los datos de un país existente")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "País actualizado exitosamente"),
        @ApiResponse(responseCode = "404", description = "País no encontrado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> actualizarPais(
            @Parameter(description = "ID del país a actualizar", required = true) @PathVariable Long id, 
            @RequestBody Pais pais) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Pais paisExistente = paisService.getPaisById(id.intValue());
            
            if (paisExistente != null) {
                pais.setIdPais(id.intValue());
                Pais paisActualizado = paisService.savePais(pais);
                response.put("exito", true);
                response.put("mensaje", "País actualizado correctamente");
                response.put("data", paisActualizado);
            } else {
                response.put("exito", false);
                response.put("mensaje", "País no encontrado");
            }
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al actualizar país: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar país", description = "Realiza eliminación lógica (soft delete) de un país")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "País eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "País no encontrado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> eliminarPais(
            @Parameter(description = "ID del país a eliminar", required = true) @PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Pais pais = paisService.getPaisById(id.intValue());
            
            if (pais != null) {
                pais.setEstado((short) 0);
                paisService.savePais(pais);
                response.put("exito", true);
                response.put("mensaje", "País eliminado correctamente");
            } else {
                response.put("exito", false);
                response.put("mensaje", "País no encontrado");
            }
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al eliminar país: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener país por ID", description = "Retorna los datos de un país específico")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "País encontrado exitosamente"),
        @ApiResponse(responseCode = "404", description = "País no encontrado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> obtenerPaisPorId(
            @Parameter(description = "ID del país a consultar", required = true) @PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Pais pais = paisService.getPaisById(id.intValue());
            
            if (pais != null) {
                response.put("exito", true);
                response.put("data", pais);
                response.put("mensaje", "País encontrado correctamente");
            } else {
                response.put("exito", false);
                response.put("mensaje", "País no encontrado");
            }
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al buscar país: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/nombre/{nombre}")
    @Operation(summary = "Buscar países por nombre", description = "Busca países que coincidan con el nombre proporcionado")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Búsqueda realizada exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> buscarPaisesPorNombre(
            @Parameter(description = "Nombre o parte del nombre a buscar", required = true) @PathVariable String nombre) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<Pais> paises = paisService.getPaisesByNombre(nombre);
            response.put("exito", true);
            response.put("data", paises);
            response.put("total", paises.size());
            response.put("mensaje", "Países que contienen: '" + nombre + "'");
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al buscar países por nombre: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
}