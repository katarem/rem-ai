---
paths:
  - "**/*.kt"
---

# Jetpack Compose

Aplica a ficheros con funciones `@Composable` y a ViewModels.

## Estado y arquitectura (UDF)
- El ViewModel expone un único `StateFlow<UiState>` inmutable y recibe acciones a través de métodos (`onSearch(query)`) o un `onEvent(UiEvent)`.
- Recoge el estado con `collectAsStateWithLifecycle()`.
- Separa *screen* (conectada al ViewModel) de *content* (sin estado, recibe `state` y lambdas). Las previews y los tests usan el *content*.
- Eleva el estado (*state hoisting*): los composables reutilizables reciben el valor y un `onValueChange`, no lo gestionan.
- Ninguna lógica de negocio ni llamadas a red/BD dentro de un composable.
- Efectos secundarios solo en `LaunchedEffect`, `DisposableEffect` o `rememberCoroutineScope`, con claves correctas.

## Composables
- Firma: parámetros obligatorios, después `modifier: Modifier = Modifier` como primer opcional, y lambdas al final.
- El `modifier` recibido se aplica al elemento raíz y solo una vez.
- `remember` para objetos costosos y `derivedStateOf` para valores derivados que cambian más que su origen.
- Parámetros estables: modelos inmutables, `ImmutableList` (kotlinx.collections.immutable) o anotados con `@Immutable`/`@Stable` cuando sea necesario.
- `LazyColumn`/`LazyRow` con `key` estable en `items`.
- Material 3 y los tokens del tema (`MaterialTheme.colorScheme`, `typography`); sin colores ni tamaños fijos repetidos.
- Textos en `strings.xml` (o recursos de Compose Multiplatform), nunca hardcodeados.
- Accesibilidad: `contentDescription` en imágenes e iconos con significado (`null` si son decorativos) y áreas táctiles de al menos 48dp.

## Previews y tests
- `@Preview` con estados representativos, incluido modo oscuro cuando aplique.
- Tests de UI con `createComposeRule()` buscando por texto, `contentDescription` o `testTag`.
