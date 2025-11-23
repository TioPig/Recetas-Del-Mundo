package cl.duoc.api.service;

import cl.duoc.api.model.entities.Receta;
import cl.duoc.api.model.entities.RecetaDelDia;
import cl.duoc.api.model.repositories.RecetaDelDiaRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.Random;

@Service
public class RecetaDelDiaService {

    private static final Logger logger = LoggerFactory.getLogger(RecetaDelDiaService.class);

    @Autowired
    private RecetaService recetaService;

    @Autowired
    private RecetaDelDiaRepository recetaDelDiaRepository;

    private volatile Receta cachedReceta;
    private volatile LocalDate cachedDate;

    @Transactional
    public Optional<Receta> getRecetaDelDia() {
        LocalDate today = LocalDate.now();
        if (cachedReceta != null && cachedDate != null && cachedDate.equals(today)) {
            return Optional.of(cachedReceta);
        }

        synchronized (this) {
            if (cachedReceta != null && cachedDate != null && cachedDate.equals(today)) {
                return Optional.of(cachedReceta);
            }

            // Si ya existe registro en BD para hoy, devolverlo
            Optional<RecetaDelDia> existing = recetaDelDiaRepository.findById(today);
            if (existing.isPresent()) {
                Integer id = existing.get().getIdReceta();
                Optional<Receta> recetaOpt = recetaService.getRecetaById(id);
                if (recetaOpt.isPresent() && recetaOpt.get().getEstado() != null && recetaOpt.get().getEstado() == 1) {
                    cachedReceta = recetaOpt.get();
                    cachedDate = today;
                    return recetaOpt;
                } else {
                    // Si la receta guardada ya no está activa, borramos el registro y continuamos con nueva selección
                    try {
                        recetaDelDiaRepository.deleteById(today);
                        logger.info("Registro receta_del_dia eliminado porque la receta referenciada no está activa: {}", id);
                    } catch (Exception e) {
                        logger.warn("No se pudo eliminar registro antiguo de receta_del_dia: {}", e.getMessage());
                    }
                }
            }

            List<Receta> activas = recetaService.getActiveRecetas();
            if (activas == null || activas.isEmpty()) {
                cachedReceta = null;
                cachedDate = today;
                return Optional.empty();
            }

            long daySeed = today.toEpochDay();
            long salt = 0L;
            try {
                String env = System.getenv("APP_RECETA_DEL_DIA_SEED");
                if (env != null && !env.isBlank()) {
                    salt = env.hashCode();
                }
            } catch (Exception ignored) {}
            Random rnd = new Random(daySeed ^ salt);
            int idx = rnd.nextInt(activas.size());
            Receta seleccionada = activas.get(idx);

            // Intentar persistir el registro de receta del día de forma transaccional
            try {
                recetaDelDiaRepository.saveAndFlush(new RecetaDelDia(today, seleccionada.getIdReceta()));
                logger.info("Receta del día guardada en BD: fecha={}, idReceta={}", today, seleccionada.getIdReceta());
            } catch (DataIntegrityViolationException dive) {
                // Puede ocurrir si otro proceso ya insertó el registro (concorrencia). Recuperamos lo insertado.
                logger.warn("Conflicto al insertar receta_del_dia (posible concurrencia): {}", dive.getMessage());
                try {
                    Optional<RecetaDelDia> existingAfter = recetaDelDiaRepository.findById(today);
                    if (existingAfter.isPresent()) {
                        Integer id = existingAfter.get().getIdReceta();
                        Optional<Receta> recetaOpt = recetaService.getRecetaById(id);
                        if (recetaOpt.isPresent()) {
                            seleccionada = recetaOpt.get();
                        }
                    }
                } catch (Exception e) {
                    logger.error("Error recuperando registro existente tras DataIntegrityViolation: {}", e.getMessage());
                }
            } catch (Exception e) {
                // No fallar la petición por problemas al persistir; registrar y seguir con la selección en memoria
                logger.error("No se pudo persistir receta_del_dia: {}", e.getMessage());
            }

            cachedReceta = seleccionada;
            cachedDate = today;
            return Optional.of(seleccionada);
        }
    }
}
