package cl.duoc.api.service;

import java.time.Instant;
import java.util.Map;

import javax.annotation.PostConstruct;

import org.bson.Document;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

@Component
public class RecetaChangeListener {

    private final MongoTemplate mongo;
    private final JdbcTemplate jdbc;

    public RecetaChangeListener(MongoTemplate mongo, JdbcTemplate jdbc) {
        this.mongo = mongo;
        this.jdbc = jdbc;
    }

    @PostConstruct
    @Async
    public void startListener() {
        // Use a lightweight LISTEN loop via JDBC; Postgres JDBC supports PGConnection but to keep compatibility
        // we'll poll the 'pg_notifications' via a simple NOTIFY-driven approach: create a helper table to store last events
        // However, here we assume the DB triggers call NOTIFY; instead of low-level PG notifications we poll a small table
        // For PoC we'll run a periodic poll of recent engagement changes by looking at timestamps in engagement tables.
        Thread t = new Thread(() -> {
            while (true) {
                try {
                    // get distinct id_receta that changed recently (last 5s)
                    String sql = "SELECT id_receta FROM (" +
                            " SELECT id_receta, GREATEST(COALESCE(MAX(fecha), '1970-01-01') ) as last_event FROM (" +
                            "  SELECT id_receta, fecha FROM receta_like UNION ALL SELECT id_receta, fecha FROM receta_comentario UNION ALL SELECT id_receta, fecha FROM receta_valoracion" +
                            " ) s GROUP BY id_receta" +
                            " ) t WHERE last_event > NOW() - INTERVAL '10 seconds'";
                    var ids = jdbc.queryForList(sql, Integer.class);
                    for (Integer idReceta : ids) {
                        upsertMetrics(idReceta);
                    }
                    Thread.sleep(5000);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    break;
                } catch (Exception e) {
                    // log and continue
                    e.printStackTrace();
                    try { Thread.sleep(5000); } catch (InterruptedException ex) { Thread.currentThread().interrupt(); break; }
                }
            }
        });
        t.setDaemon(true);
        t.start();
    }

    private void upsertMetrics(Integer idReceta) {
        try {
            String aggSql = "SELECT COALESCE(l.total_likes,0) AS total_likes, COALESCE(c.total_comments,0) AS total_comments, COALESCE(v.avg_rating,0) AS avg_rating, COALESCE(v.ratings_count,0) AS ratings_count FROM (SELECT 1) base " +
                    " LEFT JOIN (SELECT id_receta, COUNT(*) FILTER (WHERE liked) AS total_likes FROM receta_like WHERE id_receta = ? GROUP BY id_receta) l ON TRUE " +
                    " LEFT JOIN (SELECT id_receta, COUNT(*) AS total_comments FROM receta_comentario WHERE id_receta = ? GROUP BY id_receta) c ON TRUE " +
                    " LEFT JOIN (SELECT id_receta, AVG(score) AS avg_rating, COUNT(*) AS ratings_count FROM receta_valoracion WHERE id_receta = ? GROUP BY id_receta) v ON TRUE";

            Map<String, Object> row = jdbc.queryForMap(aggSql, idReceta, idReceta, idReceta);

            Document doc = new Document();
            doc.put("id_receta", idReceta);
            doc.put("total_likes", ((Number)row.get("total_likes")).intValue());
            doc.put("total_comments", ((Number)row.get("total_comments")).intValue());
            Number rc = (Number) row.get("ratings_count");
            int ratingsCount = rc == null ? 0 : rc.intValue();
            doc.put("ratings_count", ratingsCount);
            if (ratingsCount > 0) {
                Number avg = (Number) row.get("avg_rating");
                doc.put("avg_rating", avg == null ? null : avg.doubleValue());
            } else {
                doc.put("avg_rating", null);
            }
            doc.put("updated_at", Instant.now());

            mongo.getCollection("receta_metrics").replaceOne(new Document("id_receta", idReceta), doc, new com.mongodb.client.model.ReplaceOptions().upsert(true));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
