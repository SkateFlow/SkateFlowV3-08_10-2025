class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String imageUrl;
  final String organizerId;
  final List<String> participants;
  final String? linkSite;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.imageUrl,
    required this.organizerId,
    required this.participants,
    this.linkSite,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    String locationText = '';
    if (map['lugar_id'] != null) {
      final lugar = map['lugar_id'];
      if (lugar is Map<String, dynamic>) {
        final nome = lugar['nome'] ?? '';
        final rua = lugar['rua'] ?? '';
        final bairro = lugar['bairro'] ?? '';
        final cidade = lugar['cidade'] ?? '';
        
        if (nome.isNotEmpty) {
          locationText = nome;
          if (rua.isNotEmpty && bairro.isNotEmpty) {
            locationText += ', $rua, $bairro';
          } else if (cidade.isNotEmpty) {
            locationText += ', $cidade';
          }
        } else if (rua.isNotEmpty && bairro.isNotEmpty) {
          locationText = '$rua, $bairro';
          if (cidade.isNotEmpty) {
            locationText += ', $cidade';
          }
        }
      }
    }
    
    return Event(
      id: map['id'].toString(),
      title: map['nome'] ?? map['title'] ?? '',
      description: map['info'] ?? map['description'] ?? '',
      date: map['dataInicio'] != null 
          ? DateTime.parse(map['dataInicio'].toString())
          : (map['date'] is DateTime 
              ? map['date'] 
              : DateTime.parse(map['date'].toString())),
      location: locationText.isNotEmpty ? locationText : (map['location'] ?? ''),
      imageUrl: map['imageUrl'] ?? '',
      organizerId: map['usuario_id'] != null 
          ? map['usuario_id']['id'].toString()
          : (map['organizerId'] ?? ''),
      participants: List<String>.from(map['participants'] ?? []),
      linkSite: map['linkSite'],
    );
  }
}
