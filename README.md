# MisTareas

Aplicación móvil Flutter basada en la interfaz y los flujos de
`Proyecto_react_guía/`. Se ejecuta directamente como app: no incorpora la
presentación web de React ni un marco que simule un teléfono.

Incluye bienvenida, acceso, registro, panel de tareas, creación de tareas,
estado vacío y perfil editable, con búsqueda, filtros, recordatorios, tareas
completadas y temas claro/oscuro. Firebase Authentication gestiona el acceso
por correo y contraseña; el perfil y las tareas se guardan en Cloud Firestore
bajo el UID de cada usuario. El avatar abre el perfil; cerrar sesión es una
acción separada que pide confirmación. El tema elegido se conserva en el
dispositivo.

Antes de ejecutar, habilita el proveedor **Correo electrónico/contraseña** en
Firebase Authentication y crea la base de datos de Cloud Firestore. Las reglas
de `firestore.rules` limitan perfiles y tareas a su propietario; despliega las
reglas con Firebase CLI:

```sh
firebase deploy --only firestore:rules
```

La app usa el proyecto y las plataformas que aparecen en
`lib/firebase_options.dart`. iOS requiere además el `GoogleService-Info.plist`
de esa app Firebase. No publiques nunca reglas abiertas para resolver errores
de permisos.

El diseño de referencia no tiene una barra de navegación inferior: deja esa
zona libre salvo por el botón «+» y muestra las tareas en una lista desplazable.

## Ejecutar y verificar

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```
