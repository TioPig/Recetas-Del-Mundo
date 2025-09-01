package cl.duoc.api.controller;

import cl.duoc.api.model.dto.PaisDTO;
import cl.duoc.api.model.entities.Pais;
import cl.duoc.api.service.PaisService;
import org.springframework.beans.BeanUtils;
// import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/paises")
public class PaisController {

    private final PaisService paisService;

    // @Autowired
    public PaisController(PaisService paisService) {
        this.paisService = paisService;
    }

    @GetMapping
    public List<PaisDTO> getAllPaises() {
        List<Pais> paises = paisService.getAllPaises();
        return paises.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    @GetMapping("/{id_pais}")
    public ResponseEntity<PaisDTO> getPaisById(@PathVariable("id_pais") int id_pais) {
        Optional<Pais> pais = paisService.getPaisById(id_pais);
        return pais.map(value -> ResponseEntity.ok(convertToDTO(value))).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping("/nombre/{nombre}")
    public List<PaisDTO> buscarPaisPorNombre(@PathVariable("nombre") String nombre) {
        List<Pais> paises = paisService.buscarPaisPorNombre(nombre);
        return paises.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    @PostMapping
    public PaisDTO createPais(@RequestBody PaisDTO paisDTO) {
        Pais pais = convertToEntity(paisDTO);
        Pais createdPais = paisService.createPais(pais);
        return convertToDTO(createdPais);
    }

    @PutMapping("/{id_pais}")
    public ResponseEntity<PaisDTO> updatePais(@PathVariable("id_pais") int id_pais, @RequestBody PaisDTO paisDTO) {
        Pais pais = convertToEntity(paisDTO);
        try {
            Pais updatedPais = paisService.updatePais(id_pais, pais);
            return ResponseEntity.ok(convertToDTO(updatedPais));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id_pais}")
    public ResponseEntity<String> deletePais(@PathVariable("id_pais") int id_pais) {
        try {
            paisService.deletePais(id_pais);
            return ResponseEntity.ok("País eliminado exitosamente");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    private PaisDTO convertToDTO(Pais pais) {
        PaisDTO paisDTO = new PaisDTO();
        BeanUtils.copyProperties(pais, paisDTO);
        return paisDTO;
    }

    private Pais convertToEntity(PaisDTO paisDTO) {
        Pais pais = new Pais();
        BeanUtils.copyProperties(paisDTO, pais);
        return pais;
    }
}