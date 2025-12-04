import 'package:flutter/foundation.dart';

import '../models/profile.dart';

class ProfileController extends ChangeNotifier {
  ProfileController._internal();
  static final ProfileController _instance = ProfileController._internal();

  factory ProfileController() {
    return _instance;
  }

  Profile _profile = Profile(
    weightInKg: 70,
    heightInCm: 175,
    gender: Gender.male,
    climate: Climate.temperate,
  );

  Profile get profile => _profile;

  void saveProfile({
    required int weightInKg,
    required int heightInCm,
    required Gender gender,
    required Climate climate,
  }) {
    _profile = Profile(
      weightInKg: weightInKg,
      heightInCm: heightInCm,
      gender: gender,
      climate: climate,
    );
    notifyListeners();
  }

  double dailyGoalInLiters() => _profile.dailyGoalInLiters();
}
