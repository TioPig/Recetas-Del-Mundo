"""
Sincronizador simple Postgres -> MongoDB (datamart)
- Agrega/actualiza documentos en la colección `receta_metrics` con:
  { id_receta, total_likes, total_comments, avg_rating, ratings_count, updated_at }
- Configurable vía variables de entorno:
  PG_DSN (ej: postgresql://recetas:recetas@localhost:5432/recetas)
  MONGO_URI (ej: mongodb://localhost:27017/datamart)

Uso:
  pip install psycopg2-binary pymongo
  python sync_to_datamart.py

Este script está pensado como ejemplo/PoC. Para producción recomiendo:
- Manejar paginación/batch si hay muchas recetas.
- Ejecutarlo periódicamente (cron, systemd timer) o mediante triggers/queue.
- Añadir logging estructurado y supervisión.
"""

import os
import datetime
from urllib.parse import urlparse

try:
    import psycopg2
    import psycopg2.extras
    from pymongo import MongoClient
except Exception as e:
    raise SystemExit("Faltan dependencias: pip install psycopg2-binary pymongo\n" + str(e))

PG_DSN = os.environ.get('PG_DSN', 'postgresql://recetas:recetas@localhost:5432/recetas')
MONGO_URI = os.environ.get('MONGO_URI', 'mongodb://localhost:27017/datamart')

def aggregate_metrics(pg_conn):
    sql = """
    SELECT r.id_receta,
           COALESCE(likes.total_likes,0) AS total_likes,
           COALESCE(com.total_comments,0) AS total_comments,
           COALESCE(v.avg_rating,0)::numeric(3,2) AS avg_rating,
           COALESCE(v.ratings_count,0) AS ratings_count
    FROM receta r
    LEFT JOIN (
      SELECT id_receta, COUNT(*) FILTER (WHERE liked) AS total_likes
      FROM receta_like GROUP BY id_receta
    ) likes ON likes.id_receta = r.id_receta
    LEFT JOIN (
      SELECT id_receta, COUNT(*) AS total_comments
      FROM receta_comentario GROUP BY id_receta
    ) com ON com.id_receta = r.id_receta
    LEFT JOIN (
      SELECT id_receta, AVG(score) AS avg_rating, COUNT(*) AS ratings_count
      FROM receta_valoracion GROUP BY id_receta
    ) v ON v.id_receta = r.id_receta
    """
    cur = pg_conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    cur.execute(sql)
    rows = cur.fetchall()
    cur.close()
    results = []
    for r in rows:
        results.append({
            'id_receta': r['id_receta'],
            'total_likes': int(r['total_likes']),
            'total_comments': int(r['total_comments']),
            'avg_rating': float(r['avg_rating']) if r['ratings_count'] else None,
            'ratings_count': int(r['ratings_count']),
            'updated_at': datetime.datetime.utcnow()
        })
    return results


def upsert_to_mongo(mongo_uri, docs):
    client = MongoClient(mongo_uri)
    db = client.get_default_database()
    col = db.get_collection('receta_metrics')
    ops = []
    for d in docs:
        ops.append(
            (
                {'id_receta': d['id_receta']},
                {'$set': {
                    'total_likes': d['total_likes'],
                    'total_comments': d['total_comments'],
                    'avg_rating': d['avg_rating'],
                    'ratings_count': d['ratings_count'],
                    'updated_at': d['updated_at']
                }}
            )
        )
    # Ejecutar upserts
    for filt, upd in ops:
        col.update_one(filt, upd, upsert=True)
    client.close()


def main():
    print('Conectando a Postgres:', PG_DSN)
    pg_conn = psycopg2.connect(PG_DSN)
    try:
        docs = aggregate_metrics(pg_conn)
        print('Agregados a procesar:', len(docs))
    finally:
        pg_conn.close()

    print('Conectando a MongoDB:', MONGO_URI)
    upsert_to_mongo(MONGO_URI, docs)
    print('Sincronización completada. Registros escritos:', len(docs))


if __name__ == '__main__':
    main()
