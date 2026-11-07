# Flujo de trabajo con agentes

- Para tareas no triviales (más de un fichero, decisiones de diseño o requisitos ambiguos) delega primero en `architect` para obtener un plan. No escribas código antes de tener el plan.
- Implementa con el agente especialista de la tecnología si está disponible (`spring-backend-dev`, `android-compose-dev`, `frontend-dev`…). Si no lo hay, implementa tú siguiendo las reglas del proyecto.
- Tras implementar, usa `test-engineer` para cubrir el cambio con tests y `code-reviewer` antes de abrir la PR.
- Los subagentes no ven la conversación: al delegar, pásales el objetivo, los ficheros relevantes, las restricciones, el plan acordado y el criterio de "terminado".
- Lanza subagentes en paralelo solo para tareas independientes entre sí.
- No delegues tareas triviales (renombrar, una línea, una pregunta rápida): hazlas directamente.
- Si un subagente devuelve un resultado incompleto o dudoso, verifícalo antes de presentarlo como hecho.
