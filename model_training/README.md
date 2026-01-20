# Model Training Pipeline

This directory contains scripts for training and optimizing machine learning models for edge trading applications.

## Directory Structure

```
model_training/
├── data_collection/
│   └── market_data_collector.py    # Data collection utilities
├── model_development/
│   └── train_trading_model.py      # Model training script
├── model_conversion/
│   └── convert_to_tflite.py        # TensorFlow Lite conversion
└── requirements.txt                 # Python dependencies
```

## Quick Start

1. **Install Dependencies**
```bash
pip install -r requirements.txt
```

2. **Collect Data**
```bash
cd data_collection
python market_data_collector.py
```

3. **Train Model**
```bash
cd ../model_development
python train_trading_model.py
```

4. **Convert to TensorFlow Lite**
```bash
cd ../model_conversion
python convert_to_tflite.py
```

## Data Collection

### Market Data Collector

Features:
- Historical data fetching via yfinance
- WebSocket streaming support
- Sentiment data collection
- Data caching and storage

Usage:
```python
from data_collection.market_data_collector import MarketDataCollector

collector = MarketDataCollector("AAPL")
historical = collector.get_historical_data(period="1y", interval="1h")
```

## Model Training

### Trading Model Trainer

The training script includes:
- Feature engineering (RSI, MACD, Bollinger Bands, etc.)
- Sequence preparation for time series
- LSTM/CNN model architectures
- Training with early stopping and learning rate reduction

Model Architecture:
- Input: 60 timesteps × 17 features
- Layers: LSTM (128) → LSTM (64) → Dense (32) → Output (3)
- Output: Buy/Hold/Sell classification

Training Parameters:
- Sequence length: 60
- Epochs: 50 (with early stopping)
- Batch size: 32
- Learning rate: 0.001

## Model Conversion

### TensorFlow Lite Converter

Supports multiple quantization strategies:
- **Dynamic Quantization**: Default, ~75% size reduction
- **Float16 Quantization**: Additional size reduction, minimal accuracy loss
- **INT8 Quantization**: Maximum compression, requires representative dataset

Output:
- `trading_model.tflite` - Basic conversion
- `trading_model_quantized.tflite` - Dynamic quantization (recommended)
- `trading_model_float16.tflite` - Float16 quantization

## Features

The model uses the following features:

1. **Price Features**: Open, High, Low, Close
2. **Volume**: Trading volume and volume ratios
3. **Technical Indicators**:
   - RSI (Relative Strength Index)
   - MACD (Moving Average Convergence Divergence)
   - Bollinger Bands (Upper, Middle, Lower)
   - SMA (Simple Moving Average) - 20 and 50 periods
4. **Volatility**: Price change volatility
5. **Momentum**: Price change and ratios

## Model Evaluation

The training script outputs:
- Training/validation loss
- Accuracy metrics
- Model architecture summary

## Optimization Tips

1. **Reduce Model Size**:
   - Use quantization
   - Reduce sequence length
   - Remove unnecessary features

2. **Improve Accuracy**:
   - Increase training data
   - Tune hyperparameters
   - Add more features
   - Ensemble models

3. **Reduce Latency**:
   - Use smaller models
   - Optimize feature calculation
   - Use quantization

## Output Files

After training and conversion:
- `models/trading_model.h5` - Full TensorFlow model
- `models/trading_model_scaler.pkl` - Feature scaler
- `models/trading_model_quantized.tflite` - Optimized mobile model

Copy `trading_model_quantized.tflite` to `mobile_app/assets/models/` for deployment.

