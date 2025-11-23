package cl.duoc.api.service;

import cl.duoc.api.model.entities.Favorito;
import cl.duoc.api.model.repositories.FavoritoRepository;
import org.springframework.stereotype.Service;

@Service
public class FavoritoService {
    private final FavoritoRepository repo;
    public FavoritoService(FavoritoRepository repo) { this.repo = repo; }
    public Favorito save(Favorito f) { return repo.save(f); }
    public long countByReceta(Integer idReceta) { return repo.countByRecetaIdReceta(idReceta); }
    public boolean exists(Integer idReceta, Integer idUsr) { return repo.existsByRecetaIdRecetaAndUsuarioIdUsr(idReceta, idUsr); }
    public void delete(Integer id) { repo.deleteById(id); }
    public void deleteByRecetaAndUsuario(Integer idReceta, Integer idUsr) {
        java.util.List<Favorito> list = repo.findByRecetaIdReceta(idReceta);
        if (list == null) return;
        for (Favorito f : list) {
            if (f.getUsuario() != null && f.getUsuario().getIdUsr() != null && f.getUsuario().getIdUsr().equals(idUsr)) {
                repo.deleteById(f.getIdFav());
                return;
            }
        }
    }

    public java.util.List<Favorito> getFavoritosByUsuario(Integer idUsuario) {
        return repo.findByUsuarioIdUsr(idUsuario);
    }
    
    // Métodos adicionales para CRUD completo
    public java.util.Optional<Favorito> getFavoritoById(Integer id) { return repo.findById(id); }
    public java.util.List<Favorito> getAllFavoritos() { return repo.findAll(); }
}
