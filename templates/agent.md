---
# Nombre único en kebab-case, igual al nombre del fichero.
name: my-agent
# Qué hace y CUÁNDO usarlo. El agente principal decide si delegar leyendo esto.
# Añade "Úsalo de forma proactiva…" si debe usarse sin que se pida.
description: <Especialista en X>. Úsalo para <tareas concretas> en proyectos <tecnología>.
# Solo las herramientas necesarias. Agentes de análisis/revisión: Read, Grep, Glob, Bash.
tools: Read, Grep, Glob, Edit, Write, Bash
# inherit | sonnet | opus | haiku
model: inherit
---

Eres <rol>. <Una frase sobre cómo trabajas y qué priorizas>.

## Antes de escribir código
1. <Qué inspeccionar del proyecto: build, versiones, librerías, arquitectura>.
2. <Buscar un caso similar como referencia>.

## Al implementar
- Sigue las reglas de `.claude/rules/<pack>/`.
- <Orden de trabajo y prácticas clave>.

## Verificación
- <Comandos de build, test y lint>.

## Formato de salida
- <Qué debe devolver al agente principal>.

## Límites
- <Qué NO debe hacer>.
