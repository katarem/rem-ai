# Git

## Ramas
- Todo cambio se hace en una **rama nueva** creada desde la rama principal actualizada. Nunca hagas commit en la principal (`main`, `master` o `develop`).
- Nombre `<tipo>/<que-se-implementa>`: `<tipo>` es el de Conventional Commits del cambio; `<que-se-implementa>`, en inglés y kebab-case, de 2 a 5 palabras, nombra la funcionalidad o el arreglo. Con issue: `fix/123-null-price-on-checkout`.
- Prohibidos los nombres genéricos (`dev`, `wip`, `update`), aleatorios o autogenerados (`claude/sleepy-fermat-1nz1ng`), con personas o fechas. Renómbralos antes del primer push (`git branch -m <nuevo-nombre>`), y también si el alcance cambia de forma sustancial.
- Una rama por cambio lógico.

## Commits
- En inglés con [Conventional Commits](https://www.conventionalcommits.org/): `tipo(scope): descripción` (`feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `build`, `ci`, `perf`).
- Atómicos: un cambio lógico por commit, y cada commit compila y pasa los tests.
- Nunca hagas commit de secretos, `.env`, ficheros generados ni artefactos de build.

## Pull requests (GitHub)
- Todo repositorio en GitHub tiene CI (`ci.yml`) y release (`release.yml`) según la regla `ci-cd`; si faltan, propón `/github-ci-setup`. Una PR con los checks en rojo no se integra. La versión sale del tag `vX.Y.Z`: no la edites a mano en los ficheros de build.
- Todo cambio termina en una **PR** hacia la rama principal.
- Antes de abrirla: build, tests y linter en verde, resultados verificados por `outcome-verifier`, revisión (`code-reviewer` o la pasada combinada del modo ligero) sin hallazgos críticos y rama actualizada con la principal.
- Título como los commits. Descripción en inglés: qué cambia, por qué, sección "Outcomes" (resultados con su evidencia), cómo se ha probado y `Closes #123`. Usa la plantilla de PR si existe.
- En *draft* si el trabajo no está terminado. No hagas merge: la aprueba y la integra una persona, salvo que te pidan lo contrario.
- Si el remoto no es GitHub, sube la rama e indica que la MR queda pendiente.

## Prohibido
- Push directo a la rama principal.
- Reescribir historia compartida (`push --force`, `rebase` de ramas ajenas). En tu rama, solo `--force-with-lease` y si es necesario.
