package cl.duoc.api.service;

import cl.duoc.api.model.entities.MeGusta;
import cl.duoc.api.model.repositories.MeGustaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class MeGustaService {
    
    @Autowired
    private MeGustaRepository meGustaRepository;

    public List<MeGusta> getMeGustasByUsuario(Integer usuarioId) {
        return meGustaRepository.findAll();
    }

    public MeGusta save(MeGusta meGusta) {
        return meGustaRepository.save(meGusta);
    }

    public void deleteByRecetaAndUsuario(Integer idReceta, Integer idUsuario) {
        meGustaRepository.deleteById(idReceta);
    }

    public Long countByReceta(Integer idReceta) {
        return meGustaRepository.countByRecetaIdReceta(idReceta);
    }

    public Optional<MeGusta> getMeGustaById(Integer id) {
        return meGustaRepository.findById(id);
    }

    public List<MeGusta> getAllMeGusta() {
        return meGustaRepository.findAll();
    }

    public void delete(Integer id) {
        meGustaRepository.deleteById(id);
    }

    public boolean toggleMeGusta(Integer usuarioId, Integer recetaId) {
        // Implementación básica de toggle - puede mejorarse
        return true;
    }
}