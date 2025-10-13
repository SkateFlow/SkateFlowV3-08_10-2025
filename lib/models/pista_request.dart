class PistaRequest {
  final String id;
  final String nome;
  final String descricao;
  final String categoria;
  final String cep;
  final String rua;
  final String bairro;
  final String numero;
  final double? latitude;
  final double? longitude;
  final bool publica;
  final List<String> fotos;
  final String status;
  final DateTime dataSolicitacao;
  final String? usuarioId;

  PistaRequest({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.categoria,
    required this.cep,
    required this.rua,
    required this.bairro,
    required this.numero,
    this.latitude,
    this.longitude,
    required this.publica,
    required this.fotos,
    this.status = 'pendente',
    required this.dataSolicitacao,
    this.usuarioId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'categoria': categoria,
      'cep': cep,
      'rua': rua,
      'bairro': bairro,
      'numero': numero,
      'latitude': latitude,
      'longitude': longitude,
      'publica': publica,
      'fotos': fotos,
      'status': status,
      'dataSolicitacao': dataSolicitacao.toIso8601String(),
      'usuarioId': usuarioId,
    };
  }

  factory PistaRequest.fromJson(Map<String, dynamic> json) {
    return PistaRequest(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      categoria: json['categoria'],
      cep: json['cep'],
      rua: json['rua'],
      bairro: json['bairro'],
      numero: json['numero'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      publica: json['publica'],
      fotos: List<String>.from(json['fotos']),
      status: json['status'] ?? 'pendente',
      dataSolicitacao: DateTime.parse(json['dataSolicitacao']),
      usuarioId: json['usuarioId'],
    );
  }

  String get endereco {
    final parts = [rua, numero, bairro].where((part) => part.isNotEmpty).toList();
    return parts.join(', ');
  }
}