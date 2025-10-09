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
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(park['image'] as String),
                          fit: BoxFit.cover,
                          onError: (error, stackTrace) {},
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.7),
                              Colors.white.withValues(alpha: 0.95),
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                        child: InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Container(),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      park['name'] as String,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800, 
                                          fontSize: 17,
                                          color: Colors.black,
                                          letterSpacing: 0.3),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.black87,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            park['type'] as String,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                                letterSpacing: 0.5),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.location_on,
                                            size: 14, color: Colors.black54),
                                        const SizedBox(width: 2),
                                        Text(park['distance'] as String,
                                            style: const TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 13)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star,
                                            size: 16, color: Colors.amber),
                                        const SizedBox(width: 4),
                                        Text(
                                          park['rating'].toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                              fontSize: 14),
                                        ),
                                        const SizedBox(width: 12),
                                        GestureDetector(
                                          onTap: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Removido dos favoritos')),
                                            );
                                          },
                                          child: const Icon(Icons.favorite, color: Colors.red, size: 20),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
