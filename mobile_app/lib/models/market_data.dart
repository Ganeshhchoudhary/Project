class MarketData {
  final int? id;
  final String symbol;
  final double price;
  final int volume;
  final DateTime timestamp;
  final double? change;
  final double? changePercent;
  final double? high;
  final double? low;
  final double open;
  final double close;

  MarketData({
    this.id,
    required this.symbol,
    required this.price,
    required this.volume,
    required this.timestamp,
    this.change,
    this.changePercent,
    this.high,
    this.low,
    required this.open,
    required this.close,
  });

  factory MarketData.fromMap(Map<String, dynamic> map) {
    return MarketData(
      id: map['id'] as int?,
      symbol: map['symbol'] as String,
      price: map['price'] as double,
      volume: map['volume'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
      change: map['change'] as double?,
      changePercent: map['change_percent'] as double?,
      high: map['high'] as double?,
      low: map['low'] as double?,
      open: map['open'] as double? ?? map['price'] as double,
      close: map['close'] as double? ?? map['price'] as double,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'symbol': symbol,
      'price': price,
      'volume': volume,
      'timestamp': timestamp.toIso8601String(),
      'change': change,
      'change_percent': changePercent,
      'high': high ?? price,
      'low': low ?? price,
      'open': open,
      'close': close,
    };
  }

  MarketData copyWith({
    int? id,
    String? symbol,
    double? price,
    int? volume,
    DateTime? timestamp,
    double? change,
    double? changePercent,
    double? high,
    double? low,
    double? open,
    double? close,
  }) {
    return MarketData(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      price: price ?? this.price,
      volume: volume ?? this.volume,
      timestamp: timestamp ?? this.timestamp,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      high: high ?? this.high,
      low: low ?? this.low,
      open: open ?? this.open,
      close: close ?? this.close,
    );
  }
}

