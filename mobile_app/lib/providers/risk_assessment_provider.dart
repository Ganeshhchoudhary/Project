import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/market_data.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart';

enum RiskLevel { low, medium, high, critical }

class RiskAssessment {
  final double score; // 0.0 to 1.0
  final RiskLevel level;
  final Map<String, dynamic> factors;
  final String explanation;
  final DateTime timestamp;

  RiskAssessment({
    required this.score,
    required this.level,
    required this.factors,
    required this.explanation,
    required this.timestamp,
  });

  String get levelString {
    switch (level) {
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.medium:
        return 'Medium';
      case RiskLevel.high:
        return 'High';
      case RiskLevel.critical:
        return 'Critical';
    }
  }
}

class RiskAssessmentProvider with ChangeNotifier {
  RiskAssessment? _currentAssessment;
  List<RiskAssessment> _history = [];
  bool _isAssessing = false;
  Timer? _assessmentTimer;
  String _symbol = 'AAPL';

  RiskAssessment? get currentAssessment => _currentAssessment;
  List<RiskAssessment> get history => _history;
  bool get isAssessing => _isAssessing;

  Future<void> assessRisk(MarketData? currentData, List<MarketData> historicalData) async {
    if (currentData == null || historicalData.isEmpty) return;

    _isAssessing = true;
    notifyListeners();

    try {
      // Use AI service for risk assessment
      final signal = await AIService.instance.generateSignal(currentData, historicalData);
      
      final riskLevel = _calculateRiskLevel(signal.riskScore);
      final factors = _calculateRiskFactors(currentData, historicalData);
      final explanation = _generateRiskExplanation(riskLevel, factors);

      _currentAssessment = RiskAssessment(
        score: signal.riskScore,
        level: riskLevel,
        factors: factors,
        explanation: explanation,
        timestamp: DateTime.now(),
      );

      // Save to history
      await DatabaseService.instance.insertRiskHistory(
        _symbol,
        signal.riskScore,
        riskLevel.levelString,
        factors,
      );

      _history.insert(0, _currentAssessment!);
      if (_history.length > 50) {
        _history = _history.take(50).toList();
      }

      _isAssessing = false;
      notifyListeners();
    } catch (e) {
      print('Error assessing risk: $e');
      _isAssessing = false;
      notifyListeners();
    }
  }

  RiskLevel _calculateRiskLevel(double score) {
    if (score < 0.3) return RiskLevel.low;
    if (score < 0.5) return RiskLevel.medium;
    if (score < 0.7) return RiskLevel.high;
    return RiskLevel.critical;
  }

  Map<String, dynamic> _calculateRiskFactors(MarketData current, List<MarketData> historical) {
    final factors = <String, dynamic>{};

    // Volatility
    if (historical.length >= 20) {
      final returns = <double>[];
      for (int i = 1; i < historical.length && i < 20; i++) {
        if (historical[i].close > 0 && historical[i - 1].close > 0) {
          returns.add((historical[i].close - historical[i - 1].close) / historical[i - 1].close);
        }
      }
      if (returns.isNotEmpty) {
        final mean = returns.reduce((a, b) => a + b) / returns.length;
        final variance = returns.map((r) => (r - mean) * (r - mean)).reduce((a, b) => a + b) / returns.length;
        final volatility = variance;
        factors['volatility'] = volatility;
      }
    }

    // Price movement
    if (historical.isNotEmpty) {
      final priceChange = (current.close - historical.first.close) / historical.first.close;
      factors['price_change'] = priceChange;
    }

    // Volume
    if (historical.length >= 20) {
      final avgVolume = historical.take(20).map((d) => d.volume).reduce((a, b) => a + b) / 20;
      factors['volume_ratio'] = current.volume / avgVolume;
    }

    // Market momentum
    factors['momentum'] = current.changePercent ?? 0.0;

    return factors;
  }

  String _generateRiskExplanation(RiskLevel level, Map<String, dynamic> factors) {
    final explanations = <String>[];
    
    explanations.add('Risk Level: ${level.levelString}');

    if (factors['volatility'] != null) {
      final vol = factors['volatility'] as double;
      if (vol > 0.05) {
        explanations.add('High volatility detected (${(vol * 100).toStringAsFixed(2)}%).');
      } else if (vol < 0.01) {
        explanations.add('Low volatility environment.');
      }
    }

    if (factors['volume_ratio'] != null) {
      final volRatio = factors['volume_ratio'] as double;
      if (volRatio > 2.0) {
        explanations.add('Unusually high trading volume.');
      } else if (volRatio < 0.5) {
        explanations.add('Below average trading volume.');
      }
    }

    if (factors['price_change'] != null) {
      final priceChange = factors['price_change'] as double;
      if (priceChange.abs() > 0.05) {
        explanations.add('Significant price movement (${(priceChange * 100).toStringAsFixed(2)}%).');
      }
    }

    return explanations.join(' ');
  }

  void startContinuousAssessment(String symbol, MarketData? currentData, List<MarketData> historicalData) {
    _symbol = symbol;
    _assessmentTimer?.cancel();
    _assessmentTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      assessRisk(currentData, historicalData);
    });
  }

  void stopContinuousAssessment() {
    _assessmentTimer?.cancel();
  }

  Future<void> loadHistory(String symbol) async {
    try {
      final history = await DatabaseService.instance.getRiskHistory(symbol);
      _history = history.map((item) {
        final score = item['risk_score'] as double;
        final levelStr = item['risk_level'] as String;
        final level = levelStr.toLowerCase() == 'low' 
            ? RiskLevel.low 
            : levelStr.toLowerCase() == 'medium'
                ? RiskLevel.medium
                : levelStr.toLowerCase() == 'high'
                    ? RiskLevel.high
                    : RiskLevel.critical;
        
        return RiskAssessment(
          score: score,
          level: level,
          factors: {},
          explanation: '',
          timestamp: DateTime.parse(item['timestamp'] as String),
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading risk history: $e');
    }
  }

  @override
  void dispose() {
    _assessmentTimer?.cancel();
    super.dispose();
  }
}

