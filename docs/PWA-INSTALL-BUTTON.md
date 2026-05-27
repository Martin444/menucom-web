# PWA Install Button

Botón de "Instalar aplicación" (Add to Home Screen) para el PWA de Menucom Catalog.

## Arquitectura

```
web/index.html                          ← JS: captura beforeinstallprompt
       │
       ▼
lib/core/pwa/pwa_install_helper.dart    ← Dart ↔ JS interop
       │
       ▼
lib/core/pwa/pwa_install_controller.dart ← GetX controller (isInstallable observable)
       │
       ▼
pu_material/lib/atoms/pwa_install_button_atom.dart  ← Átomo UI
       │
       ▼
lib/features/home/presentation/widgets/head_home.dart  ← Integración en header
```

## Flujo

1. El navegador detecta que la app cumple requisitos PWA y dispara `beforeinstallprompt`
2. El JS en `index.html` captura el evento con `e.preventDefault()` y lo almacena en `window._deferredPrompt`
3. Dispara un custom event `pwa-install-available` que el helper Dart escucha
4. `PwaInstallController` actualiza `isInstallable` a `true`
5. El botón aparece en el header (junto al carrito)
6. Usuario hace clic → se llama `triggerPwaInstall()` → JS ejecuta `prompt.prompt()` → se muestra el diálogo nativo del navegador
7. Si el usuario acepta, se dispara `appinstalled` → JS limpia `_deferredPrompt` y emite `pwa-installed` → controller actualiza `isInstallable` a `false` → botón desaparece

## Archivos

### web/index.html

Dos event listeners globales:

```js
window._deferredPrompt = null;

window.addEventListener('beforeinstallprompt', function(e) {
  e.preventDefault();
  window._deferredPrompt = e;
  window.dispatchEvent(new CustomEvent('pwa-install-available'));
});

window.addEventListener('appinstalled', function() {
  window._deferredPrompt = null;
  window.dispatchEvent(new CustomEvent('pwa-installed'));
});
```

Tres funciones expuestas en `window`:

| Función | Retorno | Descripción |
|---|---|---|
| `isPwaInstallAvailable()` | `bool` | Si hay un prompt pendiente |
| `triggerPwaInstall()` | `Promise<bool>` | Muestra el prompt y retorna si el usuario aceptó |

### lib/core/pwa/pwa_install_helper.dart

Usa `dart:js` y `dart:html` (mismo patrón que `mercadopago_web.dart`).

| Método | Descripción |
|---|---|
| `isAvailable` | Retorna `true` si hay prompt disponible |
| `triggerInstall()` | Dispara el prompt, retorna `Future<bool>` |
| `onInstallAvailable(callback)` | Escucha el custom event `pwa-install-available` |
| `onInstalled(callback)` | Escucha el custom event `pwa-installed` |

### lib/core/pwa/pwa_install_controller.dart

GetX controller con:
- `RxBool isInstallable` — se sincroniza con los eventos JS
- `install()` — dispara el prompt nativo

### pu_material/lib/atoms/pwa_install_button_atom.dart

Átomo presentacional:
- Ícono: `FluentIcons.arrow_download_24_regular`
- Sin lógica de negocio, recibe `onPressed` y `tooltip`
- Tooltip opcional (envuelve en `Tooltip` si no es null)

### head_home.dart

Se agregó un `Obx` dentro del `GetBuilder<HomeController>` que:
- Hace `Get.find<PwaInstallController>()` para acceder al estado
- Muestra `PwaInstallButtonAtom` solo si `isInstallable == true`
- Al presionar llama `pwaCtrl.install()`

---

# Dynamic Manifest (por comercio)

Cuando un usuario instala la PWA desde la página de un comercio específico, la app instalada muestra el **nombre, logo y color de ese comercio** en lugar de "Menucom Catalogo".

## Arquitectura

```
web/index.html
  │
  ├── <script inline> detecta commerceId en la URL
  │     y cambia <link rel="manifest"> a /.netlify/functions/manifest?id={id}
  │
  ▼
netlify/functions/manifest.js    ← Serverless function en Node.js
  │
  ├── GET /.netlify/functions/manifest?id={commerceId}
  │
  ▼
API (menucom-api.onrender.com)   ← GET /catalogs/{id}
  │
  ▼
Responde manifest.json dinámico  ← { name, short_name, description,
                                     theme_color, icons (logo comercio) }
```

## Flujo

1. Usuario visita `menu-commerce.netlify.app/<commerceId>`
2. El HTML incluye un `<script>` inline que:
   - Extrae el commerce ID de la ruta (pattern UUID)
   - Cambia `href` del `<link rel="manifest">` a `/.netlify/functions/manifest?id=<commerceId>`
3. El navegador descarga el manifest desde la Netlify Function
4. La function pide los datos del catálogo a la API y genera un manifest personalizado
5. Si el usuario instala la PWA, se usan los datos del comercio

## Archivos

### netlify/functions/manifest.js

Serverless function que recibe `?id={commerceId}` y retorna un `manifest.json` dinámico:

| Campo | Fuente |
|---|---|
| `name` | `catalog.name` |
| `short_name` | `catalog.name` truncado a 12 chars |
| `description` | `catalog.description` |
| `theme_color` | `catalog.settings.themeColor` o fallback `#CEDDFE` |
| `background_color` | `catalog.settings.backgroundColor` o fallback `#FFFFFF` |
| `icons` | `catalog.coverImageUrl` + fallback a iconos default de Menucom |

Si no hay commerce ID o falla la API, retorna el manifest default.

### web/index.html

Script inline al inicio de `<head>` que:
- Busca un UUID en `window.location.pathname`
- Si encuentra, actualiza el `href` del `<link rel="manifest">` a la función
- Se ejecuta de forma síncrona ANTES de que el navegador descargue el manifest

```html
<link rel="manifest" id="manifest-link" href="manifest.json">
<script>
  (function() {
    var commerceId = null;
    var pathParts = window.location.pathname.split('/').filter(Boolean);
    if (pathParts.length > 0) {
      var last = pathParts[pathParts.length - 1];
      var uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
      if (uuidPattern.test(last)) {
        commerceId = last;
      }
    }
    if (commerceId) {
      var link = document.getElementById('manifest-link');
      if (link) {
        link.href = '/.netlify/functions/manifest?id=' + commerceId;
      }
    }
  })();
</script>
```

## Notas

- La función se despliega automáticamente con el resto del proyecto (la ruta `netlify/functions/` está configurada en `netlify.toml`)
- Usa `fetch` nativo de Node.js 18+ (no necesita dependencias)
- El manifest se actualiza solo al cargar la página; si el usuario navega entre comercios sin recargar, el manifest no cambia (limitación del navegador, no re-descarga el manifest)

---

## Notas generales

- El botón solo aparece en navegadores que soportan PWA y donde la app no está instalada
- En iOS Safari no existe `beforeinstallprompt`, así que el botón nunca se mostrará (no hay API para instalación programática en iOS)
- El controller se registra con `lazyPut` en `CatalogBinding` y se resuelve con `Get.find()` bajo demanda
- Usa `dart:js` / `dart:html` — solo funciona en web (mismo patrón que el resto del proyecto)
