# Idioma

- Programa y documenta **siempre en inglés**: código, identificadores, comentarios, Javadoc/KDoc/JSDoc, nombres de tests, mensajes de log y de excepción, README y documentación técnica.
- También en inglés todo lo que queda en el historial: mensajes de commit, nombres de ramas, títulos y descripciones de PR e issues.
- Esto aplica aunque el usuario te escriba en otro idioma: conversa con el usuario en su idioma, pero los artefactos que generes van en inglés.
- Los textos visibles para el usuario final (UI, emails, notificaciones) no están sujetos a esta regla: van en ficheros de recursos/i18n (`strings.xml`, `messages.properties`, `i18n/*.json`…) en el idioma que defina el producto, nunca escritos directamente en el código.
- Si el código existente está en otro idioma, escribe el código nuevo en inglés y no traduzcas en masa lo existente sin pedir permiso; propónlo como tarea aparte.
