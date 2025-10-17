class Skatepark {
  final String id;
  final String name;
  final String type;
  final String address;
  final double lat;
  final double lng;
  final List<String> features;
  final double rating;
  final String hours;
  final String description;
  final List<String> images;
  final String? addedBy;
  final String? usuarioNome;
  final String? usuarioNivelAcesso;

  Skatepark({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.lat,
    required this.lng,
    required this.features,
    required this.rating,
    required this.hours,
    required this.description,
    required this.images,
    this.addedBy,
    this.usuarioNome,
    this.usuarioNivelAcesso,
  });

  String get addedByText {
    if (usuarioNome == null || usuarioNivelAcesso == 'ADMIN') {
      return 'Adicionado por: SkateFlow';
    }
    return 'Adicionado por: $usuarioNome';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'address': address,
      'lat': lat,
      'lng': lng,
      'features': features,
      'rating': rating,
      'hours': hours,
      'description': description,
      'images': images,
      'addedBy': addedBy,
      'usuarioNome': usuarioNome,
      'usuarioNivelAcesso': usuarioNivelAcesso,
    };
  }

  factory Skatepark.fromJson(Map<String, dynamic> json) {
    return Skatepark(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      address: json['address'],
      lat: json['lat'].toDouble(),
      lng: json['lng'].toDouble(),
      features: List<String>.from(json['features']),
      rating: json['rating'].toDouble(),
      hours: json['hours'],
      description: json['description'],
      images: List<String>.from(json['images']),
      addedBy: json['addedBy'],
      usuarioNome: json['usuarioNome'],
      usuarioNivelAcesso: json['usuarioNivelAcesso'],
    );
  }

  Skatepark copyWith({
    String? id,
    String? name,
    String? type,
    String? address,
    double? lat,
    double? lng,
    List<String>? features,
    double? rating,
    String? hours,
    String? description,
    List<String>? images,
    String? addedBy,
    String? usuarioNome,
    String? usuarioNivelAcesso,
  }) {
    return Skatepark(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      features: features ?? this.features,
      rating: rating ?? this.rating,
      hours: hours ?? this.hours,
      description: description ?? this.description,
      images: images ?? this.images,
      addedBy: addedBy ?? this.addedBy,
      usuarioNome: usuarioNome ?? this.usuarioNome,
      usuarioNivelAcesso: usuarioNivelAcesso ?? this.usuarioNivelAcesso,
    );
  }
}
