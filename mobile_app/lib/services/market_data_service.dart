import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/market_data.dart';
import 'database_service.dart';

class MarketDataService {
  static final MarketDataService instance = MarketDataService._init();
  MarketDataService._init();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  final Connectivity _connectivity = Connectivity();

  StreamController<MarketData>? _dataStreamController;
  Stream<MarketData>? get dataStream => _dataStreamController?.stream;

  bool get isConnected => _isConnected;

  void initialize(String symbol) {
    _dataStreamController = StreamController<MarketData>.broadcast();
    _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none && !_isConnected) {
        connect(symbol);
      } else if (result == ConnectivityResult.none) {
        disconnect();
      }
    });
  }

  Future<void> connect(String symbol) async {
    if (_isConnected) return;

    try {
      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print('No internet connection - using cached data');
        await _loadCachedData(symbol);
        return;
      }

      // WebSocket URL (replace with actual API endpoint)
      final wsUrl = Uri.parse('wss://api.example.com/stream'); // Replace with actual endpoint
      
      _channel = WebSocketChannel.connect(wsUrl);
      
      // Send subscription message
      _channel!.sink.add(jsonEncode({
        'action': 'subscribe',
        'symbols': [symbol],
      }));

      _subscription = _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message as String);
            final marketData = _parseMarketData(data, symbol);
            
            // Save to local database
            DatabaseService.instance.insertMarketData(marketData);
            
            // Emit to stream
            _dataStreamController?.add(marketData);
          } catch (e) {
            print('Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          _isConnected = false;
          _scheduleReconnect(symbol);
        },
        onDone: () {
          print('WebSocket connection closed');
          _isConnected = false;
          _scheduleReconnect(symbol);
        },
      );

      _isConnected = true;
      print('WebSocket connected for $symbol');
    } catch (e) {
      print('Error connecting WebSocket: $e');
      await _loadCachedData(symbol);
      _scheduleReconnect(symbol);
    }
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _reconnectTimer?.cancel();
    _isConnected = false;
    print('WebSocket disconnected');
  }

  void _scheduleReconnect(String symbol) {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected) {
        connect(symbol);
      }
    });
  }

  MarketData _parseMarketData(Map<String, dynamic> data, String symbol) {
    return MarketData(
      symbol: symbol,
      price: (data['price'] ?? data['c'] ?? 0.0).toDouble(),
      volume: (data['volume'] ?? data['v'] ?? 0).toInt(),
      timestamp: DateTime.now(),
      change: (data['change'] ?? data['p'] ?? 0.0).toDouble(),
      changePercent: (data['change_percent'] ?? data['P'] ?? 0.0).toDouble(),
      high: (data['high'] ?? data['h'] ?? data['price'] ?? 0.0).toDouble(),
      low: (data['low'] ?? data['l'] ?? data['price'] ?? 0.0).toDouble(),
      open: (data['open'] ?? data['o'] ?? data['price'] ?? 0.0).toDouble(),
      close: (data['close'] ?? data['c'] ?? data['price'] ?? 0.0).toDouble(),
    );
  }

  Future<void> _loadCachedData(String symbol) async {
    try {
      final cachedData = await DatabaseService.instance.getMarketData(symbol, limit: 100);
      for (var data in cachedData) {
        _dataStreamController?.add(data);
      }
    } catch (e) {
      print('Error loading cached data: $e');
    }
  }

  /// Fetch historical data from REST API (fallback)
  Future<List<MarketData>> fetchHistoricalData(String symbol, {int days = 30}) async {
    try {
      // Example API call (replace with actual endpoint)
      final url = Uri.parse('https://api.example.com/historical/$symbol?days=$days');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => _parseMarketData(item, symbol)).toList();
      }
    } catch (e) {
      print('Error fetching historical data: $e');
    }
    return [];
  }

  /// Get latest market data (from cache or API)
  Future<MarketData?> getLatestData(String symbol) async {
    // Try to get from cache first
    var latest = await DatabaseService.instance.getLatestMarketData(symbol);
    
    if (latest == null && _isConnected) {
      // Try to fetch from API
      final historical = await fetchHistoricalData(symbol, days: 1);
      if (historical.isNotEmpty) {
        latest = historical.last;
        await DatabaseService.instance.insertMarketData(latest!);
      }
    }
    
    return latest;
  }

  void dispose() {
    disconnect();
    _dataStreamController?.close();
  }
}

