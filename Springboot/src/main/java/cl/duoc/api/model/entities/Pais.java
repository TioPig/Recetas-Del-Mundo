package cl.duoc.api.model.entities;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "pais")
@JsonIgnoreProperties({"hibernateLazyInitializer","handler"})
public class Pais {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_pais")
    private Integer idPais;

    @Column(name = "nombre", nullable = false, length = 100)
    private String nombre;

    @Column(name = "url_imagen", length = 500)
    private String urlImagen;

    @Column(name = "estado", nullable = false)
    private Short estado;

    @Column(name = "fecha_creacion")
    private LocalDateTime fechaCreacion;

    @Column(name = "Comentario", length = 500)
    private String comentario;

    @Column(name = "id_usr")
    private Integer idUsr;

    // Constructors
    public Pais() {}
    
    @PrePersist
    public void prePersist() {
        if (fechaCreacion == null) {
            fechaCreacion = LocalDateTime.now();
        }
        if (estado == null) {
            estado = 1; // Activo por defecto
        }
    }

    public Pais(String nombre, String urlImagen, Short estado, LocalDateTime fechaCreacion, String comentario, Integer idUsr) {
        this.nombre = nombre;
        this.urlImagen = urlImagen;
        this.estado = estado;
        this.fechaCreacion = fechaCreacion;
        this.comentario = comentario;
        this.idUsr = idUsr;
    }

    // Getters and Setters
    public Integer getIdPais() {
        return idPais;
    }

    public void setIdPais(Integer idPais) {
        this.idPais = idPais;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getUrlImagen() {
        return urlImagen;
    }

    public void setUrlImagen(String urlImagen) {
        this.urlImagen = urlImagen;
    }

    public Short getEstado() {
        return estado;
    }

    public void setEstado(Short estado) {
        this.estado = estado;
    }

    public LocalDateTime getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(LocalDateTime fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }

    public String getComentario() {
        return comentario;
    }

    public void setComentario(String comentario) {
        this.comentario = comentario;
    }

    public Integer getIdUsr() {
        return idUsr;
    }

    public void setIdUsr(Integer idUsr) {
        this.idUsr = idUsr;
    }
}
