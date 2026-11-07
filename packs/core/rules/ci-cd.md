# CI/CD en GitHub

Todo repositorio alojado en GitHub tiene integración y entrega continuas con GitHub Actions. Si no las tiene o están incompletas, propón configurarlas con la skill `/github-ci-setup`.

## Integración continua: en cada PR
- Workflow `.github/workflows/ci.yml` que se ejecuta en `pull_request` hacia la rama principal.
- Ejecuta lint/formato, compilación y la suite completa de tests. Falla si cualquier paso falla.
- Valida que el título de la PR cumple Conventional Commits: con *squash merge* es el mensaje del commit y la base del versionado.
- Sus checks son obligatorios en la protección de la rama principal: una PR en rojo no se integra.

## Build y release: al hacer merge
- Workflow `.github/workflows/release.yml` que se ejecuta en `push` a la rama principal: build completo con tests y publicación automática de una nueva versión en GitHub.
- La versión sube según el esquema de versionado del proyecto:
  - **Por defecto, SemVer** calculado desde Conventional Commits desde el último tag: `fix`/`perf` → patch, `feat` → minor, `BREAKING CHANGE` o `!` → major.
  - Si el proyecto ya usa otro esquema o herramienta (CalVer, release-please, otro formato de tag…), respétalo.
  - Si desde la última versión solo hay commits no publicables (`docs`, `chore`, `test`, `ci`…), se hace el build pero no se publica versión.
- La fuente de verdad de la versión es el tag git (`vX.Y.Z`). El pipeline inyecta la versión en el build (`-Drevision=`, `-Pversion=`…); no se edita a mano.
- Cada versión crea el tag y una **GitHub Release** con los artefactos del build adjuntos (`.jar`, `.apk`/`.aab`, `dist.zip`…) o publicados en su registro (GitHub Packages, npm, Docker…).

## Changelog
- Cada release genera su changelog automáticamente a partir de los commits, agrupado por tipo (breaking changes, features, bug fixes, performance).
- El changelog se publica como notas de la GitHub Release y se acumula en `CHANGELOG.md` en la raíz del repositorio.
- `CHANGELOG.md` no se edita a mano: lo actualiza el pipeline con un commit `chore(release): X.Y.Z [skip ci]`.

## Buenas prácticas en los workflows
- `permissions` mínimos: `contents: read` por defecto y permisos de escritura solo en el job que los necesita.
- `concurrency` para cancelar ejecuciones obsoletas de una misma PR y no solapar releases.
- Caché de dependencias (`cache:` de `setup-java`/`setup-node`, `gradle/actions/setup-gradle`).
- Las mismas versiones de lenguaje y herramientas que el proyecto (`.java-version`, `.nvmrc`, toolchain de Gradle, wrapper).
- Acciones oficiales fijadas a versión mayor (`@v5`); acciones de terceros, a versión mayor o a SHA.
- Secretos solo mediante GitHub Secrets, nunca en el workflow ni en los logs. No uses `pull_request_target` para ejecutar código de la PR.
