package cl.duoc.api.model.entities;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "estrella")
public class Estrella {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_estrella")
    private Integer idEstrella;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_receta", nullable = false)
    private Receta receta;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_usr", nullable = false)
    private Usuario usuario;

    @Column(name = "valor", nullable = false)
    private Short valor;

    @Column(name = "fecha_creacion")
    private LocalDateTime fechaCreacion;

    public Estrella() {}

    @PrePersist
    public void prePersist() {
        if (this.fechaCreacion == null) {
            this.fechaCreacion = LocalDateTime.now();
        }
    }

    // getters/setters
    public Integer getIdEstrella() { return idEstrella; }
    public void setIdEstrella(Integer idEstrella) { this.idEstrella = idEstrella; }
    public Receta getReceta() { return receta; }
    public void setReceta(Receta receta) { this.receta = receta; }
    public Usuario getUsuario() { return usuario; }
    public void setUsuario(Usuario usuario) { this.usuario = usuario; }
    public Short getValor() { return valor; }
    public void setValor(Short valor) { this.valor = valor; }
    public LocalDateTime getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(LocalDateTime fechaCreacion) { this.fechaCreacion = fechaCreacion; }
}
