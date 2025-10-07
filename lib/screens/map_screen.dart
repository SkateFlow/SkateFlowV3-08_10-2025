import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/skatepark_service.dart';
import '../models/skatepark.dart';

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
      // Verifica se o serviço de localização está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Serviço de localização desabilitado');
      }
      
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 10),
        ),
      );
      
      debugPrint('Localização obtida: ${position.latitude}, ${position.longitude}');
      debugPrint('Precisão: ${position.accuracy}m');
      
      setState(() {
        _currentPosition = position;
      });
      
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        16,
      );
    } catch (e) {
      debugPrint('Erro ao obter localização: $e');
      // Tenta novamente com configurações menos restritivas
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 30),
          ),
        );
        
        setState(() {
          _currentPosition = position;
        });
        
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          16,
        );
      } catch (e2) {
        debugPrint('Erro ao obter localização (segunda tentativa): $e2');
        // Só usa localização padrão se realmente não conseguir
        final defaultPosition = Position(
          latitude: -23.5505,
          longitude: -46.6333,
          timestamp: DateTime.now(),
          accuracy: 10,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
        
        setState(() {
          _currentPosition = defaultPosition;
        });
        
        _mapController.move(
          LatLng(defaultPosition.latitude, defaultPosition.longitude),
          14,
        );
      }
    }
  }
  
  void _loadSkateparks() {
    final skateparks = _skateparkService.getAllSkateparks();
    final filteredParks = _applyFilters(skateparks);
    
    setState(() {
      _markers.clear();
      for (final park in filteredParks) {
        _markers.add(
          Marker(
            point: LatLng(
              park.lat,
              park.lng,
            ),
            child: GestureDetector(
              onTap: () => _showParkDetails(park),
              child: const Icon(
                Icons.location_on,
                color: Color(0xFF00294F),
                size: 40,
              ),
            ),
          ),
        );
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
                        _openWaze(park.lat, park.lng, park.address);
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
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.7,
        builder: (context, scrollController) => Column(
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
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 200,
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
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            park.type,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      park.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(Icons.location_on, park.address),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.access_time, 'Aberto das ${park.hours}'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.directions, _calculateDistance(park.lat, park.lng)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${park.rating} estrelas',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Estruturas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: park.features
                          .map(
                            (feature) => Chip(
                              label: Text(
                                feature,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.black
                                      : Colors.black,
                                ),
                              ),
                              backgroundColor: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade200,
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _openWaze(park.lat, park.lng, park.address),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Como Chegar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Favoritar'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
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
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
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
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.grey.shade600,
        foregroundColor: Colors.white,
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
                initialZoom: 14,
                maxZoom: 19,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        backgroundColor: const Color(0xFF3888D2),
        foregroundColor: Colors.white,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  void _openWaze(double lat, double lng, [String? address]) async {
    String wazeUrl;
    String fallbackUrl;
    
    if (address != null && address.isNotEmpty) {
      // Usa o endereço para navegação mais precisa
      final encodedAddress = Uri.encodeComponent(address);
      wazeUrl = 'waze://?q=$encodedAddress&navigate=yes';
      fallbackUrl = 'https://waze.com/ul?q=$encodedAddress&navigate=yes';
    } else {
      // Fallback para coordenadas
      wazeUrl = 'waze://?ll=$lat,$lng&navigate=yes';
      fallbackUrl = 'https://waze.com/ul?ll=$lat,$lng&navigate=yes';
    }
    
    try {
      if (await canLaunchUrl(Uri.parse(wazeUrl))) {
        await launchUrl(Uri.parse(wazeUrl), mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(Uri.parse(fallbackUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Se falhar, tenta com coordenadas como último recurso
      final coordUrl = 'https://waze.com/ul?ll=$lat,$lng&navigate=yes';
      await launchUrl(Uri.parse(coordUrl), mode: LaunchMode.externalApplication);
    }
  }
}