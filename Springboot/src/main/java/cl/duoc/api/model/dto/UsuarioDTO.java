package cl.duoc.api.model.dto;

import lombok.Data;

@Data
public class UsuarioDTO {
    private int id_usr;
    private String nombre;
    private String apellido;
    private String user;
    private String password;
    private int activo;
    private String token;
}
