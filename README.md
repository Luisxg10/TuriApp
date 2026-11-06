# TurisAGS

TurisAGS es una aplicación móvil Flutter para explorar lugares turísticos de Aguascalientes y consultar el clima de la ciudad o de un lugar seleccionado. El catálogo de esta etapa usa datos locales de ejemplo; el clima se obtiene de Open-Meteo.

## Estado actual

- Inicio y navegación al catálogo.
- Búsqueda por nombre, descripción y ubicación.
- Filtro por categoría: plazas, jardines y museos.
- Ilustración local para cada lugar en el catálogo y su ficha.
- Favoritos con persistencia local entre sesiones.
- Pantalla de detalle con ubicación y coordenadas.
- Pronóstico meteorológico y temperatura actual consultados por HTTP.
- Manejo de carga, errores, reintento y caché temporal del clima.

La app ya guarda favoritos en el dispositivo; autenticacion, perfiles, itinerarios y catalogo remoto siguen pendientes.

## Tecnologías

- Flutter y Dart.
- `http` para consumir Open-Meteo Forecast API.
- `shared_preferences` para guardar los favoritos en el dispositivo.
- Pruebas automatizadas con `flutter_test` y `http/testing.dart`.
- Arquitectura organizada en modelos, vistas, ViewModels y repositorios.

## Requisitos

- Flutter SDK compatible con Dart `^3.13.5` (ver `pubspec.yaml`).
- Android Studio o las herramientas Android SDK para ejecutar en Android.
- Un emulador Android o dispositivo con depuración USB. Para consultar clima se requiere Internet.

Comprueba la instalación con:

```bash
flutter doctor
```

## Instalación y ejecución

Desde la carpeta raíz del proyecto:

```bash
flutter pub get
flutter devices
flutter run
```

Para ejecutar en un dispositivo específico:

```bash
flutter run -d <device_id>
```

El permiso `INTERNET` de Android está declarado en `android/app/src/main/AndroidManifest.xml`.

## Configuración de servicios y variables

La consulta actual usa Open-Meteo (`https://api.open-meteo.com/v1/forecast`) y no requiere una clave ni variables de entorno. Las coordenadas del catálogo se mantienen en `lib/repositories/lugares_repository.dart`.

Firebase está descrito como parte del alcance futuro, pero aún no está configurado en esta versión. Cuando se agregue, documentaremos los pasos para configurar el proyecto y las variables necesarias. No publiques contraseñas, tokens, claves privadas, archivos de cuentas de servicio ni keystores. Los archivos locales se excluyen en `.gitignore`; si una herramienta requiere configuración cliente, comparte solo la configuración pública que esa herramienta indique y conserva las reglas de seguridad del servicio.

## Organización del código

```text
lib/
  app/           configuración de la aplicación
  models/        modelos de dominio y datos
  repositories/  acceso a datos locales, HTTP y favoritos
  viewmodels/    lógica de presentación y selección de datos
  views/         pantallas Flutter
test/            pruebas automatizadas
assets/images/   ilustraciones locales del catálogo
```

Las imágenes del catálogo son ilustraciones generadas para la interfaz, no fotografías oficiales de los sitios. Se cargan localmente desde `assets/images/` y están declaradas en `pubspec.yaml`.

La vista de catálogo lee el texto y la categoría seleccionada, el ViewModel aplica esos criterios a los lugares del repositorio y la vista presenta los resultados o el estado vacío.

## Pruebas y evidencias

Para ejecutar las pruebas automatizadas:

```bash
flutter test
```

Las pruebas del repositorio de clima usan un cliente HTTP simulado y sirven para revisar el procesamiento de respuestas y errores. Para evidenciar una consulta real, ejecuta la app en un emulador o teléfono conectado a Internet, abre **Consultar clima** o entra al detalle de un lugar y captura la pantalla con los datos recibidos. No presentes las respuestas simuladas de pruebas como consultas reales.

## Documentación técnica

El informe de integración con Open-Meteo está en [`informe_integracion_api.md`](informe_integracion_api.md). Ahí se describen el endpoint, los parámetros, la estructura de respuesta, el manejo de errores y las evidencias pendientes para la entrega.

## Historial de cambios

Registra cada incremento con un commit que describa el cambio, por ejemplo:

```bash
git add lib README.md .gitignore
git commit -m "feat: add catalog search and category filters"
```
