# Code Review — 2026-05-29 (PWA Install Button)

**Estado:** completado
**Revisor:** opencode-agent
**Duración:** aprox. 15 min
**Área:** PWA Install Button + Dynamic Manifest

---

## Resumen

Implementación sólida y bien documentada del botón de instalación PWA con manifest dinámico por comercio. La arquitectura JS → Dart interop → GetX controller → UI atom es limpia y sigue los patrones del proyecto. Se encontraron 2 issues de moderados (APIs deprecated, memory leak potencial) y 1 menor (const constructor).

---

## Issues Encontrados

### PERF-001: dart:js y dart:html deprecated
- **Archivo:** `lib/core/pwa/pwa_install_helper.dart:2,4`
- **Problema:** Usa `dart:js` y `dart:html` que están deprecated. Flutter recomienda `dart:js_interop` y `package:web`.
- **Impacto:** medio — funcionará hasta que se eliminen las APIs, pero genera warnings en analyze
- **Solución propuesta:** Migrar a:
  ```dart
  import 'dart:js_interop';
  import 'package:web/web.dart';
  
  // En lugar de js.context.callMethod():
  external bool isPwaInstallAvailable();
  external JSPromise<bool> triggerPwaInstall();
  
  // En lugar de html.window.addEventListener():
  window.addEventListener('pwa-install-available', ...);
  ```
- **Nota:** Requiere Flutter 3.22+ y `package:web` en pubspec.yaml

### ARCH-001: Event listeners sin cleanup (memory leak potencial)
- **Archivo:** `lib/core/pwa/pwa_install_controller.dart:21-27`
- **Problema:** `_setupListeners()` agrega event listeners al window pero nunca los remueve. Si el controller se destruye y recrea (ej: hot reload, navegación), los listeners viejos quedan activos.
- **Impacto:** medio — en una SPA web el controller vive toda la sesión, pero en hot reload o recreación puede causar doble ejecución de callbacks
- **Solución propuesta:**
  ```dart
  class PwaInstallController extends GetxController {
    late final void Function() _onAvailable;
    late final void Function() _onInstalled;
  
    @override
    void onClose() {
      html.window.removeEventListener('pwa-install-available', _onAvailable);
      html.window.removeEventListener('pwa-installed', _onInstalled);
      super.onClose();
    }
  }
  ```

### STYLE-001: Missing const constructor
- **Archivo:** `lib/features/home/presentation/widgets/head_home.dart:146`
- **Problema:** `ColorFilter.mode(...)` debería usar `const`
- **Impacto:** bajo — rebuild innecesario menor
- **Solución:** Agregar `const` antes de `ColorFilter.mode(...)`

---

## Observaciones Positivas

### ✅ Arquitectura limpia
- Separación clara: JS (index.html) → Helper (dart) → Controller (GetX) → UI Atom
- Documentación en [`PWA-INSTALL-BUTTON.md`](../PWA-INSTALL-BUTTON.md) es completa y precisa

### ✅ Manejo de edge cases
- `triggerPwaInstall()` retorna `Promise.resolve(false)` si no hay prompt
- `manifest.js` retorna DEFAULT_MANIFEST si falla la API o no hay ID
- `extractOriginalUrl()` maneja URLs con proxy correctamente

### ✅ Atomic Design compliance
- `PwaInstallButtonAtom` es puramente presentacional, sin lógica de negocio
- Nomenclatura correcta: `pwa_install_button_atom.dart`, `PwaInstallButtonAtom`
- Usa `PUColors` y `FluentIcons` correctamente

### ✅ Dynamic Manifest bien implementado
- Script inline en `<head>` se ejecuta síncronamente antes de que el navegador descargue el manifest
- UUID pattern matching es correcto
- Fallback graceful a manifest default

### ✅ GetX integration correcta
- `lazyPut` en `CatalogBinding` — controller se crea bajo demanda
- `Get.find()` en `head_home.dart` funciona porque el binding ya se ejecutó
- `Obx` envuelve solo la parte reactiva del widget tree

---

## Issues Resueltos (desde último review)

N/A — primer review de esta funcionalidad

---

## Pendientes para Próximo Review

- [ ] Verificar migración a `dart:js_interop` + `package:web`
- [ ] Confirmar que event listeners se limpian en `onClose()`
- [ ] Testear en Chrome/Edge que el botón aparece/desaparece correctamente
- [ ] Verificar comportamiento en iOS Safari (botón no debe aparecer)

---

## Checklist de Verificación

- [x] `fvm flutter analyze` ejecutado — 3 issues encontrados (2 deprecated, 1 const)
- [x] Bugs críticos documentados — ninguno crítico encontrado
- [x] Issues de arquitectura identificados — memory leak potencial en listeners
- [x] Performance evaluada — buena, solo 1 rebuild menor por const faltante
- [x] Código muerto y deuda técnica registrada — APIs deprecated
- [x] Atomic Design y cumplimiento de pu_material verificado — ✅ correcto

---

## Score General: 8/10

| Categoría | Score | Notas |
|---|---|---|
| Funcionalidad | 9/10 | Completa, edge cases cubiertos |
| Arquitectura | 8/10 | Limpia, pero falta cleanup de listeners |
| Performance | 8/10 | Buen uso de Obx, const faltante menor |
| Código | 7/10 | APIs deprecated, pero funcional |
| Documentación | 10/10 | Excelente, diagramas y flujos claros |
