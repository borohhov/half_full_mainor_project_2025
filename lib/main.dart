import 'package:flutter/material.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'controllers/profile_controller.dart';
import 'providers/data_provider.dart';
import 'providers/firestore_data_provider.dart';
import 'services/analytics_service.dart';
import 'views/consumption_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final DataProvider dataProvider = FirestoreDataProvider();
  await dataProvider.initialize();
  final AnalyticsService analyticsService = AnalyticsService();
  await analyticsService.initialize();
  runApp(
    MultiProvider(
      providers: [
        Provider<DataProvider>.value(value: dataProvider),
        Provider<AnalyticsService>.value(value: analyticsService),
        ChangeNotifierProvider<ProfileController>(
          create: (_) => ProfileController(
            dataProvider: dataProvider,
            analyticsService:
                analyticsService.isReady ? analyticsService : null,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = Provider.of<AnalyticsService>(context, listen: false);
    final app = MaterialApp(
      navigatorObservers: analytics.isReady ? [PosthogObserver()] : const [],
      title: 'Half Full',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ConsumptionScreen(),
    );
    if (analytics.isReady) {
      return PostHogWidget(child: app);
    }
    return app;
  }
}
