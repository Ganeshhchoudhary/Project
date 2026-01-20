# System Architecture

## Overview

The Edge AI Trading System is built with a hybrid architecture that enables on-device AI inference while maintaining connectivity for real-time data updates and order execution.

## System Components

### 1. Data Acquisition Layer

**Location**: `mobile_app/lib/services/market_data_service.dart`

**Responsibilities**:
- Real-time market data streaming via WebSocket
- REST API fallback for historical data
- Connectivity monitoring
- Automatic reconnection handling
- Data caching for offline access

**Key Features**:
- WebSocket-based real-time streaming
- Automatic fallback to cached data when offline
- Connection state monitoring
- Data buffering and queueing

### 2. Local Storage Layer

**Location**: `mobile_app/lib/services/database_service.dart`

**Database Schema**:
- `market_data`: Real-time and historical price data
- `trade_orders`: Order queue and execution history
- `risk_history`: Risk assessment logs

**Key Features**:
- SQLite database for persistent storage
- Efficient indexing for fast queries
- Automatic cleanup of old data
- Offline-first architecture

### 3. Edge AI Layer

**Location**: `mobile_app/lib/services/ai_service.dart`

**Components**:
- TensorFlow Lite interpreter
- Feature extraction and preprocessing
- On-device model inference
- Technical indicator calculations

**Model Architecture**:
- Input: 60 timesteps × 17 features
- Architecture: LSTM or CNN
- Output: 3-class classification (Buy/Hold/Sell)
- Quantization: Dynamic quantization for size/performance

**Features Calculated**:
- OHLC prices
- RSI (Relative Strength Index)
- MACD (Moving Average Convergence Divergence)
- Bollinger Bands
- SMA (Simple Moving Average)
- Volatility measures
- Volume indicators

### 4. Decision & Explainability Layer

**Location**: 
- `mobile_app/lib/services/ai_service.dart` (signal generation)
- `mobile_app/lib/providers/risk_assessment_provider.dart` (risk analysis)

**Outputs**:
- Trading signals (Buy/Sell/Hold)
- Confidence scores
- Risk assessments
- Explainable factors

**Explainability Features**:
- Contributing factor identification
- Risk level classification
- Explanation generation
- Confidence visualization

### 5. Execution Layer

**Location**: `mobile_app/lib/providers/trading_provider.dart`

**Features**:
- Order creation and management
- Offline order queueing
- Automatic order execution when online
- Order status tracking

## Data Flow

```
Market Data Source
    ↓
WebSocket/REST API
    ↓
Market Data Service
    ↓
Database Service (Cache)
    ↓
AI Service (Inference)
    ↓
Signal Generation
    ↓
Risk Assessment
    ↓
Trading Provider
    ↓
Order Execution (Broker API)
```

## Model Training Pipeline

```
Historical Data Collection
    ↓
Feature Engineering
    ↓
Model Training (TensorFlow)
    ↓
Model Evaluation
    ↓
Quantization & Optimization
    ↓
TensorFlow Lite Conversion
    ↓
Mobile Deployment
```

## Offline Mode Architecture

When internet connectivity is unavailable:

1. **Data Acquisition**: Uses cached market data from local database
2. **AI Inference**: Continues to run normally (on-device)
3. **Signal Generation**: Works with cached data
4. **Order Execution**: Queues orders for later execution
5. **Risk Assessment**: Continues with available data

## Performance Optimizations

### Model Optimization
- Dynamic quantization reduces model size by ~75%
- Float16 quantization for additional size reduction
- Sequence length optimization (60 timesteps)

### Mobile Optimizations
- Efficient SQLite queries with indexes
- Stream-based data processing
- Lazy loading of historical data
- Background processing for AI inference

## Security Considerations

1. **On-Device Processing**: Sensitive data never leaves device
2. **Encrypted Storage**: Database encryption for sensitive order data
3. **API Key Management**: Secure storage of broker API credentials
4. **Network Security**: HTTPS/WSS for all API communications

## Scalability

- Modular architecture allows easy feature additions
- Provider pattern enables state management scalability
- Database schema supports multiple symbols and timeframes
- Model can be retrained with new data without app updates

## Future Enhancements

1. Multi-symbol support
2. Advanced order types (stop-loss, take-profit)
3. Portfolio management
4. Backtesting capabilities
5. Real-time sentiment analysis integration
6. Location-based trading strategies
7. Advanced risk management rules

