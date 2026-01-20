import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/trading_provider.dart';
import 'providers/market_data_provider.dart';
import 'providers/risk_assessment_provider.dart';
import 'screens/dashboard_screen.dart';
import 'services/database_service.dart';
import 'services/ai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive (skip on web)
  try {
    await Hive.initFlutter();
  } catch (e) {
    // Hive not supported on web, continue without it
    print('Hive initialization skipped: $e');
  }
  
  // Initialize database (skip on web - SQLite not supported)
  try {
    await DatabaseService.instance.database;
  } catch (e) {
    print('Database not available (web platform): $e');
    print('App will continue without persistent storage');
  }
  
  // Initialize AI service
  try {
    await AIService.instance.initialize();
  } catch (e) {
    print('AI Service initialization error: $e');
  }
  
  // Set preferred orientations (skip on web)
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e) {
    // Not supported on web
    print('Orientation setting skipped: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MarketDataProvider()),
        ChangeNotifierProvider(create: (_) => RiskAssessmentProvider()),
        ChangeNotifierProvider(create: (_) => TradingProvider()),
      ],
      child: MaterialApp(
        title: 'Edge AI Trading',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}

