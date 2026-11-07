---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
---

# React

## Componentes
- Solo componentes de función. Un componente por fichero, con el mismo nombre en PascalCase.
- Props tipadas con un `type` propio (`type OrderCardProps = {…}`); no uses `React.FC`.
- Organiza por funcionalidad (`src/features/orders/…`), no por tipo técnico. Lo compartido, en `src/components` y `src/lib`.
- `key` estable y única en las listas (el id del elemento), nunca el índice si la lista puede cambiar.

## Estado y efectos
- No copies props ni datos derivables en estado: calcúlalos durante el render.
- `useEffect` solo para sincronizar con sistemas externos (suscripciones, APIs del navegador). Nunca para cargar datos, derivar estado ni reaccionar a eventos del usuario: eso va en TanStack Query, el render o el manejador del evento.
- Datos del servidor siempre con TanStack Query, con *query keys* centralizadas por funcionalidad. Invalida las consultas afectadas tras cada mutación.
- Estado lo más local posible; súbelo solo hasta el ancestro común que lo necesite. Context para valores que cambian poco (tema, usuario), no para datos del servidor.
- Respeta las reglas de los *hooks* y el linter `eslint-plugin-react-hooks` sin desactivarlo. Extrae la lógica reutilizable a *hooks* propios (`useOrderFilters`).
- No añadas `useMemo`, `useCallback` ni `memo` por defecto: solo ante un problema de rendimiento medido.

## Formularios y datos externos
- Formularios con React Hook Form y un esquema Zod compartido entre validación y tipos.
- Todo dato externo (API, URL, `localStorage`) se valida en el límite antes de usarse.

## Tests
- Prueba el comportamiento visible con Testing Library: busca por rol y texto accesible (`getByRole`), no por clases ni `testid` salvo que no haya alternativa.
- Simula la red con MSW, no los módulos de la aplicación.
