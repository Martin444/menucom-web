# Flujo de Venta para Organizador de Eventos - Menucom Catalog

## Visión General

Este documento describe el flujo completo de venta de tickets para un **Organizador de Eventos** desde la perspectiva del cliente final que utiliza la aplicación **Menucom Catalog** (`menucom_catalog`).

El catálogo es la página pública (carrito de compras) a la que los clientes acceden cuando el organizador comparte su link personalizado luego de vincular su cuenta de MercadoPago.

> **Nota importante**: El catálogo actualmente está diseñado como un carrito de compras genérico. El flujo descrito a continuación representa la lógica actual implementada y cómo se integra con el sistema de eventos/tickets del backend (`menu_dart_api`).

---

## Arquitectura General

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           CLIENTE FINAL                                 │
│                                                                         │
│   Recibe link del organizador  →  Abre Catálogo  →  Selecciona Tickets │
│        (ej: menucom.com/{commerceId})                                   │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         MENUCOM CATALOG                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌────────────────┐ │
│  │   HOME      │→ │   CARRITO   │→ │   CONFIRMAR │→ │    CHECKOUT    │ │
│  │  (Catálogo) │  │  (MiCart)   │  │   ORDEN     │  │    STATUS      │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         MENU DART API                                   │
│  ┌─────────────┐  ┌─────────────────────────┐  ┌─────────────────────┐  │
│  │   Events    │  │      Tickets            │  │     MercadoPago     │  │
│  │  (Eventos)  │  │  (Compra/Validación)    │  │   (Checkout Pref)   │  │
│  └─────────────┘  └─────────────────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Flujo Paso a Paso

### 1. El Organizador Comparte su Link

El organizador de eventos, una vez configurado su evento con los tipos de tickets en el dashboard, comparte su link de catálogo público:

```
https://menucom.com/{commerceId}
```

Donde `{commerceId}` es el UUID del organizador/comercio.

**En el backend (Dashboard/API)**:
- El organizador crea el evento usando `CreateEventUseCase`
- Configura tipos de tickets con `CreateTicketTypeUseCase`
- Vincula su cuenta de MercadoPago para recibir pagos

---

### 2. El Cliente Abre el Catálogo (HomePage)

**Archivo clave**: `lib/features/home/presentation/page/home_page.dart`

Cuando el cliente accede al link:

1. El `HomeController` detecta el `commerceId` desde la URL
2. Carga el catálogo público mediante `loadPublicCatalogsByOwnerId(ownerId)`
3. El catálogo muestra los items disponibles (productos o tickets del evento)

**Rutas involucradas** (`lib/routes/routes.dart`):
```dart
static String HOME = '/';
static String COMMERCE_DETAIL = '/:commerceId'; // Captura UUIDs dinámicos
```

**Nota**: En el caso de eventos, los items del catálogo representarían los diferentes tipos de tickets disponibles para compra.

---

### 3. El Cliente Agrega Tickets al Carrito

**Archivos clave**:
- `lib/features/home/controllers/home_controller.dart`
- `lib/features/home/controllers/cart_controller.dart`

**Flujo**:

1. El cliente selecciona un item (ticket) del catálogo
2. `HomeController.selectItem()` agrega o remueve el item del carrito
3. `CartController` mantiene el estado del carrito con:
   - Lista de items (`cartItems`)
   - Cantidades
   - Totales (subtotal, impuestos, total)

```dart
// HomeController - Agregar al carrito
void selectItem(CatalogItemModel item) {
  if (_cartController.containsItem(item.id)) {
    _cartController.removeItem(item.id);
  } else {
    _cartController.addItem(item);
  }
}
```

**En el contexto de Eventos**: Cada item del catálogo correspondería a un `TicketTypeModel` (por ejemplo: "General - $100", "VIP - $250").

---

### 4. El Cliente Revisa su Carrito (MyCartPage)

**Archivo clave**: `lib/features/my_cart/presentation/pages/my_cart_page.dart`

**Ruta**: `/mi-carrito`

En esta página el cliente:
1. Ve la lista de tickets seleccionados
2. Puede aumentar/disminuir cantidades
3. Ve el total de la orden
4. Puede continuar al checkout

```dart
// MyCartPage
CartOrderSummary(
  total: controller.totalOrder,
  onContinue: () {
    orderController.setOwnerId(controller.persistedOwnerId.value);
    orderController.createOrder(controller.listMenuSelected);
  },
)
```

