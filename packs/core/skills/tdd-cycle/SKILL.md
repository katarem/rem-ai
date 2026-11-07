---
name: tdd-cycle
description: Desarrollo guiado por tests (TDD) con ciclos rojo-verde-refactor. Úsalo cuando el usuario pida trabajar con TDD, cuando el proyecto lo siga como práctica o al corregir un bug que deba reproducirse primero con un test.
---

# Ciclo TDD

Divide el requisito (o cada resultado `O<n>` del plan, si se trabaja con `/odd-cycle`) en una lista de comportamientos pequeños (ejemplos concretos) y ordénalos de más simple a más complejo. Muéstrala al usuario. Para cada comportamiento:

## 1. Rojo
- Escribe **un único** test que exprese el siguiente comportamiento.
- Ejecútalo y confirma que **falla por la razón esperada** (no por un error de compilación ajeno o un import mal puesto).

## 2. Verde
- Escribe el código mínimo para que el test pase. Está permitido que sea ingenuo.
- Ejecuta toda la suite del módulo: todo debe estar en verde.

## 3. Refactor
- Con la suite en verde, elimina duplicación y mejora nombres y diseño, tanto en el código de producción como en el de test.
- Ejecuta la suite tras cada refactor.

## Reglas
- No escribas código de producción sin un test que falle y lo exija.
- No avances al siguiente comportamiento con tests en rojo.
- Si al implementar descubres un caso nuevo, añádelo a la lista en lugar de cubrirlo sobre la marcha.
- Si el proyecto lo permite, haz un commit por ciclo completado (`test:` + `feat:` o un único `feat:`).

## Terminado cuando
- Todos los comportamientos de la lista tienen su test, la suite está en verde y no queda refactor pendiente evidente.
