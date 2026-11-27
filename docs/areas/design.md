# Diseño

## Design system

Vive en [stitch-design.md](stitch-design.md): es el archivo que se sube a Stitch como DESIGN.md, así que contiene solo el design system.

Dirección (2026-11-26): **Mercado**, que reemplaza al violeta oscuro anterior. Modo claro por defecto porque la app se usa en el súper, de día; papel crema, verde billete, amarillo de etiqueta de precio, tickets y etiquetas de precio, y montos en DM Mono. Se eligió porque cuenta el nombre Rinde ("Haz que tu plata rinda") y se diferencia de LifeForge y Landed, que son oscuras.

El único design system válido en Stitch es **Rinde** (`assets/e5fae29435844a85ad9ce80bd4f5844b`, modo claro / Mercado). Se descartan el design system violeta anterior (`assets/11155543976960747498`), "Ahorra Neon Noir" (`assets/c8e5c08a5732461bbef307bcd2449085`) y el "Ahorra" duplicado (`assets/5d66f76d148845c9b010440895a89dc6`).

## Pantallas en Stitch

Proyecto "Ahorra-App" (id `1676522024862888488`). Actualizado el 2026-11-27 con el design system Mercado y los ajustes de ticket, `PriceTag`, DM Mono y variantes claras de categoría.

| Pantalla | Qué muestra | Captura | Módulo |
|---|---|---|---|
| Compras – Lista sugerida (`82540f027a4a4be0bbb8a389ca96c9ec`) | Lista con borde inferior dentado tipo ticket, `RateChip`, `PriceTag` amarillo en último precio unitario, steppers 48 dp (`surface-high`), swipe para quitar, `SellUsdtCard` ticket (`$ 50,00` / `37,03 USDT`), barra fija "Ir al súper". En Flutter, la acción "Quitar" del swipe no lleva el fondo bordó oscuro que quedó de la paleta anterior: ícono y texto en negative (`#B3261E`) sobre fondo claro | [compras-lista-sugerida.png](screens/compras-lista-sugerida.png) | Recomendación de compras |
| Compras – Lista sugerida: Vacío (`caa5abcbc4e84f3b868bb9d04e1d2912`) | Estado sin historial: ícono de carrito, "Todavía no hay compras registradas", texto de ayuda y botón "Registrar compra"; barra inferior con Compras activa. En Flutter llevar etiquetas de la barra inferior de 11px a ≥ 12px | [compras-lista-sugerida-vacio.png](screens/compras-lista-sugerida-vacio.png) | Recomendación de compras |
| Compras – En el súper (`a00d32d9e132497495e84f3db6763700`) | Checklist tipo ticket con borde inferior dentado, `PriceTag` en precios unitarios, confirmación inline 48 dp, steppers en pastilla (`surface-high`, 48 dp), `SellUsdtCard` ticket (`$ 50,50` / `37,40 USDT`), barra fija "Finalizar compra" | [compras-en-el-super.png](screens/compras-en-el-super.png) | Lista de compras con memoria de precio |
| Producto – Historial de precio (`918b631fd511495daba83219135981d4`) | Último precio confirmado (`$ 1,40`) en `PriceTag` amarillo con esquina recortada y DM Mono, `PriceSparkline` de 6 compras, historial con tasa BCV guardada y variación porcentual. En Flutter, el `PriceSparkline` no usa la línea `#F87171` ni las guías punteadas `#2A3350` que quedaron de la paleta anterior: línea según la variación (negative `#B3261E` si el precio sube, positive `#276B2C` si baja) y guías en outline (`#E6DFD0`) | [producto-historial.png](screens/producto-historial.png) | Lista de compras con memoria de precio |
| Inicio (`8c997bc9b2ee40dd9b88c59dc67e7c53`) | Disponible (`$ 420,00`), próximo ingreso esperado (`$ 650,00`) con contorno punteado y chips BCV/USDT al 15 %, `RateChip`, `StaleRateBanner` sin conexión, accesos a compras/metas, FAB "Agregar gasto" | [inicio.png](screens/inicio.png) | Resumen |
| Ingresos – Calendario (`3ef9f1039a34458391245e242217553f`) | Resumen del mes en MoneyTriple (`$ 1.500,00`) con DM Mono, calendario con hoy y esperados punteados, regla de repetición, ocurrencias recibida y esperadas punteadas con "Confirmar" / "Corregir monto" | [ingresos-calendario.png](screens/ingresos-calendario.png) | Ingresos |
| Ingresos – Regla de repetición (`9004d6196d5242e0a7f757a2aba9a6b4`) | Nombre y monto en USD con equivalencias BCV/USDT y tasa usada, selector de días 1–31 (48 dp, seleccionados en `#1F7A4D`), switch "último día del mes", próximas ocurrencias y barra fija `surface-high` "Cancelar" / "Guardar regla" | [ingresos-regla.png](screens/ingresos-regla.png) | Ingresos |
| Gastos (`35759c452a4743caabd53e1e38b87afa`) | Total del mes en MoneyTriple (`$ 115,50`), desglose por categoría con barra apilada y colores de categoría light (`#4F46E5`, `#BE185D`, `#A21CAF`, `#C2410C`), chips de filtro, gastos por día en DM Mono, FAB "Agregar gasto". En Flutter llevar chips BCV/USDT de 11px a 12px | [gastos.png](screens/gastos.png) | Gastos por categoría |
| Agregar gasto (`8e80d6d2b9b84c4e997b6f82330ca5c2`) | Selector Bs/USD, monto en DM Mono con conversión en vivo y tasa BCV que se guarda, grilla de categorías en variante clara, descripción, fecha y barra fija `surface-high` "Guardar gasto" | [agregar-gasto.png](screens/agregar-gasto.png) | Gastos por categoría |
| Metas (`50837e14ddf741de9a172496a9c2ffb4`) | Ahorrado en metas en MoneyTriple (`$ 1.690,00`, 51,2 % de `$ 3.300,00`), tarjetas GoalProgress con chips "Ahorro" / "Inversión" en verde tenue, barra de progreso sobre pista clara, equivalentes BCV/USDT, "Agregar aporte" y "+ Nueva meta" | [metas.png](screens/metas.png) | Metas de ahorro o inversión |
| Metas – Vacío (`ef9275d6d6454bbeaa2e2d9db300b904`) | Estado vacío de Metas: ícono, "Todavía no tienes metas" y botón "+ Crear meta" | [metas-vacio.png](screens/metas-vacio.png) | Metas de ahorro o inversión |
| Tasas – Historial (`2a5a5f6a29824e2387b0f159487eb5f7`) | Tasas BCV y USDT/Bs en DM Mono con variación a 30 días, brecha (`36,4 %`), selector de rango (`7 días`, `30 días`, `90 días`), `RateHistoryChart` (`#1F5FBF` / `#0E6E73`) y últimas actualizaciones con divisores | [tasas-historial.png](screens/tasas-historial.png) | Tasas de cambio |
| Login – Sesión única (`f4e604774dcc4d2f9ec90010ac6821ab`) | Marca Rinde, campos "Usuario" y "Contraseña" con contorno `#857F70` y ojo 48 dp, botón "Ingresar" en `#1F7A4D`, aviso de huella o PIN; sin registro, recuperación ni login social | [login.png](screens/login.png) | Acceso |
| Desbloqueo (`44826adf1d144ec596a108cfd4145555`) | "Hola, jeyker", indicador de PIN de 4, teclado 3×4 con huella y borrar, salida "Ingresar con usuario y contraseña" | [desbloqueo.png](screens/desbloqueo.png) | Acceso |

