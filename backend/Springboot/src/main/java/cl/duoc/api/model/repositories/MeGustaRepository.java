package cl.duoc.api.model.repositories;

import cl.duoc.api.model.entities.MeGusta;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface MeGustaRepository extends JpaRepository<MeGusta, Integer> {
    List<MeGusta> findByRecetaIdReceta(Integer idReceta);
    List<MeGusta> findByUsuarioIdUsr(Integer idUsr);
    long countByRecetaIdReceta(Integer idReceta);
    boolean existsByRecetaIdRecetaAndUsuarioIdUsr(Integer idReceta, Integer idUsr);
    void deleteByRecetaIdRecetaAndUsuarioIdUsr(Integer idReceta, Integer idUsr);
}
