# Base de datos

## Esquema actual

- Motor: Drift (`drift 2.34.4`, `drift_dev 2.34.0`) sobre SQLite.
- Versión actual: `schemaVersion = 2`.
- Migraciones: `v1 -> v2` crea la tabla `exchange_rates` y sus índices (`ix_exchange_rates_kind_fetched_at`, `ix_exchange_rates_kind_value_date`).

## Tablas de dominio

### `exchange_rates` (`ExchangeRates`)

Almacena los snapshots de tasas BCV y USDT/Bs replicados desde `ahorra-api` (`RateOut`).

| Columna | Tipo SQLite | Tipo Dart | Notas |
|---|---|---|---|
| `id` | `TEXT` (PK) | `String` | UUID del servidor; upsert idempotente por `id` |
| `kind` | `TEXT` | `String` | `'bcv'` o `'usdt'` |
| `value` | `TEXT` | `Decimal` | Convertido mediante `DecimalTextConverter` (sin `double`) |
| `value_date` | `TEXT` | `String` | Fecha calendario `YYYY-MM-DD` sin desfase de zona horaria |
| `origin` | `TEXT` | `String` | `'bcv_html'`, `'dolarapi'`, `'binance_p2p'` o `'manual'` |
| `status` | `TEXT` | `String` | `'confirmed'` o `'in_review'` |
| `fetched_at` | `INTEGER` | `DateTime` | Marca temporal UTC de consulta |

Índices:
- `ix_exchange_rates_kind_fetched_at (kind, fetched_at)`
- `ix_exchange_rates_kind_value_date (kind, value_date)`

## Reglas

- Todos los valores monetarios y de tasas se persisten como `TEXT` vía `DecimalTextConverter`.
- La consulta de la tasa BCV vigente filtra `value_date <= hoy` (hora de Caracas, `UTC-4`) y ordena por `value_date DESC, fetched_at DESC`, sin fallback a tasas futuras.
- Al cerrar sesión se borran los tokens en almacenamiento seguro, pero se conservan los datos locales de Drift (app de un solo usuario).
- Los archivos generados (`*.g.dart`) nunca se editan a mano.

## Riesgos conocidos

- Mantener `drift` en la rama `2.34.x` mientras Flutter fije `meta 1.17.0`, ya que `drift_dev >= 2.35` exige una versión más reciente de `meta`.
