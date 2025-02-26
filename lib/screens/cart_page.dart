import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final VoidCallback onPlaceOrder;
  final Function(int) onRemoveFromCart;

  const CartPage({
    super.key,
    required this.cart,
    required this.onPlaceOrder,
    required this.onRemoveFromCart,
  });

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  double getTotalPrice() {
    return widget.cart.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  Future<void> createOrder() async {
    double totalAmount = getTotalPrice();
    if (totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cart is empty! Add items before checkout.")),
      );
      return;
    }

    try {
      var url = Uri.parse('http://192.168.101.45:3001/razorpay/create-order');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"amount": totalAmount}), // Send in rupees, backend converts to paise
      );

      if (response.statusCode == 200) {
        var orderData = jsonDecode(response.body);
        openCheckout(orderData['id'], totalAmount);
      } else {
        print("Failed to create order: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: Unable to create Razorpay order")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error. Try again.")),
      );
    }
  }

  void openCheckout(String orderId, double totalAmount) {
    var options = {
      'key': 'rzp_test_1EQ4K9B2xhOdm5r', // Replace with your Razorpay Key ID
      'amount': (totalAmount * 100).toInt(), // Convert to paise
      'currency': 'INR',
      'name': 'Your Company Name',
      'description': 'Order Payment',
      'order_id': orderId, // Ensure order ID is passed
      'prefill': {'contact': '1234567890', 'email': 'test@example.com'},
      'theme': {'color': '#F37254'},
      'external': {'wallets': ['paytm']}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("Error: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    var url = Uri.parse('http://192.168.101.45:3001/razorpay/verify-payment');
    var verifyResponse = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "razorpay_order_id": response.orderId,
        "razorpay_payment_id": response.paymentId,
        "razorpay_signature": response.signature
      }),
    );

    var jsonResponse = jsonDecode(verifyResponse.body);
    if (jsonResponse['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Successful!"), backgroundColor: Colors.green),
      );
      widget.onPlaceOrder();
      setState(() {
        widget.cart.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Verification Failed!"), backgroundColor: Colors.red),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}"), backgroundColor: Colors.red),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet Selected: ${response.walletName}"), backgroundColor: Colors.blue),
    );
  }

  void updateQuantity(int index, int change) {
    setState(() {
      widget.cart[index]['quantity'] += change;
      if (widget.cart[index]['quantity'] <= 0) {
        widget.onRemoveFromCart(index);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(change > 0 ? "Item added" : "Item removed")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.cart.isEmpty
                ? Center(
                    child: Text("Your cart is empty", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  )
                : ListView.builder(
                    itemCount: widget.cart.length,
                    itemBuilder: (ctx, index) {
                      final item = widget.cart[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: item['image'] != null && item['image'].startsWith('http')
                              ? Image.network(
                                  item['image'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : item['image'] != null
                                  ? Image.asset(
                                      item['image'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                          title: Text(item['name']),
                          subtitle: Text("₹${item['price']}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove, color: Colors.red),
                                onPressed: () => updateQuantity(index, -1),
                              ),
                              Text("${item['quantity']}", style: TextStyle(fontSize: 18)),
                              IconButton(
                                icon: Icon(Icons.add, color: Colors.green),
                                onPressed: () => updateQuantity(index, 1),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.only(bottom: 50),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                Text(
                  "Total: ₹${getTotalPrice().toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: createOrder,
                  icon: Icon(Icons.payment),
                  label: Text("Pay with Razorpay"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
