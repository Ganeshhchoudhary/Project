"""
Market Data Collector Module
Collects real-time and historical market data from various sources
"""

import json
import time
import websocket
import threading
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Callable
import yfinance as yf
import pandas as pd
import requests


class MarketDataCollector:
    """Collects market data from multiple sources"""
    
    def __init__(self, symbol: str = "AAPL"):
        self.symbol = symbol
        self.ws = None
        self.is_running = False
        self.data_buffer = []
        self.callbacks = []
        
    def add_callback(self, callback: Callable):
        """Add callback function for real-time data updates"""
        self.callbacks.append(callback)
    
    def notify_callbacks(self, data: Dict):
        """Notify all registered callbacks"""
        for callback in self.callbacks:
            callback(data)
    
    def get_historical_data(self, period: str = "1y", interval: str = "1h") -> pd.DataFrame:
        """
        Fetch historical market data
        
        Args:
            period: Time period (1d, 5d, 1mo, 3mo, 6mo, 1y, 2y, 5y, 10y, ytd, max)
            interval: Data interval (1m, 2m, 5m, 15m, 30m, 60m, 90m, 1h, 1d, 5d, 1wk, 1mo, 3mo)
        
        Returns:
            DataFrame with OHLCV data
        """
        try:
            ticker = yf.Ticker(self.symbol)
            data = ticker.history(period=period, interval=interval)
            return data
        except Exception as e:
            print(f"Error fetching historical data: {e}")
            return pd.DataFrame()
    
    def start_websocket_stream(self, symbol: str):
        """
        Start WebSocket stream for real-time data
        Uses Alpha Vantage or similar API format
        """
        def on_message(ws, message):
            try:
                data = json.loads(message)
                market_data = {
                    'symbol': data.get('symbol', symbol),
                    'price': float(data.get('price', 0)),
                    'volume': int(data.get('volume', 0)),
                    'timestamp': datetime.now().isoformat(),
                    'change': float(data.get('change', 0)),
                    'change_percent': float(data.get('change_percent', 0))
                }
                self.data_buffer.append(market_data)
                self.notify_callbacks(market_data)
            except Exception as e:
                print(f"Error processing WebSocket message: {e}")
        
        def on_error(ws, error):
            print(f"WebSocket error: {error}")
        
        def on_close(ws, close_status_code, close_msg):
            print("WebSocket connection closed")
            self.is_running = False
        
        def on_open(ws):
            print(f"WebSocket connection opened for {symbol}")
            self.is_running = True
            # Subscribe to symbol
            subscribe_msg = json.dumps({
                "action": "subscribe",
                "symbols": symbol
            })
            ws.send(subscribe_msg)
        
        # WebSocket URL (placeholder - replace with actual API)
        ws_url = "wss://api.example.com/stream"  # Replace with actual WebSocket endpoint
        
        self.ws = websocket.WebSocketApp(
            ws_url,
            on_open=on_open,
            on_message=on_message,
            on_error=on_error,
            on_close=on_close
        )
        
        # Run in separate thread
        def run_ws():
            self.ws.run_forever()
        
        thread = threading.Thread(target=run_ws, daemon=True)
        thread.start()
        return thread
    
    def stop_stream(self):
        """Stop WebSocket stream"""
        if self.ws:
            self.ws.close()
        self.is_running = False
    
    def get_latest_data(self) -> Optional[Dict]:
        """Get the latest market data from buffer"""
        if self.data_buffer:
            return self.data_buffer[-1]
        return None
    
    def get_cached_data(self, count: int = 100) -> List[Dict]:
        """Get cached data from buffer"""
        return self.data_buffer[-count:] if len(self.data_buffer) >= count else self.data_buffer


class SentimentDataCollector:
    """Collects sentiment data from news and social media"""
    
    def __init__(self, symbol: str):
        self.symbol = symbol
        self.sentiment_scores = []
    
    def get_news_sentiment(self) -> float:
        """
        Get sentiment score from news articles
        Returns: Sentiment score between -1 (negative) and 1 (positive)
        """
        # Placeholder implementation
        # In production, integrate with news API like NewsAPI, Alpha Vantage, etc.
        return 0.0
    
    def calculate_sentiment_score(self, articles: List[Dict]) -> float:
        """
        Calculate sentiment score from news articles
        Args:
            articles: List of news articles with sentiment data
        Returns:
            Average sentiment score
        """
        if not articles:
            return 0.0
        
        scores = [article.get('sentiment', 0) for article in articles]
        return sum(scores) / len(scores) if scores else 0.0


if __name__ == "__main__":
    # Example usage
    collector = MarketDataCollector("AAPL")
    
    def on_data_update(data):
        print(f"Received data: {data}")
    
    collector.add_callback(on_data_update)
    
    # Fetch historical data
    historical = collector.get_historical_data(period="1mo", interval="1h")
    print(f"Historical data shape: {historical.shape}")
    print(historical.head())

