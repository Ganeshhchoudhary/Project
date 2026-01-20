import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/market_data.dart';

class MarketDataCard extends StatelessWidget {
  final MarketData? marketData;
  final bool isLoading;

  const MarketDataCard({
    super.key,
    required this.marketData,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && marketData == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (marketData == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No market data available'),
        ),
      );
    }

    final priceFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final percentFormat = NumberFormat.decimalPercentPattern(decimalDigits: 2);
    final volumeFormat = NumberFormat.compact();

    final changeColor = (marketData!.changePercent ?? 0) >= 0
        ? Colors.green
        : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  marketData!.symbol,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (marketData!.changePercent != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: changeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          marketData!.changePercent! >= 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: changeColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          percentFormat.format(
                            marketData!.changePercent! / 100,
                          ),
                          style: TextStyle(
                            color: changeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      priceFormat.format(marketData!.price),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Volume',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      volumeFormat.format(marketData!.volume),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  context,
                  'High',
                  priceFormat.format(marketData!.high ?? marketData!.price),
                ),
                _buildInfoItem(
                  context,
                  'Low',
                  priceFormat.format(marketData!.low ?? marketData!.price),
                ),
                _buildInfoItem(
                  context,
                  'Open',
                  priceFormat.format(marketData!.open),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Updated: ${DateFormat('HH:mm:ss').format(marketData!.timestamp)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

