# Sistema de Identificación Anónima Persistente

Este sistema implementa un identificador anónimo persistente (`anonymousId`) que se utiliza para vincular órdenes en el backend NestJS sin requerir autenticación del usuario.

## Características Principales

- **Almacenamiento persistente**: Usa `SharedPreferences` en móvil y `localStorage` en web
- **Generación automática**: UUID v4 generado automáticamente si no existe
- **Header automático**: Se agrega `X-Anonymous-Id` a todas las requests HTTP automáticamente
- **Compatibilidad universal**: Funciona en móvil (iOS/Android) y web
- **Fallback resiliente**: Genera UUID temporal en caso de errores de persistencia
- **Logging inteligente**: Solo muestra logs en modo debug para evitar exposición en producción

## Estructura del Código

### Servicios Core

1. **`AnonymousIdService`** - Servicio base para móvil usando SharedPreferences
2. **`AnonymousIdWebService`** - Servicio específico para web usando localStorage  
3. **`UniversalAnonymousIdService`** - Servicio universal que detecta la plataforma automáticamente
4. **`AnonymousHttpClient`** - Cliente HTTP que agrega automáticamente el header X-Anonymous-Id
5. **`AnonymousDioClient`** - Cliente Dio con interceptor para agregar el header automáticamente

### Integración con API

La clase `API` central fue extendida para incluir:

```dart
// Cliente HTTP con soporte para Anonymous ID automático
static AnonymousHttpClient get httpClient => AnonymousHttpClient.instance;

// Cliente Dio con soporte para Anonymous ID automático  
static AnonymousDioClient get dioClient => AnonymousDioClient.instance;

// Métodos de utilidad
static Future<String> getCurrentAnonymousId() async
static Future<String> regenerateAnonymousId() async
```

## Uso en Providers

### Antes (HTTP tradicional):
```dart
var response = await http.get(userUrl);
```

### Después (con Anonymous ID automático):
```dart
var response = await API.httpClient.get(userUrl);
```

El header `X-Anonymous-Id` se agrega automáticamente a todas las peticiones.

## Ejemplos de Uso

### 1. Obtener/Crear ID Anónimo
```dart
final anonymousId = await UniversalAnonymousIdService.instance.getOrCreateAnonymousId();
print('Anonymous ID: $anonymousId');
```

### 2. Hacer Peticiones HTTP con ID Automático
```dart
// GET request
final response = await API.httpClient.get(
  Uri.parse('${API.defaulBaseUrl}/menu/bydining/123')
);

// POST request  
final response = await API.httpClient.post(
  Uri.parse('${API.defaulBaseUrl}/orders'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode(orderData),
);
```

### 3. Regenerar ID (útil para testing)
```dart
final newId = await UniversalAnonymousIdService.instance.regenerateAnonymousId();
```

### 4. Limpiar ID almacenado
```dart
await UniversalAnonymousIdService.instance.clearAnonymousId();
```

## Controller de Ejemplo

Se incluye `AnonymousTrackingController` que demuestra:

- Inicialización automática del ID
- Regeneración de ID con feedback visual
- Limpieza de ID almacenado
- Envío de órdenes de prueba con header automático

## Página de Demostración

`AnonymousTrackingExamplePage` proporciona una interfaz visual para:

- Ver el ID anónimo actual
- Regenerar el ID manualmente
- Limpiar el ID almacenado
- Enviar órdenes de prueba
- Documentación de características

## Integración en Backend NestJS

El backend recibirá automáticamente el header:

```
X-Anonymous-Id: 550e8400-e29b-41d4-a716-446655440000
```

### Ejemplo de extracción en NestJS:

```typescript
@Post('orders')
async createOrder(
  @Headers('x-anonymous-id') anonymousId: string,
  @Body() orderData: CreateOrderDto
) {
  // Usar anonymousId para vincular la orden
  return this.ordersService.create(orderData, anonymousId);
}
```

## Migración de Providers Existentes

Para migrar providers existentes al nuevo sistema:

1. **Importar API**: Asegurar que se importe `API` de `menu_com_api`
2. **Reemplazar cliente**: Cambiar `http.get/post/put/delete` por `API.httpClient.get/post/put/delete`
3. **Remover imports**: Quitar `import 'package:http/http.dart' as http;`

### Ejemplo de migración:

```dart
// ANTES
import 'package:http/http.dart' as http;

var response = await http.post(
  Uri.parse('${API.defaulBaseUrl}/auth/login'),
  body: {
    "email": email,
    "password": password,
  },
);

// DESPUÉS  
var response = await API.httpClient.post(
  Uri.parse('${API.defaulBaseUrl}/auth/login'),
  body: {
    "email": email,
    "password": password,
  },
);
```

## Dependencias Añadidas

En `pubspec.yaml` del proyecto principal:
```yaml
dependencies:
  uuid: ^4.5.1
  shared_preferences: ^2.2.3  # Ya existía
```

En `pubspec.yaml` del paquete `menu_dart_api`:
```yaml
dependencies:
  uuid: ^4.5.1
  shared_preferences: ^2.2.3
  http: ^1.2.1  # Movido de dev_dependencies
```

## Consideraciones de Seguridad

- El UUID se genera con algoritmo seguro (UUID v4)
- Los logs del ID solo aparecen en modo debug
- No se expone información sensible del usuario
- El ID es anónimo y no contiene datos personales

## Testing

Para pruebas, se puede:

1. **Regenerar ID**: `API.regenerateAnonymousId()`
2. **Limpiar ID**: `UniversalAnonymousIdService.instance.clearAnonymousId()`
3. **Verificar header**: Inspeccionar requests en red para confirmar header `X-Anonymous-Id`

## Beneficios del Sistema

1. **Transparente**: Los developers no necesitan recordar agregar el header manualmente
2. **Consistente**: Todas las peticiones HTTP incluyen el header automáticamente  
3. **Resiliente**: Maneja errores gracefully con fallbacks
4. **Universal**: Funciona en todas las plataformas de Flutter
5. **Mantenible**: Centraliza la lógica de anonymous ID en servicios dedicados
6. **Testeable**: Permite regeneración y limpieza fácil para testing

Este sistema garantiza que todas las órdenes y requests puedan ser vinculadas en el backend para mejorar la experiencia del usuario y la funcionalidad de tracking.
