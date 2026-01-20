# Edge AI for Mobile Real-Time Trading Execution and Risk Assessment

## Project Overview

This project implements a mobile trading application that uses on-device Edge AI to perform real-time trading decisions and risk assessment. The system runs TensorFlow Lite models directly on smartphones, enabling ultra-low latency decisions, privacy preservation, and offline-capable risk assessment.

## Features

- **Ultra-Low Latency**: Sub-100ms AI decision making on mobile devices
- **Privacy-Preserving**: All AI computations run locally on the device
- **Offline Capable**: Risk assessment continues during poor connectivity
- **Explainable AI**: Trade recommendations with detailed explanations
- **Real-Time Processing**: WebSocket-based market data streaming
- **Location-Aware**: Optional GPS-based context for trading strategies

## Project Structure

```
Project/
├── mobile_app/              # Flutter mobile application
│   ├── lib/
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
├── model_training/          # Python scripts for model development
│   ├── data_collection/
│   ├── model_development/
│   └── model_conversion/
├── models/                  # Trained TensorFlow Lite models
├── docs/                    # Project documentation
└── README.md
```

## System Architecture

### Components

1. **Data Acquisition Layer**: Collects real-time market data via WebSocket APIs
2. **Local Storage Layer**: Uses SQLite/Hive for caching prices and historical data
3. **Edge AI Layer**: Runs optimized TensorFlow Lite models on-device
4. **Decision & Explainability Layer**: Generates trading signals with explanations
5. **Execution Layer**: Manages trade execution and order queuing

## Getting Started

### Prerequisites

- Python 3.8+
- Flutter SDK 3.0+
- Android Studio / Xcode
- TensorFlow 2.x

### Model Training

1. Navigate to `model_training/`
2. Install dependencies: `pip install -r requirements.txt`
3. Collect data: `python data_collection/collect_market_data.py`
4. Train model: `python model_development/train_model.py`
5. Convert to TensorFlow Lite: `python model_conversion/convert_to_tflite.py`

### Mobile App Setup

1. Navigate to `mobile_app/`
2. Install dependencies: `flutter pub get`
3. Place TensorFlow Lite models in `mobile_app/assets/models/`
4. Run the app: `flutter run`

## Methodology

1. Data Collection: Historical and live market data from public APIs
2. Model Training: ML models trained on historical market and sentiment data
3. Model Optimization: Quantization and TensorFlow Lite conversion
4. Mobile Development: Cross-platform app with live data streaming
5. On-Device Inference: Local AI inference for real-time signals
6. Testing & Evaluation: Latency, accuracy, and battery usage metrics

## Expected Outcomes

- Sub-100ms AI decision latency
- Accurate and explainable trading signals
- Continued risk assessment during poor connectivity
- Reduced cloud server dependency
- Demonstration of Edge AI feasibility in trading systems

## Tools & Technologies

- **TensorFlow Lite**: On-device AI inference
- **Python**: Data processing and model development
- **Flutter**: Cross-platform mobile app development
- **WebSocket APIs**: Real-time market data streaming
- **SQLite/Hive**: Local data storage

## License

This project is for educational and research purposes.

## Authors

Edge AI Trading System Development Team

