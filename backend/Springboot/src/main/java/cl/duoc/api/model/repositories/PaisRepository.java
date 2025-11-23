package cl.duoc.api.model.repositories;

import cl.duoc.api.model.entities.Pais;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PaisRepository extends JpaRepository<Pais, Integer> {

    @Query("SELECT p FROM Pais p WHERE p.estado = 1 ORDER BY p.nombre")
    List<Pais> findActivePaises();

    // Buscar país por nombre exacto
    java.util.Optional<Pais> findByNombre(String nombre);

    // Buscar por nombre parcial, case-insensitive
    java.util.List<Pais> findByNombreContainingIgnoreCase(String nombre);
}
