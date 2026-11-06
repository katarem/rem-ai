# rem-ai: convenciones del repositorio

Este repositorio es una biblioteca de agentes, reglas y skills para Claude Code. No contiene código de aplicación: el "código" son ficheros Markdown con frontmatter YAML que se instalan en otros proyectos mediante `scripts/install.sh`.

## Organización

- Todo vive dentro de `packs/<pack>/`, con subcarpetas `agents/`, `rules/` y `skills/` (las que hagan falta).
- `core` contiene lo que sirve a cualquier proyecto. Lo específico de una tecnología va en su propio pack.
- Un pack nuevo se crea como `packs/<tecnologia>/` en kebab-case (`python-django`, `go`, `unity-csharp`…).

## Convenciones

- **Idioma**: el contenido se escribe en español. Los identificadores (nombres de ficheros, `name` de agentes y skills) en inglés y kebab-case.
- **Nombres únicos**: un `name` de agente o skill no puede repetirse entre packs, porque todos se instalan en la misma carpeta.
- **Agentes** (`agents/<name>.md`):
  - `name` igual al nombre del fichero.
  - `description` en tercera persona, diciendo *cuándo* usarlo; es lo que el agente principal lee para decidir si delegar.
  - `tools` solo con las herramientas necesarias (los agentes de análisis o revisión no llevan `Edit`/`Write`).
  - El cuerpo define rol, proceso, formato de salida y límites.
- **Reglas** (`rules/<tema>.md`):
  - Cortas, imperativas y verificables. Nada de explicaciones largas: si hace falta un procedimiento, es una skill.
  - Las reglas de tecnología **deben** llevar `paths` en el frontmatter para no cargar contexto innecesario.
  - Las reglas sin `paths` (siempre activas) solo se permiten en `core`.
- **Skills** (`skills/<name>/SKILL.md`):
  - `name` igual al nombre de la carpeta.
  - `description` dice qué hace y cuándo activarla.
  - Pasos numerados y un criterio de "terminado" claro.

## Al añadir o cambiar piezas

1. Parte de la plantilla de `templates/`.
2. Actualiza la tabla "Packs disponibles" del `README.md`.
3. Comprueba la instalación en un directorio temporal:
   ```bash
   ./scripts/install.sh "$(mktemp -d)" core <pack>
   ```
4. Commits con Conventional Commits, usando el pack como scope: `feat(java-spring): add regla de WebFlux`.
