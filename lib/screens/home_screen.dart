import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../services/skatepark_service.dart';
import '../services/favorites_service.dart';
import '../services/event_service.dart';
import '../models/skatepark.dart';
import '../models/event.dart';
import 'rating_screen.dart';
import 'reviews_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _currentPosition;
  final List<Marker> _markers = [];
  final SkateparkService _skateparkService = SkateparkService();
  final FavoritesService _favoritesService = FavoritesService();
  final EventService _eventService = EventService();
  List<Event> _upcomingEvents = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadNearbyParks();
    _loadUpcomingEvents();
    _skateparkService.addListener(_onSkateparksUpdated);
    _favoritesService.addListener(_onFavoritesUpdated);
  }
  
  Future<void> _loadUpcomingEvents() async {
    try {
      final events = await _eventService.getUpcomingEvents(limit: 3);
      setState(() {
        _upcomingEvents = events;
      });
    } catch (e) {
      print('Erro ao carregar eventos: $e');
    }
  }

  @override
  void dispose() {
    _skateparkService.removeListener(_onSkateparksUpdated);
    _favoritesService.removeListener(_onFavoritesUpdated);
    super.dispose();
  }

  void _onSkateparksUpdated() {
    _loadNearbyParks();
  }

  void _onFavoritesUpdated() {
    setState(() {});
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

  List<Skatepark> _getNearbyParks(List<Skatepark> parks, int limit) {
    if (_currentPosition == null) return parks.take(limit).toList();
    
    // Ordena as pistas por distância
    parks.sort((a, b) {
      double distanceA = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        a.lat,
        a.lng,
      );
      double distanceB = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        b.lat,
        b.lng,
      );
      return distanceA.compareTo(distanceB);
    });
    
    return parks.take(limit).toList();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission != LocationPermission.denied) {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
        ),
      );
      setState(() {
        _currentPosition = position;
      });
    }
  }

  void _loadNearbyParks() {
    final parks = _skateparkService.getAllSkateparks();

    setState(() {
      _markers.clear();
      for (final park in parks) {
        _markers.add(
          Marker(
            point: LatLng(park.lat, park.lng),
            child: const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 30,
            ),
          ),
        );
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {

    // Pega as 3 pistas mais próximas
    final allParks = _skateparkService.getAllSkateparks();
    final nearbyParks = _getNearbyParks(allParks, 3);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Transform.translate(
          offset: const Offset(-20, 5),
          child: Image.asset(
            'assets/images/skateparks/logo-preta.png',
            height: 80,
            errorBuilder: (context, error, stackTrace) {
              return const Text(
                'SkateFlow',
                style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
              );
            },
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showAlertsDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          const SizedBox(
            width: 8,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, Skatista!',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Encontre as melhores pistas e eventos',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white.withValues(alpha: 0.8) 
                          : Colors.black.withValues(alpha: 0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Eventos em Destaque',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white 
                            : Colors.black),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>
                              const MainScreen(initialIndex: 3),
                        ),
                      );
                    },
                    child: const Text('Ver todos'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 160,
              child: _upcomingEvents.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum evento próximo',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _upcomingEvents.length,
                      itemBuilder: (context, index) {
                        final event = _upcomingEvents[index];
                        return GestureDetector(
                          onTap: () => _showEventDetails(context, event),
                    child: Container(
                      width: 320,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          width: 2,
                          color: Colors.transparent,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFF043C70),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF043C70),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        color: Colors.white, size: 16),
                                    const SizedBox(width: 6),
                                    Text(_formatDate(event.date),
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Colors.black54, size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      event.location,
                                      style: const TextStyle(
                                          color: Colors.black54, fontSize: 15),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pistas Próximas',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white 
                            : Colors.black),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>
                              const MainScreen(initialIndex: 2),
                        ),
                      );
                    },
                    child: const Text('Ver todas'),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: nearbyParks.length,
              itemBuilder: (context, index) {
                final park = nearbyParks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: _buildImage(park.images[0]),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.7),
                                Colors.white.withValues(alpha: 0.95),
                              ],
                              stops: const [0.0, 0.4, 1.0],
                            ),
                          ),
                          child: InkWell(
                            onTap: () => _showParkDetails(context, park),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Container(),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        park.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800, 
                                            fontSize: 17,
                                            color: Colors.black,
                                            letterSpacing: 0.3),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.black87,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              park.type,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  letterSpacing: 0.5),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.location_on,
                                              size: 14, color: Colors.black54),
                                          const SizedBox(width: 2),
                                          Text(_calculateDistance(park.lat, park.lng),
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star,
                                              size: 16, color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text(
                                            park.rating.toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Mapa das Pistas',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const MainScreen(initialIndex: 1),
                  ),
                );
              },
              child: Container(
                height: 300,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      _currentPosition == null
                          ? Container(
                              color: Colors.grey.shade800,
                              child: const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            )
                          : FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(_currentPosition!.latitude,
                                    _currentPosition!.longitude),
                                initialZoom: 12,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.none,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.skateflow',
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
                                          width: 16,
                                          height: 16,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF3888D2),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3888D2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.map_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Ver mapa completo',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showEventDetails(BuildContext context, Event event) {
    final eventDetails = {
      'title': event.title,
      'date': '${event.date.day}/${event.date.month}/${event.date.year} às ${event.date.hour}:${event.date.minute.toString().padLeft(2, '0')}',
      'location': event.location,
      'participants': event.participants.length,
      'description': event.description,
      'organizer': 'Organização Local',
      'category': 'Street',
      'image': null,
      'linkSite': event.linkSite,
    };

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
                        child: eventDetails['image'] != null
                            ? Image.asset(
                                eventDetails['image'] as String,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Colors.grey.shade300,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.event,
                                      size: 60,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Foto do evento',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            eventDetails['title'] as String,
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            eventDetails['category'] as String,
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
                      eventDetails['description'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white70 
                            : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(
                        Icons.location_on, eventDetails['location'] as String),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                        Icons.calendar_today, eventDetails['date'] as String),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.person,
                        'Organizador: ${eventDetails['organizer']}'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.group,
                        '${eventDetails['participants']} participantes'),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _handleSiteLink(eventDetails['linkSite'] as String?),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Ir para o Site'),
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

  void _showParkDetails(BuildContext context, Skatepark park) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => DraggableScrollableSheet(
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
                _buildInfoRow(Icons.directions, _calculateDistance(park.lat, park.lng)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewsScreen(skatepark: park),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${park.rating.toStringAsFixed(1)} estrelas',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white70 
                            : Colors.blue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.person_add, park.addedByText),
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
                    )
                  ).toList(),
                ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RatingScreen(skatepark: park),
                            ),
                          );
                        },
                        icon: const Icon(Icons.star_border),
                        label: const Text('Avaliar Pista'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showNavigationOptions(park.lat, park.lng, park.address),
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
                          child: StatefulBuilder(
                            builder: (context, setModalState) {
                              final isFav = _favoritesService.isFavorite(park.id);
                              return OutlinedButton(
                                onPressed: () async {
                                  if (isFav) {
                                    final sucesso = await _favoritesService.removeFromFavorites(park.id);
                                    if (sucesso) {
                                      ScaffoldMessenger.of(modalContext).showSnackBar(
                                        const SnackBar(content: Text('Removido dos favoritos')),
                                      );
                                      setModalState(() {});
                                    }
                                  } else {
                                    final sucesso = await _favoritesService.addToFavorites(park.id);
                                    if (sucesso) {
                                      ScaffoldMessenger.of(modalContext).showSnackBar(
                                        const SnackBar(content: Text('Adicionado aos favoritos')),
                                      );
                                      setModalState(() {});
                                    } else {
                                      ScaffoldMessenger.of(modalContext).showSnackBar(
                                        const SnackBar(
                                          content: Text('Erro ao adicionar favorito'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(isFav ? 'Remover' : 'Favoritar'),
                              );
                            },
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
              itemBuilder: (context, index) => _buildImage(images[index]),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  void _showAlertsDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => Dialog(
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
              Icon(
                Icons.notifications_off_outlined,
                size: 48,
                color: isDark ? Colors.white70 : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhuma notificação',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Você não tem notificações no momento.',
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
                child: const Text('Fechar'),
              ),
            ],
          ),
        ),
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

  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('data:image')) {
      try {
        final base64String = imagePath.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (e) {
        return Container(color: Colors.grey.shade300, child: const Icon(Icons.skateboarding, size: 60));
      }
    }
    return Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300, child: const Icon(Icons.skateboarding, size: 60)));
  }

  void _openGenericNavigation(double lat, double lng, [String? address]) async {
    String geoUrl = 'geo:$lat,$lng';
    
    try {
      if (await canLaunchUrl(Uri.parse(geoUrl))) {
        await launchUrl(Uri.parse(geoUrl), mode: LaunchMode.externalApplication);
      } else {
        _openGoogleMaps(lat, lng, address);
      }
    } catch (e) {
      _openGoogleMaps(lat, lng, address);
    }
  }

  void _handleSiteLink(String? linkSite) {
    if (linkSite != null && linkSite.isNotEmpty) {
      _launchURL(linkSite);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esse evento não possui link cadastrado'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _launchURL(String url) async {
    try {
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao abrir o link'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}