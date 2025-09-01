package cl.duoc.api.service;

import cl.duoc.api.model.entities.Usuario;
import cl.duoc.api.model.repositories.UsuarioRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
// import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;

    private final PasswordEncoder passwordEncoder;

    // @Autowired
    public UsuarioService(UsuarioRepository usuarioRepository, PasswordEncoder passwordEncoder) {
        this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public List<Usuario> getAllUsuarios() {
        return usuarioRepository.findAll();
    }

    public Optional<Usuario> getUsuarioById(int id) {
        return usuarioRepository.findById(id);
    }

    public Usuario createUsuario(Usuario usuario) {
    // hash password before saving
    usuario.setPassword(passwordEncoder.encode(usuario.getPassword()));
    return usuarioRepository.save(usuario);
    }

    public Usuario saveToken(int id, String token) {
        Usuario u = usuarioRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));
        u.setToken(token);
        return usuarioRepository.save(u);
    }

    public Usuario authenticate(String username, String password) {
        org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(UsuarioService.class);
        var uopt = usuarioRepository.findByUser(username);
        if (uopt.isEmpty()) {
            log.warn("Autenticación fallida: usuario no encontrado {}", username);
            return null;
        }
        Usuario u = uopt.get();
        boolean ok = passwordEncoder.matches(password, u.getPassword());
        if (!ok) log.warn("Autenticación fallida para user={}: password mismatch", username);
        else log.info("Autenticación exitosa para user={}", username);
        return ok ? u : null;
    }

    public Usuario updateUsuario(int id, Usuario usuario) {
        if (usuarioRepository.existsById(id)) {
            usuario.setId_usr(id);
            return usuarioRepository.save(usuario);
        } else {
            // Manejo de error si no se encuentra el usuario
            throw new IllegalArgumentException("El usuario con ID " + id + " no existe.");
        }
    }

    public void deleteUsuario(int id) {
        usuarioRepository.deleteById(id);
    }
}
