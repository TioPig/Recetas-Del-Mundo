package cl.duoc.api.model.dto;

/**
 * DTO para exponer solo información básica del usuario (nombre)
 * Usado por el frontend para mostrar datos públicos sin información sensible
 */
public class UsuarioBasicoDTO {
    
    private String nombre;
    
    // Constructor vacío
    public UsuarioBasicoDTO() {
    }
    
    // Constructor con parámetros
    public UsuarioBasicoDTO(String nombre) {
        this.nombre = nombre;
    }
    
    // Getters y Setters
    public String getNombre() {
        return nombre;
    }
    
    public void setNombre(String nombre) {
        this.nombre = nombre;
    }
    
    @Override
    public String toString() {
        return "UsuarioBasicoDTO{" +
                "nombre='" + nombre + '\'' +
                '}';
    }
}

