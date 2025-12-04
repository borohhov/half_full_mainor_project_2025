import '../models/day_consumption.dart';
import 'profile_controller.dart';

class DayConsumptionController {
  DayConsumptionController({ProfileController? profileController})
      : this._(profileController ?? ProfileController());

  DayConsumptionController._(this._profileController)
      : _consumption = DayConsumption(
          DateTime.now(),
          0,
          _profileController.dailyGoalInLiters(),
        ) {
    _profileController.addListener(_handleProfileUpdated);
  }

  final ProfileController _profileController;
  final DayConsumption _consumption;

  void _handleProfileUpdated() {
    _consumption.dayGoal = _profileController.dailyGoalInLiters();
    if (_consumption.consumption > _consumption.dayGoal) {
      _consumption.consumption = _consumption.dayGoal;
    }
  }

  void addConsumption(double consumption) {
    _consumption.consumption += consumption;
  }

  double remainingToDrink() {
    if (_consumption.consumption > _consumption.dayGoal) {
      return 0;
    }
    return _consumption.dayGoal - _consumption.consumption;
  }

  DayConsumption getConsumption() {
    return _consumption;
  }

  void dispose() {
    _profileController.removeListener(_handleProfileUpdated);
  }
}
