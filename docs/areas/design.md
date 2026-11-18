# Diseño

## Design system

Vive en [stitch-design.md](stitch-design.md): es el archivo que se sube a Stitch como DESIGN.md, así que contiene solo el design system.

## Pantallas en Stitch

Proyecto "Ahorra Login - Loading State" (id `1676522024862888488`). Revisado el 2026-11-16. Solo contiene las pantallas aprobadas y un DESIGN.md; los login viejos, la imagen de referencia y las versiones intermedias se borraron.

| Pantalla | Qué muestra | Módulo |
|---|---|---|
| Compras – Lista sugerida (Actualizada) (`a35201809b434990a7cb60795a115a9a`) | Lista sugerida, `RateChip`, steppers 48 dp (`surface-high`), swipe para quitar, `SellUsdtCard` (`$ 50,00` / `37,03 USDT`), barra fija con "Ir al súper" | Recomendación de compras |
| Compras – En el súper (Steppers en cápsula) (`306a3817414a4254bca6ee4ef720d787`) | Checklist de compra, confirmación inline 48 dp, steppers en pastilla (`surface-high`, 48 dp), `SellUsdtCard` (`$ 50,50` / `37,40 USDT`), barra fija | Lista de compras con memoria de precio |
| Producto – Historial de precio (`23f0b03dbea449e58f32a18ef790384e`) | Último precio (`$ 1,40`), `PriceSparkline` de 6 compras, historial con tasa BCV guardada y variación porcentual | Lista de compras con memoria de precio |
| Ingresos – Calendario (Mobile) (`82a668b0c53346a1ae6fabc8f5d16997`) | Resumen del mes en MoneyTriple (`$ 1.500,00`), calendario con hoy y esperados punteados, regla de repetición, ocurrencias recibida y esperadas con "Confirmar" / "Corregir monto" | Ingresos |
| Ingresos – Regla de repetición (`c0f07640c49f4d19a100715ad748441a`) | Nombre y monto en USD con equivalencias BCV/USDT y tasa usada, selector de días 1–31 (48 dp), switch "último día del mes", próximas ocurrencias y barra fija "Cancelar" / "Guardar regla" | Ingresos |
| Gastos – Actualizada (`129e41d11ca94b2cad35fb3fc7123bc9`) | Total del mes en MoneyTriple (`$ 115,50`), desglose por categoría con barra apilada, chips de filtro, gastos agrupados por día con monto original y tasa guardada, FAB "Agregar gasto" | Gastos por categoría |
| Agregar gasto (`71c5ee7711d3413ba829f42be9f99da3`) | Selector Bs/USD, monto con conversión en vivo y tasa BCV que se guarda, grilla de categorías, descripción, fecha y barra fija "Guardar gasto" | Gastos por categoría |
| Metas (`f928e0e6b8dc4493b5fd35f020684415`) | Ahorrado en metas en MoneyTriple (`$ 1.690,00`, 51,2 % de `$ 3.300,00`), tarjetas GoalProgress con avance, faltante y equivalentes BCV/USDT, "Agregar aporte" y "+ Nueva meta" | Metas de ahorro o inversión |
| Metas – Vacío (`46620e230ce548acbdb4ff2a82d59ba6`) | Estado vacío de Metas: ícono, "Todavía no tienes metas" y botón "Crear meta". Usa los tokens derivados de Stitch en vez de los hex exactos; en Flutter mandan los colores de stitch-design.md | Metas de ahorro o inversión |
| Tasas – Historial (Mobile App) (`378d50d48b2e4baeba3e9ec2cb337295`) | Tasas BCV y USDT/Bs con variación a 30 días, brecha, selector de rango, RateHistoryChart y últimas actualizaciones. Generada desde la web; en Flutter, llevar el botón atrás, el selector de rango y las filas a 48 dp | Tasas de cambio |
| Login – Sesión única (`9ccd47b8b6574e069e96df46e87faba4`) | Marca, campos "Usuario" y "Contraseña" con ojo, botón "Ingresar", aviso de huella o PIN; sin registro, recuperación ni Google/Apple. En Flutter: borde de campos #64748B (el diseño usa #2A3350, sin contraste 3:1) y botón del ojo de 48 dp | Acceso |
| Desbloqueo (`c8e05fadd04a470ead2f35934e086636`) | "Hola, jeyker", indicador de PIN de 4, teclado 3×4 con huella y borrar, salida "Ingresar con usuario y contraseña" | Acceso |
| Compras – Lista sugerida: Vacío (`0583131095fd48ee8287ffccfc3a84cf`) | Estado sin historial: ícono de carrito, "Todavía no hay compras registradas", texto de ayuda y botón "Registrar compra"; barra inferior con Compras activa | Recomendación de compras |
| Inicio (`6c0b15483f7b407e866796e045cf28b3`) | Disponible (`$ 420,00`), próximo ingreso esperado (`$ 650,00`), `RateChip`, `StaleRateBanner` sin conexión, accesos a compras/metas, FAB "Agregar gasto" | Resumen |

El único design system válido es "Ahorra" (`assets/11155543976960747498`, el que incluye "Patrones aprobados"). "Ahorra Neon Noir" y el "Ahorra" duplicado (`assets/5d66f76d148845c9b010440895a89dc6`) se descartan.

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
- Cargar este design system en Stitch (requiere aprobación).
