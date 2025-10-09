import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'favorite_parks_screen.dart';
import 'help_screen.dart';

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
                
                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showShareBottomSheet(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Compartilhar'),
                        ),
                      ),
                    ],
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
                
                // Menu Options

                _buildMenuOption(Icons.favorite, 'Pistas Favoritas', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoriteParksScreen(),
                    ),
                  );
                }),
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

  Widget _buildStatColumn(String label, String value) {
    return Builder(
      builder: (context) {
        return Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        );
      },
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

  void _showLevelInfo(BuildContext context, String level) {
    String emoji;
    String description;
    
    switch (level) {
      case 'Iniciante':
        emoji = '🙂';
        description = 'Você está começando sua jornada no skate! Aqui, o foco é aprender as bases, desenvolver equilíbrio, postura e dominar as primeiras manobras.';
        break;
      case 'Intermediário':
        emoji = '😀';
        description = 'Você já tem domínio das manobras básicas e busca novos desafios. É hora de aprimorar a técnica, aumentar a fluidez e explorar combinações mais complexas.';
        break;
      case 'Avançado':
        emoji = '😃';
        description = 'Você já domina o skate com confiança, executa manobras técnicas e cria seu próprio estilo. Agora, o objetivo é aperfeiçoar detalhes e elevar ainda mais o nível.';
        break;
      default:
        emoji = '🙂';
        description = 'Continue praticando para evoluir no skate!';
    }
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nível $level',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                  ),
                  child: const Text('Entendi'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showShareBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Compartilhar perfil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.link, color: isDark ? Colors.white : Colors.black),
                ),
                title: Text(
                  'Copiar link',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copiado para a área de transferência')),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF25D366),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chat,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                title: Text(
                  'WhatsApp',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                subtitle: Text(
                  'Compartilhar no WhatsApp',
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Compartilhado no WhatsApp')),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4405F).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE4405F), Color(0xFF833AB4), Color(0xFFF77737)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                title: Text(
                  'Instagram',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                subtitle: Text(
                  'Compartilhar no Instagram',
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Compartilhado no Instagram')),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
