# Stack tecnológico

## Stack aprobado para proyectos nuevos
Todo proyecto nuevo usa este stack; se crea con la skill `/new-project`. El detalle de librerías y herramientas de cada pieza está en la regla `stack` de su pack.

| Necesidad | Tecnología | Pack |
|-----------|------------|------|
| Backend / API | Java (última LTS) + Spring Boot, Gradle con Kotlin DSL, arquitectura hexagonal | `java-spring` |
| Aplicación web | React + Vite (SPA) con TypeScript, consume la API del backend | `typescript` |
| Web de contenido / landing | Astro con TypeScript | `typescript` |
| App móvil | Kotlin Multiplatform + Compose Multiplatform (Android e iOS) | `kotlin-compose` |
| Base de datos | PostgreSQL con migraciones Flyway | `postgresql` |
| Empaquetado y entorno local | Docker (imagen en GHCR) y Docker Compose | `docker` |
| CI/CD | GitHub Actions (regla `ci-cd`) | `core` |

- Un repositorio por componente desplegable (backend, web, app), cada uno con su CI/CD y su versión. El contrato entre ellos es la especificación OpenAPI del backend.
- Usa la última versión estable (o LTS) de cada tecnología al crear el proyecto y fíjala: wrapper, toolchain, `.nvmrc`, version catalog, lockfile.
- Mantén las dependencias al día con Renovate o Dependabot.

## Salirse del stack
- No introduzcas un lenguaje, framework, base de datos o librería que sustituya o solape con una del stack aprobado sin una decisión documentada (ADR) y aceptada por el usuario: usa la skill `/tech-decision`.
- Antes de añadir una dependencia, comprueba si el stack o el proyecto ya cubren esa necesidad.
- En proyectos existentes con otro stack, respeta el suyo: no migres de tecnología sin que te lo pidan; propónlo como tarea aparte con su ADR.
