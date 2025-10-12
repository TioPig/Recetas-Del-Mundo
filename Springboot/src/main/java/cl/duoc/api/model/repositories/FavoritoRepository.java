package cl.duoc.api.model.repositories;

import cl.duoc.api.model.entities.Favorito;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface FavoritoRepository extends JpaRepository<Favorito, Integer> {
    List<Favorito> findByRecetaIdReceta(Integer idReceta);
    long countByRecetaIdReceta(Integer idReceta);
    boolean existsByRecetaIdRecetaAndUsuarioIdUsr(Integer idReceta, Integer idUsr);
    List<Favorito> findByUsuarioIdUsr(Integer idUsuario);
}
