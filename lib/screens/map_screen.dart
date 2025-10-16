import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/skatepark_service.dart';
import '../models/skatepark.dart';
import '../widgets/create_pista_modal.dart';
import '../services/auth_service.dart';
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
  final Set<String> _favorites = <String>{};
  
  // Cache e debounce
  List<Skatepark>? _cachedSkateparks;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadSkateparks();
    _skateparkService.addListener(_onSkateparksUpdated);
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
    
    // Calcula distância em linha reta (haversine)
    double distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      lat,
      lng,
    );
    
    // Converte para km ou metros dependendo da distância
    if (distance < 1000) {
      return '${distance.round()} m';
    } else {
      // Adiciona aproximadamente 15-20% para estimar distância real por ruas
      double estimatedRoadDistance = (distance / 1000) * 1.18;
      return '${estimatedRoadDistance.toStringAsFixed(1)} km';
    }
  }
  
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Serviço de localização desabilitado');
      }
      
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
        ),
      );
      
      setState(() {
        _currentPosition = position;
      });
      
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        18,
      );
    } catch (e) {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );
      
      setState(() {
        _currentPosition = position;
      });
      
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        16,
      );
    }
  }
  
  void _loadSkateparks() {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    // Use cache se disponível
    final skateparks = _cachedSkateparks ?? _skateparkService.getAllSkateparks();
    _cachedSkateparks ??= skateparks;
    
    final filteredParks = _applyFilters(skateparks);
    
    // Debounce para evitar rebuilds frequentes
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _markers.clear();
          for (final park in filteredParks) {
            _markers.add(
              Marker(
                point: LatLng(park.lat, park.lng),
                child: GestureDetector(
                  onTap: () => _showParkDetails(park),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFF00294F),
                    size: 32, // Reduzido para melhor performance
                  ),
                ),
              ),
            );
          }
          _isLoading = false;
        });
      }
    });
  }

  List<Skatepark> _applyFilters(List<Skatepark> parks) {
    return parks.where((park) {
      // Filtro por tipo
      if (_selectedTypes.isNotEmpty && !_selectedTypes.contains(park.type)) {
        return false;
      }
      
      // Filtro por distância
      if (_currentPosition != null) {
        double distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          park.lat,
          park.lng,
        ) / 1000; // Converte para km
        
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
                  Icon(Icons.access_time, size: 16, color: isDark ? Colors.white70 : Colors.black54),
                  const SizedBox(width: 4),
                  Text(
                    'Aberto das ${park.hours}',
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
                      onPressed: () {
                        Navigator.pop(context);
                        _showFullParkDetails(park);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                      ),
                      child: const Text('Ver Mais'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showNavigationOptions(park.lat, park.lng, park.address);
                      },
                      child: const Text('Como Chegar'),
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

  void _showFullParkDetails(Skatepark park) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: _buildModalImageCarousel(park.images),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    park.name,
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    park.type,
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
            Text(
              park.description,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.grey.shade700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.location_on, park.address),
            const SizedBox(height: 6),
            _buildInfoRow(Icons.access_time, 'Aberto das ${park.hours}'),
            const SizedBox(height: 6),
            _buildInfoRow(Icons.directions, _calculateDistance(park.lat, park.lng)),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${park.rating} estrelas',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ],
            ),
            if (park.addedBy != null) const SizedBox(height: 6),
            if (park.addedBy != null)
              _buildInfoRow(Icons.person_add, 'Adicionado por: ${park.addedBy}'),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Estruturas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: park.features
                      .map(
                        (feature) => Chip(
                          label: Text(
                            feature,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                            ),
                          ),
                          backgroundColor: Colors.grey.shade200,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showNavigationOptions(park.lat, park.lng, park.address),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Como Chegar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _toggleFavorite(park.id),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(_isFavorite(park.id) ? 'Favoritado' : 'Favoritar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRatingDialog(park),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Avaliar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildModalImageCarousel(List<String> images) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        int currentModalPage = 0;
        PageController modalController = PageController();

        return Stack(
          children: [
            PageView.builder(
              controller: modalController,
              itemCount: images.length,
              onPageChanged: (pageIndex) {
                setModalState(() {
                  currentModalPage = pageIndex;
                });
              },
              itemBuilder: (context, index) {
                return Image.asset(
                  images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.skateboarding,
                            size: 60,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Imagem não encontrada',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            if (images.length > 1)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: images.asMap().entries.map((entry) {
                    return Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentModalPage == entry.key
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            if (images.length > 1)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${currentModalPage + 1}/${images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black,
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
                  urlTemplate: AppConstants.osmTileUrl,
                  userAgentPackageName: 'com.example.skateflow',
                  maxZoom: 19,
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
          // Botão Adicionar Pista
          FloatingActionButton.extended(
            onPressed: () => _showCreatePistaModal(),
            backgroundColor: const Color(AppConstants.primaryBlue),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Solicitar Pista'),
            heroTag: 'add_pista',
          ),
          const SizedBox(height: 16),
          // Botão Localização
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
    return _favorites.contains(parkId);
  }

  void _toggleFavorite(String parkId) {
    setState(() {
      if (_favorites.contains(parkId)) {
        _favorites.remove(parkId);
      } else {
        _favorites.add(parkId);
      }
    });
  }

  void _showRatingDialog(Skatepark park) {
    double rating = 0;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Avaliar ${park.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Dê sua nota:'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setDialogState(() {
                        rating = index + 1.0;
                      });
                    },
                    icon: Icon(
                      Icons.star,
                      color: index < rating ? Colors.amber : Colors.grey,
                      size: 32,
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: rating > 0 ? () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Avaliação de ${rating.toInt()} estrelas enviada!')),
                );
              } : null,
              child: const Text('Avaliar'),
            ),
          ],
        ),
      ),
    );
  }
}