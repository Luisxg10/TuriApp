# TurisAGS

TurisAGS es una aplicación móvil Flutter para descubrir lugares turísticos de Aguascalientes, consultar el clima y organizar visitas. El catálogo se lee desde Cloud Firestore; el pronóstico meteorológico procede de Open-Meteo.

## Funcionalidades

- Abre directamente el catálogo; permite buscar por texto y filtrar por categoría.
- Muestra detalles, horario, costo orientativo, ubicación y coordenadas de cada lugar.
- Consulta temperatura actual y pronóstico de siete días para Aguascalientes o para las coordenadas de un lugar.
- Registra cuentas con correo y contraseña, inicia y cierra sesión, y solicita restablecimiento de contraseña.
- Requiere iniciar sesión para guardar favoritos, planear visitas o consultar esas listas.
- Sincroniza favoritos e itinerario por cuenta en Firestore.
- Permite que una cuenta con rol de administración agregue, edite y elimine lugares.
- Usa imágenes locales empaquetadas en la app. Añadir una imagen requiere modificar el código fuente y distribuir una nueva versión.
- Conserva datos locales de ejemplo si Firestore está vacío o no está disponible; se muestran como respaldo, no como datos remotos.

## Tecnologías y arquitectura

- Flutter y Dart.
- Firebase Authentication para cuentas y sesiones.
- Cloud Firestore para catálogo, roles, favoritos e itinerario.
- Open-Meteo Forecast API para datos meteorológicos en JSON.
- `http` para solicitudes HTTP; `shared_preferences` para preferencias y compatibilidad con datos locales.
- Organización en `models`, `repositories`, `viewmodels`, `views`, `widgets`, `utils` y `app`.

## Requisitos

- Flutter SDK y Dart compatibles con las versiones indicadas en `pubspec.yaml`.
- Android Studio o Android SDK; emulador o dispositivo Android.
- Acceso a Internet para Firebase y Open-Meteo.
- Firebase CLI para publicar reglas. FlutterFire CLI se necesita al configurar otro proyecto Firebase.

Verifica las herramientas:

```bash
flutter doctor
flutter devices
```

## Instalación y ejecución

Desde la raíz del repositorio:

```bash
flutter pub get
flutter run
```

Los archivos `lib/firebase_options.dart` y `android/app/google-services.json` se generan localmente y no se versionan. Para usar tu propio Firebase, crea un proyecto en Firebase Console y registra una aplicación Android con el identificador de paquete del proyecto. Habilita Authentication con el proveedor **Correo electrónico/contraseña** y crea una base de datos Firestore.

Instala Firebase CLI y FlutterFire CLI, inicia sesión y genera la configuración local desde la raíz del proyecto:

```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
firebase login
flutterfire configure --project=ID_DEL_PROYECTO --platforms=android
```

Después ejecuta `flutter pub get` y `flutter run`. Para publicar las reglas de Firestore, usa:

```bash
firebase deploy --only firestore:rules --project=ID_DEL_PROYECTO
```

La clave API y el identificador de aplicación de Firebase son configuración cliente; no son credenciales de servidor. Restringe la clave a las APIs de Firebase que utilices y protege los datos con reglas de Firestore. Nunca subas claves privadas ni archivos de cuentas de servicio.

## Datos y permisos de Firestore

La colección `lugares` es pública para lectura. Cada lugar debe contener:

| Campo | Tipo | Requerido |
| --- | --- | --- |
| `nombre`, `descripcion`, `ubicacion`, `categoria` | texto | Sí |
| `costoOrientativo`, `horario`, `fechaActualizacion` | texto | Sí |
| `latitud`, `longitud` | número | Sí |
| `imagenAsset` | texto, ruta de asset, por ejemplo `assets/images/jardin_san_marcos.jpg` | Sí |
| `fuenteUrl` | texto con URL completa | No |

Favoritos e itinerario se guardan en `users/{uid}/favoritos` y `users/{uid}/itinerario`. Las reglas verifican que el UID autenticado coincida con el UID dueño de la ruta. La gestión del catálogo requiere un documento `administradores/{uid}` con `activo: true`; el cliente no puede crear ni modificar documentos de administrador. Para asignar el rol, una persona autorizada crea el documento desde Firebase Console.

La aplicación no usa Firebase Storage ni requiere habilitar Blaze para cargar imágenes. Si se añade una imagen nueva, debe incluirse en `assets/images/`, seleccionarse en el código del formulario y distribuirse una nueva compilación. Cloud Firestore y Authentication tienen sus propios límites del plan Firebase; revísalos en Firebase Console.

## API meteorológica

La app hace solicitudes `GET` al endpoint `https://api.open-meteo.com/v1/forecast` con latitud, longitud, variables `current` y `daily`, zona horaria `auto` y `forecast_days=7`. No usa clave API ni encabezados de autenticación para el uso educativo no comercial. La aplicación procesa temperatura actual, máximas y mínimas, probabilidad máxima de precipitación y fechas; muestra carga, error y opción para reintentar, y mantiene caché en memoria durante 15 minutos por coordenada.

Open-Meteo exige atribución y limita el acceso gratuito a uso no comercial. Consulta las condiciones y límites vigentes en sus [términos](https://open-meteo.com/en/terms) y la [documentación del endpoint](https://open-meteo.com/en/docs).

## Pruebas y demostración

Ejecuta análisis y pruebas desde la raíz:

```bash
flutter analyze
flutter test
```

Las pruebas de clima utilizan un cliente HTTP simulado para verificar el procesamiento de respuestas, errores, timeout y caché; no sustituyen una consulta en vivo. Para la demostración, ejecuta la app en Android con Internet, muestra el catálogo, inicia sesión, guarda un favorito y una visita, consulta el clima y demuestra la administración con una cuenta autorizada. Comprueba también una cuenta común. No muestres contraseñas, tokens ni datos privados en capturas o video.

## Seguridad y archivos locales

`.gitignore` excluye la configuración local generada por FlutterFire (`lib/firebase_options.dart` y `android/app/google-services.json`), archivos de entorno, keystores y credenciales de cuentas de servicio. La clave API de Firebase es configuración cliente, no una clave privada; limita su uso a las APIs necesarias. Los permisos sobre los datos se hacen cumplir con Authentication y `firestore.rules`. Nunca agregues contraseñas, claves privadas, tokens de acceso ni JSON de cuenta de servicio al repositorio.

## Historial Git

Mantén cambios pequeños y descriptivos, con mensajes en español, por ejemplo:

```bash
git add README.md
git commit -m "docs: completar documentación de entrega"
```
