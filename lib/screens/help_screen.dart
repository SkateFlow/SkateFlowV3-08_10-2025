import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final helpItems = [
      {
        'title': 'Como usar o app',
        'subtitle': 'Aprenda a navegar e usar todas as funcionalidades',
        'icon': Icons.help_outline,
      },
      {
        'title': 'Encontrar pistas',
        'subtitle': 'Como localizar e filtrar pistas próximas',
        'icon': Icons.location_on,
      },
      {
        'title': 'Participar de eventos',
        'subtitle': 'Como se inscrever e participar de eventos',
        'icon': Icons.event,
      },
      {
        'title': 'Gerenciar perfil',
        'subtitle': 'Como editar suas informações e preferências',
        'icon': Icons.person,
      },
      {
        'title': 'Favoritar pistas',
        'subtitle': 'Como salvar suas pistas preferidas',
        'icon': Icons.favorite,
      },
      {
        'title': 'Problemas técnicos',
        'subtitle': 'Soluções para problemas comuns do app',
        'icon': Icons.build,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajuda',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2C2C2C)
                    : Colors.white,
                border: Border(
                    bottom: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade700
                      : Colors.grey.shade200,
                )),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 60,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Como podemos ajudar?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Encontre respostas para suas dúvidas',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00294F), Color(0xFF043C70)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Suporte por Telefone',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '(11) 94567-8901',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Segunda a Sexta, 9h às 18h',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = helpItems[index];
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF043C70).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: const Color(0xFF043C70),
                          size: 24,
                        ),
                      ),
                      title: Text(
                        item['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item['subtitle'] as String,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _showHelpDetail(context, item);
                      },
                    ),
                  ),
                );
              },
              childCount: helpItems.length,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Ainda precisa de ajuda?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SupportScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.contact_support),
                      label: const Text('Outras Opções de Contato'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00294F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDetail(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Icon(
              item['icon'] as IconData,
              size: 32,
              color: const Color(0xFF043C70),
            ),
            const SizedBox(height: 8),
            Text(
              item['title'] as String,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _getHelpContent(item['title'] as String),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHelpContent(String title) {
    switch (title) {
      case 'Como usar o app':
        return 'O SkateFlow é seu companheiro para encontrar as melhores pistas de skate e eventos da sua região.\n\n'
            '• Use a aba "Início" para ver pistas próximas e eventos em destaque\n'
            '• Na aba "Mapa" você pode visualizar todas as pistas em um mapa interativo\n'
            '• A aba "Pistas" mostra uma lista completa com filtros\n'
            '• Em "Eventos" você encontra todos os eventos disponíveis\n'
            '• Seu "Perfil" permite personalizar suas informações';

      case 'Encontrar pistas':
        return 'Para encontrar pistas próximas a você:\n\n'
            '• Permita o acesso à sua localização quando solicitado\n'
            '• Use o mapa para visualizar pistas próximas\n'
            '• Filtre por tipo de pista (Street, Bowl, Plaza)\n'
            '• Veja avaliações e distância de cada pista\n'
            '• Toque em uma pista para ver mais detalhes';

      case 'Participar de eventos':
        return 'Para participar de eventos:\n\n'
            '• Acesse a aba "Eventos" para ver todos os eventos disponíveis\n'
            '• Toque em um evento para ver detalhes completos\n'
            '• Use o botão "Agendar Ingresso" para se inscrever\n'
            '• Adicione eventos aos favoritos para não esquecer\n'
            '• Receba notificações sobre eventos próximos';

      case 'Gerenciar perfil':
        return 'Para gerenciar seu perfil:\n\n'
            '• Acesse a aba "Perfil"\n'
            '• Toque em "Editar Perfil" para alterar suas informações\n'
            '• Adicione uma foto de perfil\n'
            '• Atualize sua bio e informações pessoais\n'
            '• Configure suas preferências de notificação';

      case 'Favoritar pistas':
        return 'Para salvar suas pistas favoritas:\n\n'
            '• Toque no botão "Favoritar" em qualquer pista\n'
            '• Acesse suas pistas favoritas através do menu do perfil\n'
            '• Remova pistas dos favoritos tocando no coração\n'
            '• Use os favoritos para acesso rápido às suas pistas preferidas';

      case 'Problemas técnicos':
        return 'Soluções para problemas comuns:\n\n'
            '• Se o mapa não carregar, verifique sua conexão com a internet\n'
            '• Para problemas de localização, verifique as permissões do app\n'
            '• Se o app estiver lento, tente reiniciá-lo\n'
            '• Para outros problemas, use a opção "Reportar Problema" nas configurações\n'
            '• Mantenha o app sempre atualizado';

      default:
        return 'Informações de ajuda não disponíveis para este tópico.';
    }
  }
}

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Precisa de Mais Ajuda',
            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
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
                  Icon(
                    Icons.support_agent,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Suporte por Email',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Descreva sua dúvida ou problema e nossa equipe responderá em breve',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Assunto',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _subjectController,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Digite o assunto da sua mensagem',
                prefixIcon: Icon(
                  Icons.subject,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.grey.shade600,
                ),
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
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Mensagem',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 6,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Descreva detalhadamente sua dúvida ou problema...\n\nIncluir informações como:\n• O que você estava tentando fazer\n• O que aconteceu\n• Mensagens de erro (se houver)',
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
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade50,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00294F).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF00294F).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF00294F)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Nossa equipe de suporte responderá em até 24 horas úteis no email cadastrado.',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : const Color(0xFF00294F),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
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
                        'Mensagem enviada com sucesso! Nossa equipe responderá em breve.',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: const Color(0xFF00294F),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.send),
                label: const Text('Enviar Mensagem'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00294F),
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
