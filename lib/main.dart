import 'package:flutter/material.dart';

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
import 'utils/performance_optimizer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PerformanceOptimizer.optimizeApp();
  PerformanceOptimizer.optimizeImageCache();
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
          seedColor: const Color(0xFF043C70),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        textTheme: GoogleFonts.lexendTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFFFFFFF),
          foregroundColor: const Color(0xFF000000),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: const Color(0xFF000000),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: GoogleFonts.lexend().fontFamily,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF043C70),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFFFFFF),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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

class _MainScreenState extends State<MainScreen> with AutomaticKeepAliveClientMixin {
  late int _currentIndex;
  final Map<int, Widget> _screens = {};
  final SyncService _syncService = SyncService();
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // Carrega apenas a tela inicial
    _screens[_currentIndex] = _getScreen(_currentIndex);
    // Inicia sync apenas após 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _syncService.startSync();
    });
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
    super.build(context);
    return Scaffold(
      body: _screens[_currentIndex] ?? _getScreen(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            // Carrega a tela apenas quando necessário
            if (!_screens.containsKey(index)) {
              _screens[index] = _getScreen(index);
            }
            setState(() {
              _currentIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFFFFFF),
        selectedItemColor: const Color(0xFF043C70),
        unselectedItemColor: const Color(0xFF888888),
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontFamily: GoogleFonts.lexend().fontFamily,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: GoogleFonts.lexend().fontFamily,
          fontWeight: FontWeight.w500,
        ),
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
