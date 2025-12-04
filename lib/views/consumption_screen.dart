import 'package:flutter/material.dart';
import 'package:half_full/utils/conversion.dart';
import '../controllers/day_consumption_controller.dart';
import '../controllers/profile_controller.dart';
import 'bottle_view/water_bottle.dart';
import 'profile_screen.dart';

class ConsumptionScreen extends StatefulWidget {
  const ConsumptionScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return ConsumptionScreenState();
  }
}

class ConsumptionScreenState extends State<ConsumptionScreen> {
  late final DayConsumptionController controller;
  final ProfileController _profileController = ProfileController();
  final GlobalKey<WaterBottleState> _bottleKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = DayConsumptionController(profileController: _profileController);
    _profileController.addListener(_handleProfileChange);
  }

  @override
  void dispose() {
    _profileController.removeListener(_handleProfileChange);
    controller.dispose();
    super.dispose();
  }

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

  void _handleProfileChange() {
    final consumption = controller.getConsumption();
    final ratio = consumption.dayGoal == 0
        ? 0.0
        : consumption.consumption / consumption.dayGoal;
    _bottleKey.currentState?.setLevel(ratio);
    setState(() {});
  }

  Future<void> _openProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
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
        actions: [
          IconButton(
            onPressed: _openProfile,
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
          )
        ],
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
            Text(
              "Today's goal: ${formatNumberToLiter(controller.getConsumption().dayGoal)}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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
