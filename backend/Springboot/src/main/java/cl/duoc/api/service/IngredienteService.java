package cl.duoc.api.service;

import cl.duoc.api.model.entities.Ingrediente;
import cl.duoc.api.model.repositories.IngredienteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class IngredienteService {

    @Autowired
    private IngredienteRepository ingredienteRepository;

    public List<Ingrediente> getIngredientesByReceta(Integer idReceta) {
        return ingredienteRepository.findByRecetaIdReceta(idReceta);
    }

    public Ingrediente save(Ingrediente ingrediente) {
        return ingredienteRepository.save(ingrediente);
    }

    public java.util.List<Ingrediente> listAll() {
        return ingredienteRepository.findAll();
    }

    public java.util.Optional<Ingrediente> getIngredienteById(Integer id) {
        return ingredienteRepository.findById(id);
    }

    public void deleteIngrediente(Integer id) {
        ingredienteRepository.deleteById(id);
    }
}
