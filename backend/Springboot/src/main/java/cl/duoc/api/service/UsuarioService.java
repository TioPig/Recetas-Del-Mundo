package cl.duoc.api.service;

import cl.duoc.api.model.entities.Usuario;
import cl.duoc.api.model.repositories.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import cl.duoc.api.config.PasswordConfig;

import java.util.List;
import java.util.Optional;

@Service
public class UsuarioService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PasswordConfig.PasswordEncoder passwordEncoder;

    public Usuario login(String email, String password) {
        Optional<Usuario> usuarioOpt = usuarioRepository.findActiveByEmail(email);

        if (usuarioOpt.isPresent()) {
            Usuario usuario = usuarioOpt.get();
            String stored = usuario.getPassword();
            if (stored != null) {
                // Si la contraseña almacenada parece un hash BCrypt, usar matches
                if (stored.startsWith("$2a$") || stored.startsWith("$2b$") || stored.startsWith("$2y$")) {
                    if (passwordEncoder.matches(password, stored)) {
                        return usuario;
                    }
                } else {
                    // Fallback: aceptar comparación en texto plano para no romper usuarios existentes
                    if (password.equals(stored)) {
                        // Re-hash de la contraseña en el primer login para mejorar seguridad
                        try {
                            usuario.setPassword(passwordEncoder.encode(password));
                            usuarioRepository.save(usuario);
                        } catch (Exception ex) {
                            // Si falla el rehash o save, no bloqueamos el login; simplemente loggear si se desea
                        }
                        return usuario;
                    }
                }
            }
        }

        return null;
    }

    public List<Usuario> getAllUsuarios() {
        return usuarioRepository.findAll();
    }

    public Usuario getUsuarioById(Integer id) {
        Optional<Usuario> usuarioOpt = usuarioRepository.findById(id);
        return usuarioOpt.orElse(null);
    }

    public Usuario saveUsuario(Usuario usuario) {
        // Si la contraseña está en texto plano, la hasheamos antes de guardar
        if (usuario.getPassword() != null) {
            String p = usuario.getPassword();
            if (!(p.startsWith("$2a$") || p.startsWith("$2b$") || p.startsWith("$2y$"))) {
                usuario.setPassword(passwordEncoder.encode(p));
            }
        }
        return usuarioRepository.save(usuario);
    }

    public void deleteUsuario(Integer id) {
        usuarioRepository.deleteById(id);
    }

    public Optional<Usuario> findById(Integer id) {
        return usuarioRepository.findById(id);
    }

    public Usuario findByEmail(String email) {
        return usuarioRepository.findActiveByEmail(email).orElse(null);
    }

    public Usuario getById(Integer id) {
        return usuarioRepository.findById(id).orElse(null);
    }

    public Usuario save(Usuario usuario) {
        if (usuario.getPassword() != null) {
            String p = usuario.getPassword();
            if (!(p.startsWith("$2a$") || p.startsWith("$2b$") || p.startsWith("$2y$"))) {
                usuario.setPassword(passwordEncoder.encode(p));
            }
        }
        return usuarioRepository.save(usuario);
    }

    public void deleteById(Integer id) {
        usuarioRepository.deleteById(id);
    }

    // --- Búsqueda por nombre (exacta y parcial) ---
    public java.util.Optional<Usuario> getUsuarioByNombre(String nombre) {
        return usuarioRepository.findByNombre(nombre);
    }

    public java.util.List<Usuario> getUsuariosByNombre(String nombre) {
        if (nombre == null || nombre.trim().isEmpty()) return java.util.Collections.emptyList();
        java.util.Optional<Usuario> exact = usuarioRepository.findByNombre(nombre);
        java.util.List<Usuario> results = new java.util.ArrayList<>();
        exact.ifPresent(results::add);
        java.util.List<Usuario> partials = usuarioRepository.findByNombreContainingIgnoreCase(nombre);
        for (Usuario u : partials) {
            if (!results.contains(u)) results.add(u);
        }
        return results;
    }

    // --- Helpers for authorization checks - ELIMINADOS CON SPRING SECURITY ---
    /*
    public Usuario getAuthenticatedUser(org.springframework.security.core.Authentication auth) {
        if (auth == null || auth.getName() == null) return null;
        return findByEmail(auth.getName());
    }

    public boolean isAuthorOrHasRole(org.springframework.security.core.Authentication auth, Integer ownerId, String... allowedRoles) {
        Usuario u = getAuthenticatedUser(auth);
        if (u == null) return false;
        if (ownerId != null && u.getIdUsr() != null && ownerId.equals(u.getIdUsr())) return true;
        if (u.getPerfil() != null && u.getPerfil().getNombre() != null) {
            String role = u.getPerfil().getNombre().toUpperCase();
            for (String allowed : allowedRoles) {
                if (allowed != null && role.equals(allowed.toUpperCase())) return true;
            }
        }
        return false;
    }
    */
}