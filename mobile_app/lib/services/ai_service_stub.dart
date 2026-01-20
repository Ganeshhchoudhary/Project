import '../models/trading_signal.dart';
import '../models/market_data.dart';

/// Web stub for AIService. Flutter Web does not support Dart FFI,
/// so tflite_flutter cannot be used. This stub provides the same
/// API surface but returns mock responses or throws informative
/// errors when methods requiring native inference are called.

class AIService {
  static final AIService instance = AIService._init();
  bool _isInitialized = false;

  AIService._init();

  Future<void> initialize() async {
    _isInitialized = false;
    // No-op on web; model inference is unsupported.
    print('AIService (web stub): initialization skipped — tflite not supported on web');
  }

  bool get isInitialized => _isInitialized;

  Future<TradingSignal> generateSignal(
    MarketData currentData,
    List<MarketData> historicalData,
  ) async {
    // Return a conservative default signal on web.
    return TradingSignal(
      action: TradingAction.hold,
      confidence: 0.5,
      riskScore: 0.5,
      explanation: 'ML inference not available on web; running in stub mode',
    );
  }

  void dispose() {
    _isInitialized = false;
  }
}
