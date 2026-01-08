import 'package:flutter/foundation.dart';

import '../models/profile.dart';
import '../providers/data_provider.dart';
import '../services/analytics_service.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({
    required DataProvider dataProvider,
    AnalyticsService? analyticsService,
  })  : _dataProvider = dataProvider,
        _analytics = analyticsService {
    _loadProfile();
  }

  final DataProvider _dataProvider;
  final AnalyticsService? _analytics;

  Profile _profile = Profile(
    weightInKg: 70,
    heightInCm: 175,
    gender: Gender.male,
    climate: Climate.temperate,
  );

  bool _isLoading = true;

  Profile get profile => _profile;

  bool get isLoading => _isLoading;

  Future<void> _loadProfile() async {
    try {
      final storedProfile = await _dataProvider.fetchProfile();
      if (storedProfile != null) {
        _profile = storedProfile;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveProfile({
    required int weightInKg,
    required int heightInCm,
    required Gender gender,
    required Climate climate,
  }) async {
    _profile = Profile(
      weightInKg: weightInKg,
      heightInCm: heightInCm,
      gender: gender,
      climate: climate,
    );
    notifyListeners();
    await _dataProvider.saveProfile(_profile);
    _analytics?.trackEvent('profile_saved', properties: {
      'weightKg': weightInKg,
      'heightCm': heightInCm,
      'gender': gender.name,
      'climate': climate.name,
    });
  }

  double dailyGoalInLiters() => _profile.dailyGoalInLiters();
}
