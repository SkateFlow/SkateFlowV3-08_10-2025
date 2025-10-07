import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/skatepark_service.dart';
import '../models/skatepark.dart';

class SkateparksScreen extends StatefulWidget {
  const SkateparksScreen({super.key});

  @override
  State<SkateparksScreen> createState() => _SkateparksScreenState();
}

class _SkateparksScreenState extends State<SkateparksScreen> {
  final Map<int, PageController> _pageControllers = {};
  final Map<int, int> _currentPages = {};
  final Map<int, Timer> _timers = {};
  
  String _selectedDistance = 'Todas';
  double _selectedRating = 0.0;
  String _selectedType = 'Todos';
  String _selectedHours = 'Todos';
  String _searchQuery = '';
  List<Skatepark> _filteredSkateparks = [];
  Position? _currentPosition;
  final SkateparkService _skateparkService = SkateparkService();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _skateparkService.addListener(_onSkateparksUpdated);
  }

  void _onSkateparksUpdated() {
    _applyFilters();
  }

  @override
  void dispose() {
    _skateparkService.removeListener(_onSkateparksUpdated);
    _searchController.dispose();
    for (final controller in _pageControllers.values) {
      controller.dispose();
    }
    for (final timer in _timers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.denied) {
        _currentPosition = await Geolocator.getCurrentPosition();
      }
    } catch (e) {
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
    }
    _applyFilters();
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

  void _applyFilters() {
    final skateparks = _skateparkService.getAllSkateparks();

    setState(() {
      _filteredSkateparks = skateparks.where((park) {
        if (_selectedDistance != 'Todas' && _currentPosition != null) {
          double distance = Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            park.lat,
            park.lng,
          ) / 1000;
          switch (_selectedDistance) {
            case 'Até 1 km':
              if (distance > 1.0) return false;
              break;
            case '1-3 km':
              if (distance <= 1.0 || distance > 3.0) return false;
              break;
            case 'Mais de 3 km':
              if (distance <= 3.0) return false;
              break;
          }
        }

        if (_selectedRating > 0 && park.rating < _selectedRating) {
          return false;
        }

        if (_selectedType != 'Todos' && park.type != _selectedType) {
          return false;
        }

        if (_selectedHours != 'Todos') {
          String hours = park.hours;
          switch (_selectedHours) {
            case 'Manhã (6h-12h)':
              if (!hours.contains('6h') && !hours.contains('7h') && !hours.contains('8h')) return false;
              break;
            case 'Tarde (12h-18h)':
              if (!hours.contains('18h') && !hours.contains('20h') && !hours.contains('22h')) return false;
              break;
            case 'Noite (18h-22h)':
              if (!hours.contains('20h') && !hours.contains('22h')) return false;
              break;
          }
        }

        // Filtro de pesquisa
        if (_searchQuery.isNotEmpty) {
          return park.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 park.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 park.type.toLowerCase().contains(_searchQuery.toLowerCase());
        }

        return true;
      }).toList();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Pistas',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.grey.shade600,
        foregroundColor: Colors.white,
        actions: [
          Container(
            width: 200,
            margin: const EdgeInsets.only(right: 8),
            height: 40,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _applyFilters();
              },
              decoration: InputDecoration(
                hintText: 'Pesquisar pistas...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFiltersDialog(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredSkateparks.length,
        itemBuilder: (context, index) {
          final park = _filteredSkateparks[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showParkDetails(context, park),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 250,
                  child: Stack(
                    children: [
                      _buildImageCarousel(
                        park.images, 
                        index,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      park.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      park.type,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Text(
                                    _calculateDistance(park.lat, park.lng),
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.star, size: 16, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    park.rating.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showParkDetails(BuildContext context, Skatepark park) {
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
                const SizedBox(height: 4),
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
                  children: park.features.map((feature) => 
                    Chip(
                      label: Text(
                        feature,
                        style: const TextStyle(color: Colors.black),
                      ),
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ).toList(),
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

  Widget _buildImageCarousel(List<String> images, int carouselIndex) {
    _pageControllers[carouselIndex] ??= PageController();
    _currentPages[carouselIndex] ??= 0;
    
    return Stack(
      children: [
        PageView.builder(
          controller: _pageControllers[carouselIndex],
          itemCount: images.length,
          onPageChanged: (pageIndex) {
            setState(() {
              _currentPages[carouselIndex] = pageIndex;
            });
          },
          itemBuilder: (context, index) {
            return GestureDetector(
              onPanStart: (details) {
                _timers[carouselIndex]?.cancel();
              },
              onPanUpdate: (details) {
                if (details.delta.dx.abs() > 5) {
                  if (details.delta.dx > 0) {
                    final currentPage = _currentPages[carouselIndex] ?? 0;
                    if (currentPage > 0) {
                      _pageControllers[carouselIndex]?.previousPage(
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.fastEaseInToSlowEaseOut,
                      );
                    }
                  } else {
                    final currentPage = _currentPages[carouselIndex] ?? 0;
                    if (currentPage < images.length - 1) {
                      _pageControllers[carouselIndex]?.nextPage(
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.fastEaseInToSlowEaseOut,
                      );
                    }
                  }
                }
              },
              child: Image.asset(
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
                          size: 40,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Imagem não encontrada',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
        if (images.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.asMap().entries.map((entry) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPages[carouselIndex] == entry.key
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                  ),
                );
              }).toList(),
            ),
          ),
        if (images.length > 1) ...[
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  final currentPage = _currentPages[carouselIndex] ?? 0;
                  if (currentPage > 0) {
                    _pageControllers[carouselIndex]?.previousPage(
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.fastEaseInToSlowEaseOut,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  final currentPage = _currentPages[carouselIndex] ?? 0;
                  if (currentPage < images.length - 1) {
                    _pageControllers[carouselIndex]?.nextPage(
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.fastEaseInToSlowEaseOut,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildModalImageCarousel(List<String> images) {
    int currentModalPage = 0;
    PageController modalController = PageController();
    
    return StatefulBuilder(
      builder: (context, setModalState) {
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
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
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

  void _showFiltersDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Filtros',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      _buildFilterSection('Distância', Icons.location_on, isDark, [
                        _buildRadioOption('Todas', _selectedDistance, (value) {
                          setDialogState(() => _selectedDistance = value!);
                        }, isDark),
                        _buildRadioOption('Até 1 km', _selectedDistance, (value) {
                          setDialogState(() => _selectedDistance = value!);
                        }, isDark),
                        _buildRadioOption('1-3 km', _selectedDistance, (value) {
                          setDialogState(() => _selectedDistance = value!);
                        }, isDark),
                        _buildRadioOption('Mais de 3 km', _selectedDistance, (value) {
                          setDialogState(() => _selectedDistance = value!);
                        }, isDark),
                      ]),
                      
                      const SizedBox(height: 16),
                      
                      _buildFilterSection('Avaliação Mínima', Icons.star, isDark, [
                        Slider(
                          value: _selectedRating,
                          min: 0.0,
                          max: 5.0,
                          divisions: 10,
                          label: _selectedRating == 0.0 ? 'Todas' : '${_selectedRating.toStringAsFixed(1)} estrelas',
                          onChanged: (value) {
                            setDialogState(() => _selectedRating = value);
                          },
                        ),
                      ]),
                      
                      const SizedBox(height: 16),
                      
                      _buildFilterSection('Tipo de Pista', Icons.skateboarding, isDark, [
                        _buildRadioOption('Todos', _selectedType, (value) {
                          setDialogState(() => _selectedType = value!);
                        }, isDark),
                        _buildRadioOption('Street', _selectedType, (value) {
                          setDialogState(() => _selectedType = value!);
                        }, isDark),
                        _buildRadioOption('Bowl', _selectedType, (value) {
                          setDialogState(() => _selectedType = value!);
                        }, isDark),
                        _buildRadioOption('Plaza', _selectedType, (value) {
                          setDialogState(() => _selectedType = value!);
                        }, isDark),
                      ]),
                      
                      const SizedBox(height: 16),
                      
                      _buildFilterSection('Horário', Icons.access_time, isDark, [
                        _buildRadioOption('Todos', _selectedHours, (value) {
                          setDialogState(() => _selectedHours = value!);
                        }, isDark),
                        _buildRadioOption('Manhã (6h-12h)', _selectedHours, (value) {
                          setDialogState(() => _selectedHours = value!);
                        }, isDark),
                        _buildRadioOption('Tarde (12h-18h)', _selectedHours, (value) {
                          setDialogState(() => _selectedHours = value!);
                        }, isDark),
                        _buildRadioOption('Noite (18h-22h)', _selectedHours, (value) {
                          setDialogState(() => _selectedHours = value!);
                        }, isDark),
                      ]),
                      
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                setDialogState(() {
                                  _selectedDistance = 'Todas';
                                  _selectedRating = 0.0;
                                  _selectedType = 'Todos';
                                  _selectedHours = 'Todos';
                                });
                              },
                              child: const Text('Limpar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _applyFilters();
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? Colors.white : Colors.black,
                                foregroundColor: isDark ? Colors.black : Colors.white,
                              ),
                              child: const Text('Aplicar'),
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
        );
      },
    );
  }

  Widget _buildFilterSection(String title, IconData icon, bool isDark, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: isDark ? Colors.white70 : Colors.black54, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildRadioOption(String title, String groupValue, ValueChanged<String?> onChanged, bool isDark) {
    bool isSelected = title == groupValue;
    return InkWell(
      onTap: () => onChanged(title),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? Colors.blue : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}