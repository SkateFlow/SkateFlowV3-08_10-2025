import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

    // Simular delay de API
    await Future.delayed(const Duration(seconds: 1));

    if (_isRegister) {
      // Validações de cadastro
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

      setState(() {
        _successMessage = 'Cadastro realizado com sucesso!';
        _loading = false;
      });

      // Voltar para login após 2 segundos
      Future.delayed(const Duration(seconds: 2), () {
        _toggleMode();
      });
    } else {
      // Login
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Preencha email e senha';
          _loading = false;
        });
        return;
      }

      setState(() {
        _loading = false;
      });
      
      Navigator.pushReplacementNamed(context, '/loading');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000a11),
              Color(0xFF000f1f),
              Color(0xFF011428),
              Color(0xFF001732),
              Color(0xFF001b3b),
              Color(0xFF001d45),
              Color(0xFF00204f),
              Color(0xFF002358),
              Color(0xFF012562),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo no topo
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Image.asset(
                      'assets/images/skateparks/logo-branca.png',
                      height: 120,
                      width: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: const Icon(
                            Icons.skateboarding,
                            size: 60,
                            color: Color(0xFF043C70),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Formulário centralizado
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Título
                          Text(
                            _isRegister ? 'CADASTRO' : 'LOGIN',
                            style: GoogleFonts.lexend(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF333333),
                              letterSpacing: 1,
                            ),
                          ),
                          
                          Container(
                            margin: const EdgeInsets.only(top: 8, bottom: 32),
                            width: 60,
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF043C70), Color(0xFF0056a3)],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),

                          // Campo nome de usuário (apenas no cadastro)
                          if (_isRegister) ...[
                            _buildInputField(
                              controller: _usernameController,
                              placeholder: 'Nome de usuário',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Campo email
                          _buildInputField(
                            controller: _emailController,
                            placeholder: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 24),

                          // Campo senha
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
                          const SizedBox(height: 24),

                          // Campo confirmar senha (apenas no cadastro)
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
                            const SizedBox(height: 24),
                          ],

                          // Mensagens de erro/sucesso
                          if (_errorMessage.isNotEmpty) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _errorMessage,
                                style: GoogleFonts.lexend(
                                  color: const Color(0xFFd32f2f),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],

                          if (_successMessage.isNotEmpty) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                border: Border.all(color: Colors.green.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _successMessage,
                                style: GoogleFonts.lexend(
                                  color: const Color(0xFF388e3c),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],

                          // Botão principal
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF043C70),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                disabledBackgroundColor: const Color(0xFF043C70).withOpacity(0.7),
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Links
                          Column(
                            children: [
                              TextButton(
                                onPressed: _toggleMode,
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  _isRegister ? 'Já tem conta? Entrar' : 'Não tem conta? Cadastrar',
                                  style: GoogleFonts.lexend(
                                    color: const Color(0xFF043C70),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              TextButton(
                                onPressed: () {
                                  // Voltar ao início (se houver uma tela inicial)
                                },
                                child: Text(
                                  'Voltar ao início',
                                  style: GoogleFonts.lexend(
                                    color: const Color(0xFF666666),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
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
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFe0e0e0),
            width: 2,
          ),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.lexend(
          color: const Color(0xFF333333),
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: GoogleFonts.lexend(
            color: const Color(0xFF999999),
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF043C70),
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
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFe0e0e0),
            width: 2,
          ),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: !showPassword,
        style: GoogleFonts.lexend(
          color: const Color(0xFF333333),
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: GoogleFonts.lexend(
            color: const Color(0xFF999999),
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(top: 16, bottom: 16, right: 40),
          suffixIcon: Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: Icon(
                showPassword ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF666666),
                size: 18,
              ),
              onPressed: onToggleVisibility,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF043C70),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}