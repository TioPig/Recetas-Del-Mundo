package cl.duoc.api.model.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDate;

@Entity
@Table(name = "receta_del_dia")
public class RecetaDelDia {

    @Id
    @Column(name = "fecha", nullable = false)
    private LocalDate fecha;

    @Column(name = "id_receta", nullable = false)
    private Integer idReceta;

    public RecetaDelDia() {}

    public RecetaDelDia(LocalDate fecha, Integer idReceta) {
        this.fecha = fecha;
        this.idReceta = idReceta;
    }

    public LocalDate getFecha() {
        return fecha;
    }

    public void setFecha(LocalDate fecha) {
        this.fecha = fecha;
    }

    public Integer getIdReceta() {
        return idReceta;
    }

    public void setIdReceta(Integer idReceta) {
        this.idReceta = idReceta;
    }
}
