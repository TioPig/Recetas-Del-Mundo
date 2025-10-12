package cl.duoc.api.model.repositories;

import cl.duoc.api.model.entities.Comentario;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ComentarioRepository extends JpaRepository<Comentario, Integer> {
    List<Comentario> findByRecetaIdReceta(Integer idReceta);
}
