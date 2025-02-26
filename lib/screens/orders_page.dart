import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final Function(int) onCancelOrder;

  const OrdersPage({
    super.key,
    required this.orders,
    required this.onCancelOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
        backgroundColor: Colors.deepPurple,
      ),
      body:
          orders.isEmpty
              ? const Center(
                child: Text(
                  'No Orders Yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: orders.length,
                itemBuilder: (ctx, index) {
                  final order = orders[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Image.asset(
                        order['image'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                      ),
                      title: Text(
                        order['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Quantity: ${order['quantity']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$${(order['price'] * order['quantity']).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed:
                                () => _showCancelConfirmation(context, index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  void _showCancelConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Cancel Order"),
            content: const Text("Are you sure you want to cancel this order?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () {
                  onCancelOrder(index);
                  Navigator.of(ctx).pop();
                },
                child: const Text("Yes", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
