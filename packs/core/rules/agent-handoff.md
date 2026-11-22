# Handoff entre agentes

## Identificadores
- `<slug>` es el nombre de la rama sin `<tipo>/` (`feat/engram-agent-handoff` → `engram-agent-handoff`); no cambia aunque se renombre la rama.
- `<handoff>` es `$(git rev-parse --path-format=absolute --git-common-dir)/rem-ai/handoff/<slug>` o, fuera de git, `${TMPDIR:-/tmp}/rem-ai-handoff/<proyecto>/<slug>`. Nunca dentro del árbol versionado.

## Dónde va cada cosa
- Engram solo para lo duradero: el plan en `plan/<slug>` y la verificación final en `verification/<slug>`. Nada de progreso, salidas de tests ni hallazgos.
- El detalle efímero va en `<handoff>/<agente>.md`, que cada agente sobrescribe. Sin engram, el plan va en `<handoff>/plan.md` y la verificación en `<handoff>/outcome-verifier.md`.
- La salida de build y tests va completa a `<handoff>/<agente>.log`; al contexto solo llegan el código de salida, el final del log y los errores.
- Si engram no está disponible o falla, no te bloquees: usa `<handoff>/` e indícalo en `Detalle:`.

## Delegar
- Pasa el `<slug>`, la referencia al plan (`plan/<slug>` o `<handoff>/plan.md`), el paso concreto y los IDs de los resultados. No copies el plan: el subagente lo lee con `mem_search` + `mem_get_observation` o con `Read`.
- Solo el `architect` escribe el plan, salvo el plan mínimo del orquestador en `<handoff>/plan.md` en el modo ligero de `/feature-workflow`. Si cambian los resultados, vuelve a delegar en él con el `<slug>` y el cambio.

## Responder
- Responde solo con el bloque `## Handoff` de tu agente: `Estado`, tabla con el veredicto de cada resultado, `Detalle:` y `Pendiente:`.
- Los veredictos van siempre en la tabla; no repitas el detalle que ya está en engram o en `<handoff>/`.
