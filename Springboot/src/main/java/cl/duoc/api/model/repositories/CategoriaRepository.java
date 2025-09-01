package cl.duoc.api.model.repositories;

import cl.duoc.api.model.entities.Categoria;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CategoriaRepository extends JpaRepository<Categoria, Integer> {
    List<Categoria> findByNombre(String nombre);
}
