# Git

- Mensajes con [Conventional Commits](https://www.conventionalcommits.org/): `tipo(scope): descripción` con `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `build`, `ci`, `perf`.
- Mensajes de commit y nombres de rama siempre en inglés (ver regla `language`).
- Commits pequeños y atómicos: un cambio lógico por commit, y cada commit debe compilar y pasar los tests.
- Ramas con prefijo según el tipo: `feature/…`, `fix/…`, `refactor/…`, `chore/…`.
- Nunca hagas commit de secretos, credenciales, `.env`, ficheros generados ni artefactos de build.
- Nunca reescribas historia publicada (`push --force`, `rebase` de ramas compartidas) sin permiso explícito.
- No hagas commit ni push si no te lo han pedido.
