package cl.duoc.api.model.repositories;

import cl.duoc.api.model.entities.Categoria;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CategoriaRepository extends JpaRepository<Categoria, Integer> {

    @Query("SELECT c FROM Categoria c WHERE c.estado = 1 ORDER BY c.nombre")
    List<Categoria> findActiveCategorias();

    Optional<Categoria> findByNombre(String nombre);

    List<Categoria> findByNombreContainingIgnoreCase(String nombre);
}
