# Diseño

## Design system

Vive en [stitch-design.md](stitch-design.md): es el archivo que se sube a Stitch como DESIGN.md, así que contiene solo el design system.

## Pantallas en Stitch

Proyecto "Ahorra Login - Loading State" (id `1676522024862888488`). Revisado el 2026-11-13.

| Pantalla | Qué muestra | Módulo |
|---|---|---|
| Login – Default (diseño y prototipo) | Email y contraseña, Google/Apple, "Crear cuenta" | Ninguno |
| Login – Loading | Campos deshabilitados, spinner, home indicator de iOS | Ninguno |
| Login – Error | "Credenciales no válidas" en el email | Ninguno |
| Imagen de referencia | App de chatbot de terceros (moodboard) | Ninguno |
| Compras – Lista sugerida (v3) (`31ea1b5c594245209129034762b41f73`) | Lista sugerida, steppers 48 dp, swipe para quitar con snackbar, SellUsdtCard (`$ 50,00` / `37,03 USDT`), barra fija con "Ir al súper" | Recomendación de compras |
| Compras – En el súper (Actualizada) (`a46bd598c0a0431b9f3cf04807f3f7b9`) | Checklist de compra, precio anterior tachado, confirmación inline, steppers 48 dp, SellUsdtCard (`$ 50,50` / `37,40 USDT`), barra fija | Lista de compras con memoria de precio |
| Producto – Historial de precio (`23f0b03dbea449e58f32a18ef790384e`) | Último precio (`$ 1,40`), `PriceSparkline` de 6 compras, historial con tasa BCV guardada y variación porcentual | Lista de compras con memoria de precio |

El design system guardado en Stitch ("Ahorra Neon Noir", glassmorphism y tono de lujo) queda reemplazado por el de este documento.

## Pendientes

- Diseñar las pantallas de v1:
  - [x] Compras – Lista sugerida
  - [ ] Compras – Lista sugerida: diseñar estado vacío (sin historial)
  - [x] Compras – En el súper
  - [x] Producto – Historial de precio
  - [ ] Inicio
  - [ ] Ingresos – Calendario
  - [ ] Ingresos – Regla de repetición
  - [ ] Gastos
  - [ ] Agregar gasto
  - [ ] Metas
  - [ ] Metas – Vacío
  - [ ] Tasas – Historial
  - [ ] Login – Sesión única (reemplaza al login actual: sin registro, Apple ni Google)
  - [ ] Desbloqueo (huella o PIN)
- Verificar que los supermercados cobran en Bs a tasa BCV; de eso depende el cálculo `USDT a vender = USD × BCV ÷ tasa USDT/Bs` (+ margen por spread).
- Cargar este design system en Stitch (requiere aprobación).
