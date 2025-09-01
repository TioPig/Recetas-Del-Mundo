package cl.duoc.api.service;

import cl.duoc.api.model.entities.Carrusel;
import cl.duoc.api.model.repositories.CarruselRepository;
// import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class CarruselService {

    private final CarruselRepository carruselRepository;

    // @Autowired
    public CarruselService(CarruselRepository carruselRepository) {
        this.carruselRepository = carruselRepository;
    }

    public List<Carrusel> getAllCarruseles() {
        return carruselRepository.findAll();
    }

    public Optional<Carrusel> getCarruselById(int id_caru) {
        return carruselRepository.findById(id_caru);
    }

    public List<Carrusel> buscarCarruselPorNombre(String nombre) {
        return carruselRepository.findByNombre(nombre);
    }
    public Carrusel createCarrusel(Carrusel carrusel) {
        return carruselRepository.save(carrusel);
    }

    public Carrusel updateCarrusel(int id_caru, Carrusel carrusel) {
        if (carruselRepository.existsById(id_caru)) {
            carrusel.setId_caru(id_caru);
            return carruselRepository.save(carrusel);
        } else {
            throw new IllegalArgumentException("El carrusel con ID " + id_caru + " no existe.");
        }
    }
    public void deleteCarrusel(int id_caru) {
        carruselRepository.deleteById(id_caru);
    }
}
