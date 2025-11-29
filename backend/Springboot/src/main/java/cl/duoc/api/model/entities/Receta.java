package cl.duoc.api.model.entities;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "receta")
@JsonIgnoreProperties({"hibernateLazyInitializer","handler"})
public class Receta {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_receta")
    private Integer idReceta;

    @Column(name = "nombre", nullable = false, length = 200)
    private String nombre;

    @Column(name = "url_imagen", nullable = false, length = 300)
    private String urlImagen;


    @OneToMany(mappedBy = "receta", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference
    private java.util.List<Ingrediente> ingredientes = new java.util.ArrayList<>();

    @Column(name = "preparacion", nullable = false)
    private String preparacion;

    @Column(name = "estado", nullable = false)
    private Short estado = 1;

    @Column(name = "id_cat", nullable = false)
    private Integer idCat;

    @Column(name = "id_pais", nullable = false)
    private Integer idPais;

    @Column(name = "fecha_creacion", nullable = false)
    private LocalDate fechaCreacion;

    @Column(name = "visitas", nullable = false)
    private Integer visitas = 0;

    @Column(name = "id_usr", nullable = false)
    private Integer idUsr;

    // Constructors
    public Receta() {}

    public Receta(Integer idReceta) {
        this.idReceta = idReceta;
    }

    public Receta(String nombre, String urlImagen, String preparacion,
                  Integer idCat, Integer idPais, Integer idUsr) {
        this.nombre = nombre;
        this.urlImagen = urlImagen;
        this.preparacion = preparacion;
        this.idCat = idCat;
        this.idPais = idPais;
        this.idUsr = idUsr;
        this.estado = 1;
        this.fechaCreacion = LocalDate.now();
    }

    // Getters and Setters
    public Integer getIdReceta() {
        return idReceta;
    }

    public void setIdReceta(Integer idReceta) {
        this.idReceta = idReceta;
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

    // legacy 'ingrediente' field removed after normalization; use getIngredientes() instead

    public java.util.List<Ingrediente> getIngredientes() {
        return ingredientes;
    }

    public void setIngredientes(java.util.List<Ingrediente> ingredientes) {
        this.ingredientes = ingredientes;
    }

    public String getPreparacion() {
        return preparacion;
    }

    public void setPreparacion(String preparacion) {
        this.preparacion = preparacion;
    }

    public Short getEstado() {
        return estado;
    }

    public void setEstado(Short estado) {
        this.estado = estado;
    }

    public Integer getIdCat() {
        return idCat;
    }

    public void setIdCat(Integer idCat) {
        this.idCat = idCat;
    }

    public Integer getIdPais() {
        return idPais;
    }

    public void setIdPais(Integer idPais) {
        this.idPais = idPais;
    }

    public LocalDate getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(LocalDate fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }

    public Integer getIdUsr() {
        return idUsr;
    }

    public void setIdUsr(Integer idUsr) {
        this.idUsr = idUsr;
    }

    public Integer getVisitas() {
        return visitas;
    }

    public void setVisitas(Integer visitas) {
        this.visitas = visitas;
    }
}