Stitch deriva sus propios tokens de Material 3: en Flutter mandan los hex, tamaños mínimos (≥ 12px) y objetivos táctiles (≥ 48 dp) de [stitch-design.md](stitch-design.md).

## Pendientes

- Diseñar las pantallas de v1:
  - [x] Compras – Lista sugerida
  - [x] Compras – Lista sugerida: diseñar estado vacío (sin historial)
  - [x] Compras – En el súper
  - [x] Producto – Historial de precio
  - [x] Inicio
  - [x] Ingresos – Calendario
  - [x] Ingresos – Regla de repetición
  - [x] Gastos
  - [x] Agregar gasto
  - [x] Metas
  - [x] Metas – Vacío
  - [x] Tasas – Historial
  - [x] Login – Sesión única (reemplaza al login actual: sin registro, Apple ni Google)
  - [x] Desbloqueo (huella o PIN)
- Verificar que los supermercados cobran en Bs a tasa BCV; de eso depende el cálculo `USDT a vender = USD × BCV ÷ tasa USDT/Bs` (+ margen por spread).
- [x] Cargar este design system en Stitch.
- [x] Regenerar en Stitch las pantallas aprobadas con el design system Mercado y capturar sus vistas actualizadas en [screens/](screens/).
- Cambiar en Flutter el tema (colores, modo claro por defecto, DM Mono para montos), aplicar `PriceTag` / tickets y actualizar el nombre visible de la app a Rinde.
