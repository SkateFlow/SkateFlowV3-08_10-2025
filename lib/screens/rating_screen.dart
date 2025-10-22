import 'package:flutter/material.dart';
import '../models/skatepark.dart';
import '../services/avaliacao_service.dart';
import '../services/auth_service.dart';

class RatingScreen extends StatefulWidget {
  final Skatepark skatepark;

  const RatingScreen({super.key, required this.skatepark});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isSubmitting = false;
  bool _isLoading = true;
  bool _jaAvaliou = false;

  @override
  void initState() {
    super.initState();
    _verificarAvaliacao();
  }

  Future<void> _verificarAvaliacao() async {
    final user = _authService.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final jaAvaliou = await AvaliacaoService.usuarioJaAvaliou(
      lugarId: int.parse(widget.skatepark.id),
      usuarioId: user.id,
    );

    setState(() {
      _jaAvaliou = jaAvaliou;
      _isLoading = false;
    });

    if (_jaAvaliou && mounted) {
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.info_outline, color: Colors.orange, size: 48),
            title: const Text('Avaliação já enviada'),
            content: Text('Você já avaliou ${widget.skatepark.name}. Cada usuário pode fazer apenas 1 avaliação por pista.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma avaliação')),
      );
      return;
    }

    final user = _authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa estar logado para avaliar')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final resultado = await AvaliacaoService.salvarAvaliacao(
      lugarId: int.parse(widget.skatepark.id),
      usuarioId: user.id,
      rating: _rating.toInt(),
      comentario: _commentController.text,
    );

    setState(() => _isSubmitting = false);

    if (resultado['success'] && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: const Text('Avaliação Enviada!'),
          content: Text('Obrigado por avaliar ${widget.skatepark.name}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else if (mounted) {
      final mensagem = resultado['message']?.toString().contains('já avaliou') == true
          ? 'Você já avaliou esta pista'
          : 'Erro ao enviar avaliação';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Avaliar Pista'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_jaAvaliou) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Avaliar Pista'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Avaliar Pista'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
              widget.skatepark.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.skatepark.address,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Como você avalia esta pista?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.star,
                      size: 40,
                      color: index < _rating ? Colors.amber : Colors.grey.shade300,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            const Text(
              'Comentário (opcional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Conte sua experiência nesta pista...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Enviar Avaliação',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      ),
    );
  }
}