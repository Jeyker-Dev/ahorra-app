# Documentación de Rinde (app)

## Mapa

| Archivo | Qué contiene |
|---|---|
| [00-vision.md](00-vision.md) | Qué es Ahorra, problema, módulos y fuera de alcance |
| [01-architecture.md](01-architecture.md) | Stack, estructura de `lib/`, capas y convenciones |
| [roadmap.md](roadmap.md) | Fases de la app |
| Decisiones (FunWork) | Los ADR viven en el módulo de Decisiones de FunWork, proyecto Ahorra; no en este repo |
| Tareas (FunWork) | Las tareas viven en FunWork, proyecto Ahorra, área frontend; no en este repo |
| [changelog.md](changelog.md) | Qué se hizo y cuándo |

## Ciclo de trabajo

1. Antes de una tarea: leer `AGENTS.md`, `00-vision.md`, `01-architecture.md` y las áreas que toca. Crear la tarea en FunWork (proyecto Ahorra, área frontend) si no existe y pasarla a `Doing`.
2. Implementar con test primero cuando haya una regla verificable, y dejar `flutter analyze` y `flutter test` en verde.
3. Al terminar: pasar la tarea a `Done` en FunWork con el commit en la descripción, agregar una entrada en `changelog.md`, actualizar el área si cambió una regla y registrar un ADR en FunWork si se tomó una decisión de arquitectura.
