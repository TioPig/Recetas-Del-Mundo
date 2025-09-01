package cl.duoc.api.model.repositories;

import org.springframework.data.jpa.repository.JpaRepository;

import cl.duoc.api.model.entities.RecetaLike;
import cl.duoc.api.model.entities.RecetaLikeId;

public interface RecetaLikeRepository extends JpaRepository<RecetaLike, RecetaLikeId> {
}
