# Quick Start Guide - How to Run the Project

## Step-by-Step Instructions

### Part 1: Model Training (Python)

#### 1.1 Install Python Dependencies

```bash
# Navigate to model training directory
cd model_training

# Install required packages
pip install -r requirements.txt
```

**Note**: If you get permission errors, use `pip install --user -r requirements.txt`

#### 1.2 Train the Model

```bash
# Train the trading model
cd model_development
python train_trading_model.py
```

**What this does**:
- Fetches historical market data (AAPL by default)
- Trains an LSTM model
- Saves model as `../../models/trading_model.h5`
- Takes approximately 10-30 minutes

#### 1.3 Convert to TensorFlow Lite

```bash
# Navigate to conversion directory
cd ../model_conversion

# Convert to TensorFlow Lite
python convert_to_tflite.py
```

**What this does**:
- Converts the trained model to TensorFlow Lite format
- Applies quantization for mobile optimization
- Creates `../../models/trading_model_quantized.tflite`

---

### Part 2: Mobile App Setup (Flutter)

#### 2.1 Install Flutter Dependencies

```bash
# Navigate to mobile app directory
cd ../../mobile_app

# Install Flutter packages
flutter pub get
```

#### 2.2 Copy Model to App Assets

**On Windows (PowerShell)**:
```powershell
Copy-Item ..\models\trading_model_quantized.tflite assets\models\
```

**On macOS/Linux**:
```bash
cp ../models/trading_model_quantized.tflite assets/models/
```

**Note**: If the model doesn't exist yet (after training), the app will still run but show "AI model not initialized" warnings.

#### 2.3 Configure API Endpoints (Optional)

Edit `lib/services/market_data_service.dart`:

Find this line (around line 48):
```dart
final wsUrl = Uri.parse('wss://api.example.com/stream');
```

Replace with your actual WebSocket URL, or use mock data for testing.

#### 2.4 Run the Mobile App

**For Android**:
```bash
# List available devices
flutter devices

# Run on connected device/emulator
flutter run

# Or specify device
flutter run -d <device-id>
```

**For iOS** (macOS only):
```bash
flutter run -d ios
```

**For Web** (for quick testing):
```bash
flutter run -d chrome
```

---

## Running Without Training (Testing UI Only)

If you want to test the UI without training the model:

1. **Skip model training** (Part 1)
2. **Run the Flutter app** (Part 2)
3. The app will run but show "AI model not initialized" - this is expected
4. You can still test:
   - UI components
   - Database functionality
   - Market data display (if using mock data)

---

## Common Issues & Solutions

### Issue: Python dependencies fail to install

**Solution**:
```bash
# Use virtual environment (recommended)
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Issue: Flutter pub get fails

**Solution**:
```bash
flutter clean
flutter pub get
```

### Issue: Model file not found

**Solution**: 
- Make sure you completed Part 1 (training and conversion)
- Check file exists: `models/trading_model_quantized.tflite`
- Verify it's copied to: `mobile_app/assets/models/trading_model_quantized.tflite`

### Issue: WebSocket connection fails

**Solution**: 
- This is expected if using placeholder API endpoints
- For testing, modify `market_data_service.dart` to use mock data
- Or integrate with a real market data API

### Issue: No devices found

**Solution**:
```bash
# Start Android emulator from Android Studio
# Or connect physical device via USB with USB debugging enabled
flutter doctor  # Check Flutter setup
```

---

## Testing Checklist

- [ ] Python dependencies installed
- [ ] Model trained successfully
- [ ] Model converted to TensorFlow Lite
- [ ] Model copied to `mobile_app/assets/models/`
- [ ] Flutter dependencies installed
- [ ] Device/emulator connected
- [ ] App runs without errors
- [ ] Dashboard displays (even with mock data)

---

## Next Steps After Running

1. **Test AI Inference**: Once model is loaded, check dashboard for trading signals
2. **Configure Real APIs**: Replace placeholder endpoints with actual market data APIs
3. **Test Offline Mode**: Disable internet and verify offline functionality
4. **Place Test Orders**: Use the trading screen to create orders (they'll queue if offline)

---

## Need Help?

- Check `docs/SETUP.md` for detailed setup instructions
- Review `docs/ARCHITECTURE.md` for system overview
- See `docs/API_INTEGRATION.md` for API setup

