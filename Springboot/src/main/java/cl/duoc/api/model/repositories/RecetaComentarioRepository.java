package cl.duoc.api.model.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import cl.duoc.api.model.entities.RecetaComentario;

public interface RecetaComentarioRepository extends JpaRepository<RecetaComentario, Integer> {
    List<RecetaComentario> findByIdReceta(Integer idReceta);
}
