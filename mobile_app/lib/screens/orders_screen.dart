import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/trading_provider.dart';
import '../models/trade_order.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TradingProvider>().loadOrders();
      context.read<TradingProvider>().processPendingOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tradingProvider = context.watch<TradingProvider>();
    final orders = tradingProvider.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              tradingProvider.loadOrders();
              tradingProvider.processPendingOrders();
            },
          ),
        ],
      ),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await tradingProvider.loadOrders();
                await tradingProvider.processPendingOrders();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: order.orderType == OrderType.buy
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        child: Icon(
                          order.orderType == OrderType.buy
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: order.orderType == OrderType.buy
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      title: Text(
                        '${order.orderType == OrderType.buy ? "Buy" : "Sell"} ${order.quantity} ${order.symbol}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (order.price != null)
                            Text('Price: \$${order.price!.toStringAsFixed(2)}'),
                          Text(
                            'Created: ${DateFormat('MMM dd, yyyy HH:mm').format(order.createdAt)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: _buildStatusChip(order.status),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    String label;

    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case OrderStatus.executed:
        color = Colors.green;
        label = 'Executed';
        break;
      case OrderStatus.cancelled:
        color = Colors.grey;
        label = 'Cancelled';
        break;
      case OrderStatus.failed:
        color = Colors.red;
        label = 'Failed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

