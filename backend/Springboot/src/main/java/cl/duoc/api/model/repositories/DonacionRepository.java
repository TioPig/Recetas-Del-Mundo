package cl.duoc.api.model.repositories;

import cl.duoc.api.model.entities.Donacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface DonacionRepository extends JpaRepository<Donacion, Integer> {
    
    @Query("SELECT d FROM Donacion d WHERE d.idUsr = :idUsuario ORDER BY d.fechaCreacion DESC")
    List<Donacion> findByUsuarioId(@Param("idUsuario") Integer idUsuario);
    
    @Query("SELECT d FROM Donacion d WHERE d.idReceta = :idReceta ORDER BY d.fechaCreacion DESC")
    List<Donacion> findByRecetaId(@Param("idReceta") Integer idReceta);
    
    @Query("SELECT d FROM Donacion d WHERE d.stripeSessionId = :sessionId")
    Optional<Donacion> findByStripeSessionId(@Param("sessionId") String sessionId);
    
    @Query("SELECT d FROM Donacion d WHERE d.stripePaymentIntent = :paymentIntent")
    Optional<Donacion> findByStripePaymentIntent(@Param("paymentIntent") String paymentIntent);
    
    @Query("SELECT d FROM Donacion d WHERE d.status = :status ORDER BY d.fechaCreacion DESC")
    List<Donacion> findByStatus(@Param("status") String status);
}