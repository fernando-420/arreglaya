# Actividad 3: clima, contacto y rutas en ArreglaYa

## Adaptación de la consigna
ConectaCruz muestra una ficha de negocio. ArreglaYa muestra la ficha de un servicio aceptado al técnico: contiene el clima de la ubicación del cliente y los botones Llamar, WhatsApp y Cómo llegar. Esta equivalencia y la sustitución de los laboratorios previos deben ser aceptadas por el docente. La app no tiene carrito ni pedidos de productos, así que no se debe presentar esa parte como realizada.

## Ciclo de la petición
1. Al abrir un servicio aceptado, `ClimaCard` inicia una petición HTTP GET a Open-Meteo con latitud, longitud y los campos `temperature_2m` y `weather_code`.
2. Mientras espera muestra un indicador de carga. `ClimaService` espera hasta 10 segundos.
3. Si recibe HTTP 200, `jsonDecode` convierte el JSON y `Clima.fromJson` valida y transforma sus campos en un modelo tipado. La tarjeta muestra temperatura y descripción.
4. Ante error de conexión, tiempo de espera o datos inválidos se muestra un aviso y la opción Reintentar. Si faltan coordenadas se usa Santa Cruz como referencia y se indica en pantalla.

Open-Meteo es apropiado para esta actividad porque su modalidad no comercial no requiere clave. OpenWeather también ofrece datos actuales pero requiere cuenta y clave para las peticiones. Ver https://open-meteo.com/en/docs y https://openweathermap.org/api/current. Consulta sus condiciones si se usa comercialmente.

## Acciones y Android
- Llamar abre el marcador con `tel:` y no inicia la llamada. WhatsApp abre un mensaje preparado. Si el número tiene 8 dígitos, se agrega el prefijo de Bolivia 591; otros números deben incluir el código de país.
- Cómo llegar abre Google Maps con un destino de las coordenadas del servicio. Si no hay coordenadas, aparece un aviso.
- AndroidManifest.xml declara INTERNET y, dentro de queries, los intents DIAL/tel y VIEW/https para visibilidad en Android 11 o superior. No se necesita permiso CALL_PHONE para abrir el marcador. La apertura depende de las aplicaciones instaladas y debe comprobarse en el teléfono.

## Pruebas y capturas para la presentación
Preparar una cuenta de cliente y una cuenta de técnico verificado, una solicitud con coordenadas y teléfono de prueba, y aceptar una oferta. Abrir sesión como técnico > Mis trabajos > servicio aceptado.

- 12-A: abre https://api.open-meteo.com/v1/forecast?latitude=-17.78&longitude=-63.18&current=temperature_2m y captura el JSON.
- 12-B: captura `lib/clima_service.dart`, mostrando GET, timeout, jsonDecode y Clima.fromJson.
- 12-C: captura la tarjeta con temperatura y ubicación de la solicitud.
- 12-D: cierra y vuelve a abrir el detalle sin Wi-Fi ni datos, o entra y usa Reintentar sin conexión. Captura el mensaje y botón. Reactiva internet y pulsa Reintentar; registra el resultado.
- 13-A: captura Llamar, WhatsApp y Cómo llegar en el servicio aceptado.
- 13-B: abre WhatsApp y captura el mensaje preparado sin enviarlo.
- 13-C: abre Cómo llegar y captura Google Maps con el destino de prueba.
- 13-D: abre el mapa de trabajos cercanos, captura los marcadores aproximados de solicitudes y selecciona uno.
- 13-E: muestra `service_requests` y columnas `latitude` y `longitude` en Supabase con datos de prueba; oculta datos privados.
- 13-F: captura `<queries>` en `android/app/src/main/AndroidManifest.xml`.
- 13-G: captura el mapa y su atribución © OpenStreetMap. El proyecto usa OpenStreetMap con flutter_map, no Maps SDK.
- 13-H: captura la región real del proyecto en Supabase Project Settings; no la inventes. Una región cercana puede reducir latencia.
- Captura también el marcador abierto con el número, la versión de Android (Ajustes > Acerca del teléfono) y registra modelo, versión, fecha y resultado de cada acción.
- Laboratorios 6–11: usa capturas reales de formularios, registros, solicitudes, ofertas y roles cuando correspondan; indica explícitamente lo que ArreglaYa no implementa. El carrito/pedido y el panel de dueño no son equivalencias automáticas.

## Guion de video (60 segundos)
0–10 s: «Somos Fernando Adriel Montero Casanova y María Lizeth Marcelo Claros. ArreglaYa conecta clientes con técnicos».
10–22 s: Mostrar detalle de servicio y clima. «La app consulta Open-Meteo por HTTPS, recibe JSON y lo convierte en un modelo Clima».
22–32 s: Desconectar y mostrar error y Reintentar. «Si falla la red o pasan diez segundos, se muestra un aviso y se puede reintentar».
32–48 s: Mostrar Llamar, WhatsApp con mensaje y Cómo llegar con coordenadas, sin realizar la llamada ni enviar mensajes.
48–60 s: Mostrar `<queries>` y mapa de solicitudes. «Probamos en Android [versión real]. El mapa usa OpenStreetMap y los datos se almacenan en Supabase».

## Verificación local
Ejecutar `flutter pub get`, `flutter analyze` y `flutter test`, luego `flutter run` en el teléfono. Los resultados reales de compilación y teléfono deben anotarse después de ejecutarlos; no se han verificado en este entorno.
