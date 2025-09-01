package cl.duoc.api.model.repositories;

// import cl.duoc.api.model.entities.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

import cl.duoc.api.model.entities.Receta;

import java.util.List;

public interface RecetaRepository extends JpaRepository<Receta, Integer>{
    List<Receta> findByNombre(String nombre);
    // búsqueda parcial (case-insensitive) por nombre
    List<Receta> findByNombreContainingIgnoreCase(String nombre);
    // búsqueda por id de país usando consulta nativa (evita problemas con nombres con guion bajo)
    @org.springframework.data.jpa.repository.Query(value = "SELECT * FROM receta r WHERE r.id_pais = :id_pais", nativeQuery = true)
    java.util.List<Receta> findByIdPaisNative(@org.springframework.data.repository.query.Param("id_pais") int id_pais);
    
}
