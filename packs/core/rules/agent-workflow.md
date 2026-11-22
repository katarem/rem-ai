# Flujo de trabajo con agentes

- Trabaja guiado por resultados (skill `/odd-cycle`): todo cambio no trivial empieza con resultados observables y verificables (`O1`, `O2`…) acordados con el usuario y termina cuando cada uno está demostrado con evidencia.
- No escribas código sin resultados acordados. Si el cambio cumple los criterios del modo ligero de `/feature-workflow`, defínelos tú; si no (decisiones de diseño, requisitos ambiguos o cambios grandes), delega primero en `architect`.
- Implementa con el especialista de la tecnología (`spring-backend-dev`, `android-compose-dev`, `frontend-dev`…), que también escribe los tests de cada resultado. Si no lo hay, implementa tú siguiendo las reglas del proyecto.
- Verifica con `outcome-verifier`: en el modo ligero, en una pasada combinada con la revisión; en el flujo completo, seguido de `code-reviewer`.
- `test-engineer` solo en el flujo completo, si el verificador marca resultados `SIN TEST`, para reproducir un bug antes del fix o si se pide TDD; en el modo ligero los `SIN TEST` vuelven al especialista.
- En las correcciones, retoma al mismo agente con `SendMessage` pasándole la ruta del handoff; lanza uno nuevo solo si ya no está disponible.
- No des un cambio por terminado ni abras la PR con resultados `NO CUMPLIDO` o `NO VERIFICABLE`, salvo que el usuario lo acepte explícitamente.
- Los subagentes no ven la conversación: delega según la regla `agent-handoff`.
- Lanza subagentes en paralelo solo para tareas independientes entre sí.
- No delegues tareas triviales (renombrar, una línea, una pregunta rápida): hazlas directamente.
- Si un subagente devuelve un resultado incompleto o dudoso, verifícalo antes de presentarlo como hecho.
