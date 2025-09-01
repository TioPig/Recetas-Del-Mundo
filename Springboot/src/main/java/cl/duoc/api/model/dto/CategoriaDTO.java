package cl.duoc.api.model.dto;

import lombok.Data;

@Data
public class CategoriaDTO {
    private int id_cat;
    private String nombre;
    private int estado;
    private String fecha_creacion;
    private String Comentario;
    private String imagen;
    private int id_usr;
    
}
    
