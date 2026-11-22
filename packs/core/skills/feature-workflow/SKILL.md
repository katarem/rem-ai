---
name: feature-workflow
description: Flujo completo para implementar una funcionalidad o cambio no trivial, de principio a fin y guiado por resultados (ODD) - resultados acordados, plan, implementación con tests, verificación de resultados, revisión y commit - delegando en los agentes especializados, con un modo ligero para cambios pequeños. Úsalo cuando el usuario pida una nueva funcionalidad, un endpoint, una pantalla o un cambio que afecte a varios ficheros.
---

# Flujo de implementación de funcionalidades

El flujo sigue Outcome-Driven Development (skill `/odd-cycle`): los resultados acordados son el contrato del cambio y todos los pasos se refieren a ellos por su identificador (`O1`, `O2`…). Hay dos modos: elige el ligero si cumple todos sus criterios de entrada y el completo en cualquier otro caso.

## Modo ligero

### Criterios de entrada
Responde sí o no a cada uno; si alguno es "no", usa el flujo completo.
1. ¿Lo hace una sola tecnología (un solo especialista, o ninguno)?
2. ¿Toca como mucho 3 ficheros de producción, sin contar sus tests?
3. ¿Evita añadir o cambiar dependencias, esquema de base de datos o contrato público (API/OpenAPI, eventos), y crear módulos o capas?
4. ¿Puedes escribir de 1 a 3 resultados con verificación ejecutable sin preguntas abiertas?

### Pasos
1. **Resultados**: defínelos tú, sin `architect` (`/odd-cycle`), y acuérdalos con el usuario. Escribe un plan mínimo en `<handoff>/plan.md` (Objetivo, Rama, tabla de resultados, Restricciones, Fuera de alcance); el plan no va a engram.
2. **Rama**: como en el paso 2 del flujo completo.
3. **Implementación y tests**: delega en el especialista con el `<slug>`, `<handoff>/plan.md` y los IDs, o implementa tú si no hay especialista. El especialista escribe los tests de cada resultado.
4. **Pasada combinada**: delega en `outcome-verifier` pidiendo una pasada combinada; verifica cada resultado y revisa el diff en una sola ejecución.
   - `NO CUMPLIDO` o hallazgos CRÍTICOS/IMPORTANTES: retoma al mismo especialista con `SendMessage` y la ruta `<handoff>/outcome-verifier.md`; si ya no está disponible, lanza uno nuevo con las rutas de handoff. Después repite la pasada combinada.
   - `SIN TEST`: retoma al mismo especialista con `SendMessage` para que añada el test (o lanza uno nuevo con las rutas de handoff si ya no está disponible) y repite la pasada combinada.
   - Comenta los hallazgos MENORES al usuario sin bloquear.
5. **Commit, PR y cierre**: como en los pasos 6 y 7 del flujo completo.

### Paso al flujo completo
Si durante el trabajo deja de cumplirse un criterio (el especialista devuelve `REQUIERE DECISIÓN`, hacen falta más de 3 ficheros o aparece una decisión de diseño), para y delega en `architect` con el `<slug>` y `<handoff>/plan.md` para que lo convierta en un plan completo. Sigue desde el paso 1 del flujo completo.

## Flujo completo

### 1. Resultados y plan
- Delega en `architect` con el requisito del usuario y cualquier contexto que tengas. Su plan incluye la tabla de resultados esperados (con su verificación), las restricciones, lo que queda fuera de alcance y la rama propuesta. Lo guarda en engram (`plan/<slug>`) o en `<handoff>/plan.md` (regla `agent-handoff`) y te responde con el bloque `## Handoff`.
- Presenta al usuario los resultados y un resumen del plan. Confirma que, si se cumplen esos resultados, el trabajo está hecho; ajusta la lista y resuelve las preguntas abiertas que cambien el diseño antes de seguir. Si cambian los resultados, retoma al `architect` con `SendMessage` (o delega de nuevo con el `<slug>`) para que actualice el plan.

### 2. Rama
- Crea una rama nueva desde la rama principal actualizada (`git fetch origin` y `git switch -c <rama> origin/<principal>`) según la regla `git-workflow`. Usa la rama propuesta en el plan, cuyo nombre sale de su objetivo; su `<slug>` identifica el plan y los ficheros de handoff.

### 3. Implementación y tests
- Delega cada paso del plan en el especialista de la tecnología (`spring-backend-dev`, `android-compose-dev`, `frontend-dev`…), o implementa tú si no hay especialista. El especialista escribe los tests de cada resultado y anota en su handoff qué `O<n>` cubre cada test.
- Pasa el `<slug>`, la referencia al plan, el paso concreto y los IDs de los resultados que persigue (regla `agent-handoff`). No copies el plan.
- Pasos independientes (p. ej. backend y frontend) pueden ir en paralelo.
- Si aparece un resultado nuevo o alguno deja de tener sentido, acuérdalo con el usuario y pide al `architect` que actualice el plan.

### 4. Verificación de resultados
- Delega en `outcome-verifier` con la referencia al plan. La verificación completa queda en `verification/<slug>` (o en `<handoff>/outcome-verifier.md`).
- Por cada `NO CUMPLIDO`, retoma al mismo especialista con `SendMessage` y la referencia a la verificación (si ya no está disponible, lanza uno nuevo con las rutas de handoff).
- Por cada `NO VERIFICABLE` con nota `SIN TEST`, delega en `test-engineer` con la referencia a la verificación. Por cada otro `NO VERIFICABLE`, acuerda con el usuario cómo verificarlo.
- No sigas hasta que todos estén `CUMPLIDO` o el usuario acepte explícitamente los pendientes.

### 5. Revisión
- Delega en `code-reviewer` con la referencia al plan. Los hallazgos completos quedan en `<handoff>/code-reviewer.md`.
- Para los hallazgos CRÍTICOS e IMPORTANTES, retoma al mismo especialista con `SendMessage` y esa ruta (o lanza uno nuevo si ya no está disponible); si los cambios son significativos, repite la verificación (paso 4) y la revisión.
- Comenta los MENORES al usuario sin bloquear.

### 6. Commit y PR
- Haz commits atómicos en inglés con Conventional Commits.
- Sube la rama (`git push -u origin <rama>`).
- Si el remoto es GitHub, abre la PR hacia la rama principal siguiendo la regla `git-workflow` (título, descripción, plantilla). La descripción incluye una sección "Outcomes" con la tabla de resultados y la evidencia de cada uno, tomada de `verification/<slug>` (o de `<handoff>/outcome-verifier.md`). No hagas merge.

### 7. Cierre
- Resume al usuario: tabla de resultados con su estado y evidencia, ficheros principales, resultado de tests y revisión, decisiones tomadas, pendientes y enlace a la PR.

## Terminado cuando
- En cualquiera de los dos modos: todos los resultados acordados están `CUMPLIDO` con evidencia (o el usuario ha aceptado los pendientes), los tests pasan, la revisión (o la pasada combinada) no tiene hallazgos críticos ni importantes abiertos, la PR está abierta con la sección "Outcomes" (o la rama subida si no es GitHub) y el usuario tiene el resumen con el enlace.
