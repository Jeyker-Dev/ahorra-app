# Visión

## Qué es

App móvil de finanzas personales (Android, publicada en Play Store) pensada para la realidad venezolana: ingresos en dólares, gastos en dólares o bolívares, venta de USDT en Binance antes de comprar y precios que cambian con frecuencia. Combina un calendario de ingresos recurrentes, gastos por categoría con listas de compras, tasas de cambio y metas de ahorro o inversión.

Frontend en Flutter (este repo) y backend propio en FastAPI (Python), el repo `ahorra-api`, generado desde la plantilla `fastapi-starter-kit` y desplegado en el VPS junto a FunWork.

## Problema

- Los ingresos llegan en fechas fijas (por ejemplo, los días 15 y 30) y hoy no hay una vista clara de cuánto entra y cuándo.
- Antes de salir a comprar hay que saber cuánto dinero hace falta para vender exactamente esos USDT en Binance, y eso exige conocer qué se va a comprar y a qué precio.
- Los precios de los productos cambian seguido; cargarlos y actualizarlos a mano es tedioso y se abandona.
- Cada monto tiene tres lecturas que importan: dólares, bolívares a tasa BCV y bolívares a tasa USDT.
- El dinero está repartido entre cuentas (Binance, bancos, efectivo) y no hay un total consolidado.

## Usuario objetivo

Uso personal: una persona en Venezuela que cobra en dólares, vende USDT en Binance para sus compras y hace mercado en supermercados con tienda en línea (por ejemplo, Tu Zona Market y Rio Supermarket en Carabobo).

## Módulos actuales

Ninguno implementado. Módulos previstos:

### v1

- **Calendario de ingresos recurrentes**: reglas de repetición (por ejemplo, días 15 y 30 de cada mes, con "último día del mes" cuando el día no existe). Cada ocurrencia nace como *esperada* y se confirma o corrige como *recibida*.
- **Gastos por categoría**: cada gasto guarda su moneda y la tasa vigente en ese momento, para que el historial siga cuadrando aunque el dólar se mueva.
- **Lista de compras con memoria de precio**: catálogo propio de productos con su último precio; al marcar un producto como comprado se confirma el precio real, que pasa a ser el nuevo y alimenta un historial de precios por producto.
- **Recomendación de compras**: lista sugerida según el historial (qué se compra y cada cuánto), con total en USD, Bs a tasa BCV y USDT.
- **Tasas de cambio**: BCV y USDT/Bs (P2P de Binance), consultadas por el backend varias veces al día y guardadas con historial; la app siempre muestra la última tasa conocida.
- **Metas**: monto objetivo en dólares, avance y equivalente en Bs a ambas tasas.

### v2

- **Escaneo de facturas**: foto del ticket, lectura de productos y precios con IA, y actualización del catálogo.
- **Precios de supermercados**: lectores de las APIs públicas de Tu Zona Market y Rio Supermarket, vinculación de cada producto propio con el de cada tienda y comparación del total de la lista entre tiendas.
- **Binance**: saldos mediante una API key de solo lectura (sin permisos de retiro ni trading, restringida a la IP del VPS), guardada cifrada en el backend y consultada cada pocos minutos.

## Objetivos

- Saber en todo momento cuánto dinero entra, cuándo y cuánto queda disponible.
- Saber, antes de salir a comprar, cuánto cuesta la lista y cuántos USDT vender.
- Reducir la carga manual de precios a confirmar lo comprado, en lugar de escribirlo todo.
- Ver la evolución de precios de los productos habituales.
- Seguir el avance de las metas en dólares y en bolívares.

## Fuera de alcance

- Operar en Binance (comprar, vender, transferir): la integración es solo de lectura.
- Conectar bancos venezolanos: no tienen APIs abiertas; sus saldos se cargan a mano.
- Lectura de precios por scraping de HTML: solo se usan las APIs JSON que las tiendas ya exponen.
- Uso multiusuario o compartido, y versión para iOS, en la primera etapa.
- Asesoría de inversión.

## Visión a largo plazo

- Proyectar cuándo se alcanza cada meta según los ingresos recurrentes y el gasto promedio.
- Sugerir automáticamente el vínculo entre productos propios y productos de cada tienda.
- Alertas de precio: avisar cuando un producto habitual sube o baja de forma notable.
- Consolidar en un solo total el dinero de todas las cuentas.
- Compartir datos con las otras apps personales (por ejemplo, metas financieras en la app de gestión del tiempo).
