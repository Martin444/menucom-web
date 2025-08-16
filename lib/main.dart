import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/core/api.dart';
import 'package:menucom_catalog/core/config.dart';
import 'package:menucom_catalog/routes/pages.dart';
import 'package:menucom_catalog/routes/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await inicialiceServiceMenucomAPi();
  runApp(const MyApp());
}

Future<void> inicialiceServiceMenucomAPi() async {
  try {
    API.getInstance(URL_PICKME_API);

    // Inicializar Anonymous ID de forma opcional (no bloqueante)
    // Esto asegura que el ID esté listo antes de la primera request
    API.getCurrentAnonymousId().catchError((e) {
      // No hacer nada si falla, se generará automáticamente en la primera request
      return '';
    });
  } catch (e) {
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Menu com',
      theme: ThemeData(
        useMaterial3: false,
      ),
      getPages: PUPages.pagesRoutes,
      textDirection: TextDirection.ltr,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      initialRoute: PURoutes.HOME,
      // home: const HomePage(),
      supportedLocales: const [
        Locale('en'), // Inglés
        Locale('es'), // españól
      ],
    );
  }
}
