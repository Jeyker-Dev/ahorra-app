# Arquitectura

## Stack

- **App**: Flutter (Android), en la raíz de este repo.
- **Estado e inyección**: Riverpod.
- **Base local**: Drift (SQLite). La app es offline-first.
- **Backend**: `ahorra-api`, un repo aparte en FastAPI. Docker vive allá; este repo no usa Docker.
- **Sesión**: login contra `ahorra-api` con un access token JWT de vida corta y un refresh token rotativo. Los dos tokens se guardan en almacenamiento seguro del dispositivo.

## Capas y responsabilidades

Estructura de `lib/` organizada por feature:

```
lib/
├── app/            Arranque, router, tema y ProviderScope
├── core/
│   ├── db/         Base Drift (schemaVersion 2), tabla exchange_rates, convertidores y migraciones
│   ├── errors/     Excepciones base de reglas de negocio (BusinessRuleException)
│   ├── sync/       Cola de sincronización hacia la API (Fase 2)
│   ├── network/    Configuración de API_BASE_URL, cliente Dio e interceptor single-flight de refresh
│   ├── money/      Formateo es_VE con Decimal (sin double)
│   └── ui/         Tema Material 3 (stitch-design.md) y componentes compartidos (RateChip, StaleRateBanner, CurrencyTag)
└── features/
    └── <feature>/  rates, income, expenses, shopping, products, goals, home, auth
        ├── domain/        Dart puro: entidades, reglas y puertos
        ├── data/          DTOs, almacenamiento seguro y repositorios Drift/API
        └── presentation/  Pantallas, widgets y providers Riverpod
```

- `domain` no importa Flutter, Drift ni HTTP.
- `data` implementa los puertos de `domain`.
- `presentation` solo habla con `domain` a través de providers.
- El composition root en `app/` conecta los puertos de `core/` con los adaptadores de `features/` (por ejemplo `AuthTokenDelegate` hacia `AuthSessionDelegate` y `_HomeContainer`).

## Red y refresco de sesión (`core/network`, `features/auth`)

- La URL base llega obligatoriamente por `--dart-define=API_BASE_URL=...`; `main.dart` falla al arrancar si falta.
- Los tokens (`access_token` y `refresh_token`) se guardan en `flutter_secure_storage` detrás del puerto `TokenStore`. Nunca se guardan en Drift ni `SharedPreferences`.
- `RemoteAuthRepository` usa un `Dio` sin interceptor para `/auth/token`, `/auth/refresh` y `/auth/logout` (el logout revoca en el servidor de forma best-effort y siempre limpia el almacenamiento seguro manteniendo los datos de Drift).
- `AuthInterceptor` adjunta `Authorization: Bearer <access_token>` en las rutas protegidas. Ante un `401`, coordina un único `/auth/refresh` en vuelo (`Completer` compartido para `401` concurrentes), persiste el refresh token rotado y reintenta una vez. Si el refresh devuelve `401`/`403`, limpia los tokens y redirige a `/login`; si falla por red, conserva los tokens.

## Tasas de cambio (`features/rates`)

- `DriftRatesRepository` consulta `/rates/latest` y `/rates?kind=bcv|usdt&from=...&to=...`, haciendo upsert idempotente por `id` en `exchange_rates`.
- La UI solo observa streams de Drift (`watchCurrentRates`, `watchHistory`, `watchRecentUpdates`). Si el refresco falla, se conservan los datos locales.
- La tasa BCV vigente exige `value_date <= hoy` (hora de Caracas, `UTC-4`) sin fallback a fechas futuras; si no existe ninguna vigente, devuelve `null` y oculta la tarjeta de brecha.
- La advertencia de tasa desactualizada (`> 12 h`) evalúa el `fetched_at` más antiguo entre BCV y USDT actuales.

## Convenciones críticas

- **La UI lee solo de Drift.** Nunca muestra datos que vengan directo de la API.
- **Las escrituras van primero a Drift.** Después entran a la cola de `core/sync`, que las envía a la API y reintenta cuando hay conexión.
- **Las features no se importan entre sí.** Lo que compartan va en `core/` o se conecta en `app/`.
- **Cada monto guarda su moneda y la tasa vigente al registrarlo.** El historial no se recalcula cuando cambia la tasa.
- **Un solo usuario.** El usuario se crea por CLI en la API; la app solo tiene login, sin registro.

## Mapa de rutas

`go_router` redirige según `authStateProvider`: sin tokens va a `/login`; autenticado abre la barra inferior (`StatefulShellRoute.indexedStack`).

| Ruta | Pantalla | Barra inferior | Acceso |
|---|---|---|---|
| `/splash` | Espera inicial mientras se lee `TokenStore` | No | Arranque |
| `/login` | `LoginScreen` (sesión única) | No | Sin tokens o sesión expirada |
| `/home` | `HomeScreen` (`RateChip`, banner y menú de cierre de sesión) | Sí (Inicio) | Autenticado |
| `/income` | `IncomeScreen` (placeholder Fase 2) | Sí | Autenticado |
| `/shopping` | `ShoppingScreen` (placeholder Fase 2) | Sí | Autenticado |
| `/expenses` | `ExpensesScreen` (placeholder Fase 2) | Sí | Autenticado |
| `/goals` | `GoalsScreen` (placeholder Fase 2) | Sí | Autenticado |
| `/rates` | `RatesScreen` (tasas actuales, brecha, gráfico y últimas actualizaciones) | No | Tap en `RateChip` |

## Decisiones

Los ADR viven en el módulo de Decisiones de FunWork, proyecto Ahorra.

- ADR-007: Riverpod para estado e inyección.
- ADR-008: app offline-first con Drift y cola de sincronización.
- ADR-009: estructura por feature con capas.
- ADR-001 y ADR-002: fuentes de las tasas BCV y USDT/Bs (lado API).
