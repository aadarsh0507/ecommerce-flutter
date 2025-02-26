import 'package:flutter/material.dart';

class TrendingPage extends StatelessWidget {
  const TrendingPage({super.key});

  final List<Map<String, String>> trendingItems = const [
    {
      'title': 'New Smartwatches!',
      'description':
          'Check out the latest smartwatches with advanced features.',
      'image': 'trending/smartwatch.jpg',
    },
    {
      'title': 'Fashion Sale!',
      'description': 'Get the hottest fashion trends at discounted prices.',
      'image': 'trending/fashion.jpg',
    },
    {
      'title': 'Latest Sneakers!',
      'description': 'New stylish sneakers are now available in stock.',
      'image': 'trending/shoes.jpg',
    },
    {
      'title': 'Gaming Gadgets!',
      'description': 'Upgrade your gaming experience with the newest gadgets.',
      'image': 'trending/gadgets.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.deepPurple),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: trendingItems.length,
        itemBuilder: (context, index) {
          final item = trendingItems[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: Image.asset(
                    item['image']!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => const Icon(
                          Icons.image_not_supported,
                          size: 100,
                          color: Colors.grey,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item['description']!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.favorite_border,
                              color: Colors.red,
                            ),
                            onPressed: () {},
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text('Shop Now'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
