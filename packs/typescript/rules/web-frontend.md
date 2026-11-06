---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
  - "**/*.astro"
  - "**/*.vue"
  - "**/*.css"
  - "**/*.scss"
---

# Frontend web

## Componentes
- Componentes pequeños y con una responsabilidad. Si un componente pasa de ~150 líneas, divídelo.
- Props tipadas; los componentes de presentación no hacen *fetch* ni acceden a estado global.
- Cubre siempre los estados cargando, vacío, error y con datos.

## Accesibilidad
- HTML semántico (`button`, `nav`, `main`, `label`…) antes que `div` con `onClick`.
- Todo elemento interactivo es accesible por teclado y tiene foco visible.
- `alt` en todas las imágenes (vacío si son decorativas) y `label` asociado a cada campo de formulario.
- Contraste suficiente (WCAG AA) y respeto a `prefers-reduced-motion`.

## Rendimiento
- Envía el mínimo JavaScript: en Astro, componentes estáticos por defecto e islas (`client:visible`, `client:idle`) solo cuando haya interactividad.
- Imágenes optimizadas con el componente del framework (`<Image />`), con dimensiones explícitas y `loading="lazy"` fuera del primer pantallazo.
- Carga diferida de rutas y componentes pesados.

## Estilos
- Usa la solución de estilos del proyecto; no mezcles enfoques ni uses estilos *inline* salvo valores dinámicos.
- Diseño *mobile-first* y responsive. Colores, espacios y tipografía desde variables o tokens del tema.

## Seguridad
- Nunca insertes HTML no confiable (`innerHTML`, `set:html`, `dangerouslySetInnerHTML`) sin sanearlo.
- Solo las variables de entorno con prefijo público (`PUBLIC_`, `VITE_`, `NEXT_PUBLIC_`) llegan al cliente; nunca pongas secretos en ellas.
