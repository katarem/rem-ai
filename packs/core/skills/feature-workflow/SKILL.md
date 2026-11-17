---
name: feature-workflow
description: Flujo completo para implementar una funcionalidad o cambio no trivial, de principio a fin y guiado por resultados (ODD) - resultados acordados, plan, implementación, tests, verificación de resultados, revisión y commit - delegando en los agentes especializados. Úsalo cuando el usuario pida una nueva funcionalidad, un endpoint, una pantalla o un cambio que afecte a varios ficheros.
---

# Flujo de implementación de funcionalidades

El flujo sigue Outcome-Driven Development (skill `/odd-cycle`): los resultados acordados en el paso 1 son el contrato del cambio y todos los pasos siguientes se refieren a ellos por su identificador (`O1`, `O2`…).

## 1. Resultados y plan
- Delega en `architect` con el requisito del usuario y cualquier contexto que tengas. Su plan incluye la tabla de resultados esperados (con su verificación), las restricciones, lo que queda fuera de alcance y la rama propuesta. Lo guarda en engram (`plan/<slug>`) o en `<handoff>/plan.md` (regla `agent-handoff`) y te responde con el bloque `## Handoff`.
- Presenta al usuario los resultados y un resumen del plan. Confirma que, si se cumplen esos resultados, el trabajo está hecho; ajusta la lista y resuelve las preguntas abiertas que cambien el diseño antes de seguir. Si cambian los resultados, actualiza el plan guardado (`mem_update` o editando `plan.md`).

## 2. Rama
- Crea una rama nueva desde la rama principal actualizada, según la regla `git-workflow`, con un nombre que diga qué se va a implementar a partir del objetivo del plan: `<tipo>/<que-se-implementa>` (`feat/odd-architecture`, `fix/null-price-on-checkout`). Usa la rama propuesta en el plan; su `<slug>` identifica el plan y los ficheros de handoff.

## 3. Implementación
- Delega cada paso del plan en el agente especialista de la tecnología (`spring-backend-dev`, `android-compose-dev`, `frontend-dev`…), o implementa tú si no hay especialista.
- Pasa el `<slug>`, la referencia al plan, el paso concreto a ejecutar y los IDs de los resultados que persigue (regla `agent-handoff`). No copies el plan: el agente lo lee de engram o de `plan.md`.
- Pasos independientes (p. ej. backend y frontend) pueden ir en paralelo.
- Si aparece un resultado nuevo o alguno deja de tener sentido, acuérdalo con el usuario y actualiza el plan guardado.

## 4. Tests
- Delega en `test-engineer` con la referencia al plan: cada resultado cuya verificación sea un test debe quedar cubierto por al menos uno.
- La suite debe pasar. Si falla, vuelve al paso 3 con la ruta de `<handoff>/test-engineer.md`.

## 5. Verificación de resultados
- Delega en `outcome-verifier` con la referencia al plan. La verificación completa queda en `verification/<slug>` (o en `<handoff>/outcome-verifier.md`).
- Por cada resultado `NO CUMPLIDO`, vuelve al paso 3 con la referencia a la verificación. Por cada `NO VERIFICABLE`, añade una verificación ejecutable (paso 4) o acuerda con el usuario cómo verificarlo.
- No sigas hasta que todos estén `CUMPLIDO` o el usuario acepte explícitamente los pendientes.

## 6. Revisión
- Delega en `code-reviewer` con la referencia al plan. Los hallazgos completos quedan en `<handoff>/code-reviewer.md`: pásale esa ruta al especialista si hay que corregirlos.
- Corrige los hallazgos CRÍTICOS e IMPORTANTES; si los cambios son significativos, repite la verificación (paso 5) y la revisión.
- Comenta los MENORES al usuario sin bloquear.

## 7. Commit y PR
- Haz commits atómicos en inglés con Conventional Commits.
- Sube la rama (`git push -u origin <rama>`).
- Si el remoto es GitHub, abre la PR hacia la rama principal siguiendo la regla `git-workflow` (título, descripción, plantilla). La descripción incluye una sección "Outcomes" con la tabla de resultados y la evidencia de cada uno, tomada de `verification/<slug>`. No hagas merge.

## 8. Cierre
- Resume al usuario: tabla de resultados con su estado y evidencia, ficheros principales, resultado de tests y revisión, decisiones tomadas, pendientes y enlace a la PR.

## Terminado cuando
- Todos los resultados acordados están `CUMPLIDO` con evidencia (o el usuario ha aceptado los pendientes), los tests pasan, la revisión no tiene hallazgos críticos ni importantes abiertos, la PR está abierta con la sección "Outcomes" (o la rama subida si no es GitHub) y el usuario tiene el resumen con el enlace.
