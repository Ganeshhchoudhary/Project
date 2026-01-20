"""
Trading Model Training Script
Trains machine learning models for trading signal generation
"""

import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler, MinMaxScaler
from sklearn.model_selection import train_test_split
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from typing import Tuple, Dict
import os
import pickle


class TradingModelTrainer:
    """Trains TensorFlow models for trading signal prediction"""
    
    def __init__(self, model_type: str = "lstm"):
        self.model_type = model_type
        self.model = None
        self.scaler = StandardScaler()
        self.feature_scaler = MinMaxScaler()
        self.history = None
    
    def prepare_features(self, df: pd.DataFrame) -> Tuple[np.ndarray, np.ndarray]:
        """
        Prepare features from market data
        
        Features include:
        - Price features (OHLC)
        - Technical indicators (RSI, MACD, Bollinger Bands)
        - Volume indicators
        - Volatility measures
        
        Returns:
            X (features), y (targets)
        """
        df = df.copy()
        
        # Calculate technical indicators
        df['rsi'] = self.calculate_rsi(df['Close'], period=14)
        df['macd'], df['macd_signal'] = self.calculate_macd(df['Close'])
        df['bb_upper'], df['bb_middle'], df['bb_lower'] = self.calculate_bollinger_bands(df['Close'])
        df['sma_20'] = df['Close'].rolling(window=20).mean()
        df['sma_50'] = df['Close'].rolling(window=50).mean()
        
        # Volatility
        df['volatility'] = df['Close'].pct_change().rolling(window=20).std()
        
        # Volume indicators
        df['volume_sma'] = df['Volume'].rolling(window=20).mean()
        df['volume_ratio'] = df['Volume'] / df['volume_sma']
        
        # Price change features
        df['price_change'] = df['Close'].pct_change()
        df['high_low_ratio'] = df['High'] / df['Low']
        
        # Remove NaN values
        df = df.dropna()
        
        # Select features
        feature_columns = [
            'Open', 'High', 'Low', 'Close', 'Volume',
            'rsi', 'macd', 'macd_signal',
            'bb_upper', 'bb_middle', 'bb_lower',
            'sma_20', 'sma_50', 'volatility',
            'volume_ratio', 'price_change', 'high_low_ratio'
        ]
        
        features = df[feature_columns].values
        
        # Create target: Buy (2), Hold (1), Sell (0)
        # Based on future price movement
        future_return = df['Close'].shift(-5) / df['Close'] - 1
        y = np.where(future_return > 0.02, 2, np.where(future_return < -0.02, 0, 1))
        
        # Remove last rows with NaN targets
        valid_indices = ~np.isnan(y)
        features = features[valid_indices]
        y = y[valid_indices].astype(int)
        
        return features, y
    
    def calculate_rsi(self, prices: pd.Series, period: int = 14) -> pd.Series:
        """Calculate Relative Strength Index"""
        delta = prices.diff()
        gain = (delta.where(delta > 0, 0)).rolling(window=period).mean()
        loss = (-delta.where(delta < 0, 0)).rolling(window=period).mean()
        rs = gain / loss
        rsi = 100 - (100 / (1 + rs))
        return rsi
    
    def calculate_macd(self, prices: pd.Series, fast: int = 12, slow: int = 26, signal: int = 9) -> Tuple[pd.Series, pd.Series]:
        """Calculate MACD indicator"""
        ema_fast = prices.ewm(span=fast).mean()
        ema_slow = prices.ewm(span=slow).mean()
        macd = ema_fast - ema_slow
        macd_signal = macd.ewm(span=signal).mean()
        return macd, macd_signal
    
    def calculate_bollinger_bands(self, prices: pd.Series, period: int = 20, std_dev: int = 2) -> Tuple[pd.Series, pd.Series, pd.Series]:
        """Calculate Bollinger Bands"""
        sma = prices.rolling(window=period).mean()
        std = prices.rolling(window=period).std()
        upper = sma + (std * std_dev)
        lower = sma - (std * std_dev)
        return upper, sma, lower
    
    def build_lstm_model(self, input_shape: Tuple) -> keras.Model:
        """Build LSTM model for sequence prediction"""
        model = keras.Sequential([
            layers.LSTM(128, return_sequences=True, input_shape=input_shape),
            layers.Dropout(0.2),
            layers.LSTM(64, return_sequences=False),
            layers.Dropout(0.2),
            layers.Dense(32, activation='relu'),
            layers.Dense(3, activation='softmax')  # Buy, Hold, Sell
        ])
        
        model.compile(
            optimizer=keras.optimizers.Adam(learning_rate=0.001),
            loss='sparse_categorical_crossentropy',
            metrics=['accuracy']
        )
        
        return model
    
    def build_cnn_model(self, input_shape: Tuple) -> keras.Model:
        """Build CNN model for pattern recognition"""
        model = keras.Sequential([
            layers.Conv1D(64, 3, activation='relu', input_shape=input_shape),
            layers.MaxPooling1D(2),
            layers.Conv1D(32, 3, activation='relu'),
            layers.MaxPooling1D(2),
            layers.Flatten(),
            layers.Dense(64, activation='relu'),
            layers.Dropout(0.2),
            layers.Dense(3, activation='softmax')
        ])
        
        model.compile(
            optimizer=keras.optimizers.Adam(learning_rate=0.001),
            loss='sparse_categorical_crossentropy',
            metrics=['accuracy']
        )
        
        return model
    
    def create_sequences(self, data: np.ndarray, seq_length: int = 60) -> Tuple[np.ndarray, np.ndarray]:
        """Create sequences for time series prediction"""
        X, y = [], []
        for i in range(seq_length, len(data[0])):
            X.append(data[0][i-seq_length:i])
            y.append(data[1][i])
        return np.array(X), np.array(y)
    
    def train(self, df: pd.DataFrame, epochs: int = 50, batch_size: int = 32, sequence_length: int = 60):
        """
        Train the trading model
        
        Args:
            df: DataFrame with market data
            epochs: Number of training epochs
            batch_size: Batch size for training
            sequence_length: Length of input sequences
        """
        # Prepare features
        features, targets = self.prepare_features(df)
        
        # Normalize features
        features_scaled = self.scaler.fit_transform(features)
        
        # Create sequences
        X_seq, y_seq = self.create_sequences((features_scaled, targets), sequence_length)
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X_seq, y_seq, test_size=0.2, random_state=42, shuffle=False
        )
        
        # Build model
        input_shape = (X_train.shape[1], X_train.shape[2])
        if self.model_type == "lstm":
            self.model = self.build_lstm_model(input_shape)
        else:
            self.model = self.build_cnn_model(input_shape)
        
        # Train model
        self.history = self.model.fit(
            X_train, y_train,
            epochs=epochs,
            batch_size=batch_size,
            validation_data=(X_test, y_test),
            verbose=1,
            callbacks=[
                keras.callbacks.EarlyStopping(monitor='val_loss', patience=5, restore_best_weights=True),
                keras.callbacks.ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=3)
            ]
        )
        
        # Evaluate
        test_loss, test_accuracy = self.model.evaluate(X_test, y_test, verbose=0)
        print(f"Test Loss: {test_loss:.4f}")
        print(f"Test Accuracy: {test_accuracy:.4f}")
        
        return self.history
    
    def save_model(self, filepath: str):
        """Save trained model and scaler"""
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        self.model.save(filepath)
        
        # Save scaler
        scaler_path = filepath.replace('.h5', '_scaler.pkl')
        with open(scaler_path, 'wb') as f:
            pickle.dump(self.scaler, f)
        
        print(f"Model saved to {filepath}")
        print(f"Scaler saved to {scaler_path}")


def main():
    """Main training function"""
    import yfinance as yf
    
    # Fetch historical data
    print("Fetching historical data...")
    ticker = yf.Ticker("AAPL")
    df = ticker.history(period="2y", interval="1h")
    
    if df.empty:
        print("Failed to fetch data. Using sample data...")
        # Generate sample data
        dates = pd.date_range(start='2022-01-01', periods=2000, freq='1h')
        df = pd.DataFrame({
            'Open': np.random.randn(2000).cumsum() + 150,
            'High': np.random.randn(2000).cumsum() + 152,
            'Low': np.random.randn(2000).cumsum() + 148,
            'Close': np.random.randn(2000).cumsum() + 150,
            'Volume': np.random.randint(1000000, 10000000, 2000)
        }, index=dates)
    
    # Train model
    print("Training model...")
    trainer = TradingModelTrainer(model_type="lstm")
    trainer.train(df, epochs=20, batch_size=32, sequence_length=60)
    
    # Save model
    os.makedirs("../../models", exist_ok=True)
    trainer.save_model("../../models/trading_model.h5")
    
    print("Training completed!")


if __name__ == "__main__":
    main()

