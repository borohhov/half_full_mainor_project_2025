import 'package:flutter/material.dart';
import 'package:half_full/utils/conversion.dart';
import 'package:provider/provider.dart';
import '../controllers/day_consumption_controller.dart';
import '../controllers/profile_controller.dart';
import '../providers/data_provider.dart';
import '../services/analytics_service.dart';
import 'bottle_view/water_bottle.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class ConsumptionScreen extends StatefulWidget {
  const ConsumptionScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return ConsumptionScreenState();
  }
}

class ConsumptionScreenState extends State<ConsumptionScreen> {
  late DayConsumptionController _controller;
  final GlobalKey<WaterBottleState> _bottleKey = GlobalKey();
  ProfileController? _profileController;
  AnalyticsService? _analytics;
  bool _initialized = false;
  bool _historyLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final profileController =
        Provider.of<ProfileController>(context, listen: false)
          ..addListener(_handleProfileChange);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    _analytics = Provider.of<AnalyticsService>(context, listen: false);
    _profileController = profileController;
    _controller = DayConsumptionController(
      profileController: profileController,
      dataProvider: dataProvider,
      analyticsService: _analytics?.isReady == true ? _analytics : null,
    );
    _initialized = true;
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _historyLoaded = true;
      });
      _handleProfileChange();
    });
  }

  @override
  void dispose() {
    _profileController?.removeListener(_handleProfileChange);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleAdd(double amount) async {
    final remaining = _controller.remainingToDrink();
    if (remaining == 0) {
      return;
    }
    final bottleLevel = amount / remaining;
    await _controller.addConsumption(amount);
    _bottleKey.currentState?.addWater(bottleLevel);
    if (!mounted) return;
    setState(() {});
  }

  void _handleProfileChange() {
    final consumption = _controller.getConsumption();
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

  Future<void> _openHistory() async {
    _analytics?.trackEvent('history_opened', properties: {
      'entries': _controller.getHistory().length,
    });
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HistoryScreen(history: _controller.getHistory()),
      ),
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
      body: _historyLoaded
          ? Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  WaterBottle(
                    key: _bottleKey,
                    width: 120,
                    height: 260,
                  ),
                  Text(formatNumberToLiter(
                      _controller.getConsumption().consumption)),
                  const Text("Remaining to drink for the day:"),
                  Text(formatNumberToLiter(_controller.remainingToDrink())),
                  Text(
                    "Today's goal: ${formatNumberToLiter(_controller.getConsumption().dayGoal)}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [_buildAddButton(0.25), _buildAddButton(0.5)],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _historyLoaded ? _openHistory : null,
                    icon: const Icon(Icons.history_toggle_off),
                    label: const Text('View history'),
                  )
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
