import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/skatepark.dart';
import '../services/avaliacao_service.dart';
import '../services/auth_service.dart';

class ReviewsScreen extends StatefulWidget {
  final Skatepark skatepark;

  const ReviewsScreen({super.key, required this.skatepark});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<Map<String, dynamic>> _avaliacoes = [];
  bool _isLoading = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _carregarAvaliacoes();
  }

  Future<void> _carregarAvaliacoes() async {
    setState(() => _isLoading = true);
    
    final avaliacoes = await AvaliacaoService.buscarAvaliacoes(
      int.parse(widget.skatepark.id),
    );
    
    setState(() {
      _avaliacoes = avaliacoes;
      _isLoading = false;
    });
  }

  String _formatarData(String dataStr) {
    try {
      final data = DateTime.parse(dataStr);
      final agora = DateTime.now();
      final diferenca = agora.difference(data);

      if (diferenca.inDays == 0) {
        if (diferenca.inHours == 0) {
          return 'Há ${diferenca.inMinutes} minutos';
        }
        return 'Há ${diferenca.inHours} horas';
      } else if (diferenca.inDays == 1) {
        return 'Ontem';
      } else if (diferenca.inDays < 7) {
        return 'Há ${diferenca.inDays} dias';
      } else if (diferenca.inDays < 30) {
        return 'Há ${(diferenca.inDays / 7).floor()} semanas';
      } else if (diferenca.inDays < 365) {
        return 'Há ${(diferenca.inDays / 30).floor()} meses';
      } else {
        return 'Há ${(diferenca.inDays / 365).floor()} anos';
      }
    } catch (e) {
      return 'Data inválida';
    }
  }

  Future<void> _deletarAvaliacao(int avaliacaoId) async {
    final user = _authService.currentUser;
    if (user == null) return;

    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir esta avaliação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmacao == true) {
      final sucesso = await AvaliacaoService.deletarAvaliacao(
        avaliacaoId: avaliacaoId,
        usuarioId: user.id,
      );

      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avaliação excluída com sucesso')),
        );
        _carregarAvaliacoes();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Avaliações',
          style: GoogleFonts.lexend(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _avaliacoes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma avaliação ainda',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Seja o primeiro a avaliar esta pista!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.grey.shade100,
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.skatepark.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 28),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.skatepark.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${_avaliacoes.length} ${_avaliacoes.length == 1 ? 'avaliação' : 'avaliações'})',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _carregarAvaliacoes,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _avaliacoes.length,
                          itemBuilder: (context, index) {
                            final avaliacao = _avaliacoes[index];
                            final usuario = avaliacao['usuario'];
                            final isMyReview = user != null && usuario['id'] == user.id;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.grey.shade300,
                                          child: Text(
                                            usuario['nome'][0].toUpperCase(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                usuario['nome'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                _formatarData(avaliacao['dataAvaliacao']),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isMyReview)
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                                            onPressed: () => _deletarAvaliacao(avaliacao['id']),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: List.generate(5, (starIndex) {
                                        return Icon(
                                          Icons.star,
                                          size: 20,
                                          color: starIndex < avaliacao['rating']
                                              ? Colors.amber
                                              : Colors.grey.shade300,
                                        );
                                      }),
                                    ),
                                    if (avaliacao['comentario'] != null &&
                                        avaliacao['comentario'].toString().isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        avaliacao['comentario'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
