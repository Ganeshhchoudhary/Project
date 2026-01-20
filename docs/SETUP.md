# Setup Guide

## Prerequisites

### For Model Training (Python)

1. **Python 3.8+**
   ```bash
   python --version
   ```

2. **Install Python dependencies**
   ```bash
   cd model_training
   pip install -r requirements.txt
   ```

### For Mobile App (Flutter)

1. **Flutter SDK 3.0+**
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter doctor`

2. **Android Studio / Xcode**
   - For Android development
   - For iOS development (macOS only)

## Model Training Setup

### Step 1: Collect Market Data

```bash
cd model_training/data_collection
python market_data_collector.py
```

This will:
- Fetch historical market data
- Test WebSocket connections
- Save sample data

### Step 2: Train the Model

```bash
cd model_training/model_development
python train_trading_model.py
```

This will:
- Prepare features from market data
- Train LSTM/CNN model
- Save model to `models/trading_model.h5`
- Training typically takes 10-30 minutes depending on data size

### Step 3: Convert to TensorFlow Lite

```bash
cd model_training/model_conversion
python convert_to_tflite.py
```

This will:
- Convert model to TensorFlow Lite format
- Apply quantization (dynamic, float16)
- Save optimized models to `models/`
- Generate `trading_model_quantized.tflite` (recommended for mobile)

## Mobile App Setup

### Step 1: Install Flutter Dependencies

```bash
cd mobile_app
flutter pub get
```

### Step 2: Add Model to Assets

1. Copy the trained TensorFlow Lite model to `mobile_app/assets/models/`:
   ```bash
   cp models/trading_model_quantized.tflite mobile_app/assets/models/
   ```

2. Ensure `pubspec.yaml` includes the assets path (already configured)

### Step 3: Configure API Endpoints

Edit `mobile_app/lib/services/market_data_service.dart`:

Replace placeholder WebSocket URL:
```dart
final wsUrl = Uri.parse('wss://your-api-endpoint.com/stream');
```

Replace placeholder REST API URL:
```dart
final url = Uri.parse('https://your-api-endpoint.com/historical/$symbol?days=$days');
```

### Step 4: Run the App

#### Android
```bash
flutter run
```

#### iOS
```bash
flutter run -d ios
```

## Configuration

### Environment Variables (Optional)

Create `.env` file in `mobile_app/`:
```
API_WEBSOCKET_URL=wss://api.example.com/stream
API_REST_URL=https://api.example.com
BROKER_API_KEY=your_api_key
BROKER_API_SECRET=your_api_secret
```

### Model Configuration

Edit model parameters in `model_training/model_development/train_trading_model.py`:
- Sequence length (default: 60)
- Epochs (default: 50)
- Batch size (default: 32)
- Learning rate (default: 0.001)

## Testing

### Test Model Training

```bash
cd model_training/model_development
python train_trading_model.py
```

### Test Model Conversion

```bash
cd model_training/model_conversion
python convert_to_tflite.py
```

### Test Mobile App

```bash
cd mobile_app
flutter test
```

## Troubleshooting

### Model Training Issues

- **Out of Memory**: Reduce batch size or sequence length
- **No Data**: Check API endpoints and internet connection
- **Poor Accuracy**: Increase training epochs or data size

### Mobile App Issues

- **Model Not Found**: Ensure model file is in `assets/models/`
- **WebSocket Errors**: Check API endpoint configuration
- **Build Errors**: Run `flutter clean` and `flutter pub get`

## Next Steps

1. Integrate with actual market data API
2. Connect to broker API for order execution
3. Add user authentication
4. Implement advanced risk management
5. Add more technical indicators
6. Optimize model for better accuracy

