package cl.duoc.api.controller;

import cl.duoc.api.model.entities.Receta;
import cl.duoc.api.model.entities.Usuario;
import cl.duoc.api.model.entities.Favorito;
import cl.duoc.api.model.entities.MeGusta;
import cl.duoc.api.model.entities.Estrella;
import cl.duoc.api.model.entities.Comentario;
import cl.duoc.api.model.entities.Ingrediente;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.type.CollectionType;
import cl.duoc.api.service.RecetaService;
import cl.duoc.api.service.RecetaDelDiaService;
import cl.duoc.api.service.FavoritoService;
import cl.duoc.api.service.MeGustaService;
import cl.duoc.api.service.EstrellaService;
import cl.duoc.api.service.ComentarioService;
import cl.duoc.api.util.JwtUtil;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import jakarta.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Collections;

@RestController
@RequestMapping("/recetas")
@Tag(name = "🍽️ Recetas", description = "API completa para gestión de recetas con ingredientes")
public class RecetaController {

    private static final Logger logger = LoggerFactory.getLogger(RecetaController.class);

    @Autowired
    private RecetaService recetaService;
    
    @Autowired
    private RecetaDelDiaService recetaDelDiaService;
    
    @Autowired
    private FavoritoService favoritoService;
    
    @Autowired
    private MeGustaService meGustaService;
    
    @Autowired
    private EstrellaService estrellaService;
    
    @Autowired
    private ComentarioService comentarioService;
    
    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private ObjectMapper objectMapper;

    // Helper method para extraer usuario ID del JWT token
    private Integer getUserIdFromToken(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            logger.warn("🚫 Header Authorization inválido: {}", authHeader);
            return null;
        }
        
        String token = authHeader.substring(7);
        if (token.trim().isEmpty()) {
            logger.warn("🚫 Token vacío después de 'Bearer '");
            return null;
        }
        
