---
paths:
  - "**/Dockerfile"
  - "**/Dockerfile.*"
  - "**/*.Dockerfile"
  - "**/.dockerignore"
  - "**/compose.yaml"
  - "**/compose.*.yaml"
  - "**/docker-compose*.yml"
---

# Docker

## Imágenes
- Dockerfile multi-etapa: una etapa de build con el SDK y una final mínima solo con lo necesario para ejecutar.
- Imágenes base oficiales y con versión fijada (`eclipse-temurin:25-jre`, `node:<lts>-alpine`, `nginxinc/nginx-unprivileged:<versión>-alpine`), nunca `latest`.
  - Backend Spring: el *jar* extraído por capas (`java -Djarmode=tools -jar app.jar extract --layers --launcher`) sobre una imagen JRE.
  - SPA: el `dist/` servido por `nginx-unprivileged`, con *fallback* a `index.html` para el enrutado del cliente.
- La imagen final se ejecuta con un usuario sin privilegios (`USER`), nunca como `root`.
- Ordena las capas de menos a más cambiantes: dependencias antes que el código, para aprovechar la caché.
- `.dockerignore` excluye `.git`, artefactos de build locales, `node_modules`, `.env` y secretos.
- Ningún secreto en la imagen (ni en `ARG`/`ENV` ni en capas intermedias): la configuración llega por variables de entorno en tiempo de ejecución.
- `HEALTHCHECK` o *probes* contra el endpoint de salud (`/actuator/health` en Spring).
- La imagen se publica en GitHub Container Registry (`ghcr.io/<owner>/<repo>`) desde el workflow de release, etiquetada con la versión sin prefijo (`1.4.0`) además de `latest`.

## Docker Compose (entorno local)
- `compose.yaml` en la raíz levanta las dependencias del servicio (PostgreSQL…) con las mismas versiones que producción.
- Credenciales locales en un `.env` no versionado; versiona un `.env.example` con valores de ejemplo.
- `healthcheck` en cada servicio y `depends_on` con `condition: service_healthy`.
- Volúmenes con nombre para los datos persistentes; puertos publicados solo en `127.0.0.1`.
- En Spring Boot, usa el soporte de Docker Compose (`spring-boot-docker-compose`) para arrancar las dependencias en desarrollo.
