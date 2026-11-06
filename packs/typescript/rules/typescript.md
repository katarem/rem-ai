---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.mts"
  - "**/*.astro"
  - "**/*.vue"
---

# TypeScript

- Modo `strict` siempre. No desactives comprobaciones del compilador para que algo compile.
- Prohibido `any`: usa `unknown` y estrecha el tipo con *type guards*. Nada de `@ts-ignore`; si es inevitable, `@ts-expect-error` con comentario del motivo.
- Evita las aserciones `as` salvo justificadas; nunca `as unknown as T`.
- Deja que TypeScript infiera los tipos locales; anota explícitamente parámetros y retornos de funciones exportadas.
- Uniones discriminadas para estados y resultados (`{ status: 'loading' } | { status: 'error'; error: string } | …`) con `switch` exhaustivo (`satisfies never`).
- `readonly` y `as const` para datos que no deben mutarse.
- Valida los datos externos (APIs, formularios, `localStorage`, variables de entorno) en el límite con Zod o el validador del proyecto, y deriva los tipos del esquema.
- `async/await` en lugar de cadenas `.then()`. Ninguna promesa flotante: `await`, `return` o `void` explícito.
- Módulos ES con exportaciones nombradas; evita `export default` salvo que el framework lo exija (páginas, configuración).
- Importa tipos con `import type`.
- `===` siempre. `??` en lugar de `||` para valores por defecto que admiten `0` o `''`.
