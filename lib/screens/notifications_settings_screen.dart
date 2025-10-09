import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _eventsNotifications = true;
  bool _nearbyParksNotifications = true;
  bool _promotionsNotifications = false;
  bool _socialNotifications = true;
  bool _systemNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _eventsNotifications = prefs.getBool('events_notifications') ?? true;
      _nearbyParksNotifications = prefs.getBool('nearby_parks_notifications') ?? true;
      _promotionsNotifications = prefs.getBool('promotions_notifications') ?? false;
      _socialNotifications = prefs.getBool('social_notifications') ?? true;
      _systemNotifications = prefs.getBool('system_notifications') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notificações',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00294F).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00294F).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF00294F)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Configure quais notificações você deseja receber',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : const Color(0xFF00294F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          _buildSectionTitle('Eventos e Atividades'),
          _buildNotificationTile(
            'Novos eventos',
            'Receba notificações sobre eventos próximos',
            Icons.event,
            _eventsNotifications,
            (value) {
              setState(() => _eventsNotifications = value);
              _saveSetting('events_notifications', value);
            },
          ),
          _buildNotificationTile(
            'Pistas próximas',
            'Notificações sobre novas pistas na sua região',
            Icons.location_on,
            _nearbyParksNotifications,
            (value) {
              setState(() => _nearbyParksNotifications = value);
              _saveSetting('nearby_parks_notifications', value);
            },
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Marketing'),
          _buildNotificationTile(
            'Promoções',
            'Ofertas especiais e descontos',
            Icons.local_offer,
            _promotionsNotifications,
            (value) {
              setState(() => _promotionsNotifications = value);
              _saveSetting('promotions_notifications', value);
            },
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Social'),
          _buildNotificationTile(
            'Atividade social',
            'Novos seguidores e interações',
            Icons.people,
            _socialNotifications,
            (value) {
              setState(() => _socialNotifications = value);
              _saveSetting('social_notifications', value);
            },
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Sistema'),
          _buildNotificationTile(
            'Atualizações do sistema',
            'Informações importantes sobre o app',
            Icons.system_update,
            _systemNotifications,
            (value) {
              setState(() => _systemNotifications = value);
              _saveSetting('system_notifications', value);
            },
          ),
          
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.settings, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Configurações do Sistema',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Para configurações avançadas de notificação, acesse as configurações do seu dispositivo.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white 
              : Colors.black,
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: value ? const Color(0xFF00294F).withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: value ? const Color(0xFF00294F) : Colors.grey,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),
        value: value,
        onChanged: onChanged
      ),
    );
  }
}
