# Design system — Rinde (Mercado)

## Producto

App Android (Material 3, Flutter) de finanzas personales para Venezuela.
Ingresos en USD, compras en supermercado, venta de USDT en Binance antes de comprar.
Pregunta central de la app: "¿cuánto entra, cuánto cuesta lo que voy a comprar y cuántos USDT vendo?"
Lema: "Haz que tu plata rinda."
Fuera de alcance en la UI: registro, login social, iOS, operar en Binance, multiusuario.

## Tono

- Español neutro, tuteo, frases cortas. Primero el número y después la explicación.
- Utilitario y tranquilo, sin lenguaje de lujo ni "premium".
- Verbos concretos: "Confirmar precio", "Marcar como recibido", "Vender 42,10 USDT".

## Concepto visual

Mercado: la app se usa sobre todo en el súper, de día, con la lista en la mano. Papel crema como un ticket, verde billete para la plata que rinde y amarillo de etiqueta de precio para precios y ofertas. Formas del mundo real: etiquetas de precio para productos y tickets para la lista y su total.

## Color

Color mode: LIGHT (default). Primary color: #1F7A4D. Neutral (background): #FBF8F1. Roundness: 12px.

### Light mode palette (default)

| Token (equivalente M3) | Hex | Uso |
|---|---|---|
| primary (primary) | #1F7A4D | CTA, selección, foco (verde billete) |
| on-primary (on_primary) | #FFFFFF | Texto e íconos sobre primary |
| background (background) | #FBF8F1 | Fondo (papel crema) |
| surface (surface_container) | #FFFFFF | Tarjetas, tickets |
| surface-high (surface_container_high) | #F3EEE3 | Hojas inferiores, elementos elevados, resumen fijo |
| on-surface (on_surface) | #1C1B17 | Texto principal |
| on-surface-muted (on_surface_variant) | #5E5A50 | Etiquetas, montos secundarios |
| outline (outline_variant) | #E6DFD0 | Solo divisores decorativos en listas |
| outline-control (outline) | #857F70 | Bordes de inputs, checkboxes y contorno punteado |
| price-tag | #F5C518 | Fondo de etiquetas de precio y ofertas (texto encima en on-surface, nunca como texto) |
| tag-bcv | #1F5FBF | Etiqueta "BCV" |
| tag-usdt | #0E6E73 | Etiqueta "USDT" |
| positive | #276B2C | Recibido, precio que baja |
| negative (error) | #B3261E | Precio que sube, error |
| warning | #8A5300 | Tasa desactualizada, ingreso esperado vencido |

### Dark mode palette (reference)

| Token (equivalente M3) | Hex |
|---|---|
| primary (primary) | #5CC98E |
| on-primary (on_primary) | #12140F |
| background (background) | #12140F |
| surface (surface_container) | #1B1E17 |
| surface-high (surface_container_high) | #252920 |
| on-surface (on_surface) | #F1EEE4 |
| on-surface-muted (on_surface_variant) | #ADA898 |
| outline (outline_variant) | #333828 |
| outline-control (outline) | #7E7A6C |
| price-tag | #F5C518 |
| tag-bcv | #7FB0FF |
| tag-usdt | #4FD1C5 |
| positive | #7BC47F |
| negative (error) | #F28B82 |
| warning | #F2C94C |

Contraste verificado (WCAG AA): todo texto ≥ 4,5:1 y outline-control ≥ 3:1 sobre background, surface y surface-high, en ambos modos. on-primary sobre primary: 5,3:1 (light) y 9,0:1 (dark); on-surface sobre price-tag: 10,6:1.

- El USD no tiene color: es la unidad base y va en on-surface.
- El color nunca es la única señal: siempre acompañado de etiqueta o ícono.

## Tipografía

- Headline: Manrope. Body: Inter. Label: Inter.
- Montos: DM Mono, como en un ticket (cifras de ancho fijo).

| Rol | Fuente | Tamaño | Line-height | Peso |
|---|---|---|---|---|
| display (monto principal) | DM Mono | 32px | 40px | 500 |
| headline | Manrope | 24px | 32px | 700 |
| title | Manrope | 20px | 28px | 600 |
| body | Inter | 16px | 24px | 400 |
| body-sm | Inter | 14px | 20px | 400 |
| label | Inter | 12px | 16px | 500 |

- Mayúsculas solo en las etiquetas de moneda ("BCV", "USDT").
- Formato es-VE: "$ 1.234,56", "Bs 45.067,20", "12,34 USDT".

## Forma y espacio

- Radio: 12px en tarjetas, botones e inputs; los tickets (lista y SellUsdtCard) llevan borde inferior dentado o perforado; 16px en las esquinas superiores de las hojas inferiores; 999px (pill) en chips.
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
- **PriceTag**: etiqueta de precio con fondo price-tag, esquina recortada y monto en DM Mono; marca el último precio de un producto y las ofertas.
- **Navegación**: barra inferior con Inicio, Ingresos, Compras, Gastos, Metas. FAB "Agregar gasto" en Inicio y Gastos. Las subpantallas y hojas no muestran la barra.
- **Estados**: vacío (mensaje corto y una acción), cargando (skeleton, no spinner) y sin conexión (StaleRateBanner).

### Patrones aprobados

- **Tarjetas**: sin borde exterior; se separan del fondo solo por tono (surface). Dentro de listas, divisores outline entre filas.
- **Stepper de cantidad**: pastilla (999px) en surface-high con borde outline, botones − y + de 48×48 dp y la cantidad en el centro. No usar outline-control ni forma rectangular.
- **Contorno punteado**: reservado para el ingreso *esperado* (IncomeOccurrence). Botones secundarios como "Agregar producto" usan contorno sólido.
- **RateChip**: compacto (ancho según el contenido), texto completo sin truncar ("hace 2 h"). El enlace "Ver tasas ›" va en la SellUsdtCard, no dentro del chip.
- **SellUsdtCard**: total en display; fila BCV con chip, "Bs …" y "@ 220,00" a la derecha; fila USDT con chip, "Vender X USDT" en DM Mono 20px/500 y "Ver tasas ›"; debajo, la base del cálculo. Igual en todas las pantallas.
- **Chips de moneda**: "BCV" y "USDT" siempre como pill con fondo del color al 15 %, también en tarjetas secundarias.
- **Quitar de una lista**: deslizar la fila revela "Quitar" (ícono + texto en negative) y luego aparece un snackbar "Producto quitado · Deshacer". Sin botón ×.
- **Resumen fijo**: barra en surface-high sobre la navegación, sin sombra, con el total y la acción principal ("Ir al súper", "Finalizar compra").
- **Objetivos táctiles**: todo control interactivo mide al menos 48×48 dp (checkbox con área de 48, botón atrás, botones de confirmar).
- **Colores de categoría**: Supermercado #4F46E5, Servicios #BE185D, Salud #A21CAF, Transporte #C2410C (light; en dark usar las variantes claras #818CF8, #F472B6, #E879F9, #FB923C); nunca los de BCV, USDT, positive, negative ni warning. Ícono en círculo y chip pill con el color al 15 %.
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
- Texto en price-tag: el amarillo es solo fondo, nunca color de texto.
- Login social, registro o selección de cuentas.