**Validaciones actuales**:
- El carrito no puede estar vacío
- Se establece el `ownerId` (identificador del comercio/organizador)

**Para Eventos**: Aquí se debería validar:
- Que la cantidad seleccionada no exceda `maxPerUser` del ticket type
- Que haya stock disponible (`remainingQuantity`)

---

### 5. Confirmación de Orden (ConfirmOrderPage)

**Archivo clave**: `lib/features/my_cart/presentation/pages/confirm_order_page.dart`

**Ruta**: `/confirmar-pedido`

El cliente ingresa sus datos de contacto:
- **Nombre completo** (requerido para tickets)
- **Email** (requerido para envío de tickets)

**Acciones disponibles**:
- Revisar los items de la orden
- Ver totales
- Confirmar y proceder al pago

```dart
// ConfirmOrderPage muestra:
// - ConfirmOrderHeader: Estado de la orden
// - ProductsSection: Lista de tickets
// - TotalsSection: Total a pagar
// - ConfirmOrderActions: Botón de confirmar
```

**Para Eventos**: Los datos del comprador se usarían para:
- Generar el `PurchaseTicketParams.customerName`
- Generar el `PurchaseTicketParams.customerEmail`
- Enviar los tickets por email tras la compra

---

### 6. Proceso de Checkout con MercadoPago

**Archivo clave**: `lib/features/my_cart/getx/order_controller.dart`

#### 6.1 Creación de la Orden

Cuando el cliente confirma:

```dart
// OrderController.createOrder()
void saveContactToLastOrder(String contact) async {
  // 1. Validar ownerId (comercio/organizador)
  final currentOwnerId = ownerId.value.isNotEmpty ? ownerId.value : orders.value.ownerId;
  
  // 2. Actualizar orden con datos de contacto
  final updatedOrder = orders.value.copyWith(
    customerEmail: contactInfo,
    ownerId: currentOwnerId,
  );
  
  // 3. Crear orden en el backend
  var orderCreated = await CreateOrderUseCase().call(orders.value);
}
```

#### 6.2 Integración con MercadoPago

El backend (`menu_dart_api`) crea una preferencia de pago mediante:
- `CreateCheckoutPreferenceUseCase` → llama a `TicketRepository.checkout()`

El `CheckoutResponse` retorna:
```dart
CheckoutResponse(
  preferenceId: 'pref-123',
  paymentUrl: 'https://www.mercadopago.com.ar/checkout/v1/redirect?pref_id=...',
  totalAmount: 200.0,
  currency: 'ARS',
)
```

#### 6.3 Redirección al Pago

```dart
// OrderController._openMercadoPagoCheckout()
String targetUrl = 'https://www.mercadopago.com.ar/checkout/v1/redirect?pref_id=$preferenceId';
await redirectToMercadoPagoCheckout(targetUrl);
```

**Comportamiento por plataforma**:
- **Web**: Abre en la misma pestaña (`_self`) para evitar bloqueadores de popups
- **Mobile**: Abre en aplicación externa (`LaunchMode.externalApplication`)

---

### 7. Pago en MercadoPago

El cliente completa el pago en la plataforma de MercadoPago.

**Posibles resultados**:
- **Éxito**: MercadoPago redirige a `/checkout/status?status=approved&preference_id=...`
- **Pendiente**: Redirige con estado `pending`
- **Fallido**: Redirige con estado `failure`

---

### 8. Página de Estado del Checkout (CheckoutStatusPage)

**Archivo clave**: `lib/features/my_cart/presentation/pages/checkout_status_page.dart`

**Ruta**: `/checkout/status`

Esta página captura los parámetros de retorno de MercadoPago:

```dart
final preferenceId = params['preference_id'] ?? '';
final merchantOrderId = params['merchant_order_id'] ?? '';
final status = params['status'] ?? params['collection_status'] ?? '';
final paymentId = params['payment_id'] ?? '';
```

**Muestra**:
- Estado del pago (aprobado, pendiente, rechazado)
- Detalles de la transacción
- Botón para descargar tickets (PDF)
- Botón para volver al inicio

**Para Eventos**: Tras un pago exitoso, el backend ejecuta:
- `PurchaseTicketUseCase` → Genera los tickets con QR codes
- `DownloadTicketPdfUseCase` → Permite descargar los tickets
- `GetTicketQrDataUseCase` → Muestra el QR para entrada al evento

---

### 9. Actualización en Tiempo Real (WebSocket)

**Archivo clave**: `lib/features/my_cart/getx/order_controller.dart`

