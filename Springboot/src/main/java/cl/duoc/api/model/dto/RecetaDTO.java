package cl.duoc.api.model.dto;

import lombok.Data;

@Data
public class RecetaDTO {

    private int id_receta;
    private String nombre;
    private String url_imagen;
    private String ingrediente;
    private String preparacion;
    private int estado; 
    private int id_cat;
    private int id_pais;
    private String fecha_creacion; 
    private int id_usr;
    
}
