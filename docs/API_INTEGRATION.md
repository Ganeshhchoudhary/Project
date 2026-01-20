# API Integration Guide

## Market Data APIs

### WebSocket API

The application uses WebSocket for real-time market data streaming.

#### Expected Message Format

**Subscribe Message**:
```json
{
  "action": "subscribe",
  "symbols": ["AAPL"]
}
```

**Incoming Data Format**:
```json
{
  "symbol": "AAPL",
  "price": 150.25,
  "volume": 1000000,
  "change": 1.25,
  "change_percent": 0.84,
  "high": 151.00,
  "low": 149.50,
  "open": 149.75,
  "close": 150.25,
  "timestamp": "2024-01-15T10:30:00Z"
}
```

**Alternative Format (Binance-style)**:
```json
{
  "s": "AAPL",
  "c": "150.25",
  "v": "1000000",
  "p": "1.25",
  "P": "0.84",
  "h": "151.00",
  "l": "149.50",
  "o": "149.75"
}
```

### REST API

#### Get Historical Data

**Endpoint**: `GET /historical/{symbol}?days={days}`

**Response**:
```json
[
  {
    "symbol": "AAPL",
    "price": 150.25,
    "volume": 1000000,
    "timestamp": "2024-01-15T10:30:00Z",
    "high": 151.00,
    "low": 149.50,
    "open": 149.75,
    "close": 150.25
  }
]
```

## Broker API Integration

### Order Execution

**Endpoint**: `POST /orders`

**Request**:
```json
{
  "symbol": "AAPL",
  "side": "buy",
  "type": "market",
  "quantity": 10,
  "price": null
}
```

**Response**:
```json
{
  "order_id": "ORD-1234567890",
  "status": "executed",
  "executed_at": "2024-01-15T10:30:00Z",
  "executed_price": 150.25
}
```

### Order Status

**Endpoint**: `GET /orders/{order_id}`

**Response**:
```json
{
  "order_id": "ORD-1234567890",
  "status": "executed",
  "symbol": "AAPL",
  "quantity": 10,
  "executed_price": 150.25,
  "executed_at": "2024-01-15T10:30:00Z"
}
```

## Example API Providers

### Alpha Vantage (Free Tier Available)

```dart
// WebSocket: Not available, use REST polling
// REST API: https://www.alphavantage.co/query
final url = Uri.parse(
  'https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$apiKey'
);
```

### Binance (Crypto)

```dart
// WebSocket: wss://stream.binance.com:9443/ws/btcusdt@ticker
// REST API: https://api.binance.com/api/v3/klines
```

### Yahoo Finance (via yfinance)

Already integrated in Python training scripts. For Flutter, use REST API wrapper.

### Custom API Integration

1. Update `market_data_service.dart`:
   ```dart
   final wsUrl = Uri.parse('wss://your-api.com/stream');
   ```

2. Implement message parsing in `_parseMarketData()` method

3. Handle authentication if required:
   ```dart
   _channel!.sink.add(jsonEncode({
     'action': 'authenticate',
     'api_key': apiKey,
   }));
   ```

## Authentication

### API Key Storage

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();
await storage.write(key: 'api_key', value: 'your_api_key');
```

### Headers

```dart
final headers = {
  'Authorization': 'Bearer $apiKey',
  'Content-Type': 'application/json',
};
```

## Error Handling

### Connection Errors

```dart
try {
  await _dataService.connect(symbol);
} catch (e) {
  if (e is SocketException) {
    // Network error - use cached data
    await _loadCachedData(symbol);
  }
}
```

### Rate Limiting

```dart
if (response.statusCode == 429) {
  // Wait and retry
  await Future.delayed(Duration(seconds: 60));
  return await fetchHistoricalData(symbol, days: days);
}
```

## Testing with Mock Data

For development without API access:

```dart
class MockMarketDataService extends MarketDataService {
  @override
  Future<void> connect(String symbol) async {
    // Generate mock data
    Timer.periodic(Duration(seconds: 1), (timer) {
      final mockData = MarketData(
        symbol: symbol,
        price: 150 + (Random().nextDouble() * 10 - 5),
        volume: 1000000 + Random().nextInt(500000),
        timestamp: DateTime.now(),
        change: (Random().nextDouble() * 2 - 1),
        changePercent: (Random().nextDouble() * 2 - 1),
        high: 155,
        low: 145,
        open: 150,
        close: 150,
      );
      _dataStreamController?.add(mockData);
    });
  }
}
```

