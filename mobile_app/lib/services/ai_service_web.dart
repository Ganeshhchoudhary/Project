import '../models/trading_signal.dart';
import '../models/market_data.dart';

class AIService {
  static final AIService instance = AIService._init();
  bool _isInitialized = false;

  AIService._init();

  Future<void> initialize() async {
    // Web: TensorFlow Lite not supported; keep mock mode
    _isInitialized = false;
    print('AI Service running in web mock mode');
  }

  bool get isInitialized => _isInitialized;

  Future<TradingSignal> generateSignal(
    MarketData currentData,
    List<MarketData> historicalData,
  ) async {
    // Return a default hold signal for web
    return TradingSignal(
      action: TradingAction.hold,
      confidence: 0.5,
      riskScore: 0.5,
      explanation: 'AI model not available on web; running mock mode',
    );
  }

  void dispose() {}
}
