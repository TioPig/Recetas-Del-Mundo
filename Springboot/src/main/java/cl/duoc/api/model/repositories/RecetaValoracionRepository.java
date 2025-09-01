package cl.duoc.api.model.repositories;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import cl.duoc.api.model.entities.RecetaValoracion;

public interface RecetaValoracionRepository extends JpaRepository<RecetaValoracion, Integer> {
    Optional<RecetaValoracion> findByIdRecetaAndIdUsr(Integer idReceta, Integer idUsr);
}