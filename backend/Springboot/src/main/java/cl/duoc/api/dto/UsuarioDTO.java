package cl.duoc.api.dto;

public class UsuarioDTO {
    private Integer idUsr;
    private String nombre;
    private String email;
    private String perfil;

    public UsuarioDTO() {}

    public UsuarioDTO(Integer idUsr, String nombre, String email, String perfil) {
        this.idUsr = idUsr;
        this.nombre = nombre;
        this.email = email;
        this.perfil = perfil;
    }

    public Integer getIdUsr() {
        return idUsr;
    }

    public void setIdUsr(Integer idUsr) {
        this.idUsr = idUsr;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPerfil() {
        return perfil;
    }

    public void setPerfil(String perfil) {
        this.perfil = perfil;
    }
}
