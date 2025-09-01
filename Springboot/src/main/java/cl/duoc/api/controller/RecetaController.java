package cl.duoc.api.controller;

import cl.duoc.api.model.entities.Usuario;
import cl.duoc.api.model.entities.Receta;
import cl.duoc.api.service.RecetaService;
import cl.duoc.api.service.UsuarioService;
import cl.duoc.api.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import cl.duoc.api.model.dto.RecetaDTO;
import cl.duoc.api.model.entities.Pais;
import cl.duoc.api.service.PaisService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.ArrayList;
import lombok.extern.log4j.Log4j2;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/recetas")
@Log4j2
@Tag(name = "Recetas", description = "API para gestión de recetas culinarias")
public class RecetaController {

    @Autowired
    RecetaService recetaService;
    @Autowired
    PaisService paisService;
    @Autowired
    JwtUtil jwtUtil;

    @GetMapping
    @Operation(summary = "Listar todas las recetas", description = "Obtiene una lista paginada de todas las recetas disponibles")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Lista de recetas obtenida exitosamente"),
        @ApiResponse(responseCode = "400", description = "Parámetros de paginación inválidos")
    })
    public ResponseEntity<Page<Receta>> listarTodasRecetas(
            @Parameter(description = "Número de página (comienza en 1)", example = "1")
            @RequestParam(defaultValue = "1") int page,
            @Parameter(description = "Tamaño de página", example = "10")
            @RequestParam(defaultValue = "10") int size) {

        Pageable pageable = PageRequest.of(page - 1, size); // Convertir a 0-based
        Page<Receta> recetas = recetaService.listarTodasRecetasPaginadas(pageable);
        return ResponseEntity.ok(recetas);
    }

    @GetMapping(path = "/all")
    @Operation(summary = "Listar todas las recetas sin paginación", description = "Obtiene todas las recetas sin paginación (solo para casos específicos)")
    public List<Receta> listarTodasRecetasSinPaginacion() {
        return recetaService.listarTodasRecetas();
    }

    @GetMapping(path = "/{id_receta}")
    @Operation(summary = "Buscar receta por ID", description = "Obtiene una receta específica por su ID")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Receta encontrada"),
        @ApiResponse(responseCode = "404", description = "Receta no encontrada")
    })
    public ResponseEntity<Receta> buscarRecetaPorId(@PathVariable("id_receta") int idReceta) {
        Optional<Receta> receta = recetaService.buscarRecetaPorId(idReceta);
        if (receta.isPresent()) {
            return ResponseEntity.ok(receta.get());
        } else {
            return ResponseEntity.notFound().build();
        }
    }
    @PostMapping
    @Operation(summary = "Crear nueva receta", description = "Crea una nueva receta en el sistema")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Receta creada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos de receta inválidos")
    })
    public String crearReceta(@RequestBody RecetaDTO recetaDTO) {
        log.info("Creando la receta en la base de datos");
        return recetaService.crearReceta(recetaDTO);
    }

    @GetMapping(path = "/nombre/{nombre}")
    @Operation(summary = "Buscar recetas por nombre", description = "Busca recetas que contengan el nombre especificado")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Recetas encontradas"),
        @ApiResponse(responseCode = "404", description = "No se encontraron recetas con ese nombre")
    })
    public ResponseEntity<List<Receta>> buscarRecetasPorNombre(@PathVariable("nombre") String nombre) {
        List<Receta> recetas = recetaService.buscarRecetasPorNombre(nombre);
        if (recetas.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(recetas);
    }

    @GetMapping(path = "/pais/{id_pais}")
    @Operation(summary = "Buscar recetas por país", description = "Busca recetas por ID de país o nombre de país")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Recetas encontradas"),
        @ApiResponse(responseCode = "404", description = "No se encontraron recetas para ese país")
    })
    public ResponseEntity<List<Receta>> buscarRecetasPorPaisId(@PathVariable("id_pais") String id_pais_or_name) {
        List<Receta> recetas;
        // Si el path es numérico, tratarlo como id_pais
        try {
            int id = Integer.parseInt(id_pais_or_name);
            recetas = recetaService.buscarRecetasPorPaisId(id);
        } catch (NumberFormatException ex) {
            // Si no es numérico, buscar por nombre de país y devolver recetas asociadas
            List<Pais> paises = paisService.buscarPaisPorNombre(id_pais_or_name);
            recetas = new ArrayList<>();
            for (Pais p : paises) {
                recetas.addAll(recetaService.buscarRecetasPorPaisId(p.getId_pais()));
            }
        }

        if (recetas.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(recetas);
    }

    @GetMapping(path = "/pais/nombre/{nombre}")
    @Operation(summary = "Buscar recetas por nombre de país", description = "Busca recetas por nombre de país")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Recetas encontradas"),
        @ApiResponse(responseCode = "404", description = "No se encontraron recetas para ese país")
    })
    public ResponseEntity<List<Receta>> buscarRecetasPorNombrePais(@PathVariable("nombre") String nombre) {
        List<Pais> paises = paisService.buscarPaisPorNombre(nombre);
        List<Receta> recetas = new ArrayList<>();
        for (Pais p : paises) {
            recetas.addAll(recetaService.buscarRecetasPorPaisId(p.getId_pais()));
        }

        if (recetas.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(recetas);
    }

    @PutMapping(path = "/{id_receta}")
    @Operation(summary = "Modificar receta", description = "Actualiza una receta existente")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Receta modificada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Receta no encontrada"),
        @ApiResponse(responseCode = "400", description = "Datos de receta inválidos")
    })
    public ResponseEntity<String> modificarReceta(@PathVariable("id_receta") int idReceta, @RequestBody RecetaDTO recetaDTO) {
        boolean resultado = recetaService.modificarReceta(idReceta, recetaDTO);
        if (resultado) {
            return ResponseEntity.ok("Receta modificada exitosamente");
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping(path = "/count")
    @Operation(summary = "Contar recetas", description = "Obtiene el número total de recetas en el sistema")
    @ApiResponse(responseCode = "200", description = "Conteo obtenido exitosamente")
    public ResponseEntity<Long> contarRecetas() {
        long count = recetaService.contarRecetas();
        return ResponseEntity.ok(count);
    }
}
