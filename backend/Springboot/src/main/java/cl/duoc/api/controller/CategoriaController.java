package cl.duoc.api.controller;

import cl.duoc.api.model.entities.Categoria;
import cl.duoc.api.service.CategoriaService;
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
@RequestMapping("/categorias")
@CrossOrigin(origins = "*")
@Tag(name = "📂 Categorías", description = "API para gestión de categorías de recetas")
public class CategoriaController {

    @Autowired
    private CategoriaService categoriaService;

    @GetMapping
    public ResponseEntity<Map<String, Object>> obtenerCategorias() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<Categoria> categorias = categoriaService.getActiveCategorias();
            response.put("exito", true);
            response.put("data", categorias);
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al obtener categorias: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> crearCategoria(@RequestBody Categoria categoria) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Categoria nuevaCategoria = categoriaService.saveCategoria(categoria);
            response.put("exito", true);
            response.put("mensaje", "Categoria creada correctamente");
            response.put("data", nuevaCategoria);
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al crear categoria: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> obtenerCategoriaPorId(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Categoria categoria = categoriaService.getCategoriaById(id.intValue());
            
            if (categoria != null) {
                response.put("exito", true);
                response.put("data", categoria);
            } else {
                response.put("exito", false);
                response.put("mensaje", "Categoria no encontrada");
            }
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al buscar categoria: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> actualizarCategoria(@PathVariable Long id, @RequestBody Categoria categoria) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Categoria categoriaExistente = categoriaService.getCategoriaById(id.intValue());
            
            if (categoriaExistente != null) {
                // Mantener los datos existentes y actualizar los nuevos
                categoriaExistente.setNombre(categoria.getNombre());
                // Solo actualizar estado si se proporciona
                if (categoria.getEstado() != null) {
                    categoriaExistente.setEstado(categoria.getEstado());
                }
                Categoria categoriaActualizada = categoriaService.saveCategoria(categoriaExistente);
                response.put("exito", true);
                response.put("mensaje", "Categoria actualizada correctamente");
                response.put("data", categoriaActualizada);
            } else {
                response.put("exito", false);
                response.put("mensaje", "Categoria no encontrada");
            }
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al actualizar categoria: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> eliminarCategoria(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Categoria categoria = categoriaService.getCategoriaById(id.intValue());
            
            if (categoria != null) {
                // Soft delete: cambiar estado en lugar de eliminar
                categoria.setEstado((short) 0); // 0 = INACTIVO
                categoriaService.saveCategoria(categoria);
                response.put("exito", true);
                response.put("mensaje", "Categoria eliminada correctamente");
            } else {
                response.put("exito", false);
                response.put("mensaje", "Categoria no encontrada");
            }
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al eliminar categoria: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
}