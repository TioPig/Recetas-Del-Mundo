package cl.duoc.api.model.entities;

import java.time.LocalDateTime;

import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;

import lombok.Data;

@Data
@Entity
@Table(name = "receta_like")
public class RecetaLike {

    @EmbeddedId
    private RecetaLikeId id;

    @Column(name = "liked", nullable = false)
    private Boolean liked = true;

    @Column(name = "fecha")
    private LocalDateTime fecha;
}
