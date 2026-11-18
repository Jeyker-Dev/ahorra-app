# Design system — Ahorra

## Producto

App Android (Material 3, Flutter) de finanzas personales para Venezuela, de un solo usuario.
Ingresos en USD, compras en supermercado, venta de USDT en Binance antes de comprar.
Pregunta central de la app: "¿cuánto entra, cuánto cuesta lo que voy a comprar y cuántos USDT vendo?"
Fuera de alcance en la UI: registro, login social, iOS, operar en Binance, multiusuario.

## Tono

- Español neutro, tuteo, frases cortas. Primero el número y después la explicación.
- Utilitario y tranquilo, sin lenguaje de lujo ni "premium".
- Verbos concretos: "Confirmar precio", "Marcar como recibido", "Vender 42,10 USDT".

## Color

Color mode: DARK (default). Primary color: #A78BFA. Neutral (background): #0B1020. Roundness: 12px.

### Dark mode palette (default)

| Token (equivalente M3) | Hex | Uso |
|---|---|---|
| primary (primary) | #A78BFA | CTA, selección, foco |
| on-primary (on_primary) | #0B1020 | Texto e íconos sobre primary |
| background (background) | #0B1020 | Fondo |
| surface (surface_container) | #131A2E | Tarjetas |
| surface-high (surface_container_high) | #1B2440 | Hojas inferiores, elementos elevados |
| on-surface (on_surface) | #E6E9F5 | Texto principal |
| on-surface-muted (on_surface_variant) | #9AA3BD | Etiquetas, montos secundarios |
| outline (outline_variant) | #2A3350 | Solo divisores decorativos en listas |
| outline-control (outline) | #64748B | Bordes de inputs, checkboxes y contorno punteado |
| tag-bcv | #60A5FA | Etiqueta "BCV" |
| tag-usdt | #2DD4BF | Etiqueta "USDT" |
| positive | #4ADE80 | Recibido, precio que baja |
| negative (error) | #F87171 | Precio que sube, error |
| warning | #FBBF24 | Tasa desactualizada, ingreso esperado vencido |

### Light mode palette (reference)

| Token (equivalente M3) | Hex |
|---|---|
| primary (primary) | #7C3AED |
| on-primary (on_primary) | #FFFFFF |
| background (background) | #F7F7FA |
| surface (surface_container) | #FFFFFF |
| surface-high (surface_container_high) | #EEF0F5 |
| on-surface (on_surface) | #151826 |
| on-surface-muted (on_surface_variant) | #5B6275 |
| outline (outline_variant) | #D9DCE5 |
| outline-control (outline) | #6B7280 |
| tag-bcv | #2563EB |
| tag-usdt | #0F766E |
| positive | #166534 |
| negative (error) | #B91C1C |
| warning | #92400E |

Contraste verificado (WCAG AA): todo texto ≥ 4,5:1 y outline-control ≥ 3:1 sobre background, surface y surface-high, en ambos modos.

- El USD no tiene color: es la unidad base y va en on-surface.
- El color nunca es la única señal: siempre acompañado de etiqueta o ícono.

## Tipografía

- Headline: Manrope. Body: Inter. Label: Inter.
- Montos: Inter con cifras tabulares (tnum).

| Rol | Fuente | Tamaño | Line-height | Peso |
|---|---|---|---|---|
| display (monto principal) | Inter | 32px | 40px | 700 |
| headline | Manrope | 24px | 32px | 700 |
| title | Manrope | 20px | 28px | 600 |
| body | Inter | 16px | 24px | 400 |
| body-sm | Inter | 14px | 20px | 400 |
| label | Inter | 12px | 16px | 500 |

- Mayúsculas solo en las etiquetas de moneda ("BCV", "USDT").
- Formato es-VE: "$ 1.234,56", "Bs 45.067,20", "12,34 USDT".

## Forma y espacio

- Radio: 12px en tarjetas, botones e inputs; 16px en las esquinas superiores de las hojas inferiores; 999px (pill) en chips.
- Espaciado con base de 4px: 4, 8, 12, 16, 24.
- Elevación por tono de superficie (surface → surface-high), no por sombras.
- Ancho de referencia 360–412 dp, con la barra de navegación de Android.

## Componentes

