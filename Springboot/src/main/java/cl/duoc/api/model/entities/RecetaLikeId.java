package cl.duoc.api.model.entities;

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.Embeddable;

import lombok.Data;

import com.fasterxml.jackson.annotation.JsonProperty;

@Data
@Embeddable
public class RecetaLikeId implements Serializable {

    private static final long serialVersionUID = 1L;

    @Column(name = "id_receta")
    @JsonProperty("id_receta")
    private Integer idReceta;

    @Column(name = "id_usr")
    @JsonProperty("id_usr")
    private Integer idUsr;
}
