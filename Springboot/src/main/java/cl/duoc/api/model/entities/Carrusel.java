package cl.duoc.api.model.entities;

import lombok.Data;

import javax.persistence.*;

@Data
@Entity
@Table(name = "carrusel")
public class Carrusel {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_caru")
    private int id_caru;

    @Column(name = "nombre")
    private String nombre;

    @Column(name = "url_imagen")
    private String urlImagen;

    @Column(name = "estado")
    private int estado;

    @Column(name = "fecha_creacion")
    @javax.persistence.Convert(converter = cl.duoc.api.model.converters.StringToLocalDateTimeConverter.class)
    private String fechaCreacion;

    @Column(name = "id_usr")
    private int idUsr;

}
