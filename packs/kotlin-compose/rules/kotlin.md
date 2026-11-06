---
paths:
  - "**/*.kt"
  - "**/*.kts"
---

# Kotlin

- `val` por defecto; `var` solo cuando haga falta mutar. Colecciones inmutables (`List`, `Map`) en las APIs públicas.
- `data class` para modelos, `sealed interface` para estados, resultados y eventos cerrados; `when` exhaustivo sin `else`.
- Null-safety: nunca `!!`. Usa `?.`, `?:`, `requireNotNull` con mensaje o modela la ausencia en el tipo.
- Corrutinas con concurrencia estructurada: nunca `GlobalScope` ni `runBlocking` fuera de `main` y tests.
- Inyecta los `CoroutineDispatcher` en lugar de usar `Dispatchers.IO` directamente, para poder testear.
- Funciones `suspend` *main-safe*: quien las implementa cambia de dispatcher, no quien las llama.
- `Flow` para streams de datos; `StateFlow` para estado observable. No expongas `MutableStateFlow` públicamente.
- No captures `CancellationException`: relánzala si usas `catch` genéricos o `runCatching`.
- Funciones de extensión para utilidades cohesionadas con el tipo, no como cajón de sastre.
- Errores esperados modelados en el tipo (`Result` o `sealed` propios); excepciones para lo excepcional.
- Respeta el formato de ktlint/detekt si el proyecto lo tiene configurado.
