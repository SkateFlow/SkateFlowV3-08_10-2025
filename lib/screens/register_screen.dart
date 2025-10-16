import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _nameError = false;
  bool _emailError = false;
  bool _passwordError = false;
  bool _confirmPasswordError = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _passwordErrorMessage;

  String? _validatePassword(String password) {
    if (password.isEmpty) return null;
    if (password.length < 8) {
      return 'Mínimo 8 caracteres';
    }
    return null;
  }

  // ✅ ALTERADO: método que chama o backend
  void _register() async {
    final passwordValidation = _validatePassword(_passwordController.text);

    setState(() {
      _nameError = _nameController.text.isEmpty;
      _emailError = _emailController.text.isEmpty;
      _passwordError = _passwordController.text.isEmpty || passwordValidation != null;
      _passwordErrorMessage = passwordValidation;
      _confirmPasswordError = _confirmPasswordController.text.isEmpty ||
          _confirmPasswordController.text != _passwordController.text;
    });

    if (!_nameError &&
        !_emailError &&
        !_passwordError &&
        !_confirmPasswordError) {
      
      // 🔹 Registra o usuário usando AuthService
      final success = await AuthService().register(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
      );

      if (success) {
        // ✅ Sucesso no cadastro
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cadastro realizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/loading');
        }
      } else {
        // ❌ Falha no cadastro
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao cadastrar. Tente novamente.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF00294F),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/skateparks/logo-branca.png',
                      height: 180,
                      width: 180,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Junte-se à comunidade skate',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 350),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF08243E),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _nameController,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Nome completo',
                              labelStyle: TextStyle(
                                color:
                                    _nameError ? Colors.red : Colors.white70,
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.person_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      _nameError ? Colors.red : Colors.white,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      _nameError ? Colors.red : Colors.white,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      _nameError ? Colors.red : Colors.black,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.1),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                            textCapitalization: TextCapitalization.words,
                            onChanged: (value) {
                              if (_nameError && value.isNotEmpty) {
                                setState(() {
                                  _nameError = false;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _emailController,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                color:
                                    _emailError ? Colors.red : Colors.white70,
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(Icons.email_outlined,
                                  color: Colors.white, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      _emailError ? Colors.red : Colors.white,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      _emailError ? Colors.red : Colors.white,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      _emailError ? Colors.red : Colors.black,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.1),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              errorText: _emailError &&
                                      _emailController.text.isNotEmpty
                                  ? 'Email inválido'
                                  : null,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) {
                              if (_emailError && value.isNotEmpty) {
                                setState(() {
                                  _emailError = false;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passwordController,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              labelStyle: TextStyle(
                                color: _passwordError
                                    ? Colors.red
                                    : Colors.white70,
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(Icons.lock_outlined,
                                  color: Colors.white, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white,
                                    size: 20),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _passwordError
                                      ? Colors.red
                                      : Colors.white,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _passwordError
                                      ? Colors.red
                                      : Colors.white,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _passwordError
                                      ? Colors.red
                                      : Colors.black,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.1),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              errorText:
                                  _passwordError && _passwordErrorMessage != null
                                      ? _passwordErrorMessage
                                      : null,
                            ),
                            obscureText: _obscurePassword,
                            onChanged: (value) {
                              final validation = _validatePassword(value);
                              setState(() {
                                _passwordError = validation != null;
                                _passwordErrorMessage = validation;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _confirmPasswordController,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Confirmar senha',
                              labelStyle: TextStyle(
                                color: _confirmPasswordError
                                    ? Colors.red
                                    : Colors.white70,
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(Icons.lock_outlined,
                                  color: Colors.white, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _confirmPasswordError
                                      ? Colors.red
                                      : Colors.white,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _confirmPasswordError
                                      ? Colors.red
                                      : Colors.white,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _confirmPasswordError
                                      ? Colors.red
                                      : Colors.black,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.1),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              errorText: _confirmPasswordError &&
                                      _confirmPasswordController.text
                                          .isNotEmpty
                                  ? 'As senhas não coincidem'
                                  : null,
                            ),
                            obscureText: _obscureConfirmPassword,
                            onChanged: (value) {
                              setState(() {
                                _confirmPasswordError = value.isNotEmpty &&
                                    value != _passwordController.text;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Cadastrar',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Já tem conta? Faça login',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