- **MoneyTriple**: USD grande (display); debajo, "Bs … · BCV" y "Bs … · USDT" (o "≈ X USDT a vender") en body-sm on-surface-muted, con etiqueta de color.
- **RateChip**: tasa BCV y USDT/Bs con antigüedad ("hace 2 h"); en warning si pasan más de 12 h.
- **StaleRateBanner**: banner en warning, "Tasa desactualizada · última: hace 14 h". También se usa sin conexión ("Sin conexión · usando la última tasa conocida").
- **IncomeOccurrence**: fecha, monto, estado *esperado* (contorno punteado en outline-control) o *recibido* (relleno y check en positive); acciones "Confirmar" y "Corregir monto".
- **ShoppingItemRow**: checkbox, nombre, último precio en USD, cantidad. Al marcarlo pide confirmar el precio real inline; si cambió, el precio anterior queda tachado en on-surface-muted.
- **PriceSparkline**: línea del historial de precio de un producto, con la variación porcentual (positive/negative).
- **RateHistoryChart**: dos líneas (BCV en tag-bcv y USDT/Bs en tag-usdt) con leyenda de texto.
- **SellUsdtCard**: total de la lista en MoneyTriple, "Vender X USDT" destacado, la tasa usada y la base del cálculo ("pagando en Bs a tasa BCV + 1 % de margen").
- **ExpenseRow**: categoría (ícono + chip), monto en la moneda original y la tasa guardada en ese momento.
- **GoalProgress**: barra de avance en USD y el equivalente en Bs a ambas tasas.
- **Navegación**: barra inferior con Inicio, Ingresos, Compras, Gastos, Metas. FAB "Agregar gasto" en Inicio y Gastos. Las subpantallas y hojas no muestran la barra.
- **Estados**: vacío (mensaje corto y una acción), cargando (skeleton, no spinner) y sin conexión (StaleRateBanner).

### Patrones aprobados

- **Tarjetas**: sin borde exterior; se separan del fondo solo por tono (surface). Dentro de listas, divisores outline entre filas.
- **Stepper de cantidad**: pastilla (999px) en surface-high con borde outline (#2A3350), botones − y + de 48×48 dp y la cantidad en el centro. No usar outline-control ni forma rectangular.
- **Contorno punteado**: reservado para el ingreso *esperado* (IncomeOccurrence). Botones secundarios como "Agregar producto" usan contorno sólido.
- **RateChip**: compacto (ancho según el contenido), texto completo sin truncar ("hace 2 h"). El enlace "Ver tasas ›" va en la SellUsdtCard, no dentro del chip.
- **SellUsdtCard**: total en display; fila BCV con chip, "Bs …" y "@ 220,00" a la derecha; fila USDT con chip, "Vender X USDT" en Inter 20px/600 y "Ver tasas ›"; debajo, la base del cálculo. Igual en todas las pantallas.
- **Chips de moneda**: "BCV" y "USDT" siempre como pill con fondo del color al 15 %, también en tarjetas secundarias.
- **Quitar de una lista**: deslizar la fila revela "Quitar" (ícono + texto en negative) y luego aparece un snackbar "Producto quitado · Deshacer". Sin botón ×.
- **Resumen fijo**: barra en surface-high sobre la navegación, sin sombra, con el total y la acción principal ("Ir al súper", "Finalizar compra").
- **Objetivos táctiles**: todo control interactivo mide al menos 48×48 dp (checkbox con área de 48, botón atrás, botones de confirmar).
- **Colores de categoría**: Supermercado #818CF8, Servicios #F472B6, Salud #E879F9, Transporte #FB923C; nunca los de BCV, USDT, positive, negative ni warning. Ícono en círculo y chip pill con el color al 15 %.
- **Porcentajes**: con espacio antes del signo ("56,7 %", "+12 %").

## Do's and Don'ts

Do:
- Hacer del monto en USD el elemento principal y mostrar debajo las dos lecturas en Bs.
- Usar divisores (outline) en listas densas.
- Mostrar siempre la tasa usada y su antigüedad cerca de cualquier conversión.

Don't:
- Glassmorphism, desenfoque de fondo, gradientes neón o brillos.
- Notch, home indicator o patrones de iOS.
- Texto blanco sobre primary en modo oscuro (usar on-primary).
- Login social, registro o selección de cuentas.
