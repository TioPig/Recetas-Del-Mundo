package cl.duoc.api.controller;

import cl.duoc.api.model.dto.CategoriaDTO;
import cl.duoc.api.model.entities.Categoria;
import cl.duoc.api.service.CategoriaService;
import org.springframework.beans.BeanUtils;
// import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/categorias")
public class CategoriaController {

    private final CategoriaService categoriaService;

    // @Autowired
    public CategoriaController(CategoriaService categoriaService) {
        this.categoriaService = categoriaService;
    }

    @GetMapping
    public List<CategoriaDTO> getAllCategorias() {
        List<Categoria> categorias = categoriaService.getAllCategorias();
        return categorias.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    @GetMapping("/{id_cat}")
    public ResponseEntity<CategoriaDTO> getCategoriaById(@PathVariable("id_cat") int id_cat) {
        Optional<Categoria> categoria = categoriaService.getCategoriaById(id_cat);
        return categoria.map(value -> ResponseEntity.ok(convertToDTO(value))).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping("/nombre/{nombre}")
    public List<CategoriaDTO> buscarCategoriaPorNombre(@PathVariable("nombre") String nombre) {
        List<Categoria> categorias = categoriaService.buscarCategoriaPorNombre(nombre);
        return categorias.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    @PostMapping
    public CategoriaDTO createCategoria(@RequestBody CategoriaDTO categoriaDTO) {
        Categoria categoria = convertToEntity(categoriaDTO);
        Categoria createdCategoria = categoriaService.createCategoria(categoria);
        return convertToDTO(createdCategoria);
    }

    @PutMapping("/{id_cat}")
    public ResponseEntity<CategoriaDTO> updateCategoria(@PathVariable("id_cat") int id_cat, @RequestBody CategoriaDTO categoriaDTO) {
        Categoria categoria = convertToEntity(categoriaDTO);
        try {
            Categoria updatedCategoria = categoriaService.updateCategoria(id_cat, categoria);
            return ResponseEntity.ok(convertToDTO(updatedCategoria));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id_cat}")
    public ResponseEntity<String> deleteCategoria(@PathVariable("id_cat") int id_cat) {
        try {
            categoriaService.deleteCategoria(id_cat);
            return ResponseEntity.ok("Categoría eliminada exitosamente");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    private CategoriaDTO convertToDTO(Categoria categoria) {
        CategoriaDTO categoriaDTO = new CategoriaDTO();
        BeanUtils.copyProperties(categoria, categoriaDTO);
        return categoriaDTO;
    }

    private Categoria convertToEntity(CategoriaDTO categoriaDTO) {
        Categoria categoria = new Categoria();
        BeanUtils.copyProperties(categoriaDTO, categoria);
        return categoria;
    }
}