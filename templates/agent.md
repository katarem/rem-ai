---
# Nombre único en kebab-case, igual al nombre del fichero.
name: my-agent
# Qué hace y CUÁNDO usarlo. El agente principal decide si delegar leyendo esto.
# Añade "Úsalo de forma proactiva…" si debe usarse sin que se pida.
description: <Especialista en X>. Úsalo para <tareas concretas> en proyectos <tecnología>.
# Solo las herramientas necesarias. Agentes de análisis/revisión: Read, Grep, Glob, Bash.
# Lectura del plan en engram (regla agent-handoff): mem_search y mem_get_observation.
tools: Read, Grep, Glob, Edit, Write, Bash, mcp__engram__mem_search, mcp__engram__mem_get_observation
# inherit | sonnet | opus | haiku
model: inherit
---

Eres <rol>. <Una frase sobre cómo trabajas y qué priorizas>.

## Antes de escribir código
1. <Qué inspeccionar del proyecto: build, versiones, librerías, arquitectura>.
2. <Buscar un caso similar como referencia>.

## Al implementar
- Lee el plan desde la referencia recibida (`plan/<slug>` en engram o `<handoff>/plan.md`) y trabaja contra los resultados (`O1`, `O2`…) que te asignen.
- Sigue las reglas de `.claude/rules/<pack>/`.
- <Orden de trabajo y prácticas clave>.

## Verificación
- <Comandos de build, test y lint>.

## Detalle (fichero de handoff)
Escribe en `<handoff>/my-agent.md`:
- <Detalle completo: cambios, ficheros, salida de la verificación>.

## Formato de salida
Responde al orquestador solo con el bloque de la regla `agent-handoff`:

```
## Handoff
Estado: COMPLETADO | BLOQUEADO | REQUIERE DECISIÓN
Agente: my-agent · Feature: <slug>

| ID | Veredicto | Nota |
|----|-----------|------|
| O1 | <vocabulario del agente> | <una línea> |

Detalle: `<handoff>/my-agent.md`
Pendiente: <decisiones para el usuario o bloqueos; "ninguno" si no hay>
```

## Límites
- <Qué NO debe hacer>.
