import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class AnalyticsService {
  AnalyticsService({
    String? apiKey,
    String? host,
    Posthog? client,
  })  : _apiKey = apiKey ??
            const String.fromEnvironment('POSTHOG_API_KEY', defaultValue: ''),
        _host = host ??
            const String.fromEnvironment(
              'POSTHOG_HOST',
              defaultValue: 'https://us.i.posthog.com',
            ),
        _client = client ?? Posthog();

  final String _apiKey;
  final String _host;
  final Posthog _client;
  bool _initialized = false;

  bool get isEnabled => _apiKey.isNotEmpty;
  bool get isReady => _initialized;

  Future<void> initialize() async {
    if (_initialized || !isEnabled) {
      if (!isEnabled) {
        debugPrint(
          'AnalyticsService: POSTHOG_API_KEY unset. Analytics disabled.',
        );
      }
      return;
    }

    final config = PostHogConfig(_apiKey)
      ..host = _host
      ..flushAt = 1
      ..captureApplicationLifecycleEvents = true
      ..debug = kDebugMode
      ..sessionReplay = false;

    try {
      await _client.setup(config);
      _initialized = true;
    } catch (error, stackTrace) {
      debugPrint('AnalyticsService: Failed to initialize PostHog: $error');
      debugPrint(stackTrace.toString());
    }
  }

  void trackEvent(String eventName, {Map<String, Object?>? properties}) {
    if (!_initialized) {
      return;
    }
    unawaited(
      _client.capture(
        eventName: eventName,
        properties: _sanitizeProperties(properties),
      ),
    );
  }

  void identifyUser({
    required String userId,
    Map<String, Object?>? userProperties,
  }) {
    if (!_initialized) {
      return;
    }
    unawaited(
      _client.identify(
        userId: userId,
        userProperties: _sanitizeProperties(userProperties),
      ),
    );
  }

  Map<String, Object>? _sanitizeProperties(Map<String, Object?>? properties) {
    if (properties == null) {
      return null;
    }
    final filtered = <String, Object>{};
    properties.forEach((key, value) {
      if (value == null) return;
      if (value is num ||
          value is String ||
          value is bool ||
          value is Map ||
          value is List) {
        filtered[key] = value;
      } else {
        filtered[key] = value.toString();
      }
    });
    return filtered;
  }
}
