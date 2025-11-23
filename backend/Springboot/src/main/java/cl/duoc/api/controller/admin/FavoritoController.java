package cl.duoc.api.controller.admin;

import cl.duoc.api.model.entities.Favorito;
import cl.duoc.api.service.FavoritoService;
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
@RequestMapping("/admin/favoritos")
@Tag(name = "⭐ Admin - Favoritos", description = "API administrativa para gestión de favoritos")
public class FavoritoController {

    @Autowired
    private FavoritoService favoritoService;

    @GetMapping
    @Operation(summary = "Obtener todos los favoritos")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Lista de favoritos obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<List<Favorito>> getAllFavoritos() {
        try {
            List<Favorito> favoritos = favoritoService.getAllFavoritos();
            return new ResponseEntity<>(favoritos, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener favorito por ID")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Favorito encontrado"),
        @ApiResponse(responseCode = "404", description = "Favorito no encontrado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Favorito> getFavoritoById(@PathVariable Integer id) {
        try {
            Optional<Favorito> favorito = favoritoService.getFavoritoById(id);
            if (favorito.isPresent()) {
                return new ResponseEntity<>(favorito.get(), HttpStatus.OK);
            } else {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping
    @Operation(summary = "Crear un nuevo favorito")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Favorito creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos de entrada inválidos"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Favorito> createFavorito(@RequestBody Favorito favorito) {
        try {
            // Forzar fechaCreacion por servidor
            favorito.setFechaCreacion(java.time.LocalDateTime.now());
            Favorito newFavorito = favoritoService.save(favorito);
            return new ResponseEntity<>(newFavorito, HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PutMapping("/{id}")
    @Operation(summary = "Actualizar favorito existente")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Favorito actualizado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Favorito no encontrado"),
        @ApiResponse(responseCode = "400", description = "Datos de entrada inválidos"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Favorito> updateFavorito(@PathVariable Integer id, @RequestBody Favorito favorito) {
        try {
            Optional<Favorito> existing = favoritoService.getFavoritoById(id);
            if (existing.isPresent()) {
                Favorito base = existing.get();
                favorito.setIdFav(id);
                if (favorito.getFechaCreacion() == null) {
                    favorito.setFechaCreacion(base.getFechaCreacion());
                }
                // preservar receta/usuario si no vienen
                if (favorito.getReceta() == null) {
                    favorito.setReceta(base.getReceta());
                }
                if (favorito.getUsuario() == null) {
                    favorito.setUsuario(base.getUsuario());
                }
                Favorito updated = favoritoService.save(favorito);
                return new ResponseEntity<>(updated, HttpStatus.OK);
            } else {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar favorito")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Favorito eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Favorito no encontrado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Void> deleteFavorito(@PathVariable Integer id) {
        try {
            Optional<Favorito> favorito = favoritoService.getFavoritoById(id);
            if (favorito.isPresent()) {
                favoritoService.delete(id);
                return new ResponseEntity<>(HttpStatus.NO_CONTENT);
            } else {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}