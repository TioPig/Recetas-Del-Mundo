package cl.duoc.api.service;

import cl.duoc.api.model.entities.Categoria;
import cl.duoc.api.model.repositories.CategoriaRepository;
// import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class CategoriaService {

    private final CategoriaRepository categoriaRepository;

    // @Autowired
    public CategoriaService(CategoriaRepository categoriaRepository) {
        this.categoriaRepository = categoriaRepository;
    }

    public List<Categoria> getAllCategorias() {
        return categoriaRepository.findAll();
    }

    public Optional<Categoria> getCategoriaById(int id) {
        return categoriaRepository.findById(id);
    }

    public Categoria createCategoria(Categoria categoria) {
        return categoriaRepository.save(categoria);
    }

    public List<Categoria> buscarCategoriaPorNombre(String nombre) {
        return categoriaRepository.findByNombre(nombre);
    }

    public Categoria updateCategoria(int id, Categoria categoria) {
        if (categoriaRepository.existsById(id)) {
            categoria.setId_cat(id);
            return categoriaRepository.save(categoria);
        } else {
            throw new IllegalArgumentException("La categoría con ID " + id + " no existe.");
        }
    }

    public void deleteCategoria(int id) {
        categoriaRepository.deleteById(id);
    }
}

