package cl.duoc.api.service;

import cl.duoc.api.model.entities.Perfil;
import cl.duoc.api.model.repositories.PerfilRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class PerfilService {

    @Autowired
    private PerfilRepository perfilRepository;

    public List<Perfil> findAll() {
        return perfilRepository.findAll();
    }

    public Optional<Perfil> findById(Long id) {
        return perfilRepository.findById(id.intValue());
    }

    public Perfil findById(Integer id) {
        Optional<Perfil> perfil = perfilRepository.findById(id);
        return perfil.orElse(null);
    }

    public Perfil findByNombre(String nombre) {
        return perfilRepository.findByNombre(nombre);
    }

    public Perfil save(Perfil perfil) {
        return perfilRepository.save(perfil);
    }

    public void deleteById(Long id) {
        perfilRepository.deleteById(id.intValue());
    }

    public void deleteById(Integer id) {
        perfilRepository.deleteById(id);
    }

    public boolean existsById(Integer id) {
        return perfilRepository.existsById(id);
    }
}