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
│   │   ├── rules/         # flujo con agentes, idioma, git, CI/CD, calidad de código
│   │   └── skills/        # feature-workflow, odd-cycle, tdd-cycle, github-ci-setup
│   ├── java-spring/       # Java 21 + Spring Boot + hexagonal/DDD
│   ├── kotlin-compose/    # Kotlin + Jetpack Compose / KMP
│   └── typescript/        # TypeScript + frontend web (Astro, React…)
├── templates/             # Plantillas para crear agentes, reglas y skills
├── scripts/install.sh     # Instalador de packs
└── CLAUDE.md              # Convenciones para mantener este repositorio
```

## Packs disponibles

| Pack | Agentes | Reglas | Skills |
|------|---------|--------|--------|
| `core` | `architect`, `code-reviewer`, `test-engineer`, `outcome-verifier` | `agent-workflow`, `language`, `git-workflow`, `ci-cd`, `code-quality` | `feature-workflow`, `odd-cycle`, `tdd-cycle`, `github-ci-setup` |
| `java-spring` | `spring-backend-dev` | `java`, `spring-boot`, `hexagonal-ddd`, `testing-java` | — |
| `kotlin-compose` | `android-compose-dev` | `kotlin`, `jetpack-compose` | — |
| `typescript` | `frontend-dev` | `typescript`, `web-frontend` | — |

## Instalación

Instala en un proyecto concreto los packs que necesite (`core` es casi siempre recomendable):

```bash
./scripts/install.sh ~/proyectos/mi-api core java-spring
```

Instala a nivel de usuario (`~/.claude`), disponible en todos tus proyectos:

```bash
./scripts/install.sh --global core
```

Opciones:

- `--link`: crea enlaces simbólicos en lugar de copias, así un `git pull` en este repo actualiza todos los proyectos.
- `--force`: sobrescribe ficheros existentes.
- `--list`: muestra los packs disponibles.

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

Antes de escribir código se acuerda con el usuario qué debe ser cierto al terminar: una lista corta de resultados observables (`O1`, `O2`…), cada uno con su verificación ejecutable, más las restricciones y lo que queda fuera de alcance. El plan, los tests, la revisión y la PR se refieren a esos resultados, y el cambio solo se da por terminado cuando `outcome-verifier` demuestra cada uno con evidencia (tests, comandos, peticiones reales), no porque el código "parezca correcto". ODD se combina con TDD (`/tdd-cycle`): los resultados dicen *qué* debe cumplirse y TDD, *cómo* llegar en pasos pequeños.

Todo cambio se hace en una rama nueva (`feature/…`, `fix/…`) y, si el repositorio está en GitHub, termina en una PR que revisa e integra una persona (regla `git-workflow`).

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
