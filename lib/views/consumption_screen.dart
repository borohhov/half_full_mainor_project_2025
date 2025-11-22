import 'package:flutter/material.dart';
import 'package:half_full/utils/conversion.dart';
import '../controllers/day_consumption_controller.dart';
import 'bottle_view/water_bottle.dart';

class ConsumptionScreen extends StatefulWidget {
  const ConsumptionScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return ConsumptionScreenState();
  }
}

class ConsumptionScreenState extends State<ConsumptionScreen> {
  DayConsumptionController controller = DayConsumptionController();
  final GlobalKey<WaterBottleState> _bottleKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Half Full"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            WaterBottle(
              key: _bottleKey,
              width: 120,
              height: 260,
            ),
            Text(formatNumberToLiter(controller.getConsumption().consumption)),
            Text("Remaining to drink for the day:"),
            Text(formatNumberToLiter(controller.remainingToDrink())),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        double bottleLevel = 0.25 / controller.remainingToDrink();
                        controller.addConsumption(0.25);
                        _bottleKey.currentState?.addWater(bottleLevel);
                      });
                    },
                    child: Text("Add ${formatNumberToLiter(0.25)}")),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        double bottleLevel = 0.5 / controller.remainingToDrink();
                        controller.addConsumption(0.5);
                        _bottleKey.currentState?.addWater(bottleLevel);
                      });
                    },
                    child: Text("Add ${formatNumberToLiter(0.5)}"))
              ],
            )
          ],
        ),
      ),
    );
  }
}
