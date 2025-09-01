
package cl.duoc.api.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import cl.duoc.api.model.entities.Receta;
import cl.duoc.api.model.dto.RecetaDTO;
import cl.duoc.api.model.repositories.RecetaRepository;
import lombok.extern.log4j.Log4j2;
import java.util.List;
import java.util.Optional;

@Service
@Log4j2
public class RecetaService {

    @Autowired
    RecetaRepository recetaRepository;

    public String crearReceta(RecetaDTO recetaDTO){
        Receta receta = translateRecetaDto(recetaDTO);
        recetaRepository.save(receta);
        return "Receta creada";
    }

    public Receta translateRecetaDto(RecetaDTO recetaDTO){
        Receta receta = new Receta();
        receta.setNombre(recetaDTO.getNombre());
        receta.setUrl_imagen(recetaDTO.getUrl_imagen());
        receta.setIngrediente(recetaDTO.getIngrediente());
        receta.setPreparacion(recetaDTO.getPreparacion());
        receta.setEstado(recetaDTO.getEstado());
        receta.setId_cat(recetaDTO.getId_cat());
        receta.setId_pais(recetaDTO.getId_pais());
        receta.setFecha_creacion(recetaDTO.getFecha_creacion());
        receta.setId_usr(recetaDTO.getId_usr());
        return receta;
    }

    public List<Receta> listarTodasRecetas() {
        List<Receta> recetas = recetaRepository.findAll();
        return recetas;
    }

    public Page<Receta> listarTodasRecetasPaginadas(Pageable pageable) {
        return recetaRepository.findAll(pageable);
    }

    public List<Receta> buscarRecetasPorNombre(String nombre) {
        List<Receta> exact = recetaRepository.findByNombre(nombre);
        if (exact != null && !exact.isEmpty()) return exact;
        // fallback: buscar parcialmente (case-insensitive)
        return recetaRepository.findByNombreContainingIgnoreCase(nombre);
    }

    // búsqueda parcial (contiene, case-insensitive)
    public List<Receta> buscarRecetasPorNombreParcial(String nombre) {
        return recetaRepository.findByNombreContainingIgnoreCase(nombre);
    }

    // búsqueda por id de país
    public List<Receta> buscarRecetasPorPaisId(int id_pais) {
    return recetaRepository.findByIdPaisNative(id_pais);
    }

    public Optional<Receta> buscarRecetaPorId(int id) {
        return recetaRepository.findById(id);
    }
    public boolean modificarReceta(int idReceta, RecetaDTO recetaDTO) {
        Optional<Receta> optionalReceta = recetaRepository.findById(idReceta);
        if (optionalReceta.isPresent()) {
            Receta receta = optionalReceta.get();
            receta.setNombre(recetaDTO.getNombre());
            receta.setUrl_imagen(recetaDTO.getUrl_imagen());
            receta.setIngrediente(recetaDTO.getIngrediente());
            receta.setPreparacion(recetaDTO.getPreparacion());
            receta.setEstado(recetaDTO.getEstado());
            receta.setId_cat(recetaDTO.getId_cat());
            receta.setId_pais(recetaDTO.getId_pais());
            receta.setFecha_creacion(recetaDTO.getFecha_creacion());
            receta.setId_usr(recetaDTO.getId_usr());
            recetaRepository.save(receta);
            return true;
        } else {
            return false;
        }
    }

    public long contarRecetas() {
        return recetaRepository.count();
    }
}
