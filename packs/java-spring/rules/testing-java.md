---
paths:
  - "**/src/test/**/*.java"
---

# Tests en Java / Spring

- JUnit 5 + AssertJ para las aserciones (`assertThat(...)`), Mockito para dobles de prueba.
- Nombres que describen comportamiento: `should_reject_order_when_stock_is_insufficient` o `@DisplayName` legible. Sigue la convención existente del proyecto.
- Estructura `// given`, `// when`, `// then`.
- **Dominio**: tests unitarios puros, sin Spring ni mocks salvo para puertos de salida.
- **Adaptadores**: usa *test slices* (`@WebMvcTest`, `@WebFluxTest`, `@DataJpaTest`, `@JsonTest`) en lugar de `@SpringBootTest` cuando baste.
- **Base de datos**: Testcontainers con el mismo motor que producción, no H2.
- **HTTP externo**: WireMock o `MockRestServiceServer`; nunca llames a APIs reales.
- `@SpringBootTest` solo para tests de integración de extremo a extremo; reutiliza el contexto (evita `@DirtiesContext` y `@MockBean` innecesarios).
- Nada de `Thread.sleep`: usa Awaitility para comportamiento asíncrono y `StepVerifier` para Reactor.
- Datos de prueba con *builders* u *object mothers*, no con constructores de 10 parámetros repetidos.
