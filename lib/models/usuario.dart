class Usuario {
  final int id;
  final String nome;
  final String email;
  final String statusUsuario;
  final String? nivelAcesso;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.statusUsuario,
    this.nivelAcesso,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'] ?? '',
      email: json['email'],
      statusUsuario: json['statusUsuario'],
      nivelAcesso: json['nivelAcesso'],
    );
  }
}