import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'help_screen.dart';
import '../services/favorites_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Map<String, dynamic> user = {
      'name': 'Carlos Silva',
      'username': '@carlosskate',
      'bio': 'Skatista há 5 anos. Especialista em manobras de street.',
      'level': 'Intermediário',
      'favoriteSpot': 'Skatepark Central',
      'sessionsCount': 47,
      'totalTime': '120h',
    };

  final FavoritesService _favoritesService = FavoritesService();

  // Lista de acessos recentes
  final List<Map<String, dynamic>> _recentAccesses = [
    {
      'name': 'Skate Park Central',
      'date': '15/01/2024',
      'rating': 4.5,
    },
    {
      'name': 'Pista do Ibirapuera',
      'date': '12/01/2024',
      'rating': 4.0,
    },
    {
      'name': 'Bowl da Vila Madalena',
      'date': '10/01/2024',
      'rating': 5.0,
    },
  ];

  int _getRecentAccessesCount() {
    return _recentAccesses.length;
  }

  @override
  void initState() {
    super.initState();
    _favoritesService.addListener(_onFavoritesUpdated);
  }

  @override
  void dispose() {
    _favoritesService.removeListener(_onFavoritesUpdated);
    super.dispose();
  }

  void _onFavoritesUpdated() {
    setState(() {});
  }

  void _showMaxFavoritesWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Você pode ter no máximo ${FavoritesService.maxFavoriteParks} pistas favoritas'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showFavoriteParkDetails(BuildContext context, Map<String, dynamic> park) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(park['image'] as String),
                    fit: BoxFit.cover,
                    onError: (error, stackTrace) {},
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    park['name'] as String,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Colors.black,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    park['type'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    park['address'] as String? ?? 'Endereço não disponível',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Aberto das ${park['hours'] as String? ?? '6h às 22h'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${park['rating']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  park['distance'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _favoritesService.removeFromFavorites(park['name'] as String);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Removido dos favoritos')),
                  );
                },
                icon: const Icon(Icons.favorite),
                label: const Text('Remover dos Favoritos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecentAccessesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Acessos Recentes'),
          content: SizedBox(
            width: double.maxFinite,
            child: _recentAccesses.isEmpty
                ? const Text('Nenhuma pista visitada recentemente.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _recentAccesses.length,
                    itemBuilder: (context, index) {
                      final access = _recentAccesses[index];
                      return ListTile(
                        leading: const Icon(Icons.skateboarding, color: Colors.green),
                        title: Text(access['name']),
                        subtitle: Text('Visitado em: ${access['date']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            Text('${access['rating']}'),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            title: const Text(
              'Perfil',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade300,
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user['name'] as String,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['username'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user['bio'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Action Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Editar Perfil'),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Profile Info Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => _showRecentAccessesDialog(context),
                        child: _buildInfoCard(
                          Icons.history,
                          'Acessos Recentes',
                          '${_getRecentAccessesCount()} pistas visitadas',
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Favorite Parks Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Pistas Favoritas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_favoritesService.favoriteParks.length}/${FavoritesService.maxFavoriteParks}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _favoritesService.favoriteParks.isNotEmpty
                    ? SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _favoritesService.favoriteParks.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final park = _favoritesService.favoriteParks[index];
                            return GestureDetector(
                              onTap: () => _showFavoriteParkDetails(context, park),
                              child: Container(
                                width: 200,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: AssetImage(park['image'] as String),
                                    fit: BoxFit.cover,
                                    onError: (error, stackTrace) {},
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.7),
                                      ],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        park['name'] as String,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              park['type'] as String,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          const Icon(Icons.star, color: Colors.amber, size: 12),
                                          const SizedBox(width: 2),
                                          Text(
                                            park['rating'].toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        height: 120,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 32,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Você ainda não possui pistas favoritas',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                const SizedBox(height: 30),

                // Menu Options
                _buildMenuOption(Icons.settings, 'Configurações', () {
                  Navigator.pushNamed(context, '/settings');
                }),
                _buildMenuOption(Icons.help, 'Ajuda', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpScreen(),
                    ),
                  );
                }),
                _buildMenuOption(Icons.logout, 'Sair', () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                }, isDestructive: true),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildInfoCard(IconData icon, String title, String subtitle, Color color) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuOption(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return ListTile(
          leading: Icon(
            icon,
            color: isDestructive 
                ? Colors.red 
                : (isDark ? Colors.white70 : Colors.grey.shade700),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isDestructive 
                  ? Colors.red 
                  : (isDark ? Colors.white : Colors.black),
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isDark ? Colors.white70 : Colors.grey.shade600,
          ),
          onTap: onTap,
        );
      },
    );
  }




}
