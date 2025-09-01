package cl.duoc.api.model.repositories;

import cl.duoc.api.model.entities.Carrusel;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CarruselRepository extends JpaRepository<Carrusel, Integer> {
    List<Carrusel> findByNombre(String nombre);
}
