import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/core/api.dart';
import 'package:menucom_catalog/core/config.dart';
import 'package:menucom_catalog/core/firebase_config.dart';
import 'package:menucom_catalog/routes/pages.dart';
import 'package:menucom_catalog/routes/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pu_material/pu_material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:menucom_catalog/core/services/google_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: FirebaseConfig.currentPlatform);
  } else {
    // Si ya existe, usamos la instancia actual
    Firebase.app();
  }
  
  await inicialiceServiceMenucomAPi();
  runApp(const MyApp());

  // Intentar restaurar sesión de forma silenciosa en segundo plano
  // (útil para persistir login tras recargas en Flutter Web)
  try {
    // ignore: unawaited_futures
    GoogleAuthService().signInSilently();
  } catch (_) {
    // Silencioso, no bloqueamos el inicio de la app
  }
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
        useMaterial3: true,
        primaryColor: PUColors.primaryColor,
        scaffoldBackgroundColor: PUColors.primaryBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: PUColors.primaryColor,
          primary: PUColors.primaryColor,
          secondary: PUColors.accentColor,
          surface: Colors.white,
          error: PUColors.bgError,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.jostTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: PUColors.iconColorBlack),
        ),
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
