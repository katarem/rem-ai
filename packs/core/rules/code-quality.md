# Calidad de código

## Principios
- Sigue el estilo, la arquitectura y las librerías que ya usa el proyecto antes que tus preferencias.
- Prioriza la legibilidad: nombres descriptivos, funciones cortas con una sola responsabilidad, sin abreviaturas crípticas.
- Resuelve el problema pedido sin sobreingeniería: nada de abstracciones, parámetros o capas "por si acaso".
- No dejes código muerto, comentado ni `TODO` sin contexto. Los comentarios explican el *porqué*, no el *qué*.
- No añadas dependencias nuevas sin justificarlo y sin comprobar que no existe ya una alternativa en el proyecto.

## Errores
- No silencies errores (`catch` vacíos, ignorar resultados). Gestiónalos o propágalos con contexto.
- Falla pronto: valida entradas en los límites del sistema (API, UI, ficheros, mensajes).

## Seguridad
- Nunca escribas secretos en el código ni en la configuración versionada: usa variables de entorno o un gestor de secretos.
- Trata toda entrada externa como no confiable: valida, escapa y usa consultas parametrizadas.
- No registres en logs datos personales, tokens ni contraseñas.

## Verificación
- Antes de dar una tarea por terminada, compila, ejecuta los tests y el linter del proyecto. Si algo falla, dilo.
