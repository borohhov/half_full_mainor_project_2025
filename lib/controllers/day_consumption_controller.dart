import '../models/day_consumption.dart';

DayConsumption exampleDayConsumption = DayConsumption(DateTime.now(), 0, 2);

class DayConsumptionController {
  void addConsumption(double consumption) {
    exampleDayConsumption.consumption += consumption;
  }

  double remainingToDrink() {
    if(exampleDayConsumption.consumption > exampleDayConsumption.dayGoal) {
      return 0;
    }
    else {
      return exampleDayConsumption.dayGoal - exampleDayConsumption.consumption;
    }
  }

  DayConsumption getConsumption() {
    return exampleDayConsumption;
  }
}