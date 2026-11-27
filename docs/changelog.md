# Changelog

## 2026-11-27

- **Diseño en Stitch (Mercado)**: se aplicó el design system **Mercado** (`assets/e5fae29435844a85ad9ce80bd4f5844b`, modo claro con papel crema, verde billete, `PriceTag` amarillo, borde de ticket dentado en compras y `SellUsdtCard`, montos en DM Mono y colores claros de categoría) a las 14 pantallas aprobadas en Stitch, guardando sus capturas actualizadas en `docs/areas/screens/`.

## 2026-11-25

- **Acceso y sesión**: se agregó la pantalla de login de sesión única (`/login`), almacenamiento seguro de tokens (`flutter_secure_storage`), cliente HTTP `Dio` con refresco rotativo single-flight ante `401`, redirección reactiva según estado de autenticación y cierre de sesión desde el menú de Inicio.
- **Navegación base**: se implementó el shell con barra inferior de 5 pestañas (`Home`, `Income`, `Shopping`, `Expenses`, `Goals`) y rutas placeholder para los módulos pendientes.
- **Pantalla de tasas (`/rates`)**: se añadió la tabla `exchange_rates` en Drift (`schemaVersion` 2), sincronización desde `/rates/latest` y `/rates`, cálculo de variación a 30 días y brecha BCV/USDT con `Decimal`, gráfico de historial (7, 30 y 90 días), lista de últimas actualizaciones, `RateChip` en Inicio y avisos de tasa desactualizada (`> 12 h`) o sin conexión (`StaleRateBanner`).
