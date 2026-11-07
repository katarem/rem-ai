---
name: github-ci-setup
description: Configura CI/CD con GitHub Actions en un repositorio de GitHub según la regla ci-cd - tests en cada PR, build al hacer merge, release automática con versionado y changelog. Úsalo cuando el repositorio no tenga pipelines, estén incompletos o el usuario pida configurar CI/CD, releases o changelog.
---

# Configurar CI/CD en GitHub

Resultado: `ci.yml` (en cada PR), `release.yml` (al hacer merge), la configuración de versionado y changelog, y la protección de la rama principal. Las plantillas están en `templates/` dentro de esta skill.

## 1. Analiza el repositorio
- Confirma que el remoto es GitHub y cuál es la rama principal (`git remote -v`, `git symbolic-ref refs/remotes/origin/HEAD`).
- Detecta el stack con la tabla del paso 3 y la versión de lenguaje/herramientas (`.java-version`, toolchain, `.nvmrc`, `engines`).
- Revisa los workflows existentes en `.github/workflows/`: amplíalos en lugar de duplicarlos.
- Detecta el esquema de versionado actual:
  - Tags existentes y su formato (`git tag --sort=-v:refname | head`).
  - Herramientas de release ya configuradas (`.releaserc*`, `release-please-config.json`, `CHANGELOG.md`, `gradle.properties` con `version`, plugins de release).
  - Versión declarada en los ficheros de build.
- Si ya hay herramienta o esquema propio, adáptalo en lugar de imponer semantic-release y SemVer.

## 2. Presenta el plan
- Explica al usuario los workflows a crear, el esquema de versionado detectado o propuesto, los artefactos que se publicarán y la configuración del repositorio necesaria.
- Si el versionado es ambiguo (por ejemplo, la versión en el build no coincide con los tags), pregunta antes de seguir.

## 3. Crea el workflow de CI
Copia `templates/ci.yml` a `.github/workflows/ci.yml` y adapta los bloques *STACK SETUP* y *STACK COMMANDS* (las plantillas vienen preparadas para el backend del stack aprobado, Gradle con Java LTS):

| Stack | Se detecta por | Setup | Comandos de CI |
|-------|----------------|-------|----------------|
| Maven | `pom.xml` | `actions/setup-java` con `cache: maven` | `./mvnw -B -ntp verify` |
| Gradle (JVM) | `build.gradle(.kts)` | `actions/setup-java` + `gradle/actions/setup-gradle@v4` | `./gradlew check` |
| Android | plugin `com.android.application` | igual que Gradle | `./gradlew lint testDebugUnitTest` |
| Node / TypeScript | `package.json` | `actions/setup-node` con `cache` según el lockfile (`pnpm/action-setup` si es pnpm) | `npm ci`, `npm run lint`, typecheck (`tsc --noEmit` / `astro check`), `npm test` |

- Sustituye `main` si la rama principal tiene otro nombre.
- Comprueba la última versión mayor de cada acción antes de usarla y actualiza las de las plantillas si hay una más reciente.

## 4. Crea el workflow de release
Copia `templates/release.yml` a `.github/workflows/release.yml` (mismo bloque de setup que en CI) y `templates/releaserc.json` a `.releaserc.json`. Adapta el `prepareCmd` (build con la versión calculada) y los `assets`:

| Stack | Inyección de versión | `prepareCmd` | `assets` |
|-------|----------------------|--------------|----------|
| Maven | `<version>${revision}</version>` con la propiedad `revision` a `0.0.0-SNAPSHOT` y `flatten-maven-plugin` | `./mvnw -B -ntp -DskipTests -Drevision=${nextRelease.version} package` | `target/*.jar` |
| Gradle (JVM) | `version = findProperty("releaseVersion") ?: "0.0.0-SNAPSHOT"` | `./gradlew assemble -PreleaseVersion=${nextRelease.version}` | `build/libs/*.jar` |
| Android | `versionName` desde `releaseVersion` y `versionCode` derivado (`major*10000 + minor*100 + patch`) | `./gradlew assembleRelease bundleRelease -PreleaseVersion=${nextRelease.version}` | `app/build/outputs/apk/release/*.apk`, `app/build/outputs/bundle/release/*.aab` |
| Node / TypeScript | `@semantic-release/npm` (incluido en semantic-release) con `"npmPublish": false` salvo que se publique en npm; añade `package.json` y el lockfile a los `assets` de `@semantic-release/git` | `npm run build && cd dist && zip -r ../dist.zip .` | `dist.zip` |

- Si el proyecto tiene `Dockerfile`, la release publica también la imagen en GHCR (regla `docker`): conserva el bloque *DOCKER* y el permiso `packages: write` de `release.yml` y el `publishCmd` de `.releaserc.json`, sustituyendo `OWNER/REPO` por el repositorio en minúsculas. Si no lo tiene, elimina los tres.
- En Android, la firma va por secretos (keystore en base64 y contraseñas). Si no existen, pide al usuario que los cree; nunca los generes ni los versiones.
- Si el proyecto ya tiene una versión publicada sin tag (por ejemplo `0.3.2` en el build), crea el tag `v0.3.2` sobre la rama principal antes de la primera release para que la numeración continúe desde ahí. Sin tags, semantic-release empieza en `1.0.0`.

## 5. Configura el token de release
- El job de release hace commit de `CHANGELOG.md` en la rama principal protegida, así que necesita un token con permiso para saltarse la protección:
  - Opción recomendada: una GitHub App con `contents`, `issues` y `pull-requests` de escritura y token generado con `actions/create-github-app-token`.
  - Alternativa: un *fine-grained PAT* con esos permisos sobre el repositorio.
- Se guarda como secreto `RELEASE_TOKEN` y el actor se añade a la lista de *bypass* de la protección de la rama. Indica al usuario cómo hacerlo; nunca pidas ni escribas el valor del token.

## 6. Configura el repositorio
Pide confirmación antes de aplicar cambios con `gh` y, si el usuario no tiene permisos o prefiere hacerlo él, dale la lista:
- Merge: solo *squash merge*, con el título de la PR como mensaje del commit y borrado automático de ramas tras el merge.
  ```bash
  gh api -X PATCH "repos/{owner}/{repo}" -F allow_squash_merge=true -F allow_merge_commit=false -F allow_rebase_merge=false -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY -F delete_branch_on_merge=true
  ```
- Protección de la rama principal (ruleset): PR obligatoria, checks requeridos `PR title` y `Lint, build and test`, rama actualizada antes del merge, sin *force push* y *bypass* solo para el actor del `RELEASE_TOKEN`.

## 7. Verifica
- Valida la sintaxis de los workflows con `actionlint` si está disponible.
- Sube los cambios en una rama y abre la PR según la regla `git-workflow` (por ejemplo `ci: add CI/CD pipelines and automated releases`). El propio workflow de CI debe ejecutarse en esa PR y pasar.
- Explica al usuario qué ocurrirá al hacer merge: build, cálculo de versión, actualización de `CHANGELOG.md` y GitHub Release, y cómo comprobarlo en la pestaña *Actions* y en *Releases*.

## Terminado cuando
- `ci.yml` se ejecuta y pasa en la PR, `release.yml` y `.releaserc.json` están adaptados al stack, el usuario sabe qué secretos y configuración del repositorio quedan pendientes (o ya están aplicados) y la PR está abierta.
