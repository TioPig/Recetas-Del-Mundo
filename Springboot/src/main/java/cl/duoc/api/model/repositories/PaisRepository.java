package cl.duoc.api.model.repositories;

import cl.duoc.api.model.entities.Pais;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PaisRepository extends JpaRepository<Pais, Integer> {
    List<Pais> findByNombre(String nombre);
}
