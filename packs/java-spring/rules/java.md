---
paths:
  - "**/*.java"
---

# Java

- Usa las funcionalidades modernas de la versión del proyecto (Java 17/21): `record` para datos inmutables, `sealed` para jerarquías cerradas, *pattern matching* en `instanceof` y `switch`, *text blocks*.
- Prefiere la inmutabilidad: campos `final`, colecciones inmutables (`List.of`, `Collections.unmodifiable…`), sin *setters* salvo que el framework lo exija.
- `Optional` solo como tipo de retorno. Nunca como campo, parámetro ni en colecciones.
- Nunca devuelvas `null` para colecciones: devuelve una colección vacía.
- `var` solo cuando el tipo es evidente en la misma línea.
- Streams para transformaciones claras; un bucle si el stream necesita efectos secundarios o se vuelve ilegible.
- Logging con SLF4J (`private static final Logger log` o `@Slf4j`), con placeholders `{}`. Nunca `System.out` ni `printStackTrace`.
- Excepciones: no captures `Exception`/`Throwable` de forma genérica salvo en el borde del sistema. Crea excepciones de dominio con nombre significativo.
- Lombok solo si el proyecto ya lo usa; no lo introduzcas. No uses `@Data` en entidades JPA.
- Un fichero, una clase pública. Paquetes en minúscula y por funcionalidad/contexto, no por tipo técnico.
