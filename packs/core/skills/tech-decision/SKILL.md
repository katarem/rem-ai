---
name: tech-decision
description: Evalúa y documenta una decisión de tecnología como ADR (Architecture Decision Record) - comparar alternativas frente al stack aprobado, recomendar una y registrarla en docs/adr/. Úsalo cuando se proponga un lenguaje, framework, base de datos o librería fuera del stack aprobado de la regla tech-stack, o cuando el usuario quiera decidir o cambiar una tecnología.
---

# Decisión de tecnología (ADR)

Resultado: un ADR en `docs/adr/` aceptado por el usuario, que justifica usar (o no) una tecnología fuera del stack aprobado. Plantilla en `templates/adr.md` dentro de esta skill.

## 1. Delimita la necesidad
- Formula el problema en una frase, sin nombrar la solución ("necesitamos notificar en tiempo real a 10k clientes conectados", no "necesitamos Kafka").
- Anota los requisitos que la decisión debe cumplir (rendimiento, plataformas, coste, plazos, conocimiento del equipo) y cómo se medirían.

## 2. Comprueba el stack aprobado primero
- Revisa si la regla `tech-stack`, la regla `stack` del pack o las dependencias que ya tiene el proyecto cubren la necesidad. Si la cubren, la decisión es usarlas: díselo al usuario y termina sin ADR.

## 3. Compara alternativas
- Evalúa como máximo tres opciones, incluida siempre la que usa el stack aprobado.
- Para cada una: encaje con los requisitos, madurez y mantenimiento (última versión, actividad, licencia), coste operativo (infraestructura, despliegue, monitorización), curva de aprendizaje e impacto en los packs y el CI.
- Si un requisito es dudoso, demuéstralo con una prueba pequeña y desechable antes de decidir.

## 4. Recomienda y acuerda
- Recomienda una opción con su justificación y sus consecuencias, incluidas las negativas.
- Presenta la recomendación al usuario: la decisión es suya.

## 5. Registra el ADR
- Copia `templates/adr.md` a `docs/adr/NNNN-<titulo-en-kebab-case>.md` con el siguiente número libre, en inglés (regla `language`), con estado `Accepted` o `Rejected`.
- Si sustituye una decisión anterior, marca el ADR antiguo como `Superseded by NNNN` y enlázalos.
- Si la tecnología pasa a formar parte del stack para todos los proyectos, propón actualizar rem-ai (regla `tech-stack` y regla `stack` del pack) como cambio aparte.

## Terminado cuando
- O el stack aprobado ya cubría la necesidad y el usuario lo sabe, o hay un ADR en `docs/adr/` con el problema, las alternativas, la decisión del usuario y sus consecuencias, incluido en la rama del cambio que lo necesita.
