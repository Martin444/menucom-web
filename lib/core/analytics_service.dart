import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:menucom_catalog/core/analytics_events.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;
  AnalyticsService._();

  FirebaseAnalytics? _analytics;
  bool _initialized = false;

  void init() {
    try {
      _analytics = FirebaseAnalytics.instance;
      _analytics?.setAnalyticsCollectionEnabled(true);
      _initialized = true;
      debugPrint('[Analytics] Firebase Analytics initialized');
    } catch (e) {
      debugPrint('[Analytics] Error initializing: $e');
    }
  }

  FirebaseAnalytics? get instance => _analytics;

  // ── Eventos genéricos ──

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (!_initialized) return;
    try {
      await _analytics?.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('[Analytics] Error logging event "$name": $e');
    }
  }

  // ── Auth (GA4 standard) ──

  Future<void> logLogin({String method = 'google'}) async {
    if (!_initialized) return;
    try {
      await _analytics?.logLogin(loginMethod: method);
    } catch (e) {
      debugPrint('[Analytics] Error logging login: $e');
    }
  }

  Future<void> logSignUp({String method = 'google'}) async {
    if (!_initialized) return;
    try {
      await _analytics?.logSignUp(signUpMethod: method);
    } catch (e) {
      debugPrint('[Analytics] Error logging signUp: $e');
    }
  }

  Future<void> logLogout() async {
    if (!_initialized) return;
    try {
      await _analytics?.logEvent(name: AnalyticsEvents.logout);
    } catch (e) {
      debugPrint('[Analytics] Error logging logout: $e');
    }
  }

  // ── Session tracking ──

  Future<void> logAppOpen() async {
    if (!_initialized) return;
    try {
      await _analytics?.logAppOpen();
    } catch (e) {
      debugPrint('[Analytics] Error logging app_open: $e');
    }
  }

  Future<void> logAppBackground() async {
    await logEvent(name: AnalyticsEvents.appBackground);
  }

  Future<void> logAppResumed() async {
    await logEvent(name: AnalyticsEvents.appResumed);
  }

  // ── Screens ──

  Future<void> logScreen({required String screenName, String? screenClass}) async {
    if (!_initialized) return;
    try {
      await _analytics?.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
    } catch (e) {
      debugPrint('[Analytics] Error logging screen "$screenName": $e');
    }
  }

  // ── User identity ──

  Future<void> setUserId(String? id) async {
    if (!_initialized) return;
    try {
      await _analytics?.setUserId(id: id);
    } catch (e) {
      debugPrint('[Analytics] Error setting userId: $e');
    }
  }

  // ── Errores ──

  Future<void> logError(String error, {String? context, String? stackTrace}) async {
    if (!_initialized) return;
    try {
      final params = <String, Object>{
        AnalyticsParams.error: error,
        if (context != null) AnalyticsParams.context: context,
        if (stackTrace != null) AnalyticsParams.stackTrace: stackTrace,
      };
      await _analytics?.logEvent(name: AnalyticsEvents.appError, parameters: params);
    } catch (e) {
      debugPrint('[Analytics] Error logging error: $e');
    }
  }

  Future<void> logErrorWithException(
    dynamic exception, {
    String? context,
    StackTrace? stackTrace,
  }) async {
    if (!_initialized) return;
    final message = _extractMessage(exception);
    await logError(message, context: context, stackTrace: stackTrace?.toString());
  }

  String _extractMessage(dynamic error) {
    if (error is Exception && error.toString().startsWith('Exception: ')) {
      return error.toString().substring(11);
    }
    return error.toString();
  }
}
