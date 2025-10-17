import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_profile_screen.dart' as edit;
import 'notifications_settings_screen.dart';
import 'sound_vibration_settings_screen.dart';
import 'help_screen.dart';
import 'manage_account_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configurações',
          style: GoogleFonts.lexend(fontWeight: FontWeight.w600, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Perfil', [
            _buildTile(Icons.edit, 'Informações Pessoais',
                () => _navigateTo(context, '/edit-profile')),

          ]),
          _buildSection('App', [
            _buildTile(Icons.notifications, 'Notificações',
                () => _navigateTo(context, '/notifications')),
            _buildTile(Icons.volume_up, 'Som e vibração',
                () => _navigateTo(context, '/sound')),
          ]),
          _buildSection('Conta', [
            _buildTile(Icons.account_circle, 'Gerenciar conta',
                () => _navigateTo(context, '/manage-account')),
          ]),
          _buildSection('Localização', [
            _buildTile(Icons.gps_fixed, 'Permissões do Sistema',
                () => _navigateTo(context, '/gps-permissions')),
          ]),
          _buildSection('Suporte', [
            _buildTile(Icons.help, 'Central de Ajuda',
                () => _navigateTo(context, '/help')),
            _buildTile(Icons.report, 'Reportar Problema',
                () => _navigateTo(context, '/report')),
            _buildTile(Icons.info, 'Sobre o App',
                () => _navigateTo(context, '/about')),
            _buildTile(Icons.description, 'Termos de Uso',
                () => _navigateTo(context, '/terms')),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Card(
          color: Colors.white,
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTile(IconData icon, String title, VoidCallback onTap,
      {bool isDestructive = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: ListTile(
        leading: Icon(icon,
            color: isDestructive ? Colors.red : Colors.grey.shade700),
        title: Text(
          title,
          style: GoogleFonts.lexend(
            color: isDestructive ? Colors.red : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade600,
        ),
        onTap: onTap,
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => _getScreen(route),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _getScreen(String route) {
    switch (route) {
      case '/edit-profile':
        return const edit.EditProfileScreen();

      case '/notifications':
        return const NotificationsSettingsScreen();
      case '/sound':
        return const SoundVibrationSettingsScreen();
      case '/manage-account':
        return const ManageAccountScreen();
      case '/gps-permissions':
        return _buildGpsPermissionsScreen();
      case '/help':
        return const HelpScreen();
      case '/report':
        return _buildReportScreen();
      case '/about':
        return _buildAboutScreen();
      case '/terms':
        return _buildTermsScreen();
      default:
        return const Scaffold(
            body: Center(child: Text('Tela em desenvolvimento')));
    }
  }

  Widget _buildReportScreen() {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Reportar Problema', style: GoogleFonts.lexend(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.bug_report,
                    color: Colors.black,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Reportar Problema',
                    style: GoogleFonts.lexend(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajude-nos a melhorar o SkateFlow reportando problemas',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Descreva o problema',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 6,
              style: GoogleFonts.lexend(),
              decoration: InputDecoration(
                hintText:
                    'Descreva detalhadamente o problema encontrado...\n\nIncluir informações como:\n• O que você estava fazendo\n• O que esperava que acontecesse\n• O que realmente aconteceu',
                hintStyle: GoogleFonts.lexend(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF043C70)),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Problema reportado com sucesso! Obrigado pelo feedback.',
                        style: GoogleFonts.lexend(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: const Color(0xFF043C70),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.send),
                label: Text('Enviar Relatório', style: GoogleFonts.lexend()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF043C70),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sobre o App', style: GoogleFonts.lexend(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    height: 160,
                    width: 160,
                    decoration: BoxDecoration(
                      color: const Color(0xFF043C70),
                      borderRadius: BorderRadius.circular(80),
                    ),
                    child: const Icon(
                      Icons.skateboarding,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Versão 1.0.0',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                'O SkateFlow é o aplicativo definitivo para skatistas que buscam descobrir as melhores pistas e eventos em sua região. Nossa missão é conectar a vibrante comunidade do skate, facilitando a descoberta de novos spots incríveis e promovendo encontros entre skatistas apaixonados pelo esporte.\n\nCom recursos avançados de localização, avaliações da comunidade e informações detalhadas sobre cada pista, o SkateFlow transforma a experiência de explorar o mundo do skate, tornando cada sessão uma nova aventura.',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard('Desenvolvido por', 'Equipe SkateFlow', Icons.code),
            _buildInfoCard('Contato', '(11) 94567-8901', Icons.email),
            _buildInfoCard('Website', 'www.skateflow.com', Icons.language),
            _buildInfoCard('Suporte', 'suporte@skateflow.com', Icons.phone),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF043C70).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.favorite,
                    color: Color(0xFF043C70),
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Feito com ❤️ para a comunidade do skate',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2025 SkateFlow. Todos os direitos reservados.',
              style: GoogleFonts.lexend(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Termos de Uso', style: GoogleFonts.lexend(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.description,
                    color: Colors.black,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Termos de Uso do SkateFlow',
                    style: GoogleFonts.lexend(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Última atualização: Janeiro 2025',
                    style: GoogleFonts.lexend(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildTermsSection(
              '1. Aceitação dos Termos',
              'Ao usar o SkateFlow, você concorda com estes termos de uso. Se não concordar, não use o aplicativo.',
            ),
            _buildTermsSection(
              '2. Uso do Aplicativo',
              'O SkateFlow é destinado a skatistas para encontrar pistas e eventos. Você deve usar o app de forma responsável e respeitosa.',
            ),
            _buildTermsSection(
              '3. Privacidade',
              'Respeitamos sua privacidade. Coletamos apenas dados necessários para o funcionamento do app. Consulte nossa Política de Privacidade.',
            ),
            _buildTermsSection(
              '4. Conteúdo do Usuário',
              'Você é responsável pelo conteúdo que compartilha. Não publique conteúdo ofensivo, ilegal ou que viole direitos de terceiros.',
            ),
            _buildTermsSection(
              '5. Propriedade Intelectual',
              'O SkateFlow e todo seu conteúdo são protegidos por direitos autorais. Não reproduza sem autorização.',
            ),
            _buildTermsSection(
              '6. Limitação de Responsabilidade',
              'O SkateFlow não se responsabiliza por danos decorrentes do uso do aplicativo. Use por sua conta e risco.',
            ),
            _buildTermsSection(
              '7. Suspensão de Conta',
              'Podemos suspender ou encerrar sua conta em caso de violação destes termos.',
            ),
            _buildTermsSection(
              '8. Alterações no Serviço',
              'Reservamos o direito de modificar ou descontinuar o serviço a qualquer momento.',
            ),
            _buildTermsSection(
              '9. Lei Aplicável',
              'Estes termos são regidos pelas leis brasileiras. Disputas serão resolvidas no foro de São Paulo.',
            ),
            _buildTermsSection(
              '10. Modificações dos Termos',
              'Podemos modificar estes termos a qualquer momento. Continuando a usar o app, você aceita as modificações.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF043C70).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF043C70), size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          content,
          style: GoogleFonts.lexend(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildTermsSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF043C70),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.lexend(
              fontSize: 14,
              height: 1.5,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGpsPermissionsScreen() {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Permissões do Sistema', style: GoogleFonts.lexend(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.black,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Permissão de Localização',
                    style: GoogleFonts.lexend(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await openAppSettings();
                },
                icon: const Icon(Icons.settings),
                label: Text('Abrir Configurações do Sistema', style: GoogleFonts.lexend()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF043C70),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}