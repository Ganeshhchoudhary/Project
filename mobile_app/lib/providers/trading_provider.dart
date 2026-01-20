import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/trade_order.dart';
import '../models/trading_signal.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart';
import '../models/market_data.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class TradingProvider with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  TradingSignal? _currentSignal;
  List<TradeOrder> _orders = [];
  bool _isProcessing = false;
  Timer? _signalUpdateTimer;

  TradingSignal? get currentSignal => _currentSignal;
  List<TradeOrder> get orders => _orders;
  bool get isProcessing => _isProcessing;

  Future<void> generateSignal(MarketData? currentData, List<MarketData> historicalData) async {
    if (currentData == null || historicalData.isEmpty) return;

    try {
      final signal = await AIService.instance.generateSignal(currentData, historicalData);
      _currentSignal = signal;
      notifyListeners();
    } catch (e) {
      print('Error generating trading signal: $e');
    }
  }

  Future<void> createOrder({
    required String symbol,
    required OrderType orderType,
    required double quantity,
    double? price,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final order = TradeOrder(
        symbol: symbol,
        orderType: orderType,
        quantity: quantity,
        price: price,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
      );

      final orderId = await DatabaseService.instance.insertOrder(order);
      
      // Check connectivity and execute if online
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        await _executeOrder(order.copyWith(id: orderId));
      } else {
        // Queue for later execution
        _orders.add(order.copyWith(id: orderId));
        notifyListeners();
      }
    } catch (e) {
      print('Error creating order: $e');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> _executeOrder(TradeOrder order) async {
    try {
      // In production, this would call the broker API
      // For now, simulate execution
      await Future.delayed(const Duration(seconds: 1));
      
      final executedOrder = order.copyWith(
        status: OrderStatus.executed,
        executedAt: DateTime.now(),
        orderId: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      );

      await DatabaseService.instance.updateOrderStatus(
        order.id!,
        'executed',
        orderId: executedOrder.orderId,
      );

      await loadOrders();
    } catch (e) {
      print('Error executing order: $e');
      await DatabaseService.instance.updateOrderStatus(
        order.id!,
        'failed',
      );
      await loadOrders();
    }
  }

  Future<void> processPendingOrders() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) return;

      final pendingOrders = await DatabaseService.instance.getPendingOrders();
      for (var order in pendingOrders) {
        await _executeOrder(order);
      }
      await loadOrders();
    } catch (e) {
      print('Error processing pending orders: $e');
    }
  }

  Future<void> loadOrders() async {
    try {
      _orders = await DatabaseService.instance.getAllOrders();
      notifyListeners();
    } catch (e) {
      print('Error loading orders: $e');
    }
  }

  void startSignalUpdates(MarketData? currentData, List<MarketData> historicalData) {
    _signalUpdateTimer?.cancel();
    _signalUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      generateSignal(currentData, historicalData);
    });
  }

  void stopSignalUpdates() {
    _signalUpdateTimer?.cancel();
  }

  @override
  void dispose() {
    _signalUpdateTimer?.cancel();
    super.dispose();
  }
}

