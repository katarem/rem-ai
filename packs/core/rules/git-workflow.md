# Git

## Ramas
- Todo cambio (feature, fix, refactor, docs, chore…) se hace en una **rama nueva**. Nunca trabajes ni hagas commit directamente en la rama principal (`main`, `master` o `develop`).
- Crea la rama desde la rama principal actualizada: `git fetch origin` y `git switch -c <rama> origin/<principal>`.
- El nombre de la rama dice siempre **qué se va a implementar**, con el formato `<tipo>/<que-se-implementa>`: `feat/odd-architecture`, `fix/null-price-on-checkout`, `refactor/order-repository-ports`.
  - `<tipo>` es el mismo tipo de Conventional Commits que tendrá el cambio: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `build`, `ci` o `perf`.
  - `<que-se-implementa>` en inglés y kebab-case, de 2 a 5 palabras, nombrando la funcionalidad, el arreglo o el componente; no la tarea genérica.
  - Si hay issue asociada, incluye su número tras el tipo: `fix/123-null-price-on-checkout`.
- Prohibidos los nombres que no describen el cambio: genéricos (`dev`, `wip`, `changes`, `update`, `fix-bug`, `new-feature`), aleatorios o autogenerados (`claude/sleepy-fermat-1nz1ng`), con nombres de personas o fechas (`john-branch`, `2026-11-07`). Si la herramienta propone un nombre así, renómbralo antes del primer push (`git branch -m <nuevo-nombre>`).
- Decide el nombre a partir del objetivo del plan; si el alcance cambia de forma sustancial antes de abrir la PR, renombra la rama.
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
