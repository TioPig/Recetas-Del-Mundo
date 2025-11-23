package cl.duoc.api.model.repositories;

import cl.duoc.api.model.entities.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Integer> {

    Optional<Usuario> findByEmail(String email);

    @Query("SELECT u FROM Usuario u WHERE u.email = :email AND u.estado = 1")
    Optional<Usuario> findActiveByEmail(@Param("email") String email);

    @Query("SELECT u FROM Usuario u JOIN FETCH u.perfil p WHERE u.email = :email AND u.estado = 1")
    Optional<Usuario> findActiveByEmailWithPerfil(@Param("email") String email);

    // Buscar por nombre exacto y parcial (case-insensitive)
    Optional<Usuario> findByNombre(String nombre);

    java.util.List<Usuario> findByNombreContainingIgnoreCase(String nombre);
}