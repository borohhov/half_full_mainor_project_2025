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

  void _handleAdd(double amount) {
    setState(() {
      final remaining = controller.remainingToDrink();
      if (remaining == 0) {
        return;
      }
      final bottleLevel = amount / remaining;
      controller.addConsumption(amount);
      _bottleKey.currentState?.addWater(bottleLevel);
    });
  }

  Widget _buildAddButton(double amount) {
    return ElevatedButton(
      onPressed: () => _handleAdd(amount),
      child: Text("Add ${formatNumberToLiter(amount)}"),
    );
  }

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
                _buildAddButton(0.25),
                _buildAddButton(0.5)
              ],
            )
          ],
        ),
      ),
    );
  }
}
