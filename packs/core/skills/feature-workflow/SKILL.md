---
name: feature-workflow
description: Flujo completo para implementar una funcionalidad o cambio no trivial, de principio a fin - plan, implementación, tests, revisión y commit - delegando en los agentes especializados. Úsalo cuando el usuario pida una nueva funcionalidad, un endpoint, una pantalla o un cambio que afecte a varios ficheros.
---

# Flujo de implementación de funcionalidades

## 1. Plan
- Delega en `architect` con el requisito del usuario y cualquier contexto que tengas.
- Presenta el plan al usuario de forma resumida. Si hay preguntas abiertas que cambian el diseño, resuélvelas con el usuario antes de seguir.

## 2. Rama
- Crea una rama nueva desde la rama principal actualizada, según la regla `git-workflow` (`feature/<descripcion-corta>`, `fix/…`).

## 3. Implementación
- Delega cada paso del plan en el agente especialista de la tecnología (`spring-backend-dev`, `android-compose-dev`, `frontend-dev`…), o implementa tú si no hay especialista.
- Pasa el plan completo y el paso concreto a ejecutar.
- Pasos independientes (p. ej. backend y frontend) pueden ir en paralelo.

## 4. Tests
- Delega en `test-engineer` indicando qué comportamiento cubrir según la sección "Tests" del plan.
- La suite debe pasar. Si falla, vuelve al paso 3 con el error concreto.

## 5. Revisión
- Delega en `code-reviewer`.
- Corrige los hallazgos CRÍTICOS e IMPORTANTES; repite la revisión si los cambios son significativos.
- Comenta los MENORES al usuario sin bloquear.

## 6. Commit y PR
- Haz commits atómicos en inglés con Conventional Commits.
- Sube la rama (`git push -u origin <rama>`).
- Si el remoto es GitHub, abre la PR hacia la rama principal siguiendo la regla `git-workflow` (título, descripción, plantilla). No hagas merge.

## 7. Cierre
- Resume al usuario: qué se ha hecho, ficheros principales, resultado de tests y revisión, decisiones tomadas, pendientes y enlace a la PR.

## Terminado cuando
- El plan está implementado, los tests pasan, la revisión no tiene hallazgos críticos ni importantes abiertos, la PR está abierta (o la rama subida si no es GitHub) y el usuario tiene el resumen con el enlace.
