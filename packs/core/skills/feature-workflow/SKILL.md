---
name: feature-workflow
description: Flujo completo para implementar una funcionalidad o cambio no trivial, de principio a fin y guiado por resultados (ODD) - resultados acordados, plan, implementación, tests, verificación de resultados, revisión y commit - delegando en los agentes especializados. Úsalo cuando el usuario pida una nueva funcionalidad, un endpoint, una pantalla o un cambio que afecte a varios ficheros.
---

# Flujo de implementación de funcionalidades

El flujo sigue Outcome-Driven Development (skill `/odd-cycle`): los resultados acordados en el paso 1 son el contrato del cambio y todos los pasos siguientes se refieren a ellos por su identificador (`O1`, `O2`…).

## 1. Resultados y plan
- Delega en `architect` con el requisito del usuario y cualquier contexto que tengas. Su plan incluye la tabla de resultados esperados (con su verificación), las restricciones y lo que queda fuera de alcance.
- Presenta al usuario los resultados y un resumen del plan. Confirma que, si se cumplen esos resultados, el trabajo está hecho; ajusta la lista y resuelve las preguntas abiertas que cambien el diseño antes de seguir.

## 2. Rama
- Crea una rama nueva desde la rama principal actualizada, según la regla `git-workflow`, con un nombre que diga qué se va a implementar a partir del objetivo del plan: `<tipo>/<que-se-implementa>` (`feat/odd-architecture`, `fix/null-price-on-checkout`).

## 3. Implementación
- Delega cada paso del plan en el agente especialista de la tecnología (`spring-backend-dev`, `android-compose-dev`, `frontend-dev`…), o implementa tú si no hay especialista.
- Pasa el plan completo, el paso concreto a ejecutar, los resultados que persigue ese paso, las restricciones y lo que queda fuera de alcance.
- Pasos independientes (p. ej. backend y frontend) pueden ir en paralelo.
- Si aparece un resultado nuevo o alguno deja de tener sentido, acuérdalo con el usuario y actualiza la tabla.

## 4. Tests
- Delega en `test-engineer` con la tabla de resultados: cada resultado cuya verificación sea un test debe quedar cubierto por al menos uno.
- La suite debe pasar. Si falla, vuelve al paso 3 con el error concreto.

## 5. Verificación de resultados
- Delega en `outcome-verifier` con la tabla de resultados y las restricciones.
- Por cada resultado `NO CUMPLIDO`, vuelve al paso 3 con la evidencia. Por cada `NO VERIFICABLE`, añade una verificación ejecutable (paso 4) o acuerda con el usuario cómo verificarlo.
- No sigas hasta que todos estén `CUMPLIDO` o el usuario acepte explícitamente los pendientes.

## 6. Revisión
- Delega en `code-reviewer`, pasándole también la tabla de resultados y lo que queda fuera de alcance.
- Corrige los hallazgos CRÍTICOS e IMPORTANTES; si los cambios son significativos, repite la verificación (paso 5) y la revisión.
- Comenta los MENORES al usuario sin bloquear.

## 7. Commit y PR
- Haz commits atómicos en inglés con Conventional Commits.
- Sube la rama (`git push -u origin <rama>`).
- Si el remoto es GitHub, abre la PR hacia la rama principal siguiendo la regla `git-workflow` (título, descripción, plantilla). La descripción incluye una sección "Outcomes" con la tabla de resultados y la evidencia de cada uno. No hagas merge.

## 8. Cierre
- Resume al usuario: tabla de resultados con su estado y evidencia, ficheros principales, resultado de tests y revisión, decisiones tomadas, pendientes y enlace a la PR.

## Terminado cuando
- Todos los resultados acordados están `CUMPLIDO` con evidencia (o el usuario ha aceptado los pendientes), los tests pasan, la revisión no tiene hallazgos críticos ni importantes abiertos, la PR está abierta con la sección "Outcomes" (o la rama subida si no es GitHub) y el usuario tiene el resumen con el enlace.
