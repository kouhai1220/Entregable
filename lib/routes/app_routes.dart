// Definición de las pantallas (vistas) de la aplicación.
//
// Funciona como una lista de rutas "manual": AppShell usa este enum para
// saber qué pantalla mostrar y navegar entre ellas sin depender de un
// sistema de rutas por nombre.

/// Cada valor representa una pantalla distinta de la app y su etiqueta visible.
enum AppScreen {
  splash('Carga'),
  login('Acceso'),
  register('Registro'),
  tasks('Panel'),
  form('Nueva tarea'),
  empty('Estado vacío');

  const AppScreen(this.label);

  final String label;
}
