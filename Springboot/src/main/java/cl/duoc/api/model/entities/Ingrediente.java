package cl.duoc.api.model.entities;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;

@Entity
@Table(name = "ingrediente")
public class Ingrediente {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_ingrediente")
    private Integer idIngrediente;

    @Column(name = "nombre", nullable = false, length = 500)
    private String nombre;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_receta", nullable = false)
    @JsonBackReference
    private Receta receta;

    public Ingrediente() {}

    public Ingrediente(String nombre, Receta receta) {
        this.nombre = nombre;
        this.receta = receta;
    }

    public Integer getIdIngrediente() {
        return idIngrediente;
    }

    public void setIdIngrediente(Integer idIngrediente) {
        this.idIngrediente = idIngrediente;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public Receta getReceta() {
        return receta;
    }

    public void setReceta(Receta receta) {
        this.receta = receta;
    }
    
    // Helper method para JSON
    public Integer getIdReceta() {
        return receta != null ? receta.getIdReceta() : null;
    }
    
    public void setIdReceta(Integer idReceta) {
        if (idReceta != null) {
            Receta r = new Receta();
            r.setIdReceta(idReceta);
            this.receta = r;
        }
    }
}
