package cl.duoc.api.model.repositories;

import cl.duoc.api.model.entities.Ingrediente;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface IngredienteRepository extends JpaRepository<Ingrediente, Integer> {
    List<Ingrediente> findByRecetaIdReceta(Integer idReceta);
}