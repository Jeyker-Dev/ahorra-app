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
│   ├── db/         Base Drift, tablas compartidas y migraciones
│   ├── sync/       Cola de sincronización hacia la API
│   ├── network/    Cliente HTTP, interceptor de tokens y refresh
│   ├── money/      Montos con moneda y tasa usada
│   └── ui/         Componentes visuales compartidos
└── features/
    └── <feature>/  rates, income, expenses, shopping, products, goals, home, auth
        ├── domain/        Dart puro: entidades, reglas y puertos
        ├── data/          DAOs de Drift, DTOs y adaptadores de la API
        └── presentation/  Pantallas, widgets y providers
```

- `domain` no importa Flutter, Drift ni HTTP.
- `data` implementa los puertos de `domain`.
- `presentation` solo habla con `domain` a través de providers.

## Convenciones críticas

- **La UI lee solo de Drift.** Nunca muestra datos que vengan directo de la API.
- **Las escrituras van primero a Drift.** Después entran a la cola de `core/sync`, que las envía a la API y reintenta cuando hay conexión.
- **Las features no se importan entre sí.** Lo que compartan va en `core/`.
- **Cada monto guarda su moneda y la tasa vigente al registrarlo.** El historial no se recalcula cuando cambia la tasa.
- **Un solo usuario.** El usuario se crea por CLI en la API; la app solo tiene login, sin registro.

## Mapa de rutas

Pendiente. Se define cuando se implementen las primeras pantallas, a partir de los diseños aprobados en Stitch.

## Decisiones

Los ADR viven en el módulo de Decisiones de FunWork, proyecto Ahorra. Las decisiones de esta arquitectura (Riverpod, Drift offline-first, estructura por feature) todavía no están registradas ahí.
