enum OrderType { buy, sell }
enum OrderStatus { pending, executed, cancelled, failed }

class TradeOrder {
  final int? id;
  final String symbol;
  final OrderType orderType;
  final double quantity;
  final double? price; // Market order if null
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? executedAt;
  final String? orderId; // Broker order ID

  TradeOrder({
    this.id,
    required this.symbol,
    required this.orderType,
    required this.quantity,
    this.price,
    required this.status,
    required this.createdAt,
    this.executedAt,
    this.orderId,
  });

  static OrderType _parseOrderType(String type) {
    switch (type.toLowerCase()) {
      case 'buy':
        return OrderType.buy;
      case 'sell':
        return OrderType.sell;
      default:
        return OrderType.buy;
    }
  }

  static OrderStatus _parseOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'executed':
        return OrderStatus.executed;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'failed':
        return OrderStatus.failed;
      default:
        return OrderStatus.pending;
    }
  }

  factory TradeOrder.fromMap(Map<String, dynamic> map) {
    return TradeOrder(
      id: map['id'] as int?,
      symbol: map['symbol'] as String,
      orderType: _parseOrderType(map['order_type'] as String),
      quantity: map['quantity'] as double,
      price: map['price'] as double?,
      status: _parseOrderStatus(map['status'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      executedAt: map['executed_at'] != null 
          ? DateTime.parse(map['executed_at'] as String) 
          : null,
      orderId: map['order_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'symbol': symbol,
      'order_type': orderType.toString().split('.').last,
      'quantity': quantity,
      'price': price,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'executed_at': executedAt?.toIso8601String(),
      'order_id': orderId,
    };
  }

  TradeOrder copyWith({
    int? id,
    String? symbol,
    OrderType? orderType,
    double? quantity,
    double? price,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? executedAt,
    String? orderId,
  }) {
    return TradeOrder(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      orderType: orderType ?? this.orderType,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      executedAt: executedAt ?? this.executedAt,
      orderId: orderId ?? this.orderId,
    );
  }
}

