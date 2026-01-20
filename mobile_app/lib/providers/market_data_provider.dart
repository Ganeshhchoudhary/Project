import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/market_data.dart';
import '../services/market_data_service.dart';
import '../services/database_service.dart';

class MarketDataProvider with ChangeNotifier {
  final MarketDataService _dataService = MarketDataService.instance;
  MarketData? _currentData;
  List<MarketData> _historicalData = [];
  StreamSubscription<MarketData>? _dataSubscription;
  bool _isLoading = false;
  String _error = '';
  String _symbol = 'AAPL';

  MarketData? get currentData => _currentData;
  List<MarketData> get historicalData => _historicalData;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get symbol => _symbol;
  bool get isConnected => _dataService.isConnected;

  MarketDataProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _dataService.initialize(_symbol);
    await loadHistoricalData();
    await connectToStream();
  }

  Future<void> connectToStream() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      await _dataService.connect(_symbol);
      
      _dataSubscription?.cancel();
      _dataSubscription = _dataService.dataStream?.listen(
        (data) {
          _currentData = data;
          _historicalData.insert(0, data);
          if (_historicalData.length > 100) {
            _historicalData = _historicalData.take(100).toList();
          }
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          _error = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHistoricalData() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Load from local database
      final cached = await DatabaseService.instance.getMarketData(_symbol, limit: 100);
      if (cached.isNotEmpty) {
        _historicalData = cached.reversed.toList();
        _currentData = cached.first;
      }

      // Try to fetch latest from API
      final latest = await _dataService.getLatestData(_symbol);
      if (latest != null && (_currentData == null || latest.timestamp.isAfter(_currentData!.timestamp))) {
        _currentData = latest;
        if (_historicalData.isEmpty || _historicalData.first.symbol != latest.symbol) {
          _historicalData.insert(0, latest);
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeSymbol(String newSymbol) async {
    if (newSymbol == _symbol) return;
    
    _symbol = newSymbol;
    _currentData = null;
    _historicalData = [];
    _dataSubscription?.cancel();
    _dataService.disconnect();
    
    _dataService.initialize(_symbol);
    await loadHistoricalData();
    await connectToStream();
  }

  void refresh() {
    loadHistoricalData();
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _dataService.dispose();
    super.dispose();
  }
}

