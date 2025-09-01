package cl.duoc.api.service;

// import cl.duoc.api.model.entities.Categoria;
import cl.duoc.api.model.entities.Pais;
import cl.duoc.api.model.repositories.PaisRepository;
// import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class PaisService {

    private final PaisRepository paisRepository;

    // @Autowired
    public PaisService(PaisRepository paisRepository) {
        this.paisRepository = paisRepository;
    }

    public List<Pais> getAllPaises() {
        return paisRepository.findAll();
    }

    public Optional<Pais> getPaisById(int id_pais) {
        return paisRepository.findById(id_pais);
    }

    public List<Pais> buscarPaisPorNombre(String nombre) { return paisRepository.findByNombre(nombre);
    }

    public Pais createPais(Pais pais) {
        return paisRepository.save(pais);
    }

    public Pais updatePais(int id_pais, Pais pais) {
        if (paisRepository.existsById(id_pais)) {
            pais.setId_pais(id_pais);
            return paisRepository.save(pais);
        } else {
            throw new IllegalArgumentException("El país con ID " + id_pais + " no existe.");
        }
    }

    public void deletePais(int id_pais) {
        paisRepository.deleteById(id_pais);
    }
}