# Handoff entre agentes

## Identificadores
- `<slug>` es el nombre de la rama sin `<tipo>/` (`feat/engram-agent-handoff` → `engram-agent-handoff`). Lo fija el `architect` en la "Rama propuesta" del plan y no cambia aunque se renombre la rama.
- `<handoff>` es `$(git rev-parse --git-path rem-ai/handoff)/<slug>` (normalmente `.git/rem-ai/handoff/<slug>`) o, fuera de un repo git, `${TMPDIR:-/tmp}/rem-ai-handoff/<proyecto>/<slug>`. Nunca dentro del árbol versionado.

## Memoria persistente (engram)
- Guarda en engram solo lo duradero, con un `topic_key` estable: el plan del `architect` en `plan/<slug>` y la verificación final del `outcome-verifier` en `verification/<slug>`.
- Antes de guardar, busca el `topic_key` con `mem_search`: si ya existe, actualízalo con `mem_update` usando su id; nunca crees un duplicado con `mem_save`.
- No guardes en engram progreso rutinario, salidas de tests ni listas de hallazgos.
- Las herramientas son `mcp__engram__*` (servidor `engram` en ámbito de usuario). Si engram está instalado como plugin se llaman `mcp__plugin_engram_engram__*`: adapta el `tools` de los agentes o registra el servidor de usuario.

## Fichero de handoff
- El detalle efímero (salida completa de tests, hallazgos, evidencias largas, ficheros tocados) va en `<handoff>/<agente>.md`.
- Cada agente sobrescribe su propio fichero en cada ejecución. Los agentes sin `Write` lo escriben con `Bash` (`mkdir -p` + `cat > … <<'EOF'`) y no escriben en ninguna otra ruta.

## Delegar
- Pasa al subagente el `<slug>`, la referencia al plan (`plan/<slug>` en engram o `<handoff>/plan.md`), el paso concreto y los IDs de los resultados que persigue. No copies el plan.
- El subagente lee el plan con `mem_search` + `mem_get_observation`, o con `Read` sobre la ruta indicada.

## Responder
- Responde siempre con este bloque, con todos los resultados que te tocan y tu vocabulario de veredictos:

  ```
  ## Handoff
  Estado: COMPLETADO | BLOQUEADO | REQUIERE DECISIÓN
  Agente: <name> · Feature: <slug>

  | ID | Veredicto | Nota |
  |----|-----------|------|
  | O1 | <veredicto> | <una línea: qué se hizo o qué falta> |

  Detalle: engram `<topic_key>` (#<id>) | `<handoff>/<agente>.md`
  Pendiente: <decisiones para el usuario o bloqueos; "ninguno" si no hay>
  ```
- Los veredictos van siempre en la tabla; nunca respondas solo con un puntero.
- No repitas en la respuesta el detalle que ya está en engram o en el fichero de handoff.

## Sin engram
- Si las herramientas de engram no están disponibles o fallan, no te bloquees: escribe el detalle (también el plan o la verificación) en `<handoff>/`, indícalo en `Detalle:` y responde con el mismo bloque.
