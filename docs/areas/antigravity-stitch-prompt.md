# Prompt para Antigravity — pantallas de v1 en Stitch

Copiar todo lo que está debajo de la línea en el agente de Antigravity, con el workspace abierto en la raíz del repo `finance` y el MCP de Stitch conectado.

---

Vas a diseñar las pantallas de v1 de la app de finanzas "Ahorra" en Stitch, usando el MCP de Stitch. Trabajás por pasos y te detenés a esperar mi aprobación donde se indica.

## Contexto (leer antes de empezar)

1. `docs/00-vision.md`: qué es la app, módulos de v1 y v2, y qué queda fuera de alcance.
2. `docs/areas/stitch-design.md`: el design system. Es obligatorio en todas las pantallas.
3. `docs/areas/design.md`: inventario actual de Stitch y pendientes.

## Reglas

- Proyecto de Stitch: `1676522024862888488` ("Ahorra Login - Loading State"). No toques ningún otro proyecto.
- Formato de ids: `get_project` usa `name: "projects/1676522024862888488"` y `get_screen` usa `name: "projects/1676522024862888488/screens/{id}"`. El resto de las herramientas usa `projectId: "1676522024862888488"`, sin prefijo.
- No borres ni edites las pantallas de login existentes, y no uses `apply_design_system` sobre ellas.
- Generá **una sola pantalla por turno** con `generate_screen_from_text` (`projectId`, `deviceType: "MOBILE"` y el `designSystem` del paso 1). Nunca lances varias pantallas en paralelo.
- Cada `prompt` de pantalla empieza con: `"Android, Material 3, modo oscuro, navegación Android (sin home indicator de iOS ni glassmorphism), aplicar design system Ahorra. Pantalla: <Módulo – Nombre>."`
- Después de cada pantalla: compartí la captura (descargala con `download_file` usando `screenshot.name`), decime qué módulo cubre y qué decisiones tomaste, y **detenete a esperar mi aprobación** antes de pasar a la siguiente. Si pido cambios, usá `edit_screens` sobre esa pantalla (`deviceType: "MOBILE"`, `selectedScreenIds` sin el prefijo `screens/`); no generes una nueva.
- Si `generate_screen_from_text` da timeout, no reintentes: llamá a `list_screens` cada 30 s (hasta 10 veces) hasta que aparezca la pantalla nueva y después leela con `get_screen`.
- Textos de la UI en español neutro con tuteo; formato es-VE (`$ 12,50`, `Bs 1.234,56`, `12,34 USDT`).
- Datos de ejemplo realistas para Venezuela (Harina PAN, queso blanco, café, días de cobro 15 y 30) y montos coherentes entre pantallas. Un comercio puede aparecer como el lugar de un gasto, nunca como comparador de precios entre supermercados ni como saldo de un banco o de Binance.
- Usá estas tasas ilustrativas en todas las pantallas:
  - BCV: 220,00 Bs/USD
  - USDT/Bs (P2P): 300,00 Bs/USDT
  - Ejemplo (suponiendo pago en Bs a tasa BCV, sin redondeo intermedio): lista de $ 50,00 → Bs 11.000,00 a BCV → 11.000 ÷ 300 × 1,01 (1 % de margen) = **vender 37,03 USDT**.
- Fuera de alcance, no lo diseñes: registro, login con Google o Apple, iOS, operar en Binance, multiusuario, saldos por cuenta, funciones de v2 (comparación entre supermercados, escaneo de facturas, saldos de Binance).

## Paso 0 — Verificar

Llamá a `get_project` y `list_design_systems` y resumime lo que hay. Esperá mi OK.

## Paso 1 — Design system

1. Codificá el archivo en base64 UTF-8 en una sola línea (`base64 -w 0 docs/areas/stitch-design.md`) y subilo con `upload_design_md`.
2. Obtené el `{ id, sourceScreen }` de la screen instance nueva (de la respuesta o con `get_project`) y creá el design system con `create_design_system_from_design_md` (`deviceType: "MOBILE"`, `selectedScreenInstance`).
3. Verificá con `list_design_systems` que el asset nuevo tenga `colorMode: DARK`, `headlineFont: MANROPE`, `bodyFont: INTER` y los colores de la paleta oscura. Si algo quedó mal interpretado, avisame antes de seguir.
4. Decime el id del asset (`assets/...`). Ese es el `designSystem` de todas las pantallas.

Esperá mi OK.

## Paso 2 — Pantallas, en este orden

Con barra inferior (Inicio, Ingresos, Compras, Gastos, Metas): 1, 4, 5, 7, 9 y 10. Sin barra inferior (botón atrás, cierre o pantalla de bloqueo): 2, 3, 6, 8, 11, 12 y 13.

1. **Compras – Lista sugerida.** La lista que recomienda el historial (qué se compra y cada cuánto). Filas con ShoppingItemRow. Abajo, una SellUsdtCard (incluye el total en MoneyTriple, "Vender 37,03 USDT", la tasa usada y la base del cálculo). RateChip en la cabecera.
2. **Compras – En el súper.** La misma lista en modo compra: al marcar un producto se confirma el precio real inline y, si cambió, el precio anterior queda tachado en on-surface-muted. Resumen fijo abajo con la SellUsdtCard actualizada.
3. **Producto – Historial de precio.** Último precio en MoneyTriple, PriceSparkline, variación porcentual (positive/negative) y la lista de compras anteriores con fecha.
4. **Inicio.** Cuánto queda disponible y el próximo ingreso esperado, ambos en MoneyTriple; accesos a la lista de compras y a las metas; RateChip; StaleRateBanner en su variante sin conexión. FAB "Agregar gasto".
5. **Ingresos – Calendario.** Mes con ocurrencias de los días 15 y 30 (el "último día del mes" cuando el día no existe). IncomeOccurrence en estado *esperado* y *recibido*, con las acciones "Confirmar" y "Corregir monto".
6. **Ingresos – Regla de repetición.** Crear o editar un ingreso recurrente: nombre, monto en USD, días del mes (15 y 30), opción "usar el último día del mes si el día no existe" y vista previa de las próximas ocurrencias.
7. **Gastos.** Lista por categoría con ExpenseRow (moneda original y la tasa guardada en ese momento), total del mes en MoneyTriple y FAB "Agregar gasto".
8. **Agregar gasto.** Hoja inferior (surface-high) sobre Gastos, con monto, selector de moneda (USD / Bs), categoría, comercio opcional y la tasa vigente. Si la moneda es Bs, se muestran precargadas BCV y USDT/Bs, editables.
9. **Metas.** Metas con GoalProgress (avance en USD y su equivalente en Bs a las dos tasas).
10. **Metas – Vacío.** Estado vacío: mensaje corto y la acción "Crear meta".
11. **Tasas – Historial.** BCV y USDT/Bs con la hora de la última actualización, RateHistoryChart de las últimas semanas y un StaleRateBanner si pasaron más de 12 h.
12. **Login – Sesión única.** Usuario o email, contraseña y CTA "Entrar". Sin Google, Apple ni "Crear cuenta".
13. **Desbloqueo.** Huella o PIN para la cuenta ya iniciada.

## Paso 3 — Documentar

Cada vez que apruebe una pantalla, agregala a la tabla de `## Pantallas en Stitch` en `docs/areas/design.md` (pantalla, qué muestra, módulo) y marcá como hecho el sub-ítem que le corresponde en `## Pendientes`. No modifiques `docs/areas/stitch-design.md` sin pedírmelo.
