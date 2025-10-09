import 'package:flutter/material.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  // Filtros
  String _selectedDate = 'Todas';
  String _selectedCategory = 'Todas';
  String _selectedLocation = 'Todas';
  String _selectedPrice = 'Todos';
  List<Map<String, dynamic>> _filteredEvents = [];

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  void _applyFilters() {
    final events = [
      {
        'title': 'Campeonato Municipal',
        'date': '15/06',
        'location': 'Skatepark Central',
        'participants': '45',
        'description': 'Campeonato municipal de skate com premiação para os três primeiros colocados em cada categoria.',
        'organizer': 'Prefeitura Municipal',
        'category': 'Street',
        'price': 'Gratuito',
        'image': null,
      },
      {
        'title': 'Workshop de Manobras',
        'date': '22/06',
        'location': 'Bowl da Liberdade',
        'participants': '23',
        'description': 'Workshop intensivo de manobras básicas e avançadas com instrutores profissionais.',
        'organizer': 'Skate Academy',
        'category': 'Bowl',
        'price': 'Pago',
        'image': null,
      },
      {
        'title': 'Sessão Noturna',
        'date': '28/06',
        'location': 'Pista do Ibirapuera',
        'participants': '67',
        'description': 'Sessão noturna com iluminação especial e música ao vivo para uma experiência única.',
        'organizer': 'Coletivo Skate SP',
        'category': 'Half-pipe',
        'price': 'Gratuito',
        'image': null,
      },
    ];

    setState(() {
      _filteredEvents = events.where((event) {
        // Filtro por data
        if (_selectedDate != 'Todas') {
          String eventDate = event['date'] as String;
          int day = int.parse(eventDate.split('/')[0]);
          switch (_selectedDate) {
            case 'Esta semana':
              if (day < 15 || day > 21) return false;
              break;
            case 'Este mês':
              if (day < 1 || day > 30) return false;
              break;
            case 'Próximos 3 meses':
              // Todos os eventos estão no próximo mês
              break;
          }
        }

        // Filtro por categoria
        if (_selectedCategory != 'Todas' && event['category'] != _selectedCategory) {
          return false;
        }

        // Filtro por localização
        if (_selectedLocation != 'Todas') {
          String location = event['location'] as String;
          switch (_selectedLocation) {
            case 'Centro':
              if (!location.contains('Central')) return false;
              break;
            case 'Zona Sul':
              if (!location.contains('Liberdade')) return false;
              break;
            case 'Zona Norte':
              if (!location.contains('Ibirapuera')) return false;
              break;
          }
        }

        // Filtro por preço
        if (_selectedPrice != 'Todos' && event['price'] != _selectedPrice) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
          Container(
            width: 200,
            margin: const EdgeInsets.only(right: 8),
            height: 40,
            child: TextField(
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Pesquisar eventos...',
                hintStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                filled: true,
                fillColor: Colors.grey.shade200,
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
        itemCount: _filteredEvents.length,
        itemBuilder: (context, index) {
          final event = _filteredEvents[index];
          
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
                      event['image'] != null
                          ? Image.asset(
                              event['image'] as String,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Container(
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
                                      event['title'] as String,
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
                                      event['category'] as String,
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
                                    event['location'] as String,
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Text(
                                    event['date'] as String,
                                    style: const TextStyle(color: Colors.white70),
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

  void _showEventDetails(BuildContext context, Map<String, dynamic> event) {
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
                        child: event['image'] != null
                            ? Image.asset(
                                event['image'] as String,
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
                                      'Imagem do evento',
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
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            event['title'] as String,
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
                            event['category'] as String,
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
                      event['description'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white70 
                            : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(Icons.location_on, event['location'] as String),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.calendar_today, event['date'] as String),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.person, 'Organizador: ${event['organizer']}'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.group, '${event['participants']} participantes'),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Agendar Ingresso'),
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
                      
                      // Filtro de Data
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
                      
                      // Filtro de Categoria
                      _buildFilterSection('Categoria', Icons.category, isDark, [
                        _buildRadioOption('Todas', _selectedCategory, (value) {
                          setDialogState(() => _selectedCategory = value!);
                        }, isDark),
                        _buildRadioOption('Street', _selectedCategory, (value) {
                          setDialogState(() => _selectedCategory = value!);
                        }, isDark),
                        _buildRadioOption('Bowl', _selectedCategory, (value) {
                          setDialogState(() => _selectedCategory = value!);
                        }, isDark),
                        _buildRadioOption('Half-pipe', _selectedCategory, (value) {
                          setDialogState(() => _selectedCategory = value!);
                        }, isDark),
                      ]),
                      
                      const SizedBox(height: 16),
                      
                      // Filtro de Localização
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
                      
                      const SizedBox(height: 16),
                      
                      // Filtro de Preço
                      _buildFilterSection('Preço', Icons.attach_money, isDark, [
                        _buildRadioOption('Todos', _selectedPrice, (value) {
                          setDialogState(() => _selectedPrice = value!);
                        }, isDark),
                        _buildRadioOption('Gratuito', _selectedPrice, (value) {
                          setDialogState(() => _selectedPrice = value!);
                        }, isDark),
                        _buildRadioOption('Pago', _selectedPrice, (value) {
                          setDialogState(() => _selectedPrice = value!);
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
                                  _selectedCategory = 'Todas';
                                  _selectedLocation = 'Todas';
                                  _selectedPrice = 'Todos';
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
