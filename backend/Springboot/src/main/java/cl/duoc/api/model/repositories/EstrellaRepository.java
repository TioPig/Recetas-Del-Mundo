package cl.duoc.api.model.repositories;

import cl.duoc.api.model.entities.Estrella;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;

public interface EstrellaRepository extends JpaRepository<Estrella, Integer> {
    List<Estrella> findByRecetaIdReceta(Integer idReceta);
    long countByRecetaIdReceta(Integer idReceta);

    @Query("SELECT AVG(e.valor) FROM Estrella e WHERE e.receta.idReceta = :idReceta")
    Double findAverageValorByReceta(@Param("idReceta") Integer idReceta);

    List<Estrella> findByUsuarioIdUsr(Integer idUsr);

    Optional<Estrella> findByUsuarioIdUsrAndRecetaIdReceta(Integer idUsr, Integer idReceta);
}
