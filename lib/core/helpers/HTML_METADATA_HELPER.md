# HTML Metadata Helper

## Descripción

Helper para actualizar dinámicamente los metadatos HTML de la aplicación web Flutter. Permite modificar el título, favicon y meta tags Open Graph cuando se carga información del comercio.

**✨ Característica especial:** Decodifica automáticamente URLs proxy antes de usarlas, asegurando que los favicons y meta tags de Open Graph funcionen correctamente.

## Ubicación

```
lib/core/helpers/html_metadata_helper.dart
```

## Uso en MenuHomeCartController

### ✅ Actualización automática al cargar menú

Cuando se ejecuta `getItemsMenu()`, el helper actualiza automáticamente:

1. **Título de la página**: `{Nombre del comercio} - MenuCom`
2. **Favicon**: Logo del comercio (photoURL del owner)
3. **Apple Touch Icon**: Para dispositivos iOS
4. **Meta tags Open Graph**: Para compartir en redes sociales

```dart
void getItemsMenu({String? idMenu}) async {
  var response = await GetMenuUseCase().execute(idMenu!);
  
  // Actualizar metadatos HTML automáticamente
  if (response.owner != null) {
    HtmlMetadataHelper.updateCommerceMetadata(
      name: response.owner!.name ?? 'MenuCom',
      logoUrl: response.owner!.photoURL,
      description: 'Catálogo de productos y servicios',
    );
  }
}
```

### ✅ Actualización al cargar wardrobe

Para wardrobes, solo se actualiza el título (ya que no hay photoURL disponible):

```dart
Future<List<WardrobeModel>?> getWardrobebyDining({String? idMenu}) async {
  final responseWar = await GetClothingUserUsescase().execute(idMenu!);
  
  // Actualizar título
  HtmlMetadataHelper.updateTitle('${responseWar.owner} - MenuCom');
}
```

## API del Helper

### Métodos disponibles

#### `updateTitle(String title)`
Actualiza el título de la página web.

```dart
HtmlMetadataHelper.updateTitle('Mi Comercio - MenuCom');
```

#### `updateFavicon(String iconUrl)`
Actualiza el favicon de la página web.

```dart
HtmlMetadataHelper.updateFavicon('https://example.com/logo.png');
```

#### `updateAppleTouchIcon(String iconUrl)`
Actualiza el apple-touch-icon para dispositivos iOS.

```dart
HtmlMetadataHelper.updateAppleTouchIcon('https://example.com/logo.png');
```

#### `updateOpenGraphTags(...)`
Actualiza meta tags Open Graph para compartir en redes sociales.

```dart
HtmlMetadataHelper.updateOpenGraphTags(
  title: 'Mi Comercio',
  description: 'Catálogo de productos',
  imageUrl: 'https://example.com/logo.png',
  url: 'https://menu-comerce.netlify.app/uuid-123',
);
```

#### `updateCommerceMetadata(...)` ⭐ Recomendado
Método conveniente que actualiza todo de una vez.

```dart
HtmlMetadataHelper.updateCommerceMetadata(
  name: 'Cousin Vintage',
  logoUrl: 'https://example.com/logo.png',
  description: 'Tienda de ropa vintage',
);
```

## Manejo de URLs Proxy

El helper **decodifica automáticamente URLs proxy** antes de usarlas en favicons y meta tags.

### Ejemplo de transformación:

**URL Proxy (entrada):**
```
https://menucom-api-60e608ae2f99.herokuapp.com/api/image-proxy/image?url=http%3A%2F%2Fres.cloudinary.com%2Fphotographer%2Fimage%2Fupload%2Fv1757809490%2Fo5ijxvu14ir4zvm3ny7s.png
```

**URL Original (salida):**
```
https://res.cloudinary.com/photographer/image/upload/v1757809490/o5ijxvu14ir4zvm3ny7s.png
```

### Ventajas:

- ✅ **Funciona con URLs proxy**: Extrae la URL original automáticamente
- ✅ **Fuerza HTTPS**: Convierte HTTP a HTTPS para mayor seguridad
- ✅ **Fallback robusto**: Si falla la extracción, usa la URL original
- ✅ **Compatibilidad**: Funciona con URLs directas y proxy

## Beneficios

### 🎯 UX mejorada
- Los usuarios ven el nombre del comercio en la pestaña del navegador
- El favicon personalizado facilita identificar la pestaña
- **Favicon funciona incluso con URLs proxy**

### 📱 SEO y compartir en redes
- Meta tags Open Graph mejoran el preview al compartir
- Facebook, Twitter, WhatsApp muestran información rica del comercio
- **Imágenes se decodifican correctamente para redes sociales**

### 🏗️ Atomic Design
- Helper atómico: no contiene lógica de negocio
- Reutilizable en cualquier parte de la aplicación
- Separación de responsabilidades clara

## Compatibilidad

⚠️ **Solo funciona en plataforma web**. Usa `dart:html` que no está disponible en móvil.

## Arquitectura

```
MenuHomeCartController (Controller)
    ↓
HtmlMetadataHelper (Helper/Atom)
    ↓
dart:html (DOM API)
```

## Testing

Para testear esta funcionalidad:

1. **Local**: 
   ```bash
   flutter run -d chrome
   ```

2. **Verificar en el navegador**:
   - Inspeccionar el `<title>` en DevTools
   - Revisar el `<link rel="icon">` en el `<head>`
   - Verificar meta tags Open Graph

3. **Producción**:
   - Deploy a Netlify
   - Compartir URL en Facebook/WhatsApp
   - Verificar que muestra información correcta

## Ejemplo completo

```dart
// En un controller
void loadCommerceData(String ownerId) async {
  final response = await fetchOwnerData(ownerId);
  
  // Actualizar UI y metadatos HTML
  HtmlMetadataHelper.updateCommerceMetadata(
    name: response.name,
    logoUrl: response.photoURL,
    description: response.description ?? 'Catálogo de productos',
  );
}
```

## Notas técnicas

- El helper busca elementos existentes antes de crear nuevos
- Si el elemento ya existe, solo actualiza el atributo
- Si no existe, lo crea y lo agrega al `<head>`
- Maneja correctamente URLs relativas y absolutas
- **Decodifica URLs proxy automáticamente** usando `Uri.decodeComponent`
- Fuerza HTTPS en todas las URLs para mayor seguridad
- Compatible con la misma lógica de `RobustNetworkImage._extractOriginalUrl`

## Debugging

### Verificar que el favicon se actualiza correctamente:

1. Abrir DevTools (F12)
2. Ir a la pestaña **Elements**
3. Buscar en el `<head>`:
   ```html
   <link rel="icon" type="image/png" href="https://res.cloudinary.com/...">
   ```
4. Verificar que la URL es la **decodificada** (sin proxy)

### Ver logs de extracción de URL:

Si hay errores al extraer la URL, se imprimirá en consola:
```
[HtmlMetadataHelper] Error extracting URL: [detalles del error]
```

## Testing

Puedes probar la extracción de URLs con el test manual:

```bash
dart test/helpers/url_proxy_extraction_test.dart
```

Esto verificará que las URLs proxy se decodifiquen correctamente.
