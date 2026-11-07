---
paths:
  - "**/build.gradle.kts"
  - "**/settings.gradle.kts"
  - "**/gradle/libs.versions.toml"
  - "**/gradle-wrapper.properties"
---

# Stack móvil Kotlin Multiplatform

Stack aprobado para apps nuevas (regla `tech-stack`). En proyectos existentes, respeta lo que ya usen (por ejemplo Hilt o Retrofit en una app solo Android).

## Proyecto
- Kotlin Multiplatform con Compose Multiplatform, targets Android e iOS. Se genera con el asistente oficial de KMP (estructura `composeApp/`, `iosApp/` y, si hace falta, `shared/`).
- Kotlin, Compose Multiplatform y Android Gradle Plugin en su última versión estable compatible entre sí (tabla de compatibilidad de Compose Multiplatform).
- Gradle Wrapper con Kotlin DSL; versiones en `gradle/libs.versions.toml`.
- Todo el código que no dependa de la plataforma, UI incluida, va en `commonMain`. `expect`/`actual` solo cuando sea imprescindible.
- Android: `minSdk` 26 y `targetSdk`/`compileSdk` en la última API estable.

## Librerías aprobadas (todas multiplataforma)
| Necesidad | Librería |
|-----------|----------|
| UI | Compose Multiplatform + Material 3 |
| Navegación | Navigation Compose multiplataforma (`org.jetbrains.androidx.navigation`) con rutas tipadas y `@Serializable` |
| Estado | `ViewModel` y `lifecycle-runtime-compose` multiplataforma (`org.jetbrains.androidx.lifecycle`) |
| Inyección de dependencias | Koin (`koin-compose-viewmodel`) |
| Red | Ktor Client + `kotlinx.serialization` (motor OkHttp en Android, Darwin en iOS) |
| Persistencia local | Room multiplataforma con el driver SQLite empaquetado; DataStore para preferencias |
| Imágenes | Coil 3 (`coil-compose` + `coil-network-ktor3`) |
| Fechas | `kotlin.time` y `kotlinx-datetime` |
| Textos | Recursos de Compose Multiplatform (`composeResources/values/strings.xml`) |
| Tests | `kotlin-test`, `kotlinx-coroutines-test`, Turbine; tests de UI con `runComposeUiTest` |
| Calidad | ktlint (vía Spotless) y detekt, aplicados en `./gradlew check` |

## No uses
- Librerías solo Android en `commonMain` (Hilt, Retrofit, Glide, Gson…).
- Jetpack Compose solo Android ni SwiftUI para pantallas que puedan ser comunes.
- `java.time` ni `java.util` en código común.
