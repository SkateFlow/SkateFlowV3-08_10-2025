import 'package:flutter/material.dart';

class ChangePhotoScreen extends StatelessWidget {
  const ChangePhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alterar Foto',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Foto atual
            CircleAvatar(
              radius: 80,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(
                Icons.person,
                size: 80,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            
            // Opções
            _buildOption(
              Icons.camera_alt,
              'Tirar Foto',
              'Use a câmera para tirar uma nova foto',
              () {},
            ),
            const SizedBox(height: 16),
            _buildOption(
              Icons.photo_library,
              'Escolher da Galeria',
              'Selecione uma foto da sua galeria',
              () {},
            ),
            const SizedBox(height: 16),
            _buildOption(
              Icons.delete,
              'Remover Foto',
              'Voltar para a foto padrão',
              () {},
              isDestructive: true,
            ),
            
            const Spacer(),
            
            // Botão Cancelar
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white70 
                        : Colors.grey.shade600),
                ),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white70 
                        : Colors.grey.shade600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, String subtitle, VoidCallback onTap, {bool isDestructive = false}) {
    return Builder(
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300.withValues(alpha: 0.3)),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive 
                    ? Colors.red.withValues(alpha: 0.1)
                    : const Color(0xFF00294F).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon, 
                color: isDestructive ? Colors.red : const Color(0xFF00294F),
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDestructive 
                    ? Colors.red 
                    : (Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black),
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                color: isDestructive 
                    ? Colors.red.withValues(alpha: 0.7) 
                    : (Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white70 
                        : Colors.black54),
              ),
            ),
            onTap: onTap,
          ),
        );
      },
    );
  }
}
