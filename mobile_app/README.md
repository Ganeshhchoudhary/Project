# Edge AI Trading Mobile App

## Features

- **Real-Time Market Data**: WebSocket-based streaming with offline fallback
- **Edge AI Inference**: On-device TensorFlow Lite model for trading signals
- **Risk Assessment**: Continuous risk monitoring with explainable outputs
- **Order Management**: Place, track, and execute trades
- **Offline Support**: Continue operations during poor connectivity

## Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Android Studio / Xcode
- TensorFlow Lite model file (from model training)

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Add TensorFlow Lite model:
   - Place `trading_model_quantized.tflite` in `assets/models/`
   - Model should be generated from training pipeline

3. Configure API endpoints:
   - Edit `lib/services/market_data_service.dart`
   - Update WebSocket and REST API URLs

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── market_data.dart
│   ├── trading_signal.dart
│   └── trade_order.dart
├── services/                 # Core services
│   ├── ai_service.dart       # TensorFlow Lite inference
│   ├── database_service.dart # SQLite database
│   └── market_data_service.dart # Data acquisition
├── providers/                # State management
│   ├── market_data_provider.dart
│   ├── risk_assessment_provider.dart
│   └── trading_provider.dart
├── screens/                  # UI screens
│   ├── dashboard_screen.dart
│   ├── trading_screen.dart
│   └── orders_screen.dart
└── widgets/                  # Reusable widgets
    ├── market_data_card.dart
    ├── trading_signal_card.dart
    ├── risk_assessment_card.dart
    └── price_chart.dart
```

## Key Components

### AI Service

Handles TensorFlow Lite model inference:
- Loads quantized model from assets
- Processes market data into features
- Generates trading signals with explanations

### Database Service

Manages local data storage:
- Market data caching
- Order queueing
- Risk assessment history

### Market Data Service

Handles data acquisition:
- WebSocket streaming
- REST API fallback
- Offline data access

## Configuration

### Model Configuration

Edit `lib/services/ai_service.dart`:
- Model path
- Feature extraction parameters
- Technical indicator settings

### API Configuration

Edit `lib/services/market_data_service.dart`:
- WebSocket URL
- REST API endpoints
- Reconnection settings

## Building for Production

### Android

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## Testing

Run tests:
```bash
flutter test
```

## Troubleshooting

### Model Not Loading
- Ensure model file is in `assets/models/`
- Check `pubspec.yaml` includes assets
- Verify model file format (TensorFlow Lite)

### WebSocket Connection Issues
- Check internet connectivity
- Verify API endpoint URL
- Review authentication requirements

### Performance Issues
- Reduce sequence length in AI service
- Limit historical data queries
- Optimize chart rendering

