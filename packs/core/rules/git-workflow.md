# Git

## Ramas
- Todo cambio (feature, fix, refactor, docs, chore…) se hace en una **rama nueva**. Nunca trabajes ni hagas commit directamente en la rama principal (`main`, `master` o `develop`).
- Crea la rama desde la rama principal actualizada: `git fetch origin` y `git switch -c <rama> origin/<principal>`.
- Nombre en inglés con el formato `<tipo>/<descripcion-corta>` en kebab-case, con el tipo `feature`, `fix`, `refactor`, `docs`, `test` o `chore`. Si hay issue asociada, incluye su número: `fix/123-null-price-on-checkout`.
- Una rama por cambio lógico: no mezcles funcionalidades ni arreglos no relacionados.

## Commits
- Mensajes en inglés con [Conventional Commits](https://www.conventionalcommits.org/): `tipo(scope): descripción`, con tipo `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `build`, `ci` o `perf`.
- Commits pequeños y atómicos: un cambio lógico por commit, y cada commit compila y pasa los tests.
- Nunca hagas commit de secretos, credenciales, `.env`, ficheros generados ni artefactos de build.

## Pull requests (GitHub)
- Si el remoto está en GitHub, todo cambio termina en una **PR** de la rama hacia la rama principal (`gh pr create` o la herramienta de GitHub disponible).
- Antes de abrir la PR: build, tests y linter en verde, resultados verificados por `outcome-verifier`, revisión de `code-reviewer` sin hallazgos críticos y rama actualizada con la principal.
- Título de la PR con el mismo formato que los commits. Descripción en inglés con: qué cambia, por qué, sección "Outcomes" (tabla de resultados con la evidencia de cada uno), cómo se ha probado e issue relacionada (`Closes #123`).
- Si el repositorio tiene plantilla de PR, úsala.
- Abre la PR como *draft* si el trabajo no está terminado.
- No hagas merge de la PR: la aprueba y la integra una persona, salvo que te pidan explícitamente lo contrario.
- Si el remoto no es GitHub, sube la rama e indica al usuario que la petición de integración (MR) queda pendiente.

## Prohibido
- Push directo a la rama principal.
- Reescribir historia compartida (`push --force`, `rebase` de ramas de otros). En tu propia rama, solo `--force-with-lease` y si es necesario.