Durante el proceso de pago, el `OrderController` se conecta a un WebSocket:

```dart
// Conectar al WebSocket y suscribirse a la room de la orden
_socket = IO.io(wsUrl, IO.OptionBuilder()
    .setTransports(['websocket'])
    .enableReconnection()
    .setReconnectionAttempts(10)
    .build());

_socket!.emit('subscribeToOrder', orderCreated.operationID);
```

**Eventos escuchados**:
- `paymentSuccess`: El pago fue confirmado
- Actualiza el estado de la orden a `confirmed`
- Limpia el carrito persistido

---

## Modelos y Estructuras de Datos Relevantes

### En el Catálogo

```dart
// Orden (Order)
class Order {
  List<OrderItem>? items;
  double? total;
  String? status; // 'pending', 'processing', 'confirmed'
  String? ownerId; // ID del comercio/organizador
  String? customerEmail;
}

// Item de Orden (OrderItem)
class OrderItem {
  String productName;
  int quantity;
  double price;
  String sourceId; // ID del ticket type
  String sourceType; // 'menu' | 'ticket'
}
```

### En el Backend (menu_dart_api)

```dart
// Parámetros de Checkout
class CheckoutParams {
  String ticketTypeId;
  int quantity;
  String customerName;
  String customerEmail;
  String tenantId;
}

// Parámetros de Compra
class PurchaseTicketParams {
  String ticketTypeId;
  int quantity;
  String customerName;
  String customerEmail;
}

// Respuesta de Checkout
class CheckoutResponse {
  String preferenceId;
  String paymentUrl;
  double totalAmount;
  String currency;
}
```

---

## Flujo de Validación de Tickets (Post-Venta)

Una vez que el cliente tiene sus tickets, el organizador puede validarlos en la puerta del evento:

### Métodos de Validación (Backend)

1. **Validación por QR** (`ValidateQrCodeUseCase`):
   ```dart
   final ticket = await validateQrCodeUseCase.execute('qr-code-data');
   // Marca el ticket como 'validated'
   ```

2. **Validación Manual** (`ValidateTicketUseCase`):
   ```dart
   final ticket = await validateTicketUseCase.execute(ValidateTicketParams(
     ticketId: 'ticket-123',
     validationToken: 'token-xyz',
   ));
   ```

3. **Validación Offline** (`ValidateOfflineTokenUseCase`):
   - Para eventos sin conexión a internet
   - Usa tokens pre-sincronizados

4. **Verificación de Estado** (`CheckTicketStatusUseCase`):
   - Verifica si un ticket es válido sin marcarlo como usado
   - Útil para pre-validación

### Estados de un Ticket

| Estado | Descripción |
|--------|-------------|
| `pending` | Compra iniciada, pago pendiente |
| `paid` | Pago confirmado, listo para usar |
| `validated` | Ticket ya escaneado/validado |
| `cancelled` | Compra cancelada o reembolsada |

---

## Consideraciones para Implementación de Eventos

### Integración Actual vs. Deseada

**Estado actual del catálogo**:
- El catálogo es un carrito de compras genérico para cualquier tipo de producto/servicio
- Los items se representan como `CatalogItemModel` genéricos
- El checkout usa `CreateOrderUseCase` general

**Para soportar Eventos/Tickets nativamente**, el flujo debería:

1. **En la carga del catálogo**:
   - Detectar si el `ownerId` es un organizador de eventos
   - Cargar los `TicketTypeModel` en lugar de productos genéricos
   - Mostrar información específica: precio, disponibilidad, límite por usuario

2. **En el carrito**:
   - Validar `maxPerUser` por tipo de ticket
   - Mostrar contador de disponibilidad (`remainingQuantity`)
   - Validar fechas de venta (`saleStartDate` - `saleEndDate`)

3. **En el checkout**:
   - Usar `CreateCheckoutPreferenceUseCase` específico de tickets
   - Pasar `CheckoutParams` con `ticketTypeId` en lugar de `sourceId` genérico
   - Incluir `tenantId` del organizador

4. **Post-pago**:
   - Ejecutar `PurchaseTicketUseCase` para generar tickets
   - Enviar emails con QR codes
   - Permitir descarga de PDF con `DownloadTicketPdfUseCase`

---

## Endpoints del Backend Involucrados

