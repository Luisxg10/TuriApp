# TurisAGS

TurisAGS es una aplicación móvil Flutter para explorar lugares turísticos de Aguascalientes y consultar el clima de la ciudad o de un lugar seleccionado. El catálogo de esta etapa usa datos locales de ejemplo; el clima se obtiene de Open-Meteo.

## Estado actual

- Inicio y navegación al catálogo.
- Búsqueda por nombre, descripción y ubicación.
- Filtro por categoría: plazas, jardines y museos.
- Ilustración local para cada lugar en el catálogo y su ficha.
- Favoritos con persistencia local entre sesiones.
- Itinerario local de visitas con fecha, orden cronológico y opción para eliminar.
- Pantalla de detalle con ubicación y coordenadas.
- Pronóstico meteorológico y temperatura actual consultados por HTTP.
- Manejo de carga, errores, reintento y caché temporal del clima.

La app permite crear una cuenta, iniciar y cerrar sesión, y solicitar restablecimiento de contraseña mediante Firebase Authentication. Favoritos e itinerario todavía se guardan localmente en el dispositivo; la sincronización por cuenta con Firestore queda como siguiente etapa.

## Tecnologías

- Flutter y Dart.
- `http` para consumir Open-Meteo Forecast API.
- `shared_preferences` para guardar los favoritos en el dispositivo.
- `firebase_core` y `firebase_auth` para inicializar Firebase y autenticar usuarios con correo y contraseña.
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

Firebase se configura con FlutterFire. El archivo `lib/firebase_options.dart` contiene identificadores de configuración de cliente y no sustituye las reglas de seguridad del proyecto. Para conectar una instalación local, instala Firebase CLI y FlutterFire CLI, inicia sesión y ejecuta `flutterfire configure --project=turisags-2392c`; selecciona Android. La app inicia Firebase en `lib/main.dart`. En Firebase Console habilita Authentication con el proveedor **Correo electrónico/contraseña**. No se requieren variables de entorno para este flujo. No publiques contraseñas, tokens, claves privadas, archivos de cuentas de servicio ni keystores.

## Organización del código

```text
lib/
  app/           configuración de la aplicación
  models/        modelos de dominio y datos
  repositories/  acceso a datos locales, HTTP, autenticación y favoritos
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
git commit -m "feat: agregar autenticación con Firebase"
```
