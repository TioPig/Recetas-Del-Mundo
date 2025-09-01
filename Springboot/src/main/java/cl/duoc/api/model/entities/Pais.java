package cl.duoc.api.model.entities;

import lombok.Data;

import javax.persistence.*;

@Data
@Entity
@Table(name = "pais")
public class Pais {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_pais")
    private int id_pais;

    @Basic
    @Column(name = "nombre")
    private String nombre;

    @Basic
    @Column(name = "url_imagen")
    private String url_imagen;

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
    @Column(name = "id_usr")
    private int id_usr;

}