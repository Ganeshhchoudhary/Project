import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/trading_signal.dart';
import '../models/market_data.dart';
import 'database_service.dart';

class AIService {
  static final AIService instance = AIService._init();
  Interpreter? _interpreter;
  bool _isInitialized = false;

  AIService._init();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final modelPath = 'assets/models/trading_model_quantized.tflite';

      if (Platform.isAndroid || Platform.isIOS ||
          Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        try {
          _interpreter = await Interpreter.fromAsset(modelPath);
          _isInitialized = true;
          print('AI Service initialized successfully');
        } catch (e) {
          print('Model file not found or error loading: $e');
          print('AI Service will continue without model (mock mode)');
          _isInitialized = false;
        }
      } else {
        print('AI Service: TensorFlow Lite not supported on this platform');
        _isInitialized = false;
      }
    } catch (e) {
      print('Error initializing AI Service: $e');
      _isInitialized = false;
    }
  }

  bool get isInitialized => _isInitialized;

  Future<TradingSignal> generateSignal(
    MarketData currentData,
    List<MarketData> historicalData,
  ) async {
    if (!_isInitialized || _interpreter == null) {
      return TradingSignal(
        action: TradingAction.hold,
        confidence: 0.5,
        riskScore: 0.5,
        explanation: 'AI model not initialized',
      );
    }

    try {
      final features = _prepareFeatures(currentData, historicalData);
      final input = [features];
      final output = List.generate(3, (index) => 0.0);
      _interpreter!.run(input, output);

      final probabilities = output;
      final maxProb = probabilities.reduce((a, b) => a > b ? a : b);
      final actionIndex = probabilities.indexOf(maxProb);

      final action = actionIndex == 0
          ? TradingAction.buy
          : actionIndex == 1
              ? TradingAction.hold
              : TradingAction.sell;

      final confidence = probabilities[actionIndex];
      final riskScore = _calculateRiskScore(currentData, historicalData);
      final explanation = _generateExplanation(
        action,
        confidence,
        riskScore,
        currentData,
        historicalData,
      );

      return TradingSignal(
        action: action,
        confidence: confidence,
        riskScore: riskScore,
        explanation: explanation,
        contributingFactors: _getContributingFactors(currentData, historicalData),
      );
    } catch (e) {
      print('Error generating signal: $e');
      return TradingSignal(
        action: TradingAction.hold,
        confidence: 0.0,
        riskScore: 0.5,
        explanation: 'Error in AI inference: $e',
      );
    }
  }

  List<List<double>> _prepareFeatures(
    MarketData currentData,
    List<MarketData> historicalData,
  ) {
    final allData = [currentData, ...historicalData.reversed].take(60).toList();
    final features = <List<double>>[];
    for (var data in allData) {
      features.add([
        data.open,
        data.high,
        data.low,
        data.close,
        data.volume.toDouble(),
        _calculateRSI(allData, allData.indexOf(data)),
        _calculateMACD(allData, allData.indexOf(data)),
        0.0,
        _calculateBollingerUpper(allData, allData.indexOf(data)),
        _calculateBollingerMiddle(allData, allData.indexOf(data)),
        _calculateBollingerLower(allData, allData.indexOf(data)),
        _calculateSMA(allData, allData.indexOf(data), 20),
        _calculateSMA(allData, allData.indexOf(data), 50),
        _calculateVolatility(allData, allData.indexOf(data)),
        _calculateVolumeRatio(allData, allData.indexOf(data)),
        _calculatePriceChange(allData, allData.indexOf(data)),
        data.high / data.low,
      ]);
    }
    while (features.length < 60) {
      features.insert(0, features.first);
    }
    return features.take(60).toList();
  }

  double _calculateRSI(List<MarketData> data, int index) {
    if (index < 14) return 50.0;
    final prices = data.sublist(index - 14, index + 1).map((d) => d.close).toList();
    double gain = 0, loss = 0;
    for (int i = 1; i < prices.length; i++) {
      final change = prices[i] - prices[i - 1];
      if (change > 0) gain += change;
      else loss -= change;
    }
    final rs = gain / loss;
    return 100 - (100 / (1 + rs));
  }

  double _calculateMACD(List<MarketData> data, int index) {
    if (index < 26) return 0.0;
    final prices = data.sublist(index - 26, index + 1).map((d) => d.close).toList();
    final ema12 = _calculateEMA(prices, 12);
    final ema26 = _calculateEMA(prices, 26);
    return ema12 - ema26;
  }

  double _calculateEMA(List<double> prices, int period) {
    double ema = prices.first;
    final multiplier = 2.0 / (period + 1);
    for (var price in prices.skip(1)) {
      ema = (price * multiplier) + (ema * (1 - multiplier));
    }
    return ema;
  }

  double _calculateSMA(List<MarketData> data, int index, int period) {
    if (index < period) return data[index].close;
    final prices = data.sublist(index - period, index + 1).map((d) => d.close);
    return prices.reduce((a, b) => a + b) / period;
  }

  double _calculateBollingerUpper(List<MarketData> data, int index) {
    final sma = _calculateSMA(data, index, 20);
    return sma + (2 * _calculateStdDev(data, index, 20));
  }

  double _calculateBollingerMiddle(List<MarketData> data, int index) {
    return _calculateSMA(data, index, 20);
  }

  double _calculateBollingerLower(List<MarketData> data, int index) {
    final sma = _calculateSMA(data, index, 20);
    return sma - (2 * _calculateStdDev(data, index, 20));
  }

  double _calculateStdDev(List<MarketData> data, int index, int period) {
    if (index < period) return 0.0;
    final prices = data.sublist(index - period, index + 1).map((d) => d.close).toList();
    final mean = prices.reduce((a, b) => a + b) / period;
    final variance = prices.map((p) => (p - mean) * (p - mean)).reduce((a, b) => a + b) / period;
    return variance;
  }

  double _calculateVolatility(List<MarketData> data, int index) {
    if (index < 20) return 0.0;
    final returns = <double>[];
    for (int i = index - 19; i <= index; i++) {
      if (i > 0) {
        returns.add((data[i].close - data[i - 1].close) / data[i - 1].close);
      }
    }
    if (returns.isEmpty) return 0.0;
    final mean = returns.reduce((a, b) => a + b) / returns.length;
    final variance = returns.map((r) => (r - mean) * (r - mean)).reduce((a, b) => a + b) / returns.length;
    return variance;
  }

  double _calculateVolumeRatio(List<MarketData> data, int index) {
    if (index < 20) return 1.0;
    final avgVolume = data.sublist(index - 19, index + 1)
        .map((d) => d.volume)
        .reduce((a, b) => a + b) / 20;
    return data[index].volume / avgVolume;
  }

  double _calculatePriceChange(List<MarketData> data, int index) {
    if (index == 0) return 0.0;
    return (data[index].close - data[index - 1].close) / data[index - 1].close;
  }

  double _calculateRiskScore(MarketData current, List<MarketData> historical) {
    double riskScore = 0.0;
    final volatility = _calculateVolatility([current, ...historical], 0);
    riskScore += (volatility * 0.4).clamp(0.0, 0.4);
    if (historical.isNotEmpty) {
      final priceChange = (current.close - historical.first.close) / historical.first.close;
      riskScore += (priceChange.abs() * 0.3).clamp(0.0, 0.3);
    }
    final volumeRatio = _calculateVolumeRatio([current, ...historical], 0);
    riskScore += ((volumeRatio > 2.0 ? 0.3 : 0.0) * 0.3).clamp(0.0, 0.3);
    return riskScore.clamp(0.0, 1.0);
  }

  Map<String, dynamic> _getContributingFactors(
    MarketData current,
    List<MarketData> historical,
  ) {
    return {
      'rsi': _calculateRSI([current, ...historical], 0),
      'macd': _calculateMACD([current, ...historical], 0),
      'volatility': _calculateVolatility([current, ...historical], 0),
      'volume_ratio': _calculateVolumeRatio([current, ...historical], 0),
      'price_change': current.changePercent,
    };
  }

  String _generateExplanation(
    TradingAction action,
    double confidence,
    double riskScore,
    MarketData current,
    List<MarketData> historical,
  ) {
    final factors = _getContributingFactors(current, historical);
    final actionStr = action == TradingAction.buy
        ? 'Buy'
        : action == TradingAction.sell
            ? 'Sell'
            : 'Hold';
    final explanations = <String>[];
    explanations.add('AI recommends $actionStr with ${(confidence * 100).toStringAsFixed(1)}% confidence.');
    if (factors['rsi'] > 70) {
      explanations.add('RSI indicates overbought conditions.');
    } else if (factors['rsi'] < 30) {
      explanations.add('RSI indicates oversold conditions.');
    }
    if (factors['macd'] > 0) {
      explanations.add('MACD shows bullish momentum.');
    } else {
      explanations.add('MACD shows bearish momentum.');
    }
    if (riskScore > 0.7) {
      explanations.add('High risk detected - consider position sizing.');
    } else if (riskScore < 0.3) {
      explanations.add('Low risk environment.');
    }
    return explanations.join(' ');
  }

  void dispose() {
    _interpreter?.close();
    _isInitialized = false;
  }
}
