---
name: odd-cycle
description: Desarrollo guiado por resultados (Outcome-Driven Development, ODD) - define los resultados observables y verificables de un cambio antes de implementarlo y no lo da por terminado hasta demostrar cada uno con evidencia. Úsalo al planificar cualquier cambio no trivial, cuando el usuario pida trabajar con ODD o cuando un requisito sea vago y haya que concretar qué significa "hecho". Lo usa /feature-workflow en sus pasos de plan y verificación.
---

# Ciclo ODD

El trabajo se define por lo que debe ser cierto al terminar (resultados), no por las tareas que hay que hacer. Cada resultado lleva su forma de verificarlo, y el cambio solo se cierra cuando todos están demostrados.

## 1. Definir resultados
- Reformula el requisito en una frase y extrae de él una lista corta de resultados (normalmente 2-6), con identificador `O1`, `O2`…
- Cada resultado debe ser:
  - **Observable**: describe un comportamiento del sistema o del usuario, no una tarea. "`POST /orders` con un carrito vacío devuelve `422`" sí; "crear `OrderValidator`" no.
  - **Verificable**: tiene una comprobación ejecutable (test concreto, comando, petición, build, script, captura de UI) con un resultado esperado sin ambigüedad.
  - **Atómico**: si contiene un "y", probablemente son dos resultados.
- Añade:
  - **Restricciones**: lo que debe seguir siendo cierto (la API pública no cambia, la suite sigue en verde, no se añaden dependencias…).
  - **Fuera de alcance**: lo que explícitamente no se hará en este cambio.
- Formato:

  ```
  | ID | Resultado observable | Verificación |
  |----|----------------------|--------------|
  | O1 | <comportamiento> | <test/comando y resultado esperado> |

  Restricciones: …
  Fuera de alcance: …
  ```

## 2. Acordar
- Presenta la lista al usuario y confirma que, si se cumplen esos resultados, el trabajo está hecho. Si falta o sobra alguno, ajústala antes de escribir código.
- La lista acordada es el contrato del cambio: el plan, los tests, la revisión y la PR se refieren a ella por sus identificadores.

## 3. Implementar contra los resultados
- Cada paso del plan indica qué resultados persigue (`→ O1, O3`). Un paso que no persigue ningún resultado ni restricción sobra o revela un resultado no declarado: elimínalo o añade el resultado a la lista con el usuario.
- Al delegar en un agente especialista, pásale los resultados que cubre su paso, las restricciones y lo que queda fuera de alcance.
- Si al implementar descubres un resultado nuevo, añádelo a la lista y avisa al usuario en lugar de cubrirlo sobre la marcha.

## 4. Verificar
- Delega en `outcome-verifier` con la tabla de resultados y las restricciones.
- Por cada resultado `NO CUMPLIDO`, vuelve al paso 3 con la evidencia concreta. Por cada `NO VERIFICABLE`, haz la verificación ejecutable (un test, un script) o acuerda con el usuario cómo verificarlo.
- Repite hasta que todos estén `CUMPLIDO`.

## 5. Registrar la evidencia
- Incluye la tabla final con la evidencia de cada resultado en el resumen al usuario y en la descripción de la PR (sección "Outcomes").

## Reglas
- No empieces a implementar sin resultados acordados.
- Un resultado no está cumplido porque el código "parezca correcto": hace falta una verificación ejecutada cuya salida lo demuestre.
- No cambies en silencio un resultado para que cuadre con lo implementado: cualquier cambio en la lista se acuerda con el usuario.
- ODD y TDD se combinan: los resultados dicen *qué* debe ser cierto; con `/tdd-cycle`, cada resultado se descompone en comportamientos pequeños con su test.

## Terminado cuando
- Todos los resultados acordados están `CUMPLIDO` con evidencia, ninguna restricción está rota y la tabla con la evidencia está en el resumen al usuario (y en la PR si la hay).
