# rem-ai

Biblioteca de **agentes especializados**, **reglas** y **skills** para [Claude Code](https://code.claude.com/docs), organizada en *packs* por tecnología, lista para instalar en cualquier proyecto.

## Conceptos

| Pieza | Qué es | Dónde se instala | Cuándo se usa |
|-------|--------|------------------|---------------|
| **Agente** (subagent) | Especialista con su propio prompt, herramientas y contexto aislado. | `.claude/agents/<nombre>.md` | El agente principal le delega tareas, automáticamente según su `description` o cuando se le pide explícitamente. |
| **Regla** | Instrucciones que siempre se cumplen. Pueden aplicarse a todo o solo a ciertos ficheros (`paths`). | `.claude/rules/<pack>/<regla>.md` | Se cargan como memoria del proyecto; las que tienen `paths` solo cuando se trabaja con ficheros que coinciden. |
| **Skill** | Flujo de trabajo paso a paso para un tipo de tarea. | `.claude/skills/<nombre>/SKILL.md` | Bajo demanda: `/<nombre>` o cuando Claude detecta que aplica. |

## Estructura

```
rem-ai/
├── packs/
│   ├── core/              # Válido para cualquier proyecto
│   │   ├── agents/        # architect, code-reviewer, test-engineer, outcome-verifier
│   │   ├── rules/         # flujo con agentes, handoff entre agentes, stack, idioma, git, CI/CD, calidad de código
│   │   └── skills/        # feature-workflow, odd-cycle, tdd-cycle, new-project, tech-decision, github-ci-setup
│   ├── java-spring/       # Java LTS + Spring Boot + Gradle + hexagonal/DDD
│   ├── kotlin-compose/    # Kotlin Multiplatform + Compose Multiplatform
│   ├── typescript/        # TypeScript + React/Vite (SPA) y Astro
│   ├── postgresql/        # Esquema, migraciones Flyway y consultas
│   └── docker/            # Imágenes y Docker Compose
├── templates/             # Plantillas para crear agentes, reglas y skills
├── scripts/
│   ├── rem-ai             # CLI: install, update, uninstall, status, setup, self-uninstall
│   └── install.sh         # Compatibilidad: equivale a `rem-ai install`
├── tests/                 # Tests del CLI (`./tests/run.sh`)
└── CLAUDE.md              # Convenciones para mantener este repositorio
```

## Packs disponibles

| Pack | Agentes | Reglas | Skills |
|------|---------|--------|--------|
| `core` | `architect`, `code-reviewer`, `test-engineer`, `outcome-verifier` | `agent-workflow`, `agent-handoff`, `tech-stack`, `language`, `git-workflow`, `ci-cd`, `code-quality` | `feature-workflow`, `odd-cycle`, `tdd-cycle`, `new-project`, `tech-decision`, `github-ci-setup` |
| `java-spring` | `spring-backend-dev` | `stack`, `java`, `spring-boot`, `hexagonal-ddd`, `testing-java` | — |
| `kotlin-compose` | `android-compose-dev` | `stack`, `kotlin`, `jetpack-compose` | — |
| `typescript` | `frontend-dev` | `stack`, `typescript`, `react`, `web-frontend` | — |
| `postgresql` | — | `postgresql` | — |
| `docker` | — | `docker` | — |

## Stack tecnológico

Los proyectos nuevos usan un stack aprobado (regla `tech-stack`), para que las buenas prácticas estén decididas de antemano y el trabajo se centre en el producto:

| Necesidad | Tecnología | Packs a instalar |
|-----------|------------|------------------|
| Backend / API | Java LTS + Spring Boot, Gradle (Kotlin DSL), hexagonal/DDD | `core java-spring postgresql docker` |
| Aplicación web | React + Vite (SPA) + TypeScript, cliente generado desde el OpenAPI del backend | `core typescript docker` |
| Web de contenido / landing | Astro + TypeScript | `core typescript docker` |
| App móvil | Kotlin Multiplatform + Compose Multiplatform (Android e iOS) | `core kotlin-compose` |
| Datos e infraestructura | PostgreSQL + Flyway, Docker (imágenes en GHCR), GitHub Actions | — |

- Cada componente desplegable es un repositorio propio, con su CI/CD y su versión; el contrato entre backend y clientes es la especificación OpenAPI.
- La regla `stack` de cada pack fija las librerías aprobadas y las que no se usan. Se activa al tocar los ficheros de build (`build.gradle.kts`, `libs.versions.toml`, `package.json`…), justo cuando se añaden dependencias.
- `/new-project` crea un proyecto con este stack ya configurado: generador oficial, calidad, tests, Docker, CI/CD y rem-ai instalado.
- Salirse del stack exige un ADR aceptado por el usuario (`/tech-decision`, en `docs/adr/`). Si una tecnología nueva se adopta para todos los proyectos, se incorpora aquí.

## Instalación

### Requisitos

El pack `core` recomienda [engram](https://github.com/Gentleman-Programming/engram) como memoria persistente para el handoff entre agentes (regla `agent-handoff`). Regístralo como servidor MCP de usuario:

```bash
claude mcp add -s user engram -- engram mcp --tools=agent
```

- Los agentes declaran sus herramientas con el prefijo `mcp__engram__` (servidor `engram` de usuario). Si instalas engram como plugin, las herramientas se llaman `mcp__plugin_engram_engram__*`: registra también el servidor de usuario o adapta el `tools` de los agentes.
- Sin engram todo sigue funcionando: el plan, la verificación y el detalle van a ficheros de handoff en `.git/rem-ai/handoff/<slug>/`. `rem-ai install` avisa si no lo encuentra, sin fallar.

### Poner `rem-ai` en el PATH

Clona este repositorio en un sitio estable (las actualizaciones salen de ese clon) y crea el comando:

```bash
git clone <url-de-rem-ai> ~/code/rem-ai
~/code/rem-ai/scripts/rem-ai setup      # crea ~/.local/bin/rem-ai (o --bin-dir <dir>)
```

### Instalar packs

Instala en un proyecto concreto los packs que necesite (`core` es casi siempre recomendable):

```bash
rem-ai install ~/proyectos/mi-api core java-spring postgresql docker
```

Instala a nivel de usuario (`~/.claude`), disponible en todos tus proyectos:

```bash
rem-ai install --global core
```

Opciones:

- `--link`: crea enlaces simbólicos en lugar de copias, así un `git pull` en este repo actualiza todos los proyectos.
- `--force`: sobrescribe ficheros existentes.
- `rem-ai list`: muestra los packs disponibles.

`./scripts/install.sh` sigue funcionando con los mismos argumentos: es un atajo de `rem-ai install`.

### Manifiesto

Cada instalación registra en `.claude/.rem-ai-manifest` qué ha instalado: repositorio, modo (`copy` o `link`), commit, packs y cada fichero con su hash sha256 (o el destino de cada enlace). Es lo que permite actualizar y desinstalar sin tocar tus ficheros:

- Un fichero que ya tenías y es distinto no se sobrescribe ni pasa a ser de rem-ai (salvo con `--force`).
- Un fichero instalado que has modificado se conserva al actualizar o desinstalar (salvo con `--force`).
- No se puede mezclar `copy` y `link` en una misma instalación: desinstala antes de cambiar de modo.
- Puedes versionar el manifiesto junto con `.claude/`; la ruta `repo` es solo informativa.
- Las instalaciones se registran en `~/.config/rem-ai/installs` para poder desinstalarlas todas.

### Actualizar

```bash
rem-ai update ~/proyectos/mi-api      # o --global; sin argumentos, el directorio actual
```

Descarga la última versión del clon (`git pull --ff-only`) y sincroniza los packs instalados: actualiza los ficheros que no has tocado, instala los nuevos, restaura los que falten y elimina los que ya no existen en el repositorio. Si el clon tiene cambios locales, no tiene upstream o no hay red, avisa y sincroniza desde los ficheros locales. `--no-pull` omite la descarga.

`rem-ai status` muestra los packs, el modo, el commit instalado frente al del repositorio y los ficheros modificados, ausentes o no instalados.

### Desinstalar

```bash
rem-ai uninstall ~/proyectos/mi-api            # todos los packs
rem-ai uninstall ~/proyectos/mi-api docker     # solo un pack
rem-ai uninstall --global
```

Solo borra lo que figura en el manifiesto y no has modificado; deja tus ficheros y elimina las carpetas que quedan vacías.

Para quitar rem-ai del ordenador:

```bash
rem-ai self-uninstall          # muestra lo que va a hacer
rem-ai self-uninstall --yes    # desinstala de todos los proyectos registrados y quita el comando
rm -rf ~/code/rem-ai           # último paso manual: borrar el clon
```

Si creaste el comando con `setup --bin-dir <dir>`, pasa también `--bin-dir <dir>` a `self-uninstall`.

## Flujo de trabajo

El pack `core` define un flujo de trabajo por defecto (regla `agent-workflow` y skill `/feature-workflow`), guiado por resultados (**Outcome-Driven Development**, skill `/odd-cycle`):

```
Petición ──► architect ──────────► rama ──► agente especialista ──► test-engineer ──► outcome-verifier ──► code-reviewer ──► commits + PR
             (resultados O1…On          (spring-backend-dev,     (tests por         (evidencia por      (revisión)       (sección
              + plan, acordados          android-compose-dev,     resultado)         resultado)                           "Outcomes")
              con el usuario)            frontend-dev…)                                   │
                                              ▲                                           │
                                              └──────────── resultado NO CUMPLIDO ────────┘
```

Los agentes no se pasan el plan copiado: el `architect` lo guarda en engram (`plan/<slug>`) y el `outcome-verifier` deja ahí la verificación (`verification/<slug>`). El detalle efímero (salida de tests, hallazgos) va a `.git/rem-ai/handoff/<slug>/`, y cada agente responde al orquestador con un bloque corto con el veredicto de cada resultado (regla `agent-handoff`). Así el orquestador delega con una referencia y no gasta contexto en informes completos.

Antes de escribir código se acuerda con el usuario qué debe ser cierto al terminar: una lista corta de resultados observables (`O1`, `O2`…), cada uno con su verificación ejecutable, más las restricciones y lo que queda fuera de alcance. El plan, los tests, la revisión y la PR se refieren a esos resultados, y el cambio solo se da por terminado cuando `outcome-verifier` demuestra cada uno con evidencia (tests, comandos, peticiones reales), no porque el código "parezca correcto". ODD se combina con TDD (`/tdd-cycle`): los resultados dicen *qué* debe cumplirse y TDD, *cómo* llegar en pasos pequeños.

Todo cambio se hace en una rama nueva cuyo nombre dice qué se implementa (`feat/odd-architecture`, `fix/null-price-on-checkout`…) y, si el repositorio está en GitHub, termina en una PR que revisa e integra una persona (regla `git-workflow`).

En GitHub, cada repositorio tiene además su pipeline (regla `ci-cd`, se configura con `/github-ci-setup`):

```
PR abierta ──► CI: lint + build + tests + título de la PR      (ci.yml)
Merge a main ──► build ──► versión desde Conventional Commits ──► CHANGELOG.md + tag + GitHub Release   (release.yml)
```

Las reglas de cada tecnología se aplican tanto al agente principal como a los subagentes cuando tocan ficheros que coinciden con sus `paths`.

## Crear piezas nuevas

1. Copia la plantilla correspondiente de `templates/`.
2. Colócala en el pack adecuado (o crea un pack nuevo en `packs/<nombre>/`).
3. Sigue las convenciones de [`CLAUDE.md`](CLAUDE.md) y actualiza la tabla de packs de este README.
