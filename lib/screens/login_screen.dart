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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cadastro efetuado com sucesso!', style: GoogleFonts.lexend(color: Colors.white)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

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
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login efetuado com sucesso!', style: GoogleFonts.lexend(color: Colors.white)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/loading');
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
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Stack(
              children: [
                // Logo posicionada no topo (oculta quando teclado aparece)
                if (!keyboardVisible)
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                    child: Image.asset(
                      'assets/images/skateparks/logo-branca.png',
                      height: 250,
                      width: 250,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 250,
                          width: 250,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(125),
                          ),
                          child: const Icon(
                            Icons.skateboarding,
                            size: 125,
                            color: Color(0xFF043C70),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Formulário centralizado
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  padding: EdgeInsets.only(
                    top: keyboardVisible ? 20 : 270,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width > 600 ? 500 : double.infinity,
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width > 600 ? 40 : 20,
                      ),
                        padding: const EdgeInsets.all(24),
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
                            margin: const EdgeInsets.only(top: 8, bottom: 24),
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
                            const SizedBox(height: 20),
                          ],

                          // Campo email
                          _buildInputField(
                            controller: _emailController,
                            placeholder: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),

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
                          const SizedBox(height: 20),

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
                            const SizedBox(height: 20),
                          ],

                          // Mensagens de erro/sucesso
                          if (_errorMessage.isNotEmpty) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
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
                                color: Colors.green.withValues(alpha: 0.1),
                                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

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
                              
                              if (!_isRegister) ...[
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: _showForgotPasswordDialog,
                                  child: Text(
                                    'Esqueceu a senha?',
                                    style: GoogleFonts.lexend(
                                      color: const Color(0xFF666666),
                                      fontSize: 14,
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
                ),
              ],
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
          suffixIcon: IconButton(
            icon: Icon(
              showPassword ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF666666),
              size: 18,
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