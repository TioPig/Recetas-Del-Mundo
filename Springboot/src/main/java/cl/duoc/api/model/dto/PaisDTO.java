package cl.duoc.api.model.dto;

import lombok.Data;

@Data
public class PaisDTO {
    private int id_pais;
    private String nombre;
    private String url_imagen;
    private int estado;
    private String fecha_creacion;
    private String Comentario;
    private int id_usr;
    
}
