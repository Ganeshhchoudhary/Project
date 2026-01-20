import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/market_data_provider.dart';
import '../providers/trading_provider.dart';
import '../models/trade_order.dart';

class TradingScreen extends StatefulWidget {
  const TradingScreen({super.key});

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> {
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  OrderType _selectedOrderType = OrderType.buy;
  bool _isMarketOrder = true;

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final marketProvider = context.watch<MarketDataProvider>();
    final tradingProvider = context.watch<TradingProvider>();
    final currentData = marketProvider.currentData;
    final signal = tradingProvider.currentSignal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Order'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Price
            if (currentData != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Current Price',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${currentData.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Trading Signal
            if (signal != null)
              Card(
                color: signal.action == OrderType.buy
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            signal.action == TradingAction.buy
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: signal.action == TradingAction.buy
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'AI Signal: ${signal.actionString}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Confidence: ${(signal.confidence * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Order Type Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Type',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Buy'),
                            selected: _selectedOrderType == OrderType.buy,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedOrderType = OrderType.buy;
                                });
                              }
                            },
                            selectedColor: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Sell'),
                            selected: _selectedOrderType == OrderType.sell,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedOrderType = OrderType.sell;
                                });
                              }
                            },
                            selectedColor: Colors.red.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Order Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Market/Limit Order Toggle
                    SwitchListTile(
                      title: const Text('Market Order'),
                      subtitle: const Text('Execute at current market price'),
                      value: _isMarketOrder,
                      onChanged: (value) {
                        setState(() {
                          _isMarketOrder = value;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Quantity
                    TextField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        hintText: 'Enter quantity',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    
                    // Price (for limit orders)
                    if (!_isMarketOrder)
                      TextField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'Limit Price',
                          hintText: 'Enter limit price',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.attach_money),
                          suffixText: currentData != null
                              ? 'Current: \$${currentData.price.toStringAsFixed(2)}'
                              : null,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Place Order Button
            ElevatedButton(
              onPressed: tradingProvider.isProcessing
                  ? null
                  : () async {
                      final quantity = double.tryParse(_quantityController.text);
                      if (quantity == null || quantity <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a valid quantity'),
                          ),
                        );
                        return;
                      }

                      double? price;
                      if (!_isMarketOrder) {
                        price = double.tryParse(_priceController.text);
                        if (price == null || price <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid price'),
                            ),
                          );
                          return;
                        }
                      }

                      await tradingProvider.createOrder(
                        symbol: currentData?.symbol ?? 'AAPL',
                        orderType: _selectedOrderType,
                        quantity: quantity,
                        price: price,
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order placed successfully'),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _selectedOrderType == OrderType.buy
                    ? Colors.green
                    : Colors.red,
                foregroundColor: Colors.white,
              ),
              child: tradingProvider.isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Place ${_selectedOrderType == OrderType.buy ? 'Buy' : 'Sell'} Order',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

