import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/core/api.dart';
import 'package:menucom_catalog/core/config.dart';
import 'package:menucom_catalog/routes/pages.dart';
import 'package:menucom_catalog/routes/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  inicialiceServiceMenucomAPi();
  runApp(const MyApp());
}

void inicialiceServiceMenucomAPi() {
  try {
    API.getInstance(URL_PICKME_API);
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
