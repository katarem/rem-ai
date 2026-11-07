---
name: new-project
description: Crea un proyecto nuevo (backend, aplicación web, web de contenido o app móvil) con el stack aprobado de la regla tech-stack - estructura, build, calidad, tests, Docker, CI/CD y packs de rem-ai - listo para empezar a desarrollar producto. Úsalo cuando el usuario quiera empezar un proyecto, servicio, web o app desde cero.
---

# Crear un proyecto nuevo

Resultado: un repositorio con el stack aprobado (regla `tech-stack` y regla `stack` del pack de la tecnología) que compila, pasa lint y tests, arranca en local y tiene CI/CD, sin ninguna funcionalidad de producto todavía.

## 1. Define el proyecto
- Pregunta al usuario lo que no esté claro: nombre (en inglés y kebab-case), propósito en una frase, tipo de componente (backend, aplicación web, web de contenido, app móvil) y, si hay varios, cuáles. Cada componente desplegable es un repositorio propio.
- Si algún requisito no encaja en el stack aprobado, resuélvelo antes con `/tech-decision`.
- Acuerda los resultados (`/odd-cycle`). Como mínimo:
  - `O1` El build con lint y tests pasa en local con un solo comando.
  - `O2` La aplicación arranca en local y responde (health check, página inicial o app en emulador).
  - `O3` El CI se ejecuta y pasa en la PR inicial.

## 2. Resuelve las versiones
- Consulta en las fuentes oficiales la última versión estable (o LTS) de cada pieza: Java, Spring Boot, Gradle, Kotlin, Compose Multiplatform, Android Gradle Plugin, Node.js, pnpm, React, Vite, Astro, PostgreSQL.
- Comprueba que son compatibles entre sí (Kotlin ↔ Compose Multiplatform ↔ AGP, Spring Boot ↔ Java) y fíjalas en el proyecto. Nunca dejes rangos ni `latest`.

## 3. Genera el esqueleto
- Si el repositorio es nuevo, inicialízalo con un commit vacío en `main` (`git commit --allow-empty -m "chore: initial commit"`) y haz el resto en una rama `chore/bootstrap-<nombre>` (regla `git-workflow`).

Usa siempre el generador oficial y después ajústalo a la regla `stack` del pack:

| Componente | Generador | Ajustes |
|------------|-----------|---------|
| Backend | Spring Initializr (`curl https://start.spring.io/starter.zip -d type=gradle-project-kotlin -d language=java -d javaVersion=<LTS> -d dependencies=web,validation,data-jpa,postgresql,flyway,security,oauth2-resource-server,actuator,docker-compose,testcontainers`) | Version catalog, Spotless, springdoc, ArchUnit, paquetes `domain`/`application`/`infrastructure` |
| Aplicación web | `pnpm create vite@latest <nombre> --template react-ts` | ESLint estricto, Prettier, Tailwind + shadcn/ui, React Router, TanStack Query, cliente OpenAPI, i18next, Vitest + MSW, Playwright |
| Web de contenido | `pnpm create astro@latest <nombre> -- --template minimal --typescript strict` | Tailwind, colecciones de contenido, ESLint y Prettier |
| App móvil | Asistente de Kotlin Multiplatform (kmp.jetbrains.com o el de Android Studio/IntelliJ) con Android e iOS y UI compartida | Version catalog, Koin, Ktor, Room, Navigation, Spotless + detekt |

- Añade un ejemplo mínimo que recorra todas las capas para fijar el patrón (por ejemplo, un endpoint `GET /api/ping` con su test o una pantalla de inicio con su ViewModel y su test). Nada de funcionalidad de producto.

## 4. Configura el entorno
- Ficheros comunes: `.gitignore`, `.editorconfig`, `README.md` en inglés (qué es, requisitos, cómo arrancar, cómo testear) y `.env.example` si hay configuración.
- Backend: `compose.yaml` con PostgreSQL y `Dockerfile` multi-etapa según la regla `docker`; primera migración Flyway.
- Aplicación web: `Dockerfile` con `nginx-unprivileged` y variable para la URL de la API.
- Dependencias al día: `renovate.json` (o `.github/dependabot.yml`) agrupando las actualizaciones menores.

## 5. Instala rem-ai
- Instala `core` y los packs del stack con `scripts/install.sh` de rem-ai (pide al usuario la ruta de su copia local o clona rem-ai en un directorio temporal):
  - Backend: `core java-spring postgresql docker`.
  - Aplicación web o web de contenido: `core typescript docker`.
  - App móvil: `core kotlin-compose`.
- Crea un `CLAUDE.md` breve con el propósito del producto, el comando de build y tests y la arquitectura elegida.

## 6. Verifica y publica
- Ejecuta el build completo (`./gradlew check`, `pnpm lint && pnpm typecheck && pnpm test && pnpm build`) y arranca la aplicación en local para demostrar `O1` y `O2` con `outcome-verifier`.
- Si el remoto es GitHub, configura CI/CD con `/github-ci-setup` (incluida la publicación de la imagen Docker en GHCR) y abre la PR inicial según la regla `git-workflow` (`chore: bootstrap <nombre> project`). Comprueba `O3`.

## Terminado cuando
- Los resultados `O1`-`O3` están `CUMPLIDO` con evidencia, el proyecto usa solo tecnologías del stack aprobado (o con ADR aceptado), las versiones están fijadas, rem-ai está instalado y el usuario tiene el enlace a la PR y los pasos pendientes (secretos, protección de rama, despliegue).
