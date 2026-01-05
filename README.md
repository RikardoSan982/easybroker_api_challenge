# EasyBroker API Challenge (staging)

Obtiene todas las propiedades desde la API de EasyBroker en el ambiente de pruebas y muestra sus títulos.

## Ejecución
EASYBROKER_API_KEY="YOUR_KEY" ruby bin/print_titles.rb

## Diseño
- `EasyBroker::Client`: cliente HTTP con errores tipados, timeouts y un pequeño retry/backoff para respuestas 429/5xx.
- `EasyBroker::Properties`: maneja la paginación del endpoint `/v1/properties` y expone una interfaz Enumerable.

## Pruebas
ruby test/properties_test.rb
ruby test/client_retry_test.rb
