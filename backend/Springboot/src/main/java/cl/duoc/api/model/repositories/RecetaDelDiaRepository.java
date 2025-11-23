package cl.duoc.api.model.repositories;

import cl.duoc.api.model.entities.RecetaDelDia;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;

@Repository
public interface RecetaDelDiaRepository extends JpaRepository<RecetaDelDia, LocalDate> {
}
