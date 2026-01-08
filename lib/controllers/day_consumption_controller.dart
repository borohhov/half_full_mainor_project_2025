import 'dart:async';

import '../models/consumption_history.dart';
import '../models/day_consumption.dart';
import '../providers/data_provider.dart';
import '../services/analytics_service.dart';
import 'profile_controller.dart';

class DayConsumptionController {
  DayConsumptionController({
    required ProfileController profileController,
    required DataProvider dataProvider,
    AnalyticsService? analyticsService,
  })  : _profileController = profileController,
        _dataProvider = dataProvider,
        _analytics = analyticsService,
        _history = ConsumptionHistory(days: []) {
    _profileController.addListener(_handleProfileUpdated);
  }

  final ProfileController _profileController;
  final DataProvider _dataProvider;
  final AnalyticsService? _analytics;
  final ConsumptionHistory _history;
  Future<void>? _initialization;

  Future<void> initialize() {
    _initialization ??= _loadHistory();
    return _initialization!;
  }

  Future<void> _loadHistory() async {
    final storedDays = await _dataProvider.fetchHistory();
    if (storedDays.isNotEmpty) {
      _history.replaceAll(storedDays);
    }
    _ensureTodayEntry();
    _clampToday();
    await _dataProvider.saveConsumption(_today);
  }

  void _handleProfileUpdated() {
    _ensureTodayEntry();
    _clampToday();
    unawaited(_dataProvider.saveConsumption(_today));
  }

  Future<void> addConsumption(double consumption) async {
    final today = _today;
    final bool wasBelowGoal = today.consumption < today.dayGoal;
    today.consumption += consumption;
    _clampToday();
    await _dataProvider.saveConsumption(today);
    _analytics?.trackEvent('water_added', properties: {
      'amount': consumption,
      'total': today.consumption,
      'goal': today.dayGoal,
      'date': today.dateTime.toIso8601String(),
    });
    if (wasBelowGoal && today.consumption >= today.dayGoal) {
      _analytics?.trackEvent('daily_goal_met', properties: {
        'goal': today.dayGoal,
        'date': today.dateTime.toIso8601String(),
      });
    }
  }

  double remainingToDrink() {
    final today = _today;
    if (today.consumption > today.dayGoal) {
      return 0;
    }
    return today.dayGoal - today.consumption;
  }

  DayConsumption getConsumption() {
    return _today;
  }

  List<DayConsumption> getHistory() {
    return _history.days;
  }

  void dispose() {
    _profileController.removeListener(_handleProfileUpdated);
  }

  DayConsumption _ensureTodayEntry() {
    return _history.ensureDay(
      DateTime.now(),
      goal: _profileController.dailyGoalInLiters(),
    );
  }

  DayConsumption get _today => _ensureTodayEntry();

  void _clampToday() {
    final today = _today;
    if (today.consumption > today.dayGoal) {
      today.consumption = today.dayGoal;
    }
  }
}
