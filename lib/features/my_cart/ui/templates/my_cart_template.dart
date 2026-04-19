// Level: Template
// Description: Estructura de la página de carrito con secciones para cabecera, lista y resumen de orden.
import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';

class MyCartTemplate extends StatelessWidget {
  final Widget header;
  final Widget cartList;
  final Widget orderSummary;

  const MyCartTemplate({
    super.key,
    required this.header,
    required this.cartList,
    required this.orderSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PUColors.primaryBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          Expanded(child: cartList),
          orderSummary,
        ],
      ),
    );
  }
}
