package cl.duoc.api.service;

import cl.duoc.api.model.entities.MeGusta;
import cl.duoc.api.model.repositories.MeGustaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class MeGustaService {
    
    @Autowired
    private MeGustaRepository meGustaRepository;

    public List<MeGusta> getMeGustasByUsuario(Integer usuarioId) {
        if (usuarioId == null) return meGustaRepository.findAll();
        return meGustaRepository.findByUsuarioIdUsr(usuarioId);
    }

    public MeGusta save(MeGusta meGusta) {
        // Enforce one like per (receta, usuario)
        Integer recetaId = meGusta.getReceta() != null ? meGusta.getReceta().getIdReceta() : null;
        Integer usuarioId = meGusta.getUsuario() != null ? meGusta.getUsuario().getIdUsr() : null;
        if (recetaId == null || usuarioId == null) {
            throw new IllegalArgumentException("receta o usuario inválido");
        }
        boolean exists = meGustaRepository.existsByRecetaIdRecetaAndUsuarioIdUsr(recetaId, usuarioId);
        if (exists) {
            throw new IllegalStateException("El usuario ya dio me gusta a esta receta");
        }
        return meGustaRepository.save(meGusta);
    }

    public void deleteByRecetaAndUsuario(Integer idReceta, Integer idUsuario) {
        meGustaRepository.deleteByRecetaIdRecetaAndUsuarioIdUsr(idReceta, idUsuario);
    }

    @Transactional
    public void deleteByRecetaAndUsuarioTransactional(Integer idReceta, Integer idUsuario) {
        meGustaRepository.deleteByRecetaIdRecetaAndUsuarioIdUsr(idReceta, idUsuario);
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