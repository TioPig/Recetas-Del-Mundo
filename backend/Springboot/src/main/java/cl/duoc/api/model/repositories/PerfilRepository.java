package cl.duoc.api.model.repositories;

import cl.duoc.api.model.entities.Perfil;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PerfilRepository extends JpaRepository<Perfil, Integer> {
    Perfil findByNombre(String nombre);
}
