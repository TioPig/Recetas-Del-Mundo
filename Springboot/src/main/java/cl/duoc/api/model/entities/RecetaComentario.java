package cl.duoc.api.model.entities;

import java.time.LocalDateTime;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
@Entity
@Table(name = "receta_comentario")
public class RecetaComentario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;

    @Column(name = "id_receta", nullable = false)
    @JsonProperty("id_receta")
    private Integer idReceta;

    @Column(name = "id_usr")
    @JsonProperty("id_usr")
    private Integer idUsr;

    @Column(name = "comentario", columnDefinition = "text", nullable = false)
    private String comentario;

    @Column(name = "fecha")
    private LocalDateTime fecha;
}
