class Profile {
  int weightInKg;
  int heightInCm;
  Gender gender;
  Climate climate;

  Profile({
    required this.weightInKg,
    required this.heightInCm,
    required this.gender,
    required this.climate,
  });

  Profile copyWith({
    int? weightInKg,
    int? heightInCm,
    Gender? gender,
    Climate? climate,
  }) {
    return Profile(
      weightInKg: weightInKg ?? this.weightInKg,
      heightInCm: heightInCm ?? this.heightInCm,
      gender: gender ?? this.gender,
      climate: climate ?? this.climate,
    );
  }

  double dailyGoalInLiters() {
    final base = weightInKg * 0.033;
    final genderAdjustment = gender == Gender.male ? 0.2 : 0.0;
    final heightAdjustment = heightInCm > 185
        ? 0.15
        : heightInCm < 160
            ? -0.1
            : 0.0;
    final climateAdjustment = switch (climate) {
      Climate.cold => -0.15,
      Climate.temperate => 0.0,
      Climate.hot => 0.25,
    };

    final result = base + genderAdjustment + heightAdjustment + climateAdjustment;
    if (result < 1.5) {
      return 1.5;
    }
    return double.parse(result.toStringAsFixed(2));
  }
}

enum Gender {
  male, female;
}

enum Climate {
  cold, temperate, hot
}
