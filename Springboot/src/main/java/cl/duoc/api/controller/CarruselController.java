package cl.duoc.api.controller;

import cl.duoc.api.model.dto.CarruselDTO;
import cl.duoc.api.model.entities.Carrusel;
import cl.duoc.api.service.CarruselService;
import org.springframework.beans.BeanUtils;
// import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/carruseles")
public class CarruselController {

    private final CarruselService carruselService;

    // @Autowired
    public CarruselController(CarruselService carruselService) {
        this.carruselService = carruselService;
    }

    @GetMapping
    public List<CarruselDTO> getAllCarruseles() {
        List<Carrusel> carruseles = carruselService.getAllCarruseles();
        return carruseles.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    @GetMapping("/{id_caru}")
    public ResponseEntity<CarruselDTO> getCarruselById(@PathVariable("id_caru") int id_caru) {
        Optional<Carrusel> carrusel = carruselService.getCarruselById(id_caru);
        return carrusel.map(value -> ResponseEntity.ok(convertToDTO(value))).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping("/nombre/{nombre}")
    public List<CarruselDTO> buscarCarruselesPorNombre(@PathVariable("nombre") String nombre) {
        List<Carrusel> carruseles = carruselService.buscarCarruselPorNombre(nombre);
        return carruseles.stream().map(this::convertToDTO).collect(Collectors.toList());
    }
    @PostMapping
    public CarruselDTO createCarrusel(@RequestBody CarruselDTO carruselDTO) {
        Carrusel carrusel = convertToEntity(carruselDTO);
        Carrusel createdCarrusel = carruselService.createCarrusel(carrusel);
        return convertToDTO(createdCarrusel);
    }

    @PutMapping("/{id_caru}")
    public ResponseEntity<CarruselDTO> updateCarrusel(@PathVariable("id_caru") int id_caru, @RequestBody CarruselDTO carruselDTO) {
        Carrusel carrusel = convertToEntity(carruselDTO);
        try {
            Carrusel updatedCarrusel = carruselService.updateCarrusel(id_caru, carrusel);
            return ResponseEntity.ok(convertToDTO(updatedCarrusel));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id_caru}")
    public ResponseEntity<String> deleteCarrusel(@PathVariable("id_caru") int id_caru) {
        try {
            carruselService.deleteCarrusel(id_caru);
            return ResponseEntity.ok("Carrusel eliminado exitosamente");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    private CarruselDTO convertToDTO(Carrusel carrusel) {
        CarruselDTO carruselDTO = new CarruselDTO();
        BeanUtils.copyProperties(carrusel, carruselDTO);
        return carruselDTO;
    }

    private Carrusel convertToEntity(CarruselDTO carruselDTO) {
        Carrusel carrusel = new Carrusel();
        BeanUtils.copyProperties(carruselDTO, carrusel);
        return carrusel;
    }
}