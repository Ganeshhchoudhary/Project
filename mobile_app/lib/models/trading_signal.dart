enum TradingAction { buy, sell, hold }

class TradingSignal {
  final TradingAction action;
  final double confidence; // 0.0 to 1.0
  final double riskScore; // 0.0 to 1.0
  final String explanation;
  final Map<String, dynamic>? contributingFactors;
  final DateTime timestamp;

  TradingSignal({
    required this.action,
    required this.confidence,
    required this.riskScore,
    required this.explanation,
    this.contributingFactors,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  String get actionString {
    switch (action) {
      case TradingAction.buy:
        return 'BUY';
      case TradingAction.sell:
        return 'SELL';
      case TradingAction.hold:
        return 'HOLD';
    }
  }

  String get riskLevel {
    if (riskScore < 0.3) return 'Low';
    if (riskScore < 0.7) return 'Medium';
    return 'High';
  }

  Map<String, dynamic> toMap() {
    return {
      'action': action.index,
      'confidence': confidence,
      'riskScore': riskScore,
      'explanation': explanation,
      'contributingFactors': contributingFactors,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TradingSignal.fromMap(Map<String, dynamic> map) {
    return TradingSignal(
      action: TradingAction.values[map['action'] as int],
      confidence: map['confidence'] as double,
      riskScore: map['riskScore'] as double,
      explanation: map['explanation'] as String,
      contributingFactors: map['contributingFactors'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

