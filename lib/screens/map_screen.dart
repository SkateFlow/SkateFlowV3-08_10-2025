import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/skatepark_service.dart';
import '../models/skatepark.dart';
import '../widgets/create_pista_modal.dart';
import '../services/auth_service.dart';
import '../services/favorites_service.dart';
import '../constants/app_constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  final List<Marker> _markers = [];
  final SkateparkService _skateparkService = SkateparkService();
  final List<String> _selectedTypes = [];
  double _maxDistance = 50.0;
  final _authService = AuthService();
  final _favoritesService = FavoritesService();
  
  List<Skatepark>? _cachedSkateparks;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // Ignorar certificados SSL em desenvolvimento
    HttpOverrides.global = _MyHttpOverrides();
    _getCurrentLocation();
    _loadSkateparksFromBackend();
    _skateparkService.addListener(_onSkateparksUpdated);
    _favoritesService.carregarFavoritos();
  }

  Future<void> _loadSkateparksFromBackend() async {
    try {
      await _skateparkService.fetchFromServer();
      _loadSkateparks();
    } catch (e) {
      _loadSkateparks();
    }
  }

  @override
  void dispose() {
    _skateparkService.removeListener(_onSkateparksUpdated);
    super.dispose();
  }

  void _onSkateparksUpdated() {
    _loadSkateparks();
  }

  String _calculateDistance(double lat, double lng) {
    if (_currentPosition == null) return '-- km';
    
    double distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      lat,
      lng,
    ) / 1000;
    
    return '${distance.toStringAsFixed(1)} km';
  }
  
  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      Position position;
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        position = Position(
          latitude: -23.5505,
          longitude: -46.6333,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      } else {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
      }
      
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentPosition = Position(
            latitude: -23.5505,
            longitude: -46.6333,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        });
      }
    }
  }
  
  void _loadSkateparks() {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    final skateparks = _cachedSkateparks ?? _skateparkService.getAllSkateparks();
    _cachedSkateparks ??= skateparks;
    
    final filteredParks = _applyFilters(skateparks);
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _markers.clear();
          for (final park in filteredParks) {
            if (park.lat != 0.0 && park.lng != 0.0) {
              _markers.add(
                Marker(
                  point: LatLng(park.lat, park.lng),
                  child: GestureDetector(
                    onTap: () => _showParkDetails(park),
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFF00294F),
                      size: 32,
                    ),
                  ),
                ),
              );
            }
          }
          _isLoading = false;
        });
      }
    });
  }

  List<Skatepark> _applyFilters(List<Skatepark> parks) {
    return parks.where((park) {
      if (_selectedTypes.isNotEmpty && !_selectedTypes.contains(park.type)) {
        return false;
      }
      
      if (_currentPosition != null) {
        double distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          park.lat,
          park.lng,
        ) / 1000;
        
        if (distance > _maxDistance) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  void _showFilterDialog() {
    final allTypes = _skateparkService.getAllSkateparks()
        .map((park) => park.type)
        .toSet()
        .toList();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filtros'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tipos de Pista',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: allTypes.map((type) {
                    final isSelected = _selectedTypes.contains(type);
                    return FilterChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() {
                          if (selected) {
                            _selectedTypes.add(type);
                          } else {
                            _selectedTypes.remove(type);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Distância Máxima',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('${_maxDistance.round()} km'),
                Slider(
                  value: _maxDistance,
                  min: 1,
                  max: 100,
                  divisions: 99,
                  onChanged: (value) {
                    setDialogState(() {
                      _maxDistance = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialogState(() {
                  _selectedTypes.clear();
                  _maxDistance = 50.0;
                });
              },
              child: const Text('Limpar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _loadSkateparks();
              },
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showParkDetails(Skatepark park) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: 350,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      park.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      park.type,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: isDark ? Colors.white70 : Colors.black54),
                  const SizedBox(width: 4),
                  Text(
                    park.address,
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '${park.rating} estrelas',
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Estruturas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: park.features
                    .map((feature) => Chip(
                          label: Text(feature, style: const TextStyle(color: Colors.black)),
                          backgroundColor: Colors.grey.shade200,
                        ))
                    .toList(),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showNavigationOptions(park.lat, park.lng, park.address),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                      ),
                      child: const Text('Como Chegar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _toggleFavorite(park.id),
                      child: Text(_isFavorite(park.id) ? 'Favoritado' : 'Favoritar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Mapa',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _currentPosition == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando mapa...'),
                ],
              ),
            )
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                initialZoom: AppConstants.defaultZoom,
                maxZoom: 19,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.skateflow.app',
                  maxZoom: 19,
                  additionalOptions: const {
                    'crossOrigin': 'anonymous',
                  },
                ),
                MarkerLayer(
                  markers: [
                    ..._markers,
                    if (_currentPosition != null)
                      Marker(
                        point: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          width: 20,
                          height: 20,
                        ),
                      ),
                  ],
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () => _showCreatePistaModal(),
            backgroundColor: const Color(AppConstants.primaryBlue),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Solicitar Pista'),
            heroTag: 'add_pista',
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _getCurrentLocation,
            backgroundColor: const Color(AppConstants.primaryBlue),
            foregroundColor: Colors.white,
            heroTag: 'location',
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  void _showNavigationOptions(double lat, double lng, [String? address]) {
    _openGenericNavigation(lat, lng, address);
  }

  void _openGoogleMaps(double lat, double lng, [String? address]) async {
    String googleMapsUrl;
    
    if (address != null && address.isNotEmpty) {
      final encodedAddress = Uri.encodeComponent(address);
      googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
    } else {
      googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    }
    
    try {
      await launchUrl(Uri.parse(googleMapsUrl), mode: LaunchMode.externalApplication);
    } catch (e) {
      final coordUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
      await launchUrl(Uri.parse(coordUrl), mode: LaunchMode.externalApplication);
    }
  }

  void _openGenericNavigation(double lat, double lng, [String? address]) async {
    String geoUrl = 'geo:0,0?q=$lat,$lng';
    
    try {
      await launchUrl(Uri.parse(geoUrl), mode: LaunchMode.externalApplication);
    } catch (e) {
      _openGoogleMaps(lat, lng, address);
    }
  }

  void _showCreatePistaModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreatePistaModal(
        isUserLoggedIn: _authService.isLoggedIn,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  bool _isFavorite(String parkId) {
    return _favoritesService.isFavorite(parkId);
  }

  Future<void> _toggleFavorite(String parkId) async {
    if (_isFavorite(parkId)) {
      await _favoritesService.removeFromFavorites(parkId);
    } else {
      await _favoritesService.addToFavorites(parkId);
    }
    setState(() {});
  }
}

class _MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}