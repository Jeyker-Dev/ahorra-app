# Roadmap

## Principios

- App offline-first para Android en un solo usuario: la UI lee exclusivamente desde Drift y los montos conservan moneda y tasa vigente sin recalcular el historial.
- Avanzar por fases verticales verificables con tests antes de agregar complejidad especulativa.

## Fase 0 — Base del proyecto (completada)

- Scaffold Flutter (`ahorra_app`), Riverpod, base Drift vacía (`schemaVersion = 1`) y estructura por features.

## Fase 1 — Fundación y tasas de cambio (completada)

- Login de sesión única con tokens en almacenamiento seguro y cliente `Dio` con refresco rotativo single-flight.
- Navegación principal con `go_router` (5 pestañas + subruta `/rates`).
- Tabla Drift `exchange_rates` (`schemaVersion = 2`) y pantalla completa de tasas (actuales, brecha, variación a 30 días, gráfico 7/30/90 días, skeleton, estado vacío y banners de antigüedad/sin conexión).

## Fase 2 — Sincronización de escrituras y primer módulo transaccional (siguiente)

- Motor de cola offline (`core/sync`) acoplado al endpoint de cambios incrementales en `ahorra-api`.
- Primer módulo con escritura local y sincronización (por ejemplo, gastos o ingresos recurrentes).

## Fase 3 — Módulos restantes de v1 y bloqueo local

- Compras con memoria de precio, recomendación de compras, metas y pantalla de desbloqueo local (PIN/biometría).

## Referencias externas

- Tareas y ADRs: proyecto **Ahorra** (id `2`) en FunWork.
