---
paths:
  - "**/build.gradle.kts"
  - "**/settings.gradle.kts"
  - "**/gradle/libs.versions.toml"
  - "**/gradle-wrapper.properties"
  - "**/pom.xml"
---

# Stack de backend Java / Spring

Stack aprobado para servicios nuevos (regla `tech-stack`). En proyectos existentes, respeta lo que ya usen.

## Build
- Java en la última LTS, fijada con *toolchain* de Gradle (`java { toolchain { languageVersion = JavaLanguageVersion.of(25) } }`).
- Spring Boot en la última versión estable, con el plugin `org.springframework.boot` y `io.spring.dependency-management`.
- Gradle Wrapper con Kotlin DSL (`build.gradle.kts`). Versiones de plugins y librerías en `gradle/libs.versions.toml`, nunca escritas a mano en el build.
- Un solo módulo con paquetes `domain`, `application` e `infrastructure` por contexto (regla `hexagonal-ddd`); varios módulos Gradle solo si hay más de un desplegable.

## Librerías aprobadas
| Necesidad | Librería |
|-----------|----------|
| API REST | Spring Web MVC (WebFlux solo con un requisito de streaming o alta concurrencia justificado en un ADR) |
| Validación | Jakarta Validation (`spring-boot-starter-validation`) |
| Persistencia | Spring Data JPA + driver de PostgreSQL; Spring JDBC `JdbcClient` para consultas que no encajan en JPA |
| Migraciones | Flyway (`flyway-core` + `flyway-database-postgresql`) |
| Seguridad | Spring Security; OAuth2 Resource Server con JWT para APIs |
| Documentación de la API | springdoc-openapi: la especificación OpenAPI se publica en `/v3/api-docs` y es el contrato con los clientes |
| Clientes HTTP | `RestClient` de Spring con interfaces `@HttpExchange` |
| Observabilidad | Actuator + Micrometer (métricas y trazas), logs en JSON en entornos desplegados |
| Tests | JUnit 5, AssertJ, Mockito, Testcontainers (PostgreSQL), WireMock, ArchUnit, Awaitility |
| Formato | Spotless con `palantir-java-format`, aplicado en `./gradlew check` |

## No uses
- Lombok, MapStruct ni librerías de mapeo por reflexión: *records* y *mappers* explícitos.
- H2 u otra base de datos embebida en tests: Testcontainers con PostgreSQL.
- `RestTemplate` ni `WebClient` en código bloqueante: `RestClient`.
- Maven en proyectos nuevos: Gradle.
