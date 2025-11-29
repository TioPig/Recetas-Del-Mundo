package cl.duoc.api.controller.admin;

import cl.duoc.api.model.entities.Perfil;
import cl.duoc.api.service.PerfilService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/admin/perfil")
@Tag(name = "🛡️ Admin - Perfil", description = "CRUD de perfiles de usuario (administración)")
public class PerfilController {

    @Autowired
    private PerfilService perfilService;

    @GetMapping
    @Operation(summary = "Listar perfiles")
    public ResponseEntity<List<Perfil>> list() {
        List<Perfil> all = perfilService.findAll();
        return new ResponseEntity<>(all, HttpStatus.OK);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener perfil por id")
    public ResponseEntity<Perfil> getById(@PathVariable Integer id) {
        Optional<Perfil> p = Optional.ofNullable(perfilService.findById(id));
        return p.map(perf -> new ResponseEntity<>(perf, HttpStatus.OK)).orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    @PostMapping
    @Operation(summary = "Crear nuevo perfil")
    public ResponseEntity<?> create(@RequestBody Perfil perfil) {
        Map<String,Object> resp = new HashMap<>();
        if (perfil.getNombre() == null || perfil.getNombre().trim().isEmpty()) {
            resp.put("exito", false); resp.put("mensaje", "Nombre de perfil requerido");
            return ResponseEntity.badRequest().body(resp);
        }
        // evitar duplicados por nombre
        Perfil exists = perfilService.findByNombre(perfil.getNombre().trim());
        if (exists != null) { resp.put("exito", false); resp.put("mensaje", "Perfil ya existe"); return ResponseEntity.status(HttpStatus.CONFLICT).body(resp); }
        Perfil saved = perfilService.save(perfil);
        resp.put("exito", true); resp.put("data", saved); resp.put("mensaje", "Perfil creado");
        return ResponseEntity.status(HttpStatus.CREATED).body(resp);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Actualizar perfil")
    public ResponseEntity<?> update(@PathVariable Integer id, @RequestBody Perfil perfil) {
        Map<String,Object> resp = new HashMap<>();
        Perfil existing = perfilService.findById(id);
        if (existing == null) { return ResponseEntity.status(HttpStatus.NOT_FOUND).build(); }
        if (perfil.getNombre() == null || perfil.getNombre().trim().isEmpty()) { resp.put("exito", false); resp.put("mensaje", "Nombre requerido"); return ResponseEntity.badRequest().body(resp); }
        existing.setNombre(perfil.getNombre().trim());
        Perfil saved = perfilService.save(existing);
        resp.put("exito", true); resp.put("data", saved); resp.put("mensaje", "Perfil actualizado");
        return ResponseEntity.ok(resp);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar perfil")
    public ResponseEntity<?> delete(@PathVariable Integer id) {
        Map<String,Object> resp = new HashMap<>();
        if (!perfilService.existsById(id)) { return ResponseEntity.status(HttpStatus.NOT_FOUND).build(); }
        perfilService.deleteById(id);
        resp.put("exito", true); resp.put("mensaje", "Perfil eliminado");
        return ResponseEntity.ok(resp);
    }
}
