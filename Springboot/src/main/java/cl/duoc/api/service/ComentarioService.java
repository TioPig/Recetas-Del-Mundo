package cl.duoc.api.service;

import cl.duoc.api.model.entities.Comentario;
import cl.duoc.api.model.repositories.ComentarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ComentarioService {
    
    @Autowired
    private ComentarioRepository comentarioRepository;

    public List<Comentario> getComentariosByUsuario(Integer usuarioId) {
        return comentarioRepository.findAll();
    }

    public List<Comentario> getAllComentarios() {
        return comentarioRepository.findAll();
    }

    public List<Comentario> getComentariosByReceta(Integer recetaId) {
        return comentarioRepository.findByRecetaIdReceta(recetaId);
    }

    public Comentario save(Comentario comentario) {
        return comentarioRepository.save(comentario);
    }

    public Optional<Comentario> getComentarioById(Integer id) {
        return comentarioRepository.findById(id);
    }

    public void delete(Integer id) {
        comentarioRepository.deleteById(id);
    }
}