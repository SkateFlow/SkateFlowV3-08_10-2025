class Usuario {
  final int id;
  final String email;
  final String statusUsuario;

  Usuario({
    required this.id,
    required this.email,
    required this.statusUsuario,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      email: json['email'],
      statusUsuario: json['statusUsuario'],
    );
  }
}