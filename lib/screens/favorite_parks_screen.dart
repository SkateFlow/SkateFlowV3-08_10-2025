import 'package:flutter/material.dart';

class FavoriteParksScreen extends StatelessWidget {
  const FavoriteParksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteParks = [
      {
        'name': 'Skate City',
        'type': 'Street',
        'distance': '1.2 km',
        'rating': 4.5,
        'image': 'assets/images/skateparks/SkateCity.png',
      },
      {
        'name': 'Rajas Skatepark',
        'type': 'Bowl',
        'distance': '2.5 km',
        'rating': 4.8,
        'image': 'assets/images/skateparks/Rajas1.png',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pistas Favoritas',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.grey.shade600,
        foregroundColor: Colors.white,
      ),
      body: favoriteParks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma pista favorita',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione pistas aos favoritos para vê-las aqui',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteParks.length,
              itemBuilder: (context, index) {
                final park = favoriteParks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade300,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          park['image'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.skateboarding,
                              color: Colors.grey.shade600,
                              size: 30,
                            );
                          },
                        ),
                      ),
                    ),
                    title: Text(
                      park['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade700,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                park['type'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 2),
                            Text(
                              park['distance'] as String,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              park['rating'].toString(),
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Removido dos favoritos')),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
