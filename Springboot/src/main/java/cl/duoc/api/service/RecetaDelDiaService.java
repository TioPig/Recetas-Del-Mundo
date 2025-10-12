package cl.duoc.api.service;

import cl.duoc.api.model.entities.Receta;
import cl.duoc.api.model.entities.RecetaDelDia;
import cl.duoc.api.model.repositories.RecetaDelDiaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.Random;

@Service
public class RecetaDelDiaService {

    @Autowired
    private RecetaService recetaService;

    @Autowired
    private RecetaDelDiaRepository recetaDelDiaRepository;

    private volatile Receta cachedReceta;
    private volatile LocalDate cachedDate;

    public Optional<Receta> getRecetaDelDia() {
        LocalDate today = LocalDate.now();
        if (cachedReceta != null && cachedDate != null && cachedDate.equals(today)) {
            return Optional.of(cachedReceta);
        }

        synchronized (this) {
            if (cachedReceta != null && cachedDate != null && cachedDate.equals(today)) {
                return Optional.of(cachedReceta);
            }

            Optional<RecetaDelDia> existing = recetaDelDiaRepository.findById(today);
            if (existing.isPresent()) {
                Integer id = existing.get().getIdReceta();
                Optional<Receta> recetaOpt = recetaService.getRecetaById(id);
                if (recetaOpt.isPresent() && recetaOpt.get().getEstado() != null && recetaOpt.get().getEstado() == 1) {
                    cachedReceta = recetaOpt.get();
                    cachedDate = today;
                    return recetaOpt;
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

            try {
                recetaDelDiaRepository.save(new RecetaDelDia(today, seleccionada.getIdReceta()));
            } catch (Exception ignored) {}

            cachedReceta = seleccionada;
            cachedDate = today;
            return Optional.of(seleccionada);
        }
    }
}
