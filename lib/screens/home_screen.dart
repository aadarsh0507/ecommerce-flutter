import 'package:flutter/material.dart';
import 'trendingpage.dart';
import 'orders_page.dart';
import 'profile_page.dart';
import 'cart_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> cart = [];
  List<Map<String, dynamic>> orders = [];

  final List<Map<String, dynamic>> products = [
    {'name': 'Cosmetics', 'price': 600.00, 'image': 'assets/products/product1.jpg'},
    {'name': 'Watches', 'price': 1500.00, 'image': 'assets/products/product2.jpg'},
    {'name': 'T-Shirts', 'price': 200.00, 'image': 'assets/products/product3.jpg'},
    {'name': 'Chains', 'price': 500.00, 'image': 'assets/products/product4.jpg'},
    {'name': 'Shoes', 'price': 600.00, 'image': 'assets/products/product5.jpg'},
    {'name': 'School Bags', 'price': 400.00, 'image': 'assets/products/product6.jpg'},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

void showSnackBar(String message, Color color) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Dismiss any previous Snackbar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: const Duration(milliseconds: 700), // Short duration for quick updates
    ),
  );
}

void addToCart(Map<String, dynamic> product) {
  setState(() {
    int index = cart.indexWhere((item) => item['name'] == product['name']);
    if (index != -1) {
      cart[index]['quantity'] += 1;
    } else {
      cart.add({...product, 'quantity': 1});
    }
  });

  showSnackBar('${product['name']} added to cart!', Colors.green);
}

void removeFromCart(int index) {
  setState(() {
    cart.removeAt(index);
  });

  showSnackBar("Item removed from cart", Colors.red);
}

void placeOrder() {
  setState(() {
    orders.addAll(cart);
    cart.clear();
  });

  showSnackBar("Order placed successfully!", Colors.blue);
}

  List<Widget> _pages() {
    return [
      _buildHomeScreen(),
      TrendingPage(),
      OrdersPage(orders: orders, onCancelOrder: (index) => setState(() => orders.removeAt(index))),
      ProfilePage(userName: "", userEmail: "", onLogout: () => print("User logged out")),
    ];
  }

  Widget _buildHomeScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text("E-Commerce App"), backgroundColor: Colors.deepPurple),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(image: AssetImage('assets/banner/banner.jfif'), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 10),
          const Text("Welcome to Our Store", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: products.length,
              itemBuilder: (ctx, index) {
                final product = products[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          child: Image.asset(product['image'], width: double.infinity, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 5),
                      Text("₹${product['price'].toStringAsFixed(2)}", style: const TextStyle(color: Colors.green, fontSize: 14)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => addToCart(product),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                        child: const Text("Add to Cart"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartPage(cart: cart, onPlaceOrder: placeOrder, onRemoveFromCart: removeFromCart),
            ),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: Stack(
          children: [
            const Icon(Icons.shopping_cart, size: 28),
            if (cart.isNotEmpty)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: Text(cart.length.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: "Trending"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
