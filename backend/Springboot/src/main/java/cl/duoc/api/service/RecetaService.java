package cl.duoc.api.service;

import cl.duoc.api.model.entities.Receta;
import cl.duoc.api.model.entities.Ingrediente;
import cl.duoc.api.model.repositories.RecetaRepository;
import cl.duoc.api.service.IngredienteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.HashMap;
import java.util.ArrayList;

@Service
public class RecetaService {

    @Autowired
    private RecetaRepository recetaRepository;
    
    @Autowired
    private IngredienteService ingredienteService;

    public List<Receta> getAllRecetas() {
        return recetaRepository.findAll();
    }

    public List<Receta> getActiveRecetas() {
        return recetaRepository.findActiveRecetas();
    }

    public Optional<Receta> getRecetaById(Integer id) {
        return recetaRepository.findById(id);
    }

    public Optional<Receta> getRecetaByNombre(String nombre) {
        // primero intentamos match exacto
        Optional<Receta> exact = recetaRepository.findByNombre(nombre);
        if (exact.isPresent()) return exact;

        // luego búsqueda parcial case-insensitive
        List<Receta> matches = recetaRepository.findByNombreContainingIgnoreCase(nombre);
        if (matches != null && !matches.isEmpty()) {
            return Optional.of(matches.get(0));
        }
        return Optional.empty();
    }

    // Nuevo: devolver lista de coincidencias (puede estar vacía)
    public List<Receta> getRecetasByNombre(String nombre) {
        // si nombre es nulo o vacío devolver lista vacía
        if (nombre == null || nombre.trim().isEmpty()) return java.util.Collections.emptyList();

        // primero intentar exact match incluido en la lista
        List<Receta> result = new java.util.ArrayList<>();
        Optional<Receta> exact = recetaRepository.findByNombre(nombre);
        exact.ifPresent(result::add);

        // añadir coincidencias parciales que no dupliquen el exact match
        List<Receta> partials = recetaRepository.findByNombreContainingIgnoreCase(nombre);
        if (partials != null) {
            for (Receta r : partials) {
                if (!result.stream().anyMatch(x -> x.getIdReceta().equals(r.getIdReceta()))) {
                    result.add(r);
                }
            }
        }
        return result;
    }

    public List<Receta> getRecetasByUsuario(Integer idUsr) {
        return recetaRepository.findByIdUsr(idUsr);
    }

    public List<Receta> getRecetasByCategoria(Integer idCat) {
        List<Receta> recetas = recetaRepository.findActiveRecetasByCategoria(idCat);
        if (recetas == null || recetas.isEmpty()) {
            // fallback: return any recetas with that category even if estado != 1
            recetas = recetaRepository.findByIdCat(idCat);
        }
        return recetas;
    }

    public List<Receta> getRecetasByPais(Integer idPais) {
        return recetaRepository.findActiveRecetasByPais(idPais);
    }

    public Receta saveReceta(Receta receta) {
        return recetaRepository.save(receta);
    }
    
    public java.util.List<Receta> findTopByVisitas(int limit) {
        return recetaRepository.findTopByVisitasDesc(limit);
    }

    public java.util.List<Receta> findTopByLikes(int limit) {
        return recetaRepository.findTopByLikesDesc(limit);
    }

    public void deleteReceta(Integer id) {
        recetaRepository.deleteById(id);
    }

    public boolean existsById(Integer id) {
        return recetaRepository.existsById(id);
    }

    // ==================== NUEVOS MÉTODOS PARA ENDPOINTS SOLICITADOS ====================

    // Métodos que necesita el controlador (compatibilidad)
    public List<Receta> findAll() {
        return getAllRecetas();
    }

    public Optional<Receta> findById(Integer id) {
        return getRecetaById(id);
    }

    public Receta save(Receta receta) {
        return saveReceta(receta);
    }

    public void deleteById(Integer id) {
        deleteReceta(id);
    }

    public List<Receta> findByUsuarioId(Integer usuarioId) {
        return getRecetasByUsuario(usuarioId);
    }

    public List<Receta> findByCategoriaId(Integer categoriaId) {
        return getRecetasByCategoria(categoriaId);
    }

    public List<Receta> findByPaisId(Integer paisId) {
        return getRecetasByPais(paisId);
    }

    public List<Receta> findByNombreContaining(String nombre) {
        return getRecetasByNombre(nombre);
    }

    // Top 8 recetas para carrusel - ordenadas por estrellas y me gustas
    public List<Receta> findTop8ByEstrellasMeGusta() {
        // Por ahora usando findTopByLikes, se puede mejorar con query personalizada
        return recetaRepository.findTopByLikesDesc(8);
    }

    // Recetas trending (populares últimos 30 días)
    public List<Receta> findTrendingRecetas() {
        // Por ahora retornamos las más visitadas
        return findTopByVisitas(10);
    }

    // Ingredientes de una receta específica
    public List<java.util.Map<String, Object>> findIngredientesByRecetaId(Integer recetaId) {
        try {
            List<Ingrediente> ingredientes = ingredienteService.getIngredientesByReceta(recetaId);
            List<java.util.Map<String, Object>> resultado = new ArrayList<>();
            
            for (Ingrediente ingrediente : ingredientes) {
                java.util.Map<String, Object> ingredienteMap = new HashMap<>();
                ingredienteMap.put("id_ingrediente", ingrediente.getIdIngrediente());
                ingredienteMap.put("nombre", ingrediente.getNombre());
                ingredienteMap.put("id_receta", recetaId);
                resultado.add(ingredienteMap);
            }
            
            return resultado;
        } catch (Exception e) {
            // En caso de error, retornar lista vacía
            return new ArrayList<>();
        }
    }
}
