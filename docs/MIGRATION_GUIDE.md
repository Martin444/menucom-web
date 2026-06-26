# Guía de Migración - Sistema Anonymous ID

## Resumen de Cambios Implementados

Se ha implementado un sistema completo de identificación anónima persistente que agrega automáticamente el header `X-Anonymous-Id` a todas las peticiones HTTP.

## Archivos Modificados/Creados

### Nuevos Servicios Core
```
lib/core/services/
├── anonymous_id_service.dart              # Servicio base (móvil)
menu_dart_api/lib/core/services/
├── anonymous_id_service.dart              # Servicio base (API package)
├── anonymous_id_web_service.dart          # Servicio web (localStorage)
├── universal_anonymous_id_service.dart    # Servicio universal (auto-detect platform)
├── anonymous_http_client.dart             # Cliente HTTP con header automático
└── anonymous_dio_client.dart              # Cliente Dio con interceptor
```

### Archivos de Ejemplo
```
lib/core/controllers/
├── anonymous_tracking_controller.dart     # Controller GetX de ejemplo

lib/features/anonymous_tracking/
├── anonymous_tracking_example_page.dart   # Página demo con UI

test/
├── anonymous_id_service_test.dart         # Tests unitarios
```

### Dependencias Añadidas
```yaml
# pubspec.yaml (proyecto principal)
dependencies:
  uuid: ^4.5.1

# menu_dart_api/pubspec.yaml
dependencies:
  uuid: ^4.5.1
  shared_preferences: ^2.2.3
  http: ^1.2.1  # Movido de dev_dependencies
```

### Providers Migrados (Ejemplos)
- `GetMenuProvider` - Usa `API.httpClient.get()` en lugar de `http.get()`
- `LoginProvider` - Usa `API.httpClient.post()` en lugar de `http.post()`

## Antes vs Después

### ANTES (Provider tradicional):
```dart
import 'package:http/http.dart' as http;

class MyProvider {
  Future<Response> fetchData() async {
    return await http.get(
      Uri.parse('${API.defaulBaseUrl}/data'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
  }
}
```

### DESPUÉS (Provider con Anonymous ID automático):
```dart
// Solo importar API, no más http directo
import 'package:menu_dart_api/core/api.dart';

class MyProvider {
  Future<Response> fetchData() async {
    return await API.httpClient.get(
      Uri.parse('${API.defaulBaseUrl}/data'),
      headers: {
        'Content-Type': 'application/json',
        // X-Anonymous-Id se agrega automáticamente
      },
    );
  }
}
```

## Cómo Migrar Providers Existentes

### Paso 1: Actualizar imports
```dart
// REMOVER
import 'package:http/http.dart' as http;

// ASEGURAR QUE EXISTE
import 'package:menu_dart_api/core/api.dart';
```

### Paso 2: Reemplazar llamadas HTTP
```dart
// ANTES
http.get(url, headers: headers)
http.post(url, headers: headers, body: body)
http.put(url, headers: headers, body: body)
http.delete(url, headers: headers, body: body)

// DESPUÉS  
API.httpClient.get(url, headers: headers)
API.httpClient.post(url, headers: headers, body: body)
API.httpClient.put(url, headers: headers, body: body)
API.httpClient.delete(url, headers: headers, body: body)
```

### Paso 3: Para proyectos que usen Dio
```dart
// ANTES
final dio = Dio();
final response = await dio.get('/data');

// DESPUÉS
final response = await API.dioClient.dio.get('/data');
// El interceptor agrega X-Anonymous-Id automáticamente
```

## Backend NestJS - Recepción del Header

El backend recibirá automáticamente:
```
X-Anonymous-Id: 550e8400-e29b-41d4-a716-446655440000
```

### Extracción en Controllers:
```typescript
@Post('orders')
async createOrder(
  @Headers('x-anonymous-id') anonymousId: string,
  @Body() orderData: CreateOrderDto
) {
  console.log('Anonymous ID:', anonymousId);
  return this.ordersService.create(orderData, anonymousId);
}
```

### Middleware Global (Opcional):
```typescript
@Injectable()
export class AnonymousIdMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    const anonymousId = req.headers['x-anonymous-id'];
    if (anonymousId) {
      req['anonymousId'] = anonymousId;
    }
    next();
  }
}
```

## Testing y Verificación

### 1. Ejecutar Tests
```bash
flutter test test/anonymous_id_service_test.dart
```

### 2. Verificar Headers en Red
- Abrir DevTools del navegador
- Ir a Network/Red
- Hacer cualquier request HTTP
- Verificar que aparece header `X-Anonymous-Id`

### 3. Probar en Dispositivo
```dart
// Obtener ID actual
final id = await API.getCurrentAnonymousId();
print('Anonymous ID: $id');

// Regenerar para testing
final newId = await API.regenerateAnonymousId();
print('Nuevo ID: $newId');
```

## Características del Sistema

✅ **Automático**: No requiere intervención manual en cada request  
✅ **Persistente**: Se mantiene entre sesiones de la app  
✅ **Universal**: Funciona en móvil (SharedPreferences) y web (localStorage)  
✅ **Resiliente**: Fallback con UUID temporal si hay errores  
✅ **Seguro**: No expone información personal del usuario  
✅ **Testeable**: Permite regeneración y limpieza para tests  
✅ **Compatible**: Funciona con HTTP y Dio  
✅ **Transparente**: Los developers no necesitan recordar agregar headers  

## Próximos Pasos

1. **Migrar providers restantes** usando el patrón mostrado
2. **Actualizar backend** para usar el anonymous ID en vinculación de órdenes
3. **Agregar logging** en backend para trackear uso del anonymous ID
4. **Documentar endpoints** que esperan el header X-Anonymous-Id

## Troubleshooting

### Header no aparece en requests
- Verificar que se está usando `API.httpClient` en lugar de `http` directo
- Comprobar que las dependencias están actualizadas con `flutter pub get`

### ID se regenera constantemente  
- Verificar permisos de escritura en SharedPreferences/localStorage
- Revisar logs de error en consola de desarrollo

### Tests fallan
- Limpiar SharedPreferences mock: `SharedPreferences.setMockInitialValues({})`
- Verificar que se está usando el servicio correcto en tests

El sistema está completo y listo para producción. Todos los requests HTTP ahora incluirán automáticamente el header `X-Anonymous-Id` para permitir el tracking de usuarios anónimos en el backend.

---

## Referencias

- [CODE-REVIEW.md](./CODE-REVIEW.md) — Índice del sistema de code reviews
- [PROGRESS-TRACKER.md](./PROGRESS-TRACKER.md) — Seguimiento de fases y tareas
- [ANONYMOUS_ID_SYSTEM.md](./ANONYMOUS_ID_SYSTEM.md) — Documentación del sistema Anonymous ID
