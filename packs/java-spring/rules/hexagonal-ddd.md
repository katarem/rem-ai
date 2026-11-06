---
paths:
  - "**/*.java"
---

# Arquitectura hexagonal y DDD

Aplica estas reglas si el proyecto sigue arquitectura hexagonal (paquetes `domain`, `application`, `infrastructure` o similares). Si sigue otra arquitectura, respeta la existente.

## Capas y dependencias
- `domain`: modelo de negocio puro. **Sin dependencias de Spring, JPA, Jackson ni ningún framework.**
- `application`: casos de uso que orquestan el dominio. Define los puertos de entrada (casos de uso) y de salida (repositorios, clientes externos, publicadores de eventos) como interfaces.
- `infrastructure`: adaptadores que implementan los puertos (REST, persistencia, mensajería, clientes HTTP) y la configuración de Spring.
- Las dependencias solo apuntan hacia dentro: `infrastructure → application → domain`. Nunca al revés.

## Modelo de dominio
- Agregados con invariantes protegidas: el estado solo cambia a través de métodos con intención de negocio (`order.confirm()`, no `order.setStatus(...)`).
- Value objects inmutables (`record`) que se validan en su constructor (`Email`, `Money`, `OrderId`).
- Identificadores tipados en lugar de `Long`/`UUID` sueltos.
- Una interfaz de repositorio por agregado, definida en dominio/aplicación, con lenguaje del dominio.
- Los eventos de dominio describen hechos en pasado (`OrderConfirmed`).

## Adaptadores
- Las entidades JPA son distintas del modelo de dominio y viven en `infrastructure`; conviértelas con *mappers* explícitos.
- Los DTOs de la API viven en el adaptador REST.
- Los nombres de los adaptadores indican tecnología y puerto: `JpaOrderRepository`, `RestPaymentClient`.

## Verificación
- Si el proyecto usa ArchUnit, mantén o amplía sus reglas al crear paquetes nuevos.
