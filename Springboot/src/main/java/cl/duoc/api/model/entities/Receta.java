package cl.duoc.api.model.entities;

import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

import lombok.Data;

@Data
@Entity
@Table(name ="receta")
public class Receta {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)    
    @Column(name ="id_receta")
    private int id_receta;

    @Basic
    @Column(name="nombre")
    private String nombre;

    @Basic
    @Column(name="url_imagen")
    private String url_imagen;

    @Basic
    @Column(name="ingrediente")
    private String ingrediente;

    @Basic
    @Column(name="preparacion")
    private String preparacion;

    @Basic
    @Column(name="estado")
    private int estado;
    
    @Basic
    @Column(name="id_cat")
    private int id_cat;

    @Basic
    @Column(name="id_pais")
    private int id_pais;

    @Basic
    @Column(name="fecha_creacion")
    @javax.persistence.Convert(converter = cl.duoc.api.model.converters.StringToLocalDateTimeConverter.class)
    private String fecha_creacion;

    @Basic
    @Column(name="id_usr")
    private int id_usr;
}
