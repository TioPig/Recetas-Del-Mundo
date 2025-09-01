package cl.duoc.api.service;

import java.sql.Timestamp;
import java.time.LocalDateTime;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import cl.duoc.api.model.entities.RecetaComentario;
import cl.duoc.api.model.entities.RecetaLike;
import cl.duoc.api.model.entities.RecetaLikeId;
import cl.duoc.api.model.entities.RecetaValoracion;
import cl.duoc.api.model.repositories.RecetaComentarioRepository;
import cl.duoc.api.model.repositories.RecetaLikeRepository;
import cl.duoc.api.model.repositories.RecetaValoracionRepository;

@Service
public class EngagementService {

    @Autowired
    private RecetaComentarioRepository comentarioRepo;

    @Autowired
    private RecetaValoracionRepository valoracionRepo;

    @Autowired
    private RecetaLikeRepository likeRepo;

    @Autowired
    private JdbcTemplate jdbc;

    @Transactional
    public RecetaComentario addComentario(RecetaComentario c) {
        c.setFecha(LocalDateTime.now());
        RecetaComentario saved = comentarioRepo.save(c);
    // Notify datamart listener using pg_notify
    jdbc.execute("SELECT pg_notify('receta_changes', 'comment:' || " + saved.getId() + ")");
        return saved;
    }

    @Transactional
    public RecetaValoracion addOrUpdateValoracion(RecetaValoracion v) {
        v.setFecha(LocalDateTime.now());
        RecetaValoracion saved = valoracionRepo.save(v);
    jdbc.execute("SELECT pg_notify('receta_changes', 'rating:' || " + saved.getId() + ")");
        return saved;
    }

    @Transactional
    public RecetaLike setLike(Integer idReceta, Integer idUsr, boolean liked) {
    RecetaLikeId key = new RecetaLikeId();
    key.setIdReceta(idReceta);
    key.setIdUsr(idUsr);
        RecetaLike rl = new RecetaLike();
        rl.setId(key);
        rl.setLiked(liked);
        rl.setFecha(LocalDateTime.now());
        RecetaLike saved = likeRepo.save(rl);
    jdbc.execute("SELECT pg_notify('receta_changes', 'like:' || " + idReceta + ")");
        return saved;
    }
}
