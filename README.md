# Mithril Minimal

Una distribución reducida de Mithril 2.3.8 que conserva `m()`, componentes,
renderizado virtual, `m.mount`, `m.redraw`, `m.render` y `m.fragment`.

No incluye ni expone `m.route`, `m.trust` ni `m.request`. En consecuencia, no
hay router, inserción de HTML sin escapar ni cliente HTTP integrado.

```js
var m = require("mithril-minimal")

m.mount(document.body, {
  view: function () {
    return m("main", [m("h1", "Hola"), m("p", "Mithril minimal")])
  },
})
```

## Desarrollo

Ejecuta `bun run test` para comprobar la API reducida, el renderizado básico y
que el HTML de texto no sea interpretado. `bun run build` genera el artefacto
de navegador `mithril-minimal.js`.

## Actualizar desde Mithril.js

El procedimiento reproducible está en
[`scripts/update-from-mithril.sh`](scripts/update-from-mithril.sh). Descarga una
etiqueta oficial, copia únicamente el núcleo necesario, elimina router,
requests y HTML confiable, valida que no queden referencias y ejecuta tests y
build.

```bash
# Última versión configurada por defecto
bun run update:mithril

# Una etiqueta concreta de Mithril
bash scripts/update-from-mithril.sh v2.3.9

# Desde un checkout local, sin red
bash scripts/update-from-mithril.sh ignored /ruta/a/mithril.js
```

El script falla si la estructura ascendente cambia: así no publica una versión
que sólo haya eliminado parcialmente las funcionalidades.

El código procede de Mithril.js y se distribuye bajo la licencia MIT; consulta
`LICENSE` en el proyecto oficial para el texto completo.
