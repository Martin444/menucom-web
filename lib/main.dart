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
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:menucom_catalog/core/services/google_auth_service.dart';
import 'package:menucom_catalog/core/analytics_service.dart';

void main() async {
  // debugPrint no funciona si Flutter binding no está. Usamos print directo.
  print('[MAIN] main() started - before ensureInitialized');
  
  WidgetsFlutterBinding.ensureInitialized();

  print('[MAIN] WidgetsBinding ensured');
  
  try {
    if (Firebase.apps.isEmpty) {
      print('[MAIN] Firebase.initializeApp()...');
      await Firebase.initializeApp(options: FirebaseConfig.currentPlatform);
      print('[MAIN] Firebase.initializeApp() OK');
    } else {
      Firebase.app();
      print('[MAIN] Firebase.app() OK');
    }
  } catch (e, s) {
    print('[MAIN] Firebase ERROR: $e\n$s');
  }

  debugPrint('[MAIN] AnalyticsService init...');
  AnalyticsService().init();
  
  debugPrint('[MAIN] inicialiceServiceMenucomAPi...');
  await inicialiceServiceMenucomAPi();

  debugPrint('[MAIN] runApp...');
  runApp(const MyApp());

  try {
    // ignore: unawaited_futures
    GoogleAuthService().signInSilently();
  } catch (_) {}
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



class _AnalyticsLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        AnalyticsService().logAppResumed();
        break;
      case AppLifecycleState.paused:
        AnalyticsService().logAppBackground();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _lifecycleObserver = _AnalyticsLifecycleObserver();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService().logAppOpen();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

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
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
    );
  }
}
