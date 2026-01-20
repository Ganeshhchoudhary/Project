# Run Instructions - Complete Guide

## Prerequisites Checklist

Before running, ensure you have:

- [ ] **Python 3.8+** installed (`python --version`)
- [ ] **Flutter SDK 3.0+** installed (`flutter --version`)
- [ ] **Android Studio** or **Xcode** (for mobile development)
- [ ] **Android Emulator** running OR **physical device** connected

---

## Method 1: Full Setup (Recommended)

### A. Train and Prepare Model

**Step 1**: Open terminal and navigate to project root
```bash
cd "C:\Users\GANES\OneDrive\Desktop\Project"
```

**Step 2**: Install Python dependencies
```bash
cd model_training
pip install -r requirements.txt
```

**Step 3**: Train the model
```bash
cd model_development
python train_trading_model.py
```

**Wait time**: 10-30 minutes (first time)

**Step 4**: Convert to mobile format
```bash
cd ../model_conversion
python convert_to_tflite.py
```

**Step 5**: Verify model created
```bash
# Check if file exists
dir ..\..\models\trading_model_quantized.tflite
```

---

### B. Setup and Run Mobile App

**Step 1**: Navigate to mobile app
```bash
cd ..\..\mobile_app
```

**Step 2**: Copy model to assets
```powershell
# PowerShell command
Copy-Item ..\models\trading_model_quantized.tflite assets\models\
```

**Step 3**: Install Flutter dependencies
```bash
flutter pub get
```

**Step 4**: Check Flutter setup
```bash
flutter doctor
```

**Step 5**: List available devices
```bash
flutter devices
```

**Step 6**: Run the app
```bash
# Run on first available device
flutter run

# OR specify device
flutter run -d <device-name>
```

---

## Method 2: Quick Test (UI Only - No Model)

If you want to test the UI without training:

**Step 1**: Navigate to mobile app
```bash
cd mobile_app
```

**Step 2**: Install dependencies
```bash
flutter pub get
```

**Step 3**: Run the app
```bash
flutter run
```

**Note**: The app will show "AI model not initialized" warnings, but UI will work.

---

## Running on Different Platforms

### Android

```bash
# Start Android Studio and launch an emulator first
# Then run:
flutter run
```

### iOS (macOS only)

```bash
flutter run -d ios
```

### Web (for quick testing)

```bash
flutter run -d chrome
```

### Windows Desktop

```bash
flutter run -d windows
```

---

## Verifying Everything Works

### Check Model Training
- Look for `models/trading_model.h5` file
- Look for `models/trading_model_quantized.tflite` file

### Check Mobile App
1. App should launch without crashes
2. Dashboard screen should appear
3. Check console for "AI Service initialized successfully"
4. Market data card should display (may show "No data" if no API configured)

### Test Features
- [ ] Dashboard loads
- [ ] Market data displays (or shows "No data")
- [ ] AI signal card shows (may show "waiting for signal")
- [ ] Risk assessment card appears
- [ ] Navigation to Trading screen works
- [ ] Navigation to Orders screen works

---

## Expected Console Output

### When Model is Loaded:
```
AI Service initialized successfully
WebSocket connection opened for AAPL
```

### When Model Not Found:
```
Error initializing AI Service: Exception: Model file not found
AI Service will use fallback mode
```

Both are acceptable for testing!

---

## Troubleshooting Commands

### If Flutter has issues:
```bash
flutter clean
flutter pub get
flutter doctor -v
```

### If Python has issues:
```bash
python -m pip install --upgrade pip
pip install -r requirements.txt --force-reinstall
```

### Check model files:
```powershell
# PowerShell
Get-ChildItem models\*.tflite
Get-ChildItem mobile_app\assets\models\*.tflite
```

---

## Quick Reference Commands

```bash
# Navigate to project
cd "C:\Users\GANES\OneDrive\Desktop\Project"

# Train model
cd model_training\model_development && python train_trading_model.py && cd ..\..

# Convert model
cd model_training\model_conversion && python convert_to_tflite.py && cd ..\..

# Setup mobile app
cd mobile_app && flutter pub get

# Copy model (PowerShell)
Copy-Item ..\models\trading_model_quantized.tflite assets\models\

# Run app
flutter run
```

---

## Success Indicators

✅ **Model Training Success**:
- No errors during training
- `trading_model_quantized.tflite` file exists in `models/` folder

✅ **App Running Success**:
- App launches without crashes
- Dashboard appears with UI elements
- No red error screens

✅ **AI Working**:
- Trading signal card shows recommendations
- Risk assessment shows risk levels
- Console shows "AI Service initialized successfully"

---

## Need More Help?

1. Check `docs/SETUP.md` for detailed setup
2. Review error messages in console
3. Verify all prerequisites are installed
4. Check `QUICK_START.md` for alternative instructions

