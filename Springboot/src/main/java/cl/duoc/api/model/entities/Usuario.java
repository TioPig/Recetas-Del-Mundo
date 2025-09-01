package cl.duoc.api.model.entities;

import javax.persistence.*;

@Entity
@Table(name ="usuario")
public class Usuario {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)    
    @Column(name ="id_usr")
    private int id_usr;

    @Basic
    @Column(name="nombre")
    private String nombre;

    @Basic
    @Column(name="apellido")
    private String apellido;

    @Basic
    // "user" is a reserved word in Postgres; force quoted identifier so Hibernate emits "user" in SQL
    @Column(name="\"user\"")
    private String user;

    @Basic
    @Column(name="password")
    private String password;

    @Basic
    @Column(name="activo")
    private int activo;

    @Basic
    @Column(name="token")
    private String token;

    // Getters and Setters
    public int getId_usr() {
        return id_usr;
    }

    public void setId_usr(int id_usr) {
        this.id_usr = id_usr;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getApellido() {
        return apellido;
    }

    public void setApellido(String apellido) {
        this.apellido = apellido;
    }

    public String getUser() {
        return user;
    }

    public void setUser(String user) {
        this.user = user;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public int getActivo() {
        return activo;
    }

    public void setActivo(int activo) {
        this.activo = activo;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }
}
