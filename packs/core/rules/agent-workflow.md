# Flujo de trabajo con agentes

- Trabaja guiado por resultados (Outcome-Driven Development, skill `/odd-cycle`): todo cambio no trivial empieza con una lista de resultados observables y verificables (`O1`, `O2`…), acordada con el usuario, y termina cuando cada uno está demostrado con evidencia.
- Para tareas no triviales (más de un fichero, decisiones de diseño o requisitos ambiguos) delega primero en `architect` para obtener el plan con sus resultados. No escribas código antes de tener el plan y los resultados acordados.
- Implementa con el agente especialista de la tecnología si está disponible (`spring-backend-dev`, `android-compose-dev`, `frontend-dev`…). Si no lo hay, implementa tú siguiendo las reglas del proyecto.
- Tras implementar, usa `test-engineer` para cubrir los resultados con tests, `outcome-verifier` para demostrar cada resultado contra la realidad y `code-reviewer` antes de abrir la PR.
- No des un cambio por terminado ni abras la PR con resultados `NO CUMPLIDO` o `NO VERIFICABLE`, salvo que el usuario lo acepte explícitamente.
- Los subagentes no ven la conversación: al delegar, pásales el objetivo, los ficheros relevantes, los resultados que cubre su tarea, las restricciones, lo que queda fuera de alcance y el plan acordado.
- Lanza subagentes en paralelo solo para tareas independientes entre sí.
- No delegues tareas triviales (renombrar, una línea, una pregunta rápida): hazlas directamente.
- Si un subagente devuelve un resultado incompleto o dudoso, verifícalo antes de presentarlo como hecho.
