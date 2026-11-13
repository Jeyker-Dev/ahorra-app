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

El design system guardado en Stitch ("Ahorra Neon Noir", glassmorphism y tono de lujo) queda reemplazado por el de este documento.

## Pendientes

- Diseñar las pantallas de v1:
  - [ ] Compras – Lista sugerida
  - [ ] Compras – En el súper
  - [ ] Producto – Historial de precio
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
