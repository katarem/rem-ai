---
paths:
  - "**/*.sql"
  - "**/*Repository.java"
  - "**/*Entity.java"
---

# PostgreSQL

## Migraciones (Flyway)
- Todo cambio de esquema es una migración versionada en `src/main/resources/db/migration`: `V<n>__<descripcion_en_snake_case>.sql`.
- Una migración aplicada nunca se modifica ni se borra: los cambios van en una migración nueva.
- Migraciones compatibles hacia atrás con la versión anterior del código desplegada (*expand and contract*): añade columnas como *nullable* o con valor por defecto, rellena, y elimina lo antiguo en una versión posterior.
- Índices sobre tablas grandes con `CREATE INDEX CONCURRENTLY` en una migración propia, sin transacción.

## Esquema
- Nombres en inglés, `snake_case` y tablas en plural (`orders`, `order_lines`).
- Claves primarias `uuid` (generadas por la aplicación, UUIDv7) o `bigint generated always as identity`; nunca `serial`.
- Fechas con `timestamptz`, dinero con `numeric(19, 4)` o en céntimos como `bigint`; nunca `float` para importes.
- `text` en lugar de `varchar(n)` salvo que la longitud sea una regla de negocio, validada además con `CHECK`.
- `NOT NULL` por defecto; claves foráneas con índice en la columna que referencia.
- Restricciones en la base de datos (`UNIQUE`, `CHECK`, `FOREIGN KEY`) para las invariantes que no deben romperse nunca.

## Consultas
- Siempre parametrizadas; nunca concatenes valores en SQL.
- Pagina por *keyset* (`WHERE id > :last ORDER BY id LIMIT :n`) en listados grandes, no con `OFFSET`.
- Revisa con `EXPLAIN ANALYZE` las consultas nuevas sobre tablas grandes.
- El usuario de la aplicación no es superusuario ni propietario del esquema: solo tiene los permisos que necesita.
