# Diagrama Relacional - Base de Datos Recetas del Mundo

## Entidades y Atributos

### Usuario
- **id_usr** (INTEGER, PK, Auto-generated)
- nombre (VARCHAR(255))
- email (VARCHAR(255))
- password (VARCHAR(255))
- fecha_registro (TIMESTAMP)
- rol (VARCHAR(50))
- estado (INTEGER)

### Categoria
- **id_cat** (INTEGER, PK, Auto-generated)
- nombre (VARCHAR(255))
- descripcion (TEXT)
- fecha_creacion (TIMESTAMP)
- id_usr (INTEGER, FK → Usuario.id_usr)

### Pais
- **id_pais** (INTEGER, PK, Auto-generated)
- nombre (VARCHAR(255))
- descripcion (TEXT)
- fecha_creacion (TIMESTAMP)
- id_usr (INTEGER, FK → Usuario.id_usr)

### Receta
- **id_receta** (INTEGER, PK, Auto-generated)
- titulo (VARCHAR(255))
- descripcion (TEXT)
- instrucciones (TEXT)
- tiempo_preparacion (INTEGER)
- dificultad (VARCHAR(50))
- porciones (INTEGER)
- imagen_url (VARCHAR(500))
- fecha_creacion (TIMESTAMP)
- id_cat (INTEGER, FK → Categoria.id_cat)
- id_pais (INTEGER, FK → Pais.id_pais)
- id_usr (INTEGER, FK → Usuario.id_usr)

### RecetaLike
- **id_receta** (INTEGER, FK → Receta.id_receta, PK)
- **id_usr** (INTEGER, FK → Usuario.id_usr, PK)
- fecha_like (TIMESTAMP)

### RecetaComentario
- **id_comentario** (INTEGER, PK, Auto-generated)
- comentario (TEXT)
- fecha_comentario (TIMESTAMP)
- id_receta (INTEGER, FK → Receta.id_receta)
- id_usr (INTEGER, FK → Usuario.id_usr)

### RecetaValoracion
- **id_valoracion** (INTEGER, PK, Auto-generated)
- valoracion (INTEGER)
- fecha_valoracion (TIMESTAMP)
- id_receta (INTEGER, FK → Receta.id_receta)
- id_usr (INTEGER, FK → Usuario.id_usr)

### Carrusel
- **id_caru** (INTEGER, PK, Auto-generated)
- nombre (VARCHAR(255))
- url_imagen (VARCHAR(500))
- estado (INTEGER)
- fecha_creacion (TIMESTAMP)
- id_usr (INTEGER, FK → Usuario.id_usr)

### Pago
- **id_pago** (INTEGER, PK, Auto-generated)
- order_id (VARCHAR(255))
- amount (INTEGER)
- status (VARCHAR(50))
- flow_token (VARCHAR(255))
- fecha_creacion (TIMESTAMP)
- id_usr (INTEGER, FK → Usuario.id_usr)

## Relaciones

```
Usuario (1) ────► (N) Categoria     (Usuario crea Categorías)
Usuario (1) ────► (N) Pais          (Usuario crea Países)
Usuario (1) ────► (N) Receta        (Usuario crea Recetas)
Usuario (1) ────► (N) RecetaLike    (Usuario da likes)
Usuario (1) ────► (N) RecetaComentario (Usuario comenta)
Usuario (1) ────► (N) RecetaValoracion (Usuario valora)
Usuario (1) ────► (N) Carrusel      (Usuario crea elementos del carrusel)
Usuario (1) ────► (N) Pago          (Usuario realiza pagos)

Categoria (1) ────► (N) Receta      (Categoría clasifica Recetas)
Pais (1) ────► (N) Receta           (País pertenece a Recetas)

Receta (1) ────► (N) RecetaLike     (Receta recibe likes)
Receta (1) ────► (N) RecetaComentario (Receta recibe comentarios)
Receta (1) ────► (N) RecetaValoracion (Receta recibe valoraciones)
```

## Estadísticas de la Base de Datos
- **Total de Entidades**: 9
- **Total de Relaciones**: 12
- **Entidad Central**: Usuario (conecta la mayoría de las entidades)
- **Entidad Principal**: Receta (con más relaciones entrantes)
- **Relaciones Compuestas**: RecetaLike (clave primaria compuesta)

## Notas Técnicas
- Todas las entidades usan generación automática de IDs con IDENTITY
- Las relaciones están implementadas con claves foráneas (FK)
- RecetaLike usa una clave primaria compuesta (id_receta + id_usr)
- Las entidades Carrusel y Pago tienen relaciones con Usuario pero sin anotaciones JPA @ManyToOne/@JoinColumn definidas en el código
