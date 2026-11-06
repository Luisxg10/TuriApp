# TurisAGS

TurisAGS es una aplicación móvil Flutter para explorar lugares turísticos de Aguascalientes y consultar el clima de la ciudad o de un lugar seleccionado. El catálogo se consulta desde Cloud Firestore y conserva datos locales de ejemplo como respaldo; el clima se obtiene de Open-Meteo.

## Estado actual

- Inicio y navegación al catálogo.
- Lectura del catálogo desde Firestore, con respaldo local si la colección remota aún no está cargada o no hay conexión.
- Administración de lugares protegida por rol: agregar, editar y eliminar registros.
- Selección de imágenes de galería, subida a Cloud Storage y visualización remota.
- Búsqueda por nombre, descripción y ubicación.
- Filtro por categoría: plazas, jardines y museos.
- Imágenes del catálogo cargadas desde Storage, con ilustraciones locales para los registros de ejemplo.
- Favoritos locales para visitantes sin sesión y sincronizados en Firestore para usuarios autenticados.
- Itinerario con fecha, orden cronológico y opción para eliminar; local sin sesión y sincronizado en Firestore con cuenta.
- Pantalla de detalle con ubicación y coordenadas.
- Pronóstico meteorológico y temperatura actual consultados por HTTP.
- Manejo de carga, errores, reintento y caché temporal del clima.

La app permite crear una cuenta, iniciar y cerrar sesión, y solicitar restablecimiento de contraseña mediante Firebase Authentication. Cuando hay una sesión activa, favoritos e itinerario se sincronizan con Cloud Firestore en el espacio privado de esa cuenta. Los datos locales existentes se incorporan a la cuenta al cargar los datos por primera vez.

## Tecnologías

- Flutter y Dart.
- `http` para consumir Open-Meteo Forecast API.
- `shared_preferences` para guardar los favoritos en el dispositivo.
- `firebase_core` y `firebase_auth` para inicializar Firebase y autenticar usuarios con correo y contraseña.
- `cloud_firestore` para sincronizar favoritos e itinerario por cuenta.
- `firebase_storage` para las imágenes remotas y `image_picker` para seleccionar fotografías desde el dispositivo.
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

La consulta actual usa Open-Meteo (`https://api.open-meteo.com/v1/forecast`) y no requiere una clave ni variables de entorno. Los datos locales de respaldo están en `lib/repositories/lugares_repository.dart`.

Firebase se configura con FlutterFire. El archivo `lib/firebase_options.dart` contiene identificadores de configuración de cliente y no sustituye las reglas de seguridad del proyecto. Para conectar una instalación local, instala Firebase CLI y FlutterFire CLI, inicia sesión y ejecuta `flutterfire configure --project=turisags-2392c`; selecciona Android. La app inicia Firebase en `lib/main.dart`. En Firebase Console habilita Authentication con el proveedor **Correo electrónico/contraseña**.

Para habilitar la sincronización, crea una base de datos **Cloud Firestore** en el modo nativo desde Firebase Console. Después de elegir la región, publica las reglas del archivo `firestore.rules` desde la raíz del proyecto:

```bash
firebase deploy --only firestore:rules --project=turisags-2392c
```

Las reglas permiten lectura pública de `lugares/{lugarId}` y limitan lectura y escritura al usuario autenticado bajo `users/{uid}/favoritos` y `users/{uid}/itinerario`. Los documentos del catálogo usan los campos `nombre`, `descripcion`, `ubicacion`, `categoria`, `costoOrientativo`, `horario`, `fechaActualizacion` (texto `AAAA-MM-DD`), `fuenteUrl`, `latitud` y `longitud`; conservan `imagenAsset` para los ejemplos locales o usan `imagenUrl` e `imagenStoragePath` para las imágenes subidas. Después de crear o cambiar documentos, usa el botón de actualizar del catálogo.

Para administrar el catálogo, activa Cloud Storage en Firebase Console y configura el bucket. Cloud Storage for Firebase actualmente requiere que el proyecto esté en el plan Blaze, que vincula una cuenta de facturación; revisa las condiciones de facturación antes de habilitarlo. Después, ejecuta de nuevo `flutterfire configure --project=turisags-2392c --platforms=android` para actualizar `firebase_options.dart` con el bucket.

El rol administrativo se concede desde Firebase Console, no desde la app: en **Authentication > Users**, copia el UID de la cuenta admin y crea en Firestore `administradores/{UID}` con el campo booleano `activo: true`. Las reglas niegan las escrituras a esa colección para los clientes, así un usuario normal no puede asignarse el rol. Para publicar las reglas del catálogo y Storage, ejecuta:

```bash
firebase deploy --only firestore:rules,storage --project=turisags-2392c
```

Storage permite lecturas públicas para mostrar las imágenes del catálogo, y restringe las cargas y eliminaciones a administradores; acepta imágenes JPG, PNG y WebP de menos de 5 MB. La app sube el archivo a Storage y guarda en Firestore `imagenUrl` e `imagenStoragePath`. Elimina la imagen anterior cuando se reemplaza o borra un lugar.

## Organización del código

```text
lib/
  app/           configuración de la aplicación
  models/        modelos de dominio y datos
  repositories/  acceso a datos locales, HTTP, autenticación y Firestore
  viewmodels/    lógica de presentación y selección de datos
  views/         pantallas Flutter
  widgets/       componentes reutilizables, incluida la imagen remota/local
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
