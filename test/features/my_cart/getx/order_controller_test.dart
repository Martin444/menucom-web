// import 'package:flutter_test/flutter_test.dart';
// import 'package:get/get.dart';
// import 'package:mockito/mockito.dart';
// import 'package:mockito/annotations.dart';
// import 'package:menu_dart_api/menu_com_api.dart';

// @GenerateMocks([Order])
// import 'order_controller_test.mocks.dart';

// void main() {
//   group('OrderController', () {
//     late OrderController controller;

//     setUp(() {
//       Get.testMode = true;
//       controller = OrderController();
//     });

//     tearDown(() {
//       Get.reset();
//     });

//     test('test_controller_initializes_with_correct_default_state', () {
//       expect(controller.orders.value, isEmpty);
//       expect(controller.isLoading.value, isTrue);
//       expect(controller.errorText.value, equals(''));
//     });

//     test('test_loading_state_set_to_true_on_create_order', () async {
//       controller.isLoading.value = false;

//       await controller.createOrder();

//       expect(controller.isLoading.value, isTrue);
//     });

//     test('test_orders_list_remains_observable_and_reactive', () {
//       expect(controller.orders, isA<RxList<Order>>());
//       expect(controller.orders.value, isA<List<Order>>());

//       final mockOrder = MockOrder();
//       controller.orders.add(mockOrder);

//       expect(controller.orders.length, equals(1));
//       expect(controller.orders.first, equals(mockOrder));
//     });

//     test('test_exception_rethrown_on_create_order_error', () async {
//       final testController = _TestOrderController();

//       expect(() async => await testController.createOrder(), throwsException);
//     });

//     test('test_multiple_rapid_create_order_calls_handled', () async {
//       final futures = <Future<void>>[];

//       for (int i = 0; i < 5; i++) {
//         futures.add(controller.createOrder());
//       }

//       await Future.wait(futures);

//       expect(controller.isLoading.value, isTrue);
//     });

//     test('test_loading_state_on_create_order_exception', () async {
//       final testController = _TestOrderController();

//       try {
//         await testController.createOrder();
//       } catch (e) {
//         // Exception expected
//       }

//       expect(testController.isLoading.value, isTrue);
//     });
//   });
// }

// class _TestOrderController extends OrderController {
//   @override
//   Future<void> createOrder() async {
//     try {
//       isLoading.value = true;
//       throw Exception('Test exception');
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
