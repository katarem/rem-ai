---
paths:
  - "**/*.java"
  - "**/application*.yml"
  - "**/application*.yaml"
  - "**/application*.properties"
---

# Spring Boot

## Inyección y configuración
- Inyección por constructor (con campos `final`). Nunca `@Autowired` en campos.
- Configuración tipada con `@ConfigurationProperties` (preferiblemente `record`) y `@Validated`, en lugar de `@Value` disperso.
- Secretos siempre por variables de entorno o config server (`${DB_PASSWORD}`), nunca en `application.yml` versionado.
- Usa perfiles (`application-{perfil}.yml`) para diferencias entre entornos.

## API REST
- Los controladores solo traducen HTTP ↔ caso de uso: sin lógica de negocio ni acceso a repositorios.
- Nunca expongas entidades de dominio ni JPA en la API: usa DTOs (`record`) de request/response.
- Valida la entrada con Jakarta Validation (`@Valid`, `@NotNull`, `@Size`…).
- Errores centralizados en un `@RestControllerAdvice` que devuelva `ProblemDetail` (RFC 9457).
- Códigos HTTP correctos: `201` + `Location` al crear, `204` sin contenido, `404`/`409`/`422` según el caso.

## Persistencia
- `@Transactional` en la capa de aplicación (casos de uso), no en controladores ni repositorios.
- Evita el problema N+1: `JOIN FETCH`, `@EntityGraph` o proyecciones.
- Esquema con migraciones (Flyway/Liquibase). `ddl-auto` solo `validate` o `none` fuera de tests.

## WebFlux (proyectos reactivos)
- Nunca bloquees en el hilo reactivo: nada de `.block()`, JDBC ni llamadas bloqueantes sin `subscribeOn(Schedulers.boundedElastic())`.
- Devuelve `Mono`/`Flux` de extremo a extremo; no te suscribas manualmente dentro de la cadena.

## Observabilidad
- Actuator con `health` y `info` expuestos; el resto de endpoints, protegidos.
