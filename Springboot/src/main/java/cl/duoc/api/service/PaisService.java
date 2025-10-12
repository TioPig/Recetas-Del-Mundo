package cl.duoc.api.service;

import cl.duoc.api.model.entities.Pais;
import cl.duoc.api.model.repositories.PaisRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PaisService {

    @Autowired
    private PaisRepository paisRepository;

    public List<Pais> getActivePaises() {
        return paisRepository.findActivePaises();
    }

    public Pais getPaisById(Integer id) {
        return paisRepository.findById(id).orElse(null);
    }

    public Pais savePais(Pais pais) {
        return paisRepository.save(pais);
    }

    // devolver lista de coincidencias por nombre (vacía si no hay)
    public java.util.List<Pais> getPaisesByNombre(String nombre) {
        if (nombre == null || nombre.trim().isEmpty()) return java.util.Collections.emptyList();

        java.util.List<Pais> result = new java.util.ArrayList<>();
        java.util.Optional<Pais> exact = paisRepository.findByNombre(nombre);
        exact.ifPresent(result::add);

        java.util.List<Pais> partials = paisRepository.findByNombreContainingIgnoreCase(nombre);
        if (partials != null) {
            for (Pais p : partials) {
                if (!result.stream().anyMatch(x -> x.getIdPais().equals(p.getIdPais()))) {
                    result.add(p);
                }
            }
        }
        return result;
    }
}
