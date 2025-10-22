import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with AutomaticKeepAliveClientMixin {
  String _selectedDate = 'Todas';
  String _selectedLocation = 'Todas';
  List<Event> _filteredEvents = [];
  List<Event> _allEvents = [];
  final EventService _eventService = EventService();
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }
  
  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final events = await _eventService.getPublishedEvents();
      setState(() {
        _allEvents = events;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredEvents = _allEvents.where((event) {
        final now = DateTime.now();
        
        if (_selectedDate != 'Todas') {
          switch (_selectedDate) {
            case 'Esta semana':
              final weekFromNow = now.add(const Duration(days: 7));
              if (event.date.isBefore(now) || event.date.isAfter(weekFromNow)) return false;
              break;
            case 'Este mês':
              final monthFromNow = DateTime(now.year, now.month + 1, now.day);
              if (event.date.isBefore(now) || event.date.isAfter(monthFromNow)) return false;
              break;
            case 'Próximos 3 meses':
              final threeMonthsFromNow = DateTime(now.year, now.month + 3, now.day);
              if (event.date.isBefore(now) || event.date.isAfter(threeMonthsFromNow)) return false;
              break;
          }
        }

        if (_selectedLocation != 'Todas') {
          switch (_selectedLocation) {
            case 'Centro':
              if (!event.location.toLowerCase().contains('centro')) return false;
              break;
            case 'Zona Sul':
              if (!event.location.toLowerCase().contains('sul')) return false;
              break;
            case 'Zona Norte':
              if (!event.location.toLowerCase().contains('norte')) return false;
              break;
          }
        }

        return true;
      }).toList();
    });
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event,
            size: 40,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 8),
          Text(
            'Imagem do evento',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Eventos',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFiltersDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEvents,
              child: _filteredEvents.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(
                          child: Text(
                            'Sem Eventos Disponíveis',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = _filteredEvents[index];
                    final now = DateTime.now();
                    final timeUntilEvent = event.date.difference(now);
                    final isExpired = timeUntilEvent.isNegative || (timeUntilEvent.inHours < 2 && event.date.day == now.day);
          
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _showEventDetails(context, event),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 250,
                            child: Stack(
                              children: [
                                FutureBuilder<String?>(
                                  future: _eventService.getEventImage(int.parse(event.id), 1),
                                  builder: (context, snapshot) {
                                    Widget imageWidget;
                                    if (snapshot.hasData && snapshot.data != null) {
                                      try {
                                        final bytes = base64Decode(snapshot.data!);
                                        imageWidget = Image.memory(
                                          bytes,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        );
                                      } catch (e) {
                                        imageWidget = _buildPlaceholderImage();
                                      }
                                    } else {
                                      imageWidget = _buildPlaceholderImage();
                                    }
                                    
                                    if (isExpired) {
                                      return ColorFiltered(
                                        colorFilter: const ColorFilter.mode(
                                          Colors.grey,
                                          BlendMode.saturation,
                                        ),
                                        child: imageWidget,
                                      );
                                    }
                                    return imageWidget;
                                  },
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
                                        Text(
                                          event.title,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isExpired ? Colors.grey : Colors.white,
                                            decoration: isExpired ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                        if (isExpired) ...[
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade800,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'Esse evento encerrou',
                                              style: TextStyle(color: Colors.grey, fontSize: 12),
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on, size: 16, color: isExpired ? Colors.grey : Colors.white70),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                event.location,
                                                style: TextStyle(color: isExpired ? Colors.grey : Colors.white70),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Icon(Icons.calendar_today, size: 16, color: isExpired ? Colors.grey : Colors.white70),
                                            const SizedBox(width: 4),
                                            Text(
                                              _formatDate(event.date),
                                              style: TextStyle(color: isExpired ? Colors.grey : Colors.white70),
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
            ),
    );
  }

  void _showEventDetails(BuildContext context, Event event) {
    final now = DateTime.now();
    final timeUntilEvent = event.date.difference(now);
    final isExpired = timeUntilEvent.isNegative || (timeUntilEvent.inHours < 2 && event.date.day == now.day);
    
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
                        child: FutureBuilder<String?>(
                          future: _eventService.getEventImage(int.parse(event.id), 1),
                          builder: (context, snapshot) {
                            Widget imageWidget;
                            if (snapshot.hasData && snapshot.data != null) {
                              try {
                                final bytes = base64Decode(snapshot.data!);
                                imageWidget = Image.memory(bytes, fit: BoxFit.cover);
                              } catch (e) {
                                imageWidget = _buildPlaceholderImage();
                              }
                            } else {
                              imageWidget = _buildPlaceholderImage();
                            }
                            
                            if (isExpired) {
                              return ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  Colors.grey,
                                  BlendMode.saturation,
                                ),
                                child: imageWidget,
                              );
                            }
                            return imageWidget;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isExpired ? Colors.grey : (Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white 
                            : Colors.black),
                        decoration: isExpired ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (isExpired) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Esse evento encerrou',
                          style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      event.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: isExpired ? Colors.grey : (Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white70 
                            : Colors.grey.shade700),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 20, color: isExpired ? Colors.grey : Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.location,
                            style: TextStyle(
                              fontSize: 16,
                              color: isExpired ? Colors.grey : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 20, color: isExpired ? Colors.grey : Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${event.date.day}/${event.date.month}/${event.date.year} às ${event.date.hour}:${event.date.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 16,
                              color: isExpired ? Colors.grey : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (event.linkSite != null && event.linkSite!.isNotEmpty) ...[
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _handleSiteLink(event.linkSite),
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
                    ],
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
                      
                      _buildFilterSection('Data', Icons.calendar_today, isDark, [
                        _buildRadioOption('Todas', _selectedDate, (value) {
                          setDialogState(() => _selectedDate = value!);
                        }, isDark),
                        _buildRadioOption('Esta semana', _selectedDate, (value) {
                          setDialogState(() => _selectedDate = value!);
                        }, isDark),
                        _buildRadioOption('Este mês', _selectedDate, (value) {
                          setDialogState(() => _selectedDate = value!);
                        }, isDark),
                        _buildRadioOption('Próximos 3 meses', _selectedDate, (value) {
                          setDialogState(() => _selectedDate = value!);
                        }, isDark),
                      ]),
                      
                      const SizedBox(height: 16),
                      
                      _buildFilterSection('Localização', Icons.location_on, isDark, [
                        _buildRadioOption('Todas', _selectedLocation, (value) {
                          setDialogState(() => _selectedLocation = value!);
                        }, isDark),
                        _buildRadioOption('Centro', _selectedLocation, (value) {
                          setDialogState(() => _selectedLocation = value!);
                        }, isDark),
                        _buildRadioOption('Zona Sul', _selectedLocation, (value) {
                          setDialogState(() => _selectedLocation = value!);
                        }, isDark),
                        _buildRadioOption('Zona Norte', _selectedLocation, (value) {
                          setDialogState(() => _selectedLocation = value!);
                        }, isDark),
                      ]),
                      
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                setDialogState(() {
                                  _selectedDate = 'Todas';
                                  _selectedLocation = 'Todas';
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