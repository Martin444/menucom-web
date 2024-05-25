import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickme_up_web/core/injection_bindings.dart';
import 'package:pickme_up_web/features/home/presentation/page/home_page.dart';
import 'package:pickme_up_web/routes/pages.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pickme Up',
      theme: ThemeData(
        useMaterial3: false,
      ),
      getPages: PUPages.pagesRoutes,
      textDirection: TextDirection.ltr,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // home: const HomePage(),
      supportedLocales: const [
        Locale('en'), // Inglés
        Locale('es'), // españól
      ],
      initialBinding: MainBindings(),
    );
  }
}
