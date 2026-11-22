# Stack tecnológico

## Stack aprobado para proyectos nuevos
Todo proyecto nuevo usa este stack y se crea con la skill `/new-project`. El detalle de cada pieza está en la regla `stack` de su pack.

| Necesidad | Tecnología | Pack |
|-----------|------------|------|
| Backend / API | Java (última LTS) + Spring Boot, Gradle con Kotlin DSL, arquitectura hexagonal | `java-spring` |
| Aplicación web | React + Vite (SPA) con TypeScript | `typescript` |
| Web de contenido / landing | Astro con TypeScript | `typescript` |
| App móvil | Kotlin Multiplatform + Compose Multiplatform | `kotlin-compose` |
| Base de datos | PostgreSQL con migraciones Flyway | `postgresql` |
| Empaquetado y entorno local | Docker (imagen en GHCR) y Docker Compose | `docker` |
| CI/CD | GitHub Actions (regla `ci-cd`) | `core` |

- Un repositorio por componente desplegable; el contrato entre ellos es la especificación OpenAPI del backend.

## Salirse del stack
- No introduzcas un lenguaje, framework, base de datos o librería que sustituya o solape con el stack aprobado sin un ADR aceptado por el usuario: usa `/tech-decision`.
- Antes de añadir una dependencia, comprueba si el stack o el proyecto ya cubren esa necesidad.
- En proyectos existentes con otro stack, respeta el suyo: no migres sin que te lo pidan; propónlo como tarea aparte con su ADR.
