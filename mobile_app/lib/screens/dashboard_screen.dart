import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/market_data_provider.dart';
import '../providers/risk_assessment_provider.dart';
import '../providers/trading_provider.dart';
import '../widgets/market_data_card.dart';
import '../widgets/trading_signal_card.dart';
import '../widgets/risk_assessment_card.dart';
import '../widgets/price_chart.dart';
import 'trading_screen.dart';
import 'orders_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final marketProvider = context.read<MarketDataProvider>();
      final riskProvider = context.read<RiskAssessmentProvider>();
      final tradingProvider = context.read<TradingProvider>();
      
      // Start continuous updates
      riskProvider.startContinuousAssessment(
        marketProvider.symbol,
        marketProvider.currentData,
        marketProvider.historicalData,
      );
      tradingProvider.startSignalUpdates(
        marketProvider.currentData,
        marketProvider.historicalData,
      );
      
      // Initial assessments
      if (marketProvider.currentData != null) {
        riskProvider.assessRisk(
          marketProvider.currentData,
          marketProvider.historicalData,
        );
        tradingProvider.generateSignal(
          marketProvider.currentData,
          marketProvider.historicalData,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edge AI Trading'),
        actions: [
          Consumer<MarketDataProvider>(
            builder: (context, provider, _) {
              return Row(
                children: [
                  Icon(
                    provider.isConnected ? Icons.cloud_done : Icons.cloud_off,
                    color: provider.isConnected ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<MarketDataProvider>().refresh();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<MarketDataProvider>().refresh();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Market Data Card
              Consumer<MarketDataProvider>(
                builder: (context, provider, _) {
                  return MarketDataCard(
                    marketData: provider.currentData,
                    isLoading: provider.isLoading,
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // Price Chart
              Consumer<MarketDataProvider>(
                builder: (context, provider, _) {
                  return PriceChart(
                    historicalData: provider.historicalData,
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // Trading Signal Card
              Consumer<TradingProvider>(
                builder: (context, provider, _) {
                  return TradingSignalCard(
                    signal: provider.currentSignal,
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // Risk Assessment Card
              Consumer<RiskAssessmentProvider>(
                builder: (context, provider, _) {
                  return RiskAssessmentCard(
                    assessment: provider.currentAssessment,
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TradingScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.trade),
                      label: const Text('Trade'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OrdersScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.list),
                      label: const Text('Orders'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

