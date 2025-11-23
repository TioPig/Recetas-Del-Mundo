package cl.duoc.api.service;

import cl.duoc.api.model.entities.Categoria;
import cl.duoc.api.model.repositories.CategoriaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CategoriaService {

    @Autowired
    private CategoriaRepository categoriaRepository;

    public List<Categoria> getActiveCategorias() {
        return categoriaRepository.findActiveCategorias();
    }

    public Categoria getCategoriaById(Integer id) {
        return categoriaRepository.findById(id).orElse(null);
    }

    public Categoria saveCategoria(Categoria categoria) {
        return categoriaRepository.save(categoria);
    }

    public java.util.List<Categoria> getCategoriasByNombre(String nombre) {
        java.util.List<Categoria> result = new java.util.ArrayList<>();
        try {
            // exact match first
            java.util.Optional<Categoria> exact = categoriaRepository.findByNombre(nombre);
            exact.ifPresent(result::add);
            // then partial, case-insensitive
            java.util.List<Categoria> partials = categoriaRepository.findByNombreContainingIgnoreCase(nombre);
            for (Categoria c : partials) {
                if (!result.contains(c)) result.add(c);
            }
        } catch (Exception e) {
            // return empty list on error
        }
        return result;
    }
}
