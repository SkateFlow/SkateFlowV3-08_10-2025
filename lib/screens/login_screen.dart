import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isRegister = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _loading = false;
  String _errorMessage = '';
  String _successMessage = '';
  final _authService = AuthService();

  void _toggleMode() {
    setState(() {
      _isRegister = !_isRegister;
      _errorMessage = '';
      _successMessage = '';
      _emailController.clear();
      _passwordController.clear();
      _usernameController.clear();
      _confirmPasswordController.clear();
    });
  }

  void _handleSubmit() async {
    setState(() {
      _loading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    await Future.delayed(const Duration(seconds: 1));

    if (_isRegister) {
      if (_usernameController.text.isEmpty || 
          _emailController.text.isEmpty || 
          _passwordController.text.isEmpty || 
          _confirmPasswordController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Preencha todos os campos';
          _loading = false;
        });
        return;
      }

      if (_usernameController.text.length < 3) {
        setState(() {
          _errorMessage = 'Nome de usuário deve ter pelo menos 3 caracteres';
          _loading = false;
        });
        return;
      }

      if (_passwordController.text.length < 8) {
        setState(() {
          _errorMessage = 'Senha deve ter pelo menos 8 caracteres';
          _loading = false;
        });
        return;
      }

      if (!RegExp(r'[A-Z]').hasMatch(_passwordController.text)) {
        setState(() {
          _errorMessage = 'Senha deve ter pelo menos 1 letra maiúscula';
          _loading = false;
        });
        return;
      }

      if (!RegExp(r'[0-9]').hasMatch(_passwordController.text)) {
        setState(() {
          _errorMessage = 'Senha deve ter pelo menos 1 número';
          _loading = false;
        });
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'Senhas não coincidem';
          _loading = false;
        });
        return;
      }

      final success = await _authService.register(
        _emailController.text, 
        _passwordController.text, 
        _usernameController.text
      );
      
      setState(() {
        _loading = false;
      });
      
      if (success) {
        setState(() {
          _successMessage = 'Cadastro realizado com sucesso!';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cadastro efetuado com sucesso!', style: GoogleFonts.lexend(color: Colors.white)),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/loading');
            }
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Erro ao criar conta';
        });
      }
    } else {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Preencha email e senha';
          _loading = false;
        });
        return;
      }

      final success = await _authService.login(_emailController.text, _passwordController.text);
      
      setState(() {
        _loading = false;
      });
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login efetuado com sucesso!', style: GoogleFonts.lexend(color: Colors.white)),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
          
          Navigator.pushReplacementNamed(context, '/loading');
        }
      } else {
        setState(() {
          _errorMessage = 'Email ou senha inválidos';
        });
      }
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_reset,
                  size: 60,
                  color: Color(0xFF043C70),
                ),
                const SizedBox(height: 16),
                Text(
                  'Esqueceu a senha?',
                  style: GoogleFonts.lexend(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Digite seu email para receber as instruções de redefinição',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    color: const Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.lexend(),
                  decoration: InputDecoration(
                    hintText: 'Digite seu email',
                    hintStyle: GoogleFonts.lexend(color: const Color(0xFF999999)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFe0e0e0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF043C70), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF666666)),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          emailController.dispose();
                          Navigator.of(dialogContext).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (emailController.text.isNotEmpty) {
                            emailController.dispose();
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Email de redefinição de senha enviado com sucesso!',
                                  style: GoogleFonts.lexend(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF043C70),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Enviar',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF001732),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  if (!keyboardVisible) ...[
                    const SizedBox(height: 20),
                    Center(
                      child: Image.asset(
                        'assets/images/skateparks/logo-branca.png',
                        height: 200,
                        width: 200,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Icon(
                              Icons.skateboarding,
                              size: 100,
                              color: Color(0xFF043C70),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
                    const SizedBox(height: 10),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 350),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isRegister ? 'CADASTRO' : 'LOGIN',
                            style: GoogleFonts.lexend(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF333333),
                              letterSpacing: 1,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 8, bottom: 16),
                            width: 60,
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF043C70), Color(0xFF0056a3)],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          if (_isRegister) ...[
                            _buildInputField(
                              controller: _usernameController,
                              placeholder: 'Nome de usuário',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 12),
                          ],
                          _buildInputField(
                            controller: _emailController,
                            placeholder: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          _buildPasswordField(
                            controller: _passwordController,
                            placeholder: 'Senha',
                            isPassword: true,
                            showPassword: _showPassword,
                            onToggleVisibility: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          if (_isRegister) ...[
                            _buildPasswordField(
                              controller: _confirmPasswordController,
                              placeholder: 'Confirmar senha',
                              isPassword: true,
                              showPassword: _showConfirmPassword,
                              onToggleVisibility: () {
                                setState(() {
                                  _showConfirmPassword = !_showConfirmPassword;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (_errorMessage.isNotEmpty) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _errorMessage,
                                style: GoogleFonts.lexend(
                                  color: const Color(0xFFd32f2f),
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                          if (_successMessage.isNotEmpty) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _successMessage,
                                style: GoogleFonts.lexend(
                                  color: const Color(0xFF388e3c),
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF043C70),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                disabledBackgroundColor: const Color(0xFF043C70).withValues(alpha: 0.7),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      _isRegister ? 'CADASTRAR' : 'ENTRAR',
                                      style: GoogleFonts.lexend(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: [
                              TextButton(
                                onPressed: _toggleMode,
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  _isRegister ? 'Já tem conta? Entrar' : 'Não tem conta? Cadastrar',
                                  style: GoogleFonts.lexend(
                                    color: const Color(0xFF043C70),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (!_isRegister) ...[
                                TextButton(
                                  onPressed: _showForgotPasswordDialog,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                                  ),
                                  child: Text(
                                    'Esqueceu a senha?',
                                    style: GoogleFonts.lexend(
                                      color: const Color(0xFF666666),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFe0e0e0),
            width: 2,
          ),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.lexend(
          color: const Color(0xFF333333),
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: GoogleFonts.lexend(
            color: const Color(0xFF999999),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFF043C70),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String placeholder,
    required bool isPassword,
    required bool showPassword,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFe0e0e0),
            width: 2,
          ),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: !showPassword,
        style: GoogleFonts.lexend(
          color: const Color(0xFF333333),
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: GoogleFonts.lexend(
            color: const Color(0xFF999999),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          suffixIcon: IconButton(
            icon: Icon(
              showPassword ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF666666),
              size: 16,
            ),
            onPressed: onToggleVisibility,
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFF043C70),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}