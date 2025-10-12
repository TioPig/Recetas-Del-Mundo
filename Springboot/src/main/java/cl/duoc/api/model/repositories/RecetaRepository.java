package cl.duoc.api.model.repositories;

import cl.duoc.api.model.entities.Receta;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RecetaRepository extends JpaRepository<Receta, Integer> {

    Optional<Receta> findByNombre(String nombre);
    
    // Búsqueda parcial, case-insensitive. Devuelve lista para tomar el primer match en el servicio
    List<Receta> findByNombreContainingIgnoreCase(String nombre);

    List<Receta> findByEstado(Short estado);

    List<Receta> findByIdUsr(Integer idUsr);

    List<Receta> findByIdCat(Integer idCat);

    List<Receta> findByIdPais(Integer idPais);

    @Query("SELECT r FROM Receta r WHERE r.estado = 1 ORDER BY r.fechaCreacion DESC")
    List<Receta> findActiveRecetas();

    @Query("SELECT r FROM Receta r WHERE r.estado = 1 AND r.idCat = :idCat ORDER BY r.fechaCreacion DESC")
    List<Receta> findActiveRecetasByCategoria(@Param("idCat") Integer idCat);

    @Query("SELECT r FROM Receta r WHERE r.estado = 1 AND r.idPais = :idPais ORDER BY r.fechaCreacion DESC")
    List<Receta> findActiveRecetasByPais(@Param("idPais") Integer idPais);

    @Query("SELECT r FROM Receta r WHERE r.estado = 1 ORDER BY r.visitas DESC")
    java.util.List<Receta> findTopByVisitasDesc(org.springframework.data.domain.Pageable p);

    default java.util.List<Receta> findTopByVisitasDesc(int limit) {
        return findTopByVisitasDesc(org.springframework.data.domain.PageRequest.of(0, limit));
    }

    @Query("SELECT r FROM Receta r WHERE r.estado = 1 ORDER BY (SELECT COUNT(m) FROM MeGusta m WHERE m.receta = r) DESC, r.visitas DESC")
    java.util.List<Receta> findTopByLikesDesc(org.springframework.data.domain.Pageable p);

    default java.util.List<Receta> findTopByLikesDesc(int limit) {
        return findTopByLikesDesc(org.springframework.data.domain.PageRequest.of(0, limit));
    }
}
