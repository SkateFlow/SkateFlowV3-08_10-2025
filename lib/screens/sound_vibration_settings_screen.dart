import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class SoundVibrationSettingsScreen extends StatefulWidget {
  const SoundVibrationSettingsScreen({super.key});

  @override
  State<SoundVibrationSettingsScreen> createState() => _SoundVibrationSettingsScreenState();
}

class _SoundVibrationSettingsScreenState extends State<SoundVibrationSettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  double _vibrationIntensity = 0.8;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _vibrationIntensity = prefs.getDouble('vibration_intensity') ?? 0.8;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  Future<void> _testVibration() async {
    if (_vibrationEnabled && await Vibration.hasVibrator() == true) {
      final duration = (300 * _vibrationIntensity).round();
      await Vibration.vibrate(duration: duration);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Som e Vibração',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Som
          _buildSectionTitle('Som'),
          _buildSwitchTile(
            'Ativar som',
            'Sons gerais do aplicativo',
            Icons.volume_up,
            _soundEnabled,
            (value) {
              setState(() => _soundEnabled = value);
              _saveSetting('sound_enabled', value);
            },
          ),
          

          
          const SizedBox(height: 24),
          
          // Vibração
          _buildSectionTitle('Vibração'),
          _buildSwitchTile(
            'Ativar vibração',
            'Vibração para notificações e alertas',
            Icons.vibration,
            _vibrationEnabled,
            (value) {
              setState(() => _vibrationEnabled = value);
              _saveSetting('vibration_enabled', value);
            },
          ),
          
          if (_vibrationEnabled) ...[
            _buildSliderTile(
              'Intensidade da vibração',
              'Ajuste a força da vibração',
              Icons.vibration,
              Icons.vibration,
              _vibrationIntensity,
              (value) {
                setState(() => _vibrationIntensity = value);
                _saveSetting('vibration_intensity', value);
              },
            ),
            
            _buildTestTile(
              'Testar vibração',
              'Toque para testar a vibração atual',
              Icons.vibration,
              _testVibration,
            ),
          ],
          

          
          const SizedBox(height: 32),
          
          // Informações
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
                    'As configurações de som podem ser limitadas pelas configurações do sistema do seu dispositivo.',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : const Color(0xFF00294F),
                      fontSize: 14,
                    ),
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

  Widget _buildSwitchTile(
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

  Widget _buildSliderTile(
    String title,
    String subtitle,
    IconData iconMin,
    IconData iconMax,
    double value,
    Function(double) onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(iconMin, color: Colors.grey.shade600),
                Expanded(
                  child: Slider(
                    value: value,
                    onChanged: onChanged,
                    inactiveColor: Colors.grey.shade300,
                  ),
                ),
                Icon(iconMax, color: Colors.grey.shade600),
              ],
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildTestTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF00294F), size: 24),
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
        trailing: const Icon(Icons.play_arrow, color: Color(0xFF00294F)),
        onTap: onTap,
      ),
    );
  }
}
