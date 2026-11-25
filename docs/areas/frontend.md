# Frontend

## Convenciones

- **Riverpod 3**: `Provider`, `NotifierProvider`, `AsyncNotifierProvider` y `StreamProvider` escritos a mano (sin `riverpod_generator`). El composition root en `lib/app/app_providers.dart` conecta los adaptadores de `features/` hacia los puertos de `core/`.
- **Repositorios y puertos**: las interfaces viven en `domain/` (Dart puro) y las implementaciones con Drift/Dio en `data/`.
- **Precisión decimal**: montos y tasas usan `Decimal` (`decimal`) de punta a punta. La única conversión a `double` ocurre dentro de `RateHistoryChart` (`fl_chart`) para coordenadas del lienzo.
- **Reloj de la app**: `currentTimeProvider` relee la hora cada minuto; la antigüedad de las tasas, el aviso de tasa vieja (más de 12 h, según el `fetched_at` más antiguo entre BCV y USDT) y la fecha de hoy en Caracas se actualizan aunque la pantalla siga abierta.
- **Errores inesperados**: no se silencian. El refresco de tasas los relanza y el login los entrega a `FlutterError.reportError` y muestra un mensaje genérico.
- **Formato `es_VE`**: `lib/core/money/money_format.dart` usa `DecimalFormatter` + `NumberFormat` con locale `es_VE` (miles `.`, decimales `,`, porcentajes `"12,3 %"`).
- **Tema y tipografía**: `AhorraTheme` (`lib/core/ui/ahorra_theme.dart`) implementa la paleta oscura por defecto de `stitch-design.md` con fuentes locales `Manrope` y `Inter` (cifras tabulares) empaquetadas en `assets/fonts/`.
- **Permisos Android**: `android/app/src/main/AndroidManifest.xml` declara `INTERNET` para builds release.
- **Tests de arquitectura**: `test/architecture/layer_dependencies_test.dart` verifica aislamiento de `domain/`, no importación entre features y ausencia de `double` en dominio y dinero.

## Estado actual por módulo

| Módulo | Estado | Notas |
|---|---|---|
| `auth` | Implementado (Fase 1) | Login de sesión única, `SecureStorageTokenStore`, refresh rotativo single-flight y logout best-effort |
| `navigation` | Implementado (Fase 1) | `go_router` con `StatefulShellRoute` (5 pestañas) y `/rates` sin barra inferior |
| `home` | Base (Fase 1) | `RateChip`, `StaleRateBanner` y menú con cierre de sesión; tarjetas de resumen en Fase 2+ |
| `rates` | Implementado (Fase 1) | Lectura exclusiva desde Drift, refresco desde API, variación 30d, brecha, gráfico 7/30/90d y lista de actualizaciones |
| `income` | Placeholder | Pestaña y ruta listas para Fase 2+ |
| `shopping` | Placeholder | Pestaña y ruta listas para Fase 2+ |
| `expenses` | Placeholder | Pestaña y ruta listas para Fase 2+ |
| `goals` | Placeholder | Pestaña y ruta listas para Fase 2+ |

## Deuda técnica / pendientes

- **Cola de sincronización de escrituras (`core/sync`)**: diferida a Fase 2 junto con el primer módulo de escritura y el endpoint de cambios incrementales en `ahorra-api`.
- **Pantalla de desbloqueo local (PIN / biometría)**: fuera de Fase 1; pendiente para fase posterior.
- **Módulos de negocio**: resumen completo en `Home`, `Income`, `Shopping`, `Expenses` y `Goals`.
