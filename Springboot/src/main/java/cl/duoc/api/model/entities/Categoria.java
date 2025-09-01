package cl.duoc.api.model.entities;

import lombok.Data;

import javax.persistence.*;

@Data
@Entity
@Table(name = "categoria")
public class Categoria {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_cat")
    private int id_cat;

    @Basic
    @Column(name = "nombre")
    private String nombre;

    @Basic
    @Column(name = "estado")
    private int estado;

    @Basic
    @Column(name = "fecha_creacion")
    @javax.persistence.Convert(converter = cl.duoc.api.model.converters.StringToLocalDateTimeConverter.class)
    private String fecha_creacion;

    @Basic
     @Column(name = "comentario")
    private String comentario;
    @Basic
    @Column(name = "imagen")
    private String imagen;
    @Basic
    @Column(name = "id_usr")
    private int id_usr;

}