        try {
            Integer userId = jwtUtil.extractUserId(token);
            logger.info("✅ Usuario extraído del token: {}", userId);
            return userId;
        } catch (Exception e) {
            logger.error("❌ Error al extraer usuario del token: {}", e.getMessage());
            return null;
        }
    }

    @GetMapping
    public ResponseEntity<Map<String, Object>> obtenerRecetas() {
        Map<String, Object> response = new HashMap<>();
        
    try {
            List<Receta> recetas = recetaService.findAll();
            response.put("exito", true);
            response.put("data", recetas);
            response.put("total", recetas.size());
            // Asegurar campo urlImagen para cada receta
            if (recetas != null) {
                for (Receta r : recetas) {
                    if (r.getUrlImagen() == null) {
                        r.setUrlImagen("");
                    }
                }
            }
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al obtener recetas: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> obtenerRecetaPorId(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Receta> receta = recetaService.findById(id.intValue());
            
            if (receta.isPresent()) {
                response.put("exito", true);
                response.put("data", receta.get());
            } else {
                response.put("exito", false);
                response.put("mensaje", "Receta no encontrada");
            }
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al buscar receta: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> crearReceta(@RequestBody Receta receta) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Forzar que la fecha de creación la asigne el servidor
            receta.setFechaCreacion(java.time.LocalDate.now());
            
            // Asegurar que los ingredientes están correctamente relacionados
            if (receta.getIngredientes() != null) {
                for (cl.duoc.api.model.entities.Ingrediente ingrediente : receta.getIngredientes()) {
                    ingrediente.setReceta(receta);
                }
            }
            
            Receta nuevaReceta = recetaService.save(receta);
            response.put("exito", true);
            response.put("mensaje", "Receta creada correctamente con " + 
                       (nuevaReceta.getIngredientes() != null ? nuevaReceta.getIngredientes().size() : 0) + 
                       " ingredientes");
            response.put("data", nuevaReceta);
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al crear receta: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> actualizarReceta(@PathVariable Long id, @RequestBody Receta receta) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Receta> recetaExistente = recetaService.findById(id.intValue());
            
            if (recetaExistente.isPresent()) {
                Receta existing = recetaExistente.get();

                // Actualizar campos simples en la entidad persistente
                existing.setNombre(receta.getNombre() != null ? receta.getNombre() : existing.getNombre());
                existing.setUrlImagen(receta.getUrlImagen() != null ? receta.getUrlImagen() : existing.getUrlImagen());
                existing.setPreparacion(receta.getPreparacion() != null ? receta.getPreparacion() : existing.getPreparacion());
                existing.setIdCat(receta.getIdCat() != null ? receta.getIdCat() : existing.getIdCat());
                existing.setIdPais(receta.getIdPais() != null ? receta.getIdPais() : existing.getIdPais());
                existing.setEstado(receta.getEstado() != null ? receta.getEstado() : existing.getEstado());
                existing.setIdUsr(receta.getIdUsr() != null ? receta.getIdUsr() : existing.getIdUsr());
                // fechaCreacion: preservar siempre
                // Reasignar explícitamente la fecha de creación desde la entidad persistente para evitar confiar en el cliente
                existing.setFechaCreacion(existing.getFechaCreacion());

                // Manejo robusto de ingredientes: si el payload trae ingredientes, reemplazar la colección existente
                if (receta.getIngredientes() != null) {
                    // Limpiar la colección existente y añadir los nuevos, manteniendo la misma instancia
                    existing.getIngredientes().clear();
                    for (Ingrediente ingrediente : receta.getIngredientes()) {
                        ingrediente.setReceta(existing);
                        existing.getIngredientes().add(ingrediente);
                    }
                }

                Receta recetaActualizada = recetaService.save(existing);
                response.put("exito", true);
                response.put("mensaje", "Receta actualizada correctamente con " + 
                           (recetaActualizada.getIngredientes() != null ? recetaActualizada.getIngredientes().size() : 0) + 
                           " ingredientes");
                response.put("data", recetaActualizada);
            } else {
                response.put("exito", false);
                response.put("mensaje", "Receta no encontrada");
            }
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al actualizar receta: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> eliminarReceta(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Receta> receta = recetaService.findById(id.intValue());
            
            if (receta.isPresent()) {
                Receta recetaExistente = receta.get();
                recetaExistente.setEstado((short) 0);
                recetaService.save(recetaExistente);
                response.put("exito", true);
                response.put("mensaje", "Receta eliminada correctamente");
            } else {
                response.put("exito", false);
                response.put("mensaje", "Receta no encontrada");
            }
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al eliminar receta: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/carrusel")
    public ResponseEntity<Map<String, Object>> obtenerRecetasCarrusel() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<Receta> recetas = recetaService.findTop8ByEstrellasMeGusta();
            response.put("exito", true);
            response.put("data", recetas);
            response.put("total", recetas.size());
            response.put("mensaje", "Top 8 recetas mas valoradas para carrusel");
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al obtener recetas del carrusel: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/trending")
    public ResponseEntity<Map<String, Object>> obtenerRecetasTrending() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<Receta> recetas = recetaService.findTrendingRecetas();
            response.put("exito", true);
            response.put("data", recetas);
            response.put("total", recetas.size());
            response.put("mensaje", "Recetas trending de los ultimos 30 dias");
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al obtener recetas trending: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/pais/{idPais}")
    public ResponseEntity<Map<String, Object>> obtenerRecetasPorPais(@PathVariable Integer idPais) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<Receta> recetas = recetaService.findByPaisId(idPais);
            response.put("exito", true);
            response.put("data", recetas);
            response.put("total", recetas.size());
            response.put("mensaje", "Recetas del pais ID: " + idPais);
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al obtener recetas por pais: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/nombre/{nombre}")
    public ResponseEntity<Map<String, Object>> buscarRecetasPorNombre(@PathVariable String nombre) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<Receta> recetas = recetaService.findByNombreContaining(nombre);
            response.put("exito", true);
            response.put("data", recetas);
            response.put("total", recetas.size());
            response.put("mensaje", "Recetas que contienen: '" + nombre + "'");
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al buscar recetas por nombre: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/categoria/{idCategoria}")
    public ResponseEntity<Map<String, Object>> obtenerRecetasPorCategoria(@PathVariable Integer idCategoria) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<Receta> recetas = recetaService.findByCategoriaId(idCategoria);
            response.put("exito", true);
            response.put("data", recetas);
            response.put("total", recetas.size());
            response.put("mensaje", "Recetas de la categoria ID: " + idCategoria);
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al obtener recetas por categoria: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}/ingredientes")
    public ResponseEntity<Map<String, Object>> obtenerIngredientesDeReceta(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<Map<String, Object>> ingredientes = recetaService.findIngredientesByRecetaId(id.intValue());
            response.put("exito", true);
            response.put("data", ingredientes);
            response.put("total", ingredientes.size());
            response.put("recetaId", id);
            response.put("mensaje", "Ingredientes de la receta ID: " + id);
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al obtener ingredientes de la receta: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/del-dia")
    public ResponseEntity<Map<String, Object>> obtenerRecetaDelDia() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Receta> receta = recetaDelDiaService.getRecetaDelDia();
            
            if (receta.isPresent()) {
                response.put("exito", true);
                // Devolver como arreglo para mantener consistencia con otros endpoints
                response.put("data", Collections.singletonList(receta.get()));
                response.put("mensaje", "Receta del día obtenida desde base de datos");
                response.put("fecha", java.time.LocalDate.now().toString());
            } else {
                response.put("exito", false);
                response.put("mensaje", "No hay recetas disponibles para el día de hoy");
            }
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al obtener receta del día: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/usuario/{usuarioId}")
    public ResponseEntity<Map<String, Object>> obtenerRecetasPorUsuario(@PathVariable Integer usuarioId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<Receta> recetas = recetaService.findByUsuarioId(usuarioId);
            response.put("exito", true);
            response.put("data", recetas);
            response.put("total", recetas.size());
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al obtener recetas por usuario: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{id}/ingredientes")
    public ResponseEntity<Map<String, Object>> agregarIngredientesAReceta(
            @PathVariable Long id,
            @RequestBody Object ingredientesPayload) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Receta> recetaOpt = recetaService.findById(id.intValue());
            
            if (recetaOpt.isPresent()) {
                Receta receta = recetaOpt.get();
                // Normalizar payload: aceptar tanto array JSON como objeto único
                java.util.List<Ingrediente> ingredientes = new java.util.ArrayList<>();
                try {
                    if (ingredientesPayload instanceof java.util.List) {
                        CollectionType listType = objectMapper.getTypeFactory().constructCollectionType(java.util.ArrayList.class, Ingrediente.class);
                        ingredientes = objectMapper.convertValue(ingredientesPayload, listType);
                    } else {
                        Ingrediente single = objectMapper.convertValue(ingredientesPayload, Ingrediente.class);
                        if (single != null) ingredientes.add(single);
                    }
                } catch (Exception ex) {
                    response.put("exito", false);
                    response.put("mensaje", "Payload inválido para ingredientes: " + ex.getMessage());
                    return ResponseEntity.badRequest().body(response);
                }

                // Establecer la relación con la receta para cada ingrediente y añadir
                for (Ingrediente ingrediente : ingredientes) {
                    ingrediente.setReceta(receta);
                    receta.getIngredientes().add(ingrediente);
                }
                
                Receta recetaActualizada = recetaService.save(receta);
                response.put("exito", true);
                response.put("mensaje", "Ingredientes agregados correctamente");
                response.put("data", recetaActualizada.getIngredientes());
                response.put("total", recetaActualizada.getIngredientes().size());
            } else {
                response.put("exito", false);
                response.put("mensaje", "Receta no encontrada");
            }
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al agregar ingredientes: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}/ingredientes")
    public ResponseEntity<Map<String, Object>> actualizarIngredientesDeReceta(
            @PathVariable Long id,
            @RequestBody Object ingredientesPayload) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Receta> recetaOpt = recetaService.findById(id.intValue());
            
            if (recetaOpt.isPresent()) {
                Receta receta = recetaOpt.get();
                // Normalizar payload: aceptar tanto array JSON como objeto único
                java.util.List<Ingrediente> ingredientes = new java.util.ArrayList<>();
                try {
                    if (ingredientesPayload instanceof java.util.List) {
                        CollectionType listType = objectMapper.getTypeFactory().constructCollectionType(java.util.ArrayList.class, Ingrediente.class);
                        ingredientes = objectMapper.convertValue(ingredientesPayload, listType);
                    } else {
                        Ingrediente single = objectMapper.convertValue(ingredientesPayload, Ingrediente.class);
                        if (single != null) ingredientes.add(single);
                    }
                } catch (Exception ex) {
                    response.put("exito", false);
                    response.put("mensaje", "Payload inválido para ingredientes: " + ex.getMessage());
                    return ResponseEntity.badRequest().body(response);
                }

                // Limpiar ingredientes existentes y añadir los nuevos
                receta.getIngredientes().clear();
                for (Ingrediente ingrediente : ingredientes) {
                    ingrediente.setReceta(receta);
                    receta.getIngredientes().add(ingrediente);
                }
                
                Receta recetaActualizada = recetaService.save(receta);
                response.put("exito", true);
                response.put("mensaje", "Ingredientes de la receta actualizados correctamente");
                response.put("data", recetaActualizada.getIngredientes());
                response.put("total", recetaActualizada.getIngredientes().size());
            } else {
                response.put("exito", false);
                response.put("mensaje", "Receta no encontrada");
            }
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al actualizar ingredientes: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{idReceta}/ingredientes/{idIngrediente}")
    public ResponseEntity<Map<String, Object>> eliminarIngredienteDeReceta(
            @PathVariable Long idReceta, 
            @PathVariable Long idIngrediente) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Receta> recetaOpt = recetaService.findById(idReceta.intValue());
            
            if (recetaOpt.isPresent()) {
                Receta receta = recetaOpt.get();
                
                // Buscar y eliminar el ingrediente específico
                boolean eliminado = receta.getIngredientes().removeIf(
                    ingrediente -> ingrediente.getIdIngrediente().equals(idIngrediente.intValue())
                );
                
                if (eliminado) {
                    Receta recetaActualizada = recetaService.save(receta);
                    response.put("exito", true);
                    response.put("mensaje", "Ingrediente eliminado correctamente de la receta");
                    response.put("ingredientesRestantes", recetaActualizada.getIngredientes().size());
                } else {
                    response.put("exito", false);
                    response.put("mensaje", "Ingrediente no encontrado en la receta");
                }
            } else {
                response.put("exito", false);
                response.put("mensaje", "Receta no encontrada");
            }
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al eliminar ingrediente: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    // ========== ENDPOINTS DE FAVORITOS ==========
    
    @GetMapping("/favoritos")
    @Operation(summary = "Obtener favoritos del usuario autenticado", description = "Retorna las recetas favoritas del usuario autenticado mediante JWT")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Favoritos obtenidos exitosamente"),
        @ApiResponse(responseCode = "401", description = "Usuario no autenticado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> obtenerFavoritos(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Integer idUsuario = getUserIdFromToken(authHeader);
            List<Favorito> favoritos;
            
            if (idUsuario != null) {
                favoritos = favoritoService.getFavoritosByUsuario(idUsuario);
            } else {
                favoritos = favoritoService.getAllFavoritos();
            }
            response.put("exito", true);
            response.put("data", favoritos);
            response.put("total", favoritos.size());
            response.put("mensaje", "Favoritos obtenidos correctamente");
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al obtener favoritos: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/favoritos")
    @Operation(summary = "Agregar a favoritos", description = "Agrega una receta a favoritos del usuario")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Agregado a favoritos exitosamente"),
        @ApiResponse(responseCode = "400", description = "Ya existe en favoritos"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> agregarFavorito(
            HttpServletRequest request,
            @RequestParam(required = false) Integer idUsuario, 
            @RequestParam(required = false) Integer idReceta) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Preferir token en header Authorization; si no se proporciona idUsuario, extraer del token
            String authHeader = request.getHeader("Authorization");
            Integer idFromToken = getUserIdFromToken(authHeader);
            if (idUsuario == null && idFromToken != null) {
                idUsuario = idFromToken;
            }
            // Aceptar variantes de nombres de parámetros (id_usr / id_receta)
            if (idUsuario == null) {
                String alt = request.getParameter("id_usr");
                if (alt != null) {
                    try { idUsuario = Integer.parseInt(alt); } catch (NumberFormatException ignore) { }
                }
            }
            if (idReceta == null) {
                String alt = request.getParameter("id_receta");
                if (alt != null) {
                    try { idReceta = Integer.parseInt(alt); } catch (NumberFormatException ignore) { }
                }
            }
            if (idUsuario == null || idReceta == null) {
                response.put("exito", false);
                response.put("mensaje", "Parámetros requeridos: idUsuario (o id_usr) y idReceta (o id_receta). Asegúrese de incluir el header Authorization con Bearer <token> si no envía idUsuario.");
                return ResponseEntity.badRequest().body(response);
            }
            // Crear favorito usando el servicio existente
            Favorito favorito = new Favorito();
            favorito.setUsuario(new Usuario(idUsuario));
            favorito.setReceta(new Receta(idReceta));
            favorito = favoritoService.save(favorito);
            response.put("exito", true);
            response.put("mensaje", "Receta agregada a favoritos");
            response.put("data", favorito);
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al agregar favorito: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/favoritos")
    @Operation(summary = "Quitar de favoritos", description = "Remueve una receta de favoritos del usuario")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Removido de favoritos exitosamente"),
        @ApiResponse(responseCode = "404", description = "Favorito no encontrado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> quitarFavorito(
            HttpServletRequest request,
            @RequestParam(required = false) Integer idUsuario, 
            @RequestParam(required = false) Integer idReceta) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Preferir token en header Authorization; si no se proporciona idUsuario, extraer del token
            String authHeader = request.getHeader("Authorization");
            Integer idFromToken = getUserIdFromToken(authHeader);
            if (idUsuario == null && idFromToken != null) {
                idUsuario = idFromToken;
            }
            // Aceptar variantes de nombres de parámetros (id_usr / id_receta)
            if (idUsuario == null) {
                String alt = request.getParameter("id_usr");
                if (alt != null) {
                    try { idUsuario = Integer.parseInt(alt); } catch (NumberFormatException ignore) { }
                }
            }
            if (idReceta == null) {
                String alt = request.getParameter("id_receta");
                if (alt != null) {
                    try { idReceta = Integer.parseInt(alt); } catch (NumberFormatException ignore) { }
                }
            }
            if (idUsuario == null || idReceta == null) {
                response.put("exito", false);
                response.put("mensaje", "Parámetros requeridos: idUsuario (o id_usr) y idReceta (o id_receta). Asegúrese de incluir el header Authorization con Bearer <token> si no envía idUsuario.");
                return ResponseEntity.badRequest().body(response);
            }
            favoritoService.deleteByRecetaAndUsuario(idReceta, idUsuario);
            response.put("exito", true);
            response.put("mensaje", "Receta removida de favoritos");
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al quitar favorito: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/favoritos/count/{idReceta}")
    @Operation(summary = "Contar favoritos de receta", description = "Obtiene el número total de favoritos de una receta")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Conteo obtenido exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> contarFavoritos(
            @Parameter(description = "ID de la receta", required = true) @PathVariable Long idReceta) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Long count = favoritoService.countByReceta(idReceta.intValue());
            response.put("exito", true);
            response.put("count", count);
            response.put("mensaje", "Conteo de favoritos obtenido");
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al contar favoritos: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    // ========== ENDPOINTS DE ME GUSTA ==========
    
    @GetMapping("/megusta")
    @Operation(summary = "Obtener me gusta del usuario autenticado", description = "Retorna las recetas que le gustan al usuario autenticado mediante JWT")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Me gusta obtenidos exitosamente"),
        @ApiResponse(responseCode = "401", description = "Usuario no autenticado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> obtenerMeGusta(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Integer idUsuario = getUserIdFromToken(authHeader);
            List<MeGusta> meGustas;
            
            if (idUsuario != null) {
                meGustas = meGustaService.getMeGustasByUsuario(idUsuario);
            } else {
                meGustas = meGustaService.getAllMeGusta();
            }
            response.put("exito", true);
            response.put("data", meGustas);
            response.put("total", meGustas.size());
            response.put("mensaje", "Me gusta obtenidos correctamente");
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al obtener me gusta: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/megusta")
    @Operation(summary = "Dar me gusta", description = "Agrega un me gusta a una receta")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Me gusta agregado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Ya tiene me gusta"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> darMeGusta(
            HttpServletRequest request,
            @RequestParam(required = false) Integer idUsuario, 
            @RequestParam(required = false) Integer idReceta) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            logger.info("POST /recetas/megusta called - query='{}' AuthorizationPresent='{}'", request.getQueryString(), request.getHeader("Authorization") != null ? "yes" : "no");
            // Preferir token en header Authorization; si no se proporciona idUsuario, extraer del token
            String authHeader = request.getHeader("Authorization");
            Integer idFromToken = getUserIdFromToken(authHeader);
            // Si idUsuario no fue entregado por params, intentar usar id desde token
            if (idUsuario == null && idFromToken != null) {
                idUsuario = idFromToken;
            }
            // Si se entregó idUsuario y también hay token, validar que coincidan
            if (idUsuario != null && idFromToken != null && !idUsuario.equals(idFromToken)) {
                response.put("exito", false);
                response.put("mensaje", "Token no corresponde al idUsuario proporcionado");
                return ResponseEntity.status(403).body(response);
            }
            // Aceptar variantes de nombres de parámetros (compatibilidad con scripts/frontend)
            if (idUsuario == null) {
                String alt = request.getParameter("id_usr");
                if (alt != null) {
                    try {
                        idUsuario = Integer.parseInt(alt);
                    } catch (NumberFormatException nfe) {
                        // ignore, handled below
                    }
                }
            }
            if (idReceta == null) {
                String alt = request.getParameter("id_receta");
                if (alt != null) {
                    try {
                        idReceta = Integer.parseInt(alt);
                    } catch (NumberFormatException nfe) {
                        // ignore, handled below
                    }
                }
            }
            if (idUsuario == null || idReceta == null) {
                response.put("exito", false);
                response.put("mensaje", "Parámetros requeridos: idUsuario (o id_usr) y idReceta (o id_receta). Asegúrese de incluir el header Authorization con Bearer <token> si no envía idUsuario.");
                return ResponseEntity.badRequest().body(response);
            }
            // Crear meGusta usando el servicio existente
            MeGusta meGusta = new MeGusta();
            meGusta.setUsuario(new Usuario(idUsuario));
            meGusta.setReceta(new Receta(idReceta));
            meGusta = meGustaService.save(meGusta);
            response.put("exito", true);
            response.put("mensaje", "Me gusta agregado");
            response.put("data", meGusta);
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al dar me gusta: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/megusta")
    @Operation(summary = "Quitar me gusta", description = "Remueve un me gusta de una receta")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Me gusta removido exitosamente"),
        @ApiResponse(responseCode = "404", description = "Me gusta no encontrado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> quitarMeGusta(
            HttpServletRequest request,
            @RequestParam(required = false) Integer idUsuario, 
            @RequestParam(required = false) Integer idReceta) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Preferir token en header Authorization; si no se proporciona idUsuario, extraer del token
            String authHeader = request.getHeader("Authorization");
            logger.info("DELETE /recetas/megusta called - query='{}' AuthorizationPresent='{}'", request.getQueryString(), request.getHeader("Authorization") != null ? "yes" : "no");
            Integer idFromToken = getUserIdFromToken(authHeader);
            if (idUsuario == null && idFromToken != null) {
                idUsuario = idFromToken;
            }
            // Si se entregó idUsuario y también hay token, validar que coincidan
            if (idUsuario != null && idFromToken != null && !idUsuario.equals(idFromToken)) {
                response.put("exito", false);
                response.put("mensaje", "Token no corresponde al idUsuario proporcionado");
                return ResponseEntity.status(403).body(response);
            }
            // Aceptar variantes de nombres de parámetros (compatibilidad con scripts/frontend)
            if (idUsuario == null) {
                String alt = request.getParameter("id_usr");
                if (alt != null) {
                    try {
                        idUsuario = Integer.parseInt(alt);
                    } catch (NumberFormatException nfe) {
                        // ignore, handled below
                    }
                }
            }
            if (idReceta == null) {
                String alt = request.getParameter("id_receta");
                if (alt != null) {
                    try {
                        idReceta = Integer.parseInt(alt);
                    } catch (NumberFormatException nfe) {
                        // ignore, handled below
                    }
                }
            }
            if (idUsuario == null || idReceta == null) {
                response.put("exito", false);
                response.put("mensaje", "Parámetros requeridos: idUsuario (o id_usr) y idReceta (o id_receta). Asegúrese de incluir el header Authorization con Bearer <token> si no envía idUsuario.");
                return ResponseEntity.badRequest().body(response);
            }
            meGustaService.deleteByRecetaAndUsuarioTransactional(idReceta, idUsuario);
            response.put("exito", true);
            response.put("mensaje", "Me gusta removido");
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al quitar me gusta: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/megustas/count/{idReceta}")
    @Operation(summary = "Contar me gusta de receta", description = "Obtiene el número total de me gusta de una receta")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Conteo obtenido exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> contarMeGustas(
            @Parameter(description = "ID de la receta", required = true) @PathVariable Long idReceta) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Long count = meGustaService.countByReceta(idReceta.intValue());
            response.put("exito", true);
            response.put("count", count);
            response.put("mensaje", "Conteo de me gusta obtenido");
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al contar me gusta: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    // ========== ENDPOINTS DE ESTRELLAS ==========
    
    @GetMapping("/estrellas")
    @Operation(summary = "Obtener calificaciones del usuario autenticado", description = "Retorna las calificaciones (estrellas) dadas por el usuario autenticado mediante JWT")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Calificaciones obtenidas exitosamente"),
        @ApiResponse(responseCode = "401", description = "Usuario no autenticado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> obtenerEstrellas(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Integer idUsuario = getUserIdFromToken(authHeader);
            List<Estrella> estrellas;
            
            if (idUsuario != null) {
                estrellas = estrellaService.getEstrellasByUsuario(idUsuario);
            } else {
                estrellas = estrellaService.getAllEstrellas();
            }
            response.put("exito", true);
            response.put("data", estrellas);
            response.put("total", estrellas.size());
            response.put("mensaje", "Calificaciones obtenidas correctamente");
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al obtener calificaciones: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/estrellas")
    @Operation(summary = "Calificar receta", description = "Agrega o actualiza la calificación (1-5 estrellas) de una receta")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Calificación agregada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Valor de estrellas inválido"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> calificarReceta(
            HttpServletRequest request,
            @RequestParam(required = false) Integer idUsuario,
            @RequestParam(required = false) Integer id_usr,    // Soporte alias
            @RequestParam(required = false) Integer idReceta,
            @RequestParam(required = false) Integer id_receta, // Soporte alias
            @RequestParam Short estrellas) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            logger.info("⭐ POST /estrellas - Datos recibidos: idUsuario={}, id_usr={}, idReceta={}, id_receta={}, estrellas={}", 
                       idUsuario, id_usr, idReceta, id_receta, estrellas);
            
            // Extraer token y usuario
            String authHeader = request.getHeader("Authorization");
            logger.info("🔑 Authorization header presente: {}", authHeader != null ? "SI" : "NO");
            
            Integer idFromToken = getUserIdFromToken(authHeader);
            logger.info("👤 Usuario extraído del token: {}", idFromToken);
            
            // Normalizar parámetros
            if (idUsuario == null && id_usr != null) { idUsuario = id_usr; }
            if (idUsuario == null && idFromToken != null) { idUsuario = idFromToken; }
            
            if (idReceta == null && id_receta != null) { idReceta = id_receta; }
            
            logger.info("🎯 Parámetros finales: idUsuario={}, idReceta={}", idUsuario, idReceta);
            
            // Validaciones con mensajes específicos
            if (estrellas == null || estrellas < 1 || estrellas > 5) {
                response.put("exito", false);
                response.put("mensaje", "Las estrellas deben ser entre 1 y 5");
                response.put("codigo", "ESTRELLAS_INVALIDAS");
                return ResponseEntity.badRequest().body(response);
            }
            
            if (idReceta == null) {
                response.put("exito", false);
                response.put("mensaje", "Parámetro id_receta es requerido");
                response.put("codigo", "ID_RECETA_FALTANTE");
                return ResponseEntity.badRequest().body(response);
            }
            
            if (idUsuario == null) {
                response.put("exito", false);
                response.put("mensaje", "No se pudo obtener el ID de usuario. Verifique que el token JWT sea válido.");
                response.put("codigo", "ID_USUARIO_FALTANTE");
                response.put("debug", "Asegúrese de enviar el header: Authorization: Bearer <token>");
                return ResponseEntity.badRequest().body(response);
            }
            
            // Validar coherencia token vs parámetro (si ambos están presentes)
            if (idFromToken != null && idUsuario != null && !idUsuario.equals(idFromToken)) {
                response.put("exito", false);
                response.put("mensaje", "El token no corresponde al usuario especificado");
                response.put("codigo", "TOKEN_USUARIO_MISMATCH");
                return ResponseEntity.status(403).body(response);
            }

            // Upsert: verificar si ya existe calificación
            Optional<Estrella> existing = estrellaService.getEstrellaByUsuarioAndReceta(idUsuario, idReceta);
            Estrella estrella;
            boolean isUpdate = false;
            
            if (existing.isPresent()) {
                estrella = existing.get();
                estrella.setValor(estrellas);
                isUpdate = true;
                logger.info("🔄 Actualizando calificación existente: ID={}", estrella.getIdEstrella());
            } else {
                estrella = new Estrella();
                estrella.setUsuario(new Usuario(idUsuario));
                estrella.setReceta(new Receta(idReceta));
                estrella.setValor(estrellas);
                logger.info("🆕 Creando nueva calificación");
            }
            
            estrella = estrellaService.save(estrella);
            logger.info("✅ Calificación {} exitosamente: ID={}", isUpdate ? "actualizada" : "creada", estrella.getIdEstrella());
            
            // Respuesta estructurada
            Map<String, Object> data = new HashMap<>();
            data.put("idEstrella", estrella.getIdEstrella());
            data.put("estrellas", estrella.getValor());
            
            Map<String, Object> recetaData = new HashMap<>();
            recetaData.put("idReceta", idReceta);
            data.put("receta", recetaData);
            
            Map<String, Object> usuarioData = new HashMap<>();
            usuarioData.put("idUsr", idUsuario);
            data.put("usuario", usuarioData);
            
            response.put("exito", true);
            response.put("mensaje", isUpdate ? "Calificación actualizada exitosamente" : "Calificación agregada exitosamente");
            response.put("data", data);
            
        } catch (Exception e) {
            logger.error("❌ Error al calificar receta", e);
            response.put("exito", false);
            response.put("mensaje", "Error interno al calificar receta: " + e.getMessage());
            response.put("codigo", "ERROR_INTERNO");
        }
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/estrellas/stats/{idReceta}")
    @Operation(summary = "Estadísticas de calificación", description = "Obtiene el promedio y total de calificaciones de una receta")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Estadísticas obtenidas exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> obtenerEstadisticasEstrellas(
            @Parameter(description = "ID de la receta", required = true) @PathVariable Long idReceta) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Usar servicios reales para estadísticas
            Map<String, Object> stats = new HashMap<>();
            Double promedio = estrellaService.avgByReceta(idReceta.intValue());
            Long total = estrellaService.countByReceta(idReceta.intValue());
            stats.put("promedio", promedio != null ? promedio : 0.0);
            stats.put("total", total != null ? total : 0);
            response.put("exito", true);
            response.put("data", stats);
            response.put("mensaje", "Estadísticas obtenidas correctamente");
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al obtener estadísticas: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    // ========== ENDPOINTS DE COMENTARIOS ==========
    
    @GetMapping("/comentarios")
    @Operation(summary = "Obtener comentarios", description = "Retorna los comentarios de un usuario o todos los comentarios")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Comentarios obtenidos exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> obtenerComentarios(@RequestParam(required = false) Integer idUsuario) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<Comentario> comentarios;
            if (idUsuario != null) {
                // Obtener comentarios por usuario (método a implementar)
                comentarios = comentarioService.getComentariosByUsuario(idUsuario);
            } else {
                // Obtener todos los comentarios (método a implementar)
                comentarios = comentarioService.getAllComentarios();
            }
            
            response.put("exito", true);
            // sanitize comentarios: only include idComentario, texto, fechaCreacion, receta{idReceta,idUsr}, usuario{idUsr}
            java.util.List<java.util.Map<String,Object>> out = new java.util.ArrayList<>();
            for (Comentario c : comentarios) {
                java.util.Map<String,Object> m = new java.util.HashMap<>();
                m.put("idComentario", c.getIdComentario());
                m.put("texto", c.getTexto());
                m.put("fechaCreacion", c.getFechaCreacion());
                java.util.Map<String,Object> r = new java.util.HashMap<>();
                if (c.getReceta() != null) { r.put("idReceta", c.getReceta().getIdReceta()); r.put("idUsr", c.getReceta().getIdUsr()); }
                m.put("receta", r);
                java.util.Map<String,Object> u = new java.util.HashMap<>();
                if (c.getUsuario() != null) { u.put("idUsr", c.getUsuario().getIdUsr()); }
                m.put("usuario", u);
            
                out.add(m);
            }
            response.put("data", out);
            response.put("total", comentarios.size());
            response.put("mensaje", "Comentarios obtenidos correctamente");
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al obtener comentarios: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/comentarios/receta/{id}")
    @Operation(summary = "Obtener comentarios de receta", description = "Retorna todos los comentarios de una receta específica")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Comentarios obtenidos exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> obtenerComentariosPorReceta(
            @Parameter(description = "ID de la receta", required = true) @PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Usar servicio real
            List<Comentario> comentarios = comentarioService.getComentariosByReceta(id.intValue());
            response.put("exito", true);
            java.util.List<java.util.Map<String,Object>> out = new java.util.ArrayList<>();
            for (Comentario c : comentarios) {
                java.util.Map<String,Object> m = new java.util.HashMap<>();
                m.put("idComentario", c.getIdComentario());
                m.put("texto", c.getTexto());
                m.put("fechaCreacion", c.getFechaCreacion());
                java.util.Map<String,Object> r = new java.util.HashMap<>();
                if (c.getReceta() != null) { r.put("idReceta", c.getReceta().getIdReceta()); r.put("idUsr", c.getReceta().getIdUsr()); }
                m.put("receta", r);
                java.util.Map<String,Object> u = new java.util.HashMap<>();
                if (c.getUsuario() != null) { u.put("idUsr", c.getUsuario().getIdUsr()); }
                m.put("usuario", u);
                out.add(m);
            }
            response.put("data", out);
            response.put("total", comentarios.size());
            response.put("mensaje", "Comentarios de la receta obtenidos correctamente");
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al obtener comentarios: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/comentarios")
    @Operation(summary = "Agregar comentario", description = "Agrega un nuevo comentario a una receta")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Comentario agregado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> agregarComentario(
            HttpServletRequest request,
            @RequestParam(required = false) Integer idUsuario, 
            @RequestParam(required = false) Integer idReceta,
            @RequestParam(required = false) Integer id_receta, // Soporte alias
            @RequestParam(required = false) Integer id_usr,    // Soporte alias
            @RequestParam(required = false) String texto) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            logger.info("📝 POST /comentarios - Datos recibidos: idUsuario={}, idReceta={}, id_receta={}, id_usr={}, texto={}", 
                       idUsuario, idReceta, id_receta, id_usr, texto != null ? "presente" : "null");
            
            // Extraer token y usuario
            String authHeader = request.getHeader("Authorization");
            logger.info("🔑 Authorization header presente: {}", authHeader != null ? "SI" : "NO");
            
            Integer idFromToken = getUserIdFromToken(authHeader);
            logger.info("👤 Usuario extraído del token: {}", idFromToken);
            
            // Normalizar parámetros (soportar ambos formatos)
            if (idUsuario == null && id_usr != null) { idUsuario = id_usr; }
            if (idUsuario == null && idFromToken != null) { idUsuario = idFromToken; }
            
            if (idReceta == null && id_receta != null) { idReceta = id_receta; }
            
            logger.info("🎯 Parámetros finales: idUsuario={}, idReceta={}", idUsuario, idReceta);
            
            // Validaciones con mensajes específicos
            if (texto == null || texto.trim().isEmpty()) {
                response.put("exito", false);
                response.put("mensaje", "El texto del comentario no puede estar vacío");
                response.put("codigo", "TEXTO_VACIO");
                return ResponseEntity.badRequest().body(response);
            }
            
            if (idReceta == null) {
                response.put("exito", false);
                response.put("mensaje", "Parámetro id_receta es requerido");
                response.put("codigo", "ID_RECETA_FALTANTE");
                return ResponseEntity.badRequest().body(response);
            }
            
            if (idUsuario == null) {
                response.put("exito", false);
                response.put("mensaje", "No se pudo obtener el ID de usuario. Verifique que el token JWT sea válido.");
                response.put("codigo", "ID_USUARIO_FALTANTE");
                response.put("debug", "Asegúrese de enviar el header: Authorization: Bearer <token>");
                return ResponseEntity.badRequest().body(response);
            }

            // Crear y guardar comentario
            Comentario comentario = new Comentario();
            comentario.setUsuario(new Usuario(idUsuario));
            comentario.setReceta(new Receta(idReceta));
            comentario.setTexto(texto.trim());
            
            comentario = comentarioService.save(comentario);
            logger.info("✅ Comentario creado exitosamente: ID={}", comentario.getIdComentario());
            
            // Respuesta estructurada
            Map<String, Object> data = new HashMap<>();
            data.put("idComentario", comentario.getIdComentario());
            data.put("texto", comentario.getTexto());
            data.put("fechaCreacion", comentario.getFechaCreacion());
            
            Map<String, Object> recetaData = new HashMap<>();
            recetaData.put("idReceta", idReceta);
            data.put("receta", recetaData);
            
            Map<String, Object> usuarioData = new HashMap<>();
            usuarioData.put("idUsr", idUsuario);
            data.put("usuario", usuarioData);
            
            response.put("exito", true);
            response.put("mensaje", "Comentario agregado exitosamente");
            response.put("data", data);
            
        } catch (Exception e) {
            logger.error("❌ Error al crear comentario", e);
            response.put("exito", false);
            response.put("mensaje", "Error interno al agregar comentario: " + e.getMessage());
            response.put("codigo", "ERROR_INTERNO");
        }
        
        return ResponseEntity.ok(response);
    }

    // ========== OPERACIONES CRUD ADICIONALES ==========

    // UPDATE - Actualizar comentario
    @PutMapping("/comentarios/{id}")
    @Operation(summary = "Actualizar comentario", description = "Actualiza el texto de un comentario existente")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Comentario actualizado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Comentario no encontrado"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> actualizarComentario(
            @Parameter(description = "ID del comentario", required = true) @PathVariable Integer id,
            @RequestParam(required = false) String texto,
            @RequestBody(required = false) Map<String,Object> body) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Comentario> comentarioOpt = comentarioService.getComentarioById(id);
            if (!comentarioOpt.isPresent()) {
                response.put("exito", false);
                response.put("mensaje", "Comentario no encontrado con ID: " + id);
                return ResponseEntity.ok(response);
            }
            
            // texto puede venir por query param o por body JSON { "texto": "..." }
            String effectiveTexto = texto;
            if ((effectiveTexto == null || effectiveTexto.trim().isEmpty()) && body != null && body.get("texto") != null) {
                effectiveTexto = String.valueOf(body.get("texto"));
            }
            if (effectiveTexto == null || effectiveTexto.trim().isEmpty()) {
                response.put("exito", false);
                response.put("mensaje", "El texto del comentario no puede estar vacío");
                return ResponseEntity.ok(response);
            }

            Comentario comentario = comentarioOpt.get();
            comentario.setTexto(effectiveTexto.trim());
            comentario = comentarioService.save(comentario);
            
            response.put("exito", true);
            response.put("mensaje", "Comentario actualizado correctamente");
            // sanitize updated comentario
            java.util.Map<String,Object> m = new java.util.HashMap<>();
            m.put("idComentario", comentario.getIdComentario());
            m.put("texto", comentario.getTexto());
            m.put("fechaCreacion", comentario.getFechaCreacion());
            java.util.Map<String,Object> r = new java.util.HashMap<>();
            if (comentario.getReceta() != null) { r.put("idReceta", comentario.getReceta().getIdReceta()); r.put("idUsr", comentario.getReceta().getIdUsr()); }
            m.put("receta", r);
            java.util.Map<String,Object> u = new java.util.HashMap<>();
            if (comentario.getUsuario() != null) { u.put("idUsr", comentario.getUsuario().getIdUsr()); }
            m.put("usuario", u);
            response.put("data", m);
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al actualizar comentario: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    // DELETE - Eliminar comentario
    @DeleteMapping("/comentarios/{id}")
    @Operation(summary = "Eliminar comentario", description = "Elimina un comentario por su ID")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Comentario eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Comentario no encontrado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> eliminarComentario(
            @Parameter(description = "ID del comentario", required = true) @PathVariable Integer id) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Comentario> comentario = comentarioService.getComentarioById(id);
            if (!comentario.isPresent()) {
                response.put("exito", false);
                response.put("mensaje", "Comentario no encontrado con ID: " + id);
                return ResponseEntity.ok(response);
            }
            
            comentarioService.delete(id);
            response.put("exito", true);
            response.put("mensaje", "Comentario eliminado correctamente");
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al eliminar comentario: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    // UPDATE - Actualizar calificación de estrella
    @PutMapping("/estrellas/{id}")
    @Operation(summary = "Actualizar calificación", description = "Actualiza la calificación (estrellas) existente")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Calificación actualizada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Calificación no encontrada"),
        @ApiResponse(responseCode = "400", description = "Valor de estrellas inválido"),
        @ApiResponse(responseCode = "403", description = "No autorizado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> actualizarEstrella(
            @Parameter(description = "ID de la calificación", required = true) @PathVariable Integer id,
            @RequestParam Short estrellas) {
        
        logger.info("🔄 PUT /estrellas/{} - Actualizando calificación", id);
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Obtener Authorization header
            String authHeader = null;
            try {
                authHeader = ((jakarta.servlet.http.HttpServletRequest) org.springframework.web.context.request.RequestContextHolder
                    .currentRequestAttributes().resolveReference(org.springframework.web.context.request.RequestAttributes.REFERENCE_REQUEST))
                    .getHeader("Authorization");
                logger.info("🔑 Token recibido: {}", authHeader != null ? "Sí" : "No");
            } catch (Exception ignore) {
                logger.warn("⚠️ No se pudo obtener el header Authorization del contexto");
            }

            // Validar token
            Integer idFromToken = getUserIdFromToken(authHeader);
            if (idFromToken == null) {
                logger.warn("🚫 Token JWT inválido o missing");
                response.put("success", false);
                response.put("error", "Missing Bearer token");
                response.put("codigo", "AUTH_001");
                return ResponseEntity.status(401).body(response);
            }

            logger.info("👤 Usuario autenticado: {}", idFromToken);
            logger.info("🎯 Parámetros: id={}, estrellas={}", id, estrellas);
            
            // Validar rango de estrellas
            if (estrellas < 1 || estrellas > 5) {
                logger.warn("❌ Valor de estrellas inválido: {}", estrellas);
                response.put("exito", false);
                response.put("mensaje", "Las estrellas deben ser entre 1 y 5");
                response.put("codigo", "INVALID_STARS_RANGE");
                return ResponseEntity.badRequest().body(response);
            }
            
            // Verificar que la calificación existe
            Optional<Estrella> estrellaOpt = estrellaService.getEstrellaById(id);
            if (!estrellaOpt.isPresent()) {
                logger.warn("❌ Calificación no encontrada: ID={}", id);
                response.put("exito", false);
                response.put("mensaje", "Calificación no encontrada con ID: " + id);
                response.put("codigo", "RATING_NOT_FOUND");
                return ResponseEntity.status(404).body(response);
            }
            
            Estrella estrella = estrellaOpt.get();
            logger.info("📝 Calificación encontrada - Owner: {}, Receta: {}, Valor actual: {}", 
                estrella.getUsuario().getIdUsr(), estrella.getReceta().getIdReceta(), estrella.getValor());

            // Verificar ownership: solo el usuario dueño puede actualizar
            if (!idFromToken.equals(estrella.getUsuario().getIdUsr())) {
                logger.warn("🚫 Usuario {} no autorizado para modificar calificación del usuario {}", 
                    idFromToken, estrella.getUsuario().getIdUsr());
                response.put("exito", false);
                response.put("mensaje", "No autorizado para actualizar esta calificación");
                response.put("codigo", "UNAUTHORIZED_UPDATE");
                return ResponseEntity.status(403).body(response);
            }

            // Actualizar valor
            Short valorAnterior = estrella.getValor();
            estrella.setValor(estrellas);
            estrella = estrellaService.save(estrella);
            
            logger.info("✅ Calificación actualizada exitosamente: ID={}, {} -> {}", 
                id, valorAnterior, estrellas);
            
            // Respuesta estructurada
            Map<String, Object> data = new HashMap<>();
            data.put("idEstrella", estrella.getIdEstrella());
            data.put("estrellas", estrella.getValor());
            
            Map<String, Object> recetaData = new HashMap<>();
            recetaData.put("idReceta", estrella.getReceta().getIdReceta());
            data.put("receta", recetaData);
            
            Map<String, Object> usuarioData = new HashMap<>();
            usuarioData.put("idUsr", estrella.getUsuario().getIdUsr());
            data.put("usuario", usuarioData);
            
            if (estrella.getFechaCreacion() != null) {
                data.put("fechaCreacion", estrella.getFechaCreacion());
            }
            
            response.put("exito", true);
            response.put("mensaje", "Calificación actualizada exitosamente");
            response.put("data", data);
            
        } catch (Exception e) {
            logger.error("❌ Error al actualizar calificación ID={}: {}", id, e.getMessage(), e);
            response.put("exito", false);
            response.put("mensaje", "Error interno al actualizar calificación: " + e.getMessage());
            response.put("codigo", "ERROR_INTERNO");
        }
        
        return ResponseEntity.ok(response);
    }

    // DELETE - Eliminar calificación de estrella
    @DeleteMapping("/estrellas/{id}")
    @Operation(summary = "Eliminar calificación", description = "Elimina una calificación (estrella) por su ID")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Calificación eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Calificación no encontrada"),
        @ApiResponse(responseCode = "403", description = "No autorizado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> eliminarEstrella(
            @Parameter(description = "ID de la calificación", required = true) @PathVariable Integer id) {
        
        logger.info("🗑️ DELETE /estrellas/{} - Eliminando calificación", id);
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Obtener Authorization header
            String authHeader = null;
            try {
                authHeader = ((jakarta.servlet.http.HttpServletRequest) org.springframework.web.context.request.RequestContextHolder
                    .currentRequestAttributes().resolveReference(org.springframework.web.context.request.RequestAttributes.REFERENCE_REQUEST))
                    .getHeader("Authorization");
                logger.info("🔑 Token recibido: {}", authHeader != null ? "Sí" : "No");
            } catch (Exception ignore) {
                logger.warn("⚠️ No se pudo obtener el header Authorization del contexto");
            }

            // Validar token
            Integer idFromToken = getUserIdFromToken(authHeader);
            if (idFromToken == null) {
                logger.warn("🚫 Token JWT inválido o missing");
                response.put("success", false);
                response.put("error", "Missing Bearer token");
                response.put("codigo", "AUTH_001");
                return ResponseEntity.status(401).body(response);
            }

            logger.info("👤 Usuario autenticado: {}", idFromToken);
            logger.info("🎯 Parámetros: id={}", id);
            
            // Verificar que la calificación existe
            Optional<Estrella> estrellaOpt = estrellaService.getEstrellaById(id);
            if (!estrellaOpt.isPresent()) {
                logger.warn("❌ Calificación no encontrada: ID={}", id);
                response.put("exito", false);
                response.put("mensaje", "Calificación no encontrada con ID: " + id);
                response.put("codigo", "RATING_NOT_FOUND");
                return ResponseEntity.status(404).body(response);
            }
            
            Estrella estrella = estrellaOpt.get();
            logger.info("📝 Calificación encontrada - Owner: {}, Receta: {}, Valor: {}", 
                estrella.getUsuario().getIdUsr(), estrella.getReceta().getIdReceta(), estrella.getValor());

            // Verificar ownership: solo el usuario dueño puede eliminar
            if (!idFromToken.equals(estrella.getUsuario().getIdUsr())) {
                logger.warn("🚫 Usuario {} no autorizado para eliminar calificación del usuario {}", 
                    idFromToken, estrella.getUsuario().getIdUsr());
                response.put("exito", false);
                response.put("mensaje", "No autorizado para eliminar esta calificación");
                response.put("codigo", "UNAUTHORIZED_DELETE");
                return ResponseEntity.status(403).body(response);
            }

            // Datos de la calificación antes de eliminar (para el response)
            Map<String, Object> deletedData = new HashMap<>();
            deletedData.put("idEstrella", estrella.getIdEstrella());
            deletedData.put("estrellas", estrella.getValor());
            
            Map<String, Object> recetaData = new HashMap<>();
            recetaData.put("idReceta", estrella.getReceta().getIdReceta());
            deletedData.put("receta", recetaData);
            
            Map<String, Object> usuarioData = new HashMap<>();
            usuarioData.put("idUsr", estrella.getUsuario().getIdUsr());
            deletedData.put("usuario", usuarioData);

            // Eliminar calificación
            estrellaService.delete(id);
            
            logger.info("✅ Calificación eliminada exitosamente: ID={}", id);
            
            response.put("exito", true);
            response.put("mensaje", "Calificación eliminada exitosamente");
            response.put("data", deletedData);
            
        } catch (Exception e) {
            logger.error("❌ Error al eliminar calificación ID={}: {}", id, e.getMessage(), e);
            response.put("exito", false);
            response.put("mensaje", "Error interno al eliminar calificación: " + e.getMessage());
            response.put("codigo", "ERROR_INTERNO");
        }
        
        return ResponseEntity.ok(response);
    }

    // UPDATE - Actualizar favorito (cambiar receta favorita)
    @PutMapping("/favoritos/{id}")
    @Operation(summary = "Actualizar favorito", description = "Actualiza la receta de un favorito existente")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Favorito actualizado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Favorito no encontrado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> actualizarFavorito(
            @Parameter(description = "ID del favorito", required = true) @PathVariable Integer id,
            @RequestParam Integer nuevaIdReceta) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Favorito> favoritoOpt = favoritoService.getFavoritoById(id);
            if (!favoritoOpt.isPresent()) {
                response.put("exito", false);
                response.put("mensaje", "Favorito no encontrado con ID: " + id);
                return ResponseEntity.ok(response);
            }
            
            Favorito favorito = favoritoOpt.get();
            favorito.setReceta(new Receta(nuevaIdReceta));
            favorito = favoritoService.save(favorito);
            
            response.put("exito", true);
            response.put("mensaje", "Favorito actualizado correctamente");
            response.put("data", favorito);
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al actualizar favorito: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }

    // UPDATE - Actualizar me gusta
    @PutMapping("/megusta/{id}")
    @Operation(summary = "Actualizar me gusta", description = "Actualiza la receta de un me gusta existente")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Me gusta actualizado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Me gusta no encontrado"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor")
    })
    public ResponseEntity<Map<String, Object>> actualizarMeGusta(
            @Parameter(description = "ID del me gusta", required = true) @PathVariable Integer id,
            @RequestParam Integer nuevaIdReceta) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<MeGusta> meGustaOpt = meGustaService.getMeGustaById(id);
            if (!meGustaOpt.isPresent()) {
                response.put("exito", false);
                response.put("mensaje", "Me gusta no encontrado con ID: " + id);
                return ResponseEntity.ok(response);
            }
            
            MeGusta meGusta = meGustaOpt.get();
            meGusta.setReceta(new Receta(nuevaIdReceta));
            meGusta = meGustaService.save(meGusta);
            
            response.put("exito", true);
            response.put("mensaje", "Me gusta actualizado correctamente");
            response.put("data", meGusta);
        } catch (Exception e) {
            response.put("exito", false);
            response.put("mensaje", "Error al actualizar me gusta: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
}
