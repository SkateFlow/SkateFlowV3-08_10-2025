import 'package:flutter/material.dart';
import 'change_photo_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController(text: 'Carlos Silva');
  final _usernameController = TextEditingController(text: 'carlosskate');
  final _bioController = TextEditingController(text: 'Skatista há 5 anos. Especialista em manobras de street.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'Editar Perfil',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Salvar',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Foto do perfil
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePhotoScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00294F), Color(0xFF001426)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            
            // Campo Nome
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome',
                prefixIcon: Icon(Icons.person_outlined, 
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white70 
                      : Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00294F), width: 2),
                ),
                labelStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white70 
                      : Colors.grey.shade600),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white.withValues(alpha: 0.1) 
                    : Colors.grey.shade50,
              ),
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black),
            ),
            const SizedBox(height: 20),
            
            // Campo Username
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Nome de usuário',
                prefixIcon: Icon(Icons.alternate_email, 
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white70 
                      : Colors.grey.shade600),
                prefixText: '@',
                prefixStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white70 
                      : Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00294F), width: 2),
                ),
                labelStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white70 
                      : Colors.grey.shade600),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white.withValues(alpha: 0.1) 
                    : Colors.grey.shade50,
              ),
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black),
            ),
            const SizedBox(height: 20),
            
            // Campo Bio
            TextField(
              controller: _bioController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Bio',
                prefixIcon: Icon(Icons.edit_outlined, 
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white70 
                      : Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00294F), width: 2),
                ),
                labelStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white70 
                      : Colors.grey.shade600),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white.withValues(alpha: 0.1) 
                    : Colors.grey.shade50,
                alignLabelWithHint: true,
              ),
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black),
            ),
            const SizedBox(height: 40),
            
            // Botões
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00294F), Color(0xFF001426)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Salvar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