| Endpoint | Método | Descripción | Use Case |
|----------|--------|-------------|----------|
| `/tickets/checkout` | POST | Crea preferencia de pago en MercadoPago | `CreateCheckoutPreferenceUseCase` |
| `/tickets/purchase` | POST | Confirma compra y genera tickets | `PurchaseTicketUseCase` |
| `/tickets/:id/pdf` | GET | Descarga ticket en PDF | `DownloadTicketPdfUseCase` |
| `/tickets/:id/qr-data` | GET | Obtiene datos del QR | `GetTicketQrDataUseCase` |
| `/tickets/validate/:code` | POST | Valida ticket por QR | `ValidateQrCodeUseCase` |
| `/tickets/validate` | POST | Valida ticket manualmente | `ValidateTicketUseCase` |
| `/tickets/check` | POST | Verifica estado del ticket | `CheckTicketStatusUseCase` |

---

## Resumen del Flujo

```
ORGANIZADOR                          CLIENTE                              SISTEMA
    │                                   │                                    │
    ├── Crea Evento ────────────────────┼────────────────────────────────────►
    ├── Crea Ticket Types ──────────────┼────────────────────────────────────►
    ├── Vincula MercadoPago ────────────┼────────────────────────────────────►
    ├── Comparte Link ─────────────────►│                                    │
    │                                   ├── Abre Catálogo ──────────────────►
    │                                   ├── Selecciona Tickets ─────────────►
    │                                   ├── Va a Carrito ───────────────────►
    │                                   ├── Confirma Datos ─────────────────►
    │                                   ├── Procede al Pago ────────────────►
    │                                   │                                    ├── Crea Preferencia MP
    │                                   │◄────────── paymentUrl ─────────────┤
    │                                   ├── Paga en MercadoPago ────────────►
    │                                   │                                    ├── Webhook: Pago OK
    │                                   │                                    ├── Genera Tickets (QR)
    │                                   │◄────────── Tickets + QR ───────────┤
    │                                   ├── Descarga PDF ───────────────────►
    │                                   │                                    │
    │◄────────── Validación QR ─────────┼────────────────────────────────────┤
    ├── Escanear QR ───────────────────►│                                    │
    │                                   │                                    ├── Valida Ticket
    │◄────────── Ticket Válido ─────────┼────────────────────────────────────┤
```

---

## Archivos Clave del Proyecto

### Catálogo (menucom_catalog)

| Archivo | Descripción |
|---------|-------------|
| `lib/main.dart` | Punto de entrada, inicializa Firebase y API |
| `lib/routes/routes.dart` | Definición de rutas |
| `lib/routes/pages.dart` | Configuración de páginas GetX |
| `lib/features/home/controllers/home_controller.dart` | Controlador principal del catálogo |
| `lib/features/home/controllers/cart_controller.dart` | Controlador del carrito |
| `lib/features/my_cart/getx/order_controller.dart` | Lógica de checkout y pago |
| `lib/features/my_cart/presentation/pages/my_cart_page.dart` | Página del carrito |
| `lib/features/my_cart/presentation/pages/confirm_order_page.dart` | Confirmación de orden |
| `lib/features/my_cart/presentation/pages/checkout_status_page.dart` | Estado del pago |

### Backend (menu_dart_api)

| Archivo | Descripción |
|---------|-------------|
| `lib/by_feature/events/events.dart` | Barrel export del módulo de eventos |
| `lib/by_feature/events/data/usecase/purchase_ticket_usecase.dart` | Compra de tickets |
| `lib/by_feature/events/data/usecase/create_checkout_preference_usecase.dart` | Checkout MP |
| `lib/by_feature/events/data/provider/ticket_provider.dart` | Implementación HTTP |
| `lib/by_feature/events/models/checkout_params.dart` | Parámetros de checkout |
| `lib/by_feature/events/models/purchase_ticket_params.dart` | Parámetros de compra |
| `lib/by_feature/events/models/checkout_response.dart` | Respuesta de checkout |
| `lib/by_feature/events/models/ticket_model.dart` | Modelo de ticket |
| `lib/by_feature/events/models/ticket_type_model.dart` | Modelo de tipo de ticket |

---

## Notas Finales

- El catálogo utiliza **GetX** para navegación y state management
- Los pagos se procesan mediante **MercadoPago Checkout Pro**
- El sistema soporta actualizaciones en tiempo real vía **WebSocket**
- El estado de la orden se persiste localmente con **SharedPreferences**
- La lógica de eventos/tickets ya está completamente implementada en `menu_dart_api` y solo requiere integración en la capa de presentación del catálogo
