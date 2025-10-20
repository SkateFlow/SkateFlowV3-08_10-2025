import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/app_constants.dart';
import 'screens/login_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/skateparks_screen.dart';
import 'screens/events_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'services/sync_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const SkateApp());
}

class SkateApp extends StatelessWidget {
  const SkateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkateFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(AppConstants.darkBlue),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.lexendTextTheme().copyWith(
          // Fallback para fontes do sistema
          bodyLarge: const TextStyle(fontFamily: 'Roboto'),
          bodyMedium: const TextStyle(fontFamily: 'Roboto'),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey.shade600,
          foregroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto', // Fallback
          ),
        ),
      ),
      home: const LoginScreen(),
      routes: {
        '/loading': (context) => const LoadingScreen(),
        '/main': (context) => const MainScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  final Map<int, Widget> _screens = {};
  final SyncService _syncService = SyncService();
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _screens[_currentIndex] = _getScreen(_currentIndex);
    _syncService.startSync();
  }

  @override
  void dispose() {
    _syncService.stopSync();
    super.dispose();
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0: return const HomeScreen();
      case 1: return const MapScreen();
      case 2: return const SkateparksScreen();
      case 3: return const EventsScreen();
      case 4: return const ProfileScreen();
      default: return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex] ?? _getScreen(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            setState(() {
              _currentIndex = index;
              // Carrega a tela apenas quando necessário
              if (!_screens.containsKey(index)) {
                _screens[index] = _getScreen(index);
              }
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(AppConstants.darkBlue),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.skateboarding),
            label: 'Pistas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Eventos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
