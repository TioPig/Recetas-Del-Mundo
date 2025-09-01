package cl.duoc.api.model.dto;

import lombok.Data;

@Data
public class CarruselDTO {
    private int id_caru;
    private String nombre;
    private String url_imagen;
    private int estado;
    private String fecha_creacion;
    private int id_usr;
    
}
