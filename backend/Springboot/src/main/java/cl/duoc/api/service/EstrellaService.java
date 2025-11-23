package cl.duoc.api.service;

import cl.duoc.api.model.entities.Estrella;
import cl.duoc.api.model.repositories.EstrellaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class EstrellaService {
    
    @Autowired
    private EstrellaRepository estrellaRepository;

    public List<Estrella> getEstrellasByUsuario(Integer usuarioId) {
        if (usuarioId == null) return estrellaRepository.findAll();
        return estrellaRepository.findByUsuarioIdUsr(usuarioId);
    }

    public Estrella save(Estrella estrella) {
        return estrellaRepository.save(estrella);
    }

    public Optional<Estrella> getEstrellaByUsuarioAndReceta(Integer usuarioId, Integer recetaId) {
        return estrellaRepository.findByUsuarioIdUsrAndRecetaIdReceta(usuarioId, recetaId);
    }

    public Double avgByReceta(Integer idReceta) {
        return estrellaRepository.findAverageValorByReceta(idReceta);
    }

    public Long countByReceta(Integer idReceta) {
        return estrellaRepository.countByRecetaIdReceta(idReceta);
    }

    public Optional<Estrella> getEstrellaById(Integer id) {
        return estrellaRepository.findById(id);
    }

    public void delete(Integer id) {
        estrellaRepository.deleteById(id);
    }

    public List<Estrella> getAllEstrellas() {
        return estrellaRepository.findAll();
    }

    public List<Estrella> getEstrellasByReceta(Integer recetaId) {
        return estrellaRepository.findByRecetaIdReceta(recetaId);
    }

    public Double getPromedioByReceta(Integer recetaId) {
        return estrellaRepository.findAverageValorByReceta(recetaId);
    }
}