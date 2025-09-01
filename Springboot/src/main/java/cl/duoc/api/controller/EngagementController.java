package cl.duoc.api.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import cl.duoc.api.model.entities.RecetaComentario;
import cl.duoc.api.model.entities.RecetaLike;
import cl.duoc.api.model.entities.RecetaValoracion;
import cl.duoc.api.service.EngagementService;

@RestController
@RequestMapping("/api/engagement")
public class EngagementController {

    @Autowired
    private EngagementService svc;

    @Autowired
    private cl.duoc.api.service.UsuarioService usuarioService;

    @PostMapping("/comment")
    public ResponseEntity<?> addComment(@RequestBody RecetaComentario c) {
        org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(EngagementController.class);
        // check authentication and ownership
        var auth = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            log.warn("Intento de comentar sin autenticación");
            return ResponseEntity.status(401).body("No autenticado");
        }
        Integer idUsrFromToken = (Integer) auth.getDetails();
        if (idUsrFromToken == null || !idUsrFromToken.equals(c.getIdUsr())) {
            log.warn("Usuario {} intenta comentar en nombre de {}", auth.getName(), c.getIdUsr());
            return ResponseEntity.status(403).body("No autorizado para crear comentario para otro usuario");
        }
        // verify user exists and is active
        var uopt = usuarioService.getUsuarioById(idUsrFromToken);
        if (uopt.isEmpty() || uopt.get().getActivo() != 1) {
            log.warn("Usuario {} inactivo o no existe: {}", auth.getName(), idUsrFromToken);
            return ResponseEntity.status(403).body("Usuario no activo o no existe");
        }
        log.info("Usuario {} ({}) crea comentario para receta {}", auth.getName(), idUsrFromToken, c.getIdReceta());
        return ResponseEntity.ok(svc.addComentario(c));
    }

    @PostMapping("/rating")
    public ResponseEntity<?> addRating(@RequestBody RecetaValoracion v) {
        return ResponseEntity.ok(svc.addOrUpdateValoracion(v));
    }

    @PostMapping("/like")
    public ResponseEntity<?> setLike(@RequestParam Integer idReceta, @RequestParam Integer idUsr, @RequestParam boolean liked) {
        org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(EngagementController.class);
        var auth = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            log.warn("Intento de like sin autenticación");
            return ResponseEntity.status(401).body("No autenticado");
        }
        Integer idUsrFromToken = (Integer) auth.getDetails();
        if (idUsrFromToken == null || !idUsrFromToken.equals(idUsr)) {
            log.warn("Usuario {} intenta setear like en nombre de {}", auth.getName(), idUsr);
            return ResponseEntity.status(403).body("No autorizado para operar en otro usuario");
        }
        var uopt2 = usuarioService.getUsuarioById(idUsrFromToken);
        if (uopt2.isEmpty() || uopt2.get().getActivo() != 1) {
            log.warn("Usuario {} inactivo o no existe: {}", auth.getName(), idUsrFromToken);
            return ResponseEntity.status(403).body("Usuario no activo o no existe");
        }
        log.info("Usuario {} ({}) setLike receta {} -> {}", auth.getName(), idUsrFromToken, idReceta, liked);
        RecetaLike r = svc.setLike(idReceta, idUsr, liked);
        return ResponseEntity.ok(r);
    }
}
