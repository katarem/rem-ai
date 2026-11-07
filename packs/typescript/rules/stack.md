---
paths:
  - "**/package.json"
  - "**/pnpm-workspace.yaml"
  - "**/vite.config.*"
  - "**/astro.config.*"
  - "**/tsconfig*.json"
  - "**/eslint.config.*"
---

# Stack web TypeScript

Stack aprobado para webs nuevas (regla `tech-stack`). En proyectos existentes, respeta lo que ya usen.

## Base común
- Node.js en la LTS activa, fijada en `.nvmrc` y en `engines` de `package.json`.
- pnpm como gestor de paquetes, fijado con el campo `packageManager` (Corepack). Nunca mezcles lockfiles.
- TypeScript en modo `strict`, con `noUncheckedIndexedAccess`.
- ESLint (*flat config*) con `typescript-eslint` en modo `strict-type-checked` y Prettier para el formato.
- Scripts estándar en `package.json`: `dev`, `build`, `lint`, `typecheck`, `test` y `format`.

## Aplicación web: React + Vite (SPA)
| Necesidad | Librería |
|-----------|----------|
| Build | Vite con `@vitejs/plugin-react` (plantilla `react-ts`) |
| UI | React (última estable) con componentes de función y *hooks* |
| Enrutado | React Router en modo *data* (`createBrowserRouter`) |
| Estado del servidor | TanStack Query |
| Cliente de la API | Tipos generados desde el OpenAPI del backend con `openapi-typescript` y llamadas con `openapi-fetch` |
| Formularios | React Hook Form + Zod (`@hookform/resolvers`) |
| Validación de datos externos | Zod |
| Estilos | Tailwind CSS con componentes de shadcn/ui (Radix) copiados en `src/components/ui` |
| Textos | i18next + react-i18next, con los textos en `src/locales/<idioma>/*.json` |
| Tests | Vitest + Testing Library + `@testing-library/user-event`, MSW para simular la API, Playwright para E2E |

## Web de contenido: Astro
- Astro con TypeScript estricto, Tailwind CSS y colecciones de contenido tipadas (`content.config.ts`) para el contenido en Markdown/MDX.
- Islas de React solo para las piezas interactivas, con las mismas librerías que la SPA.

## No uses
- Create React App, Next.js ni otro meta-framework para una SPA que consume la API del backend.
- Estado global (Redux, Zustand…) para datos del servidor: TanStack Query. Si hace falta estado global de cliente, propón un ADR.
- Axios ni clientes escritos a mano para la API del backend: el cliente generado desde OpenAPI.
- Librerías de componentes completas (MUI, Ant Design…) ni CSS-in-JS: Tailwind + shadcn/ui.
- Jest: Vitest.
