import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/lugar_service.dart';
import '../services/auth_service.dart';
import '../constants/app_constants.dart';
import '../utils/app_theme.dart';

class CreatePistaModal extends StatefulWidget {
  final bool isUserLoggedIn;
  final VoidCallback onClose;

  const CreatePistaModal({
    super.key,
    required this.isUserLoggedIn,
    required this.onClose,
  });

  @override
  State<CreatePistaModal> createState() => _CreatePistaModalState();
}

class _CreatePistaModalState extends State<CreatePistaModal> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _cepController = TextEditingController();
  final _numeroController = TextEditingController();
  final _ruaController = TextEditingController();
  final _bairroController = TextEditingController();
  
  String _categoria = '';
  String _rua = '';
  String _bairro = '';
  double? _latitude;
  double? _longitude;
  bool _publica = true;
  bool _loading = false;
  
  final List<File?> _fotos = List.filled(AppConstants.maxPhotos, null);
  final ImagePicker _picker = ImagePicker();
  
  final List<String> _categorias = ['bowl', 'street', 'park'];

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _cepController.dispose();
    _numeroController.dispose();
    _ruaController.dispose();
    _bairroController.dispose();
    super.dispose();
  }

  String _formatCep(String value) {
    final numbers = value.replaceAll(RegExp(r'\D'), '');
    if (numbers.length <= 5) {
      return numbers;
    }
    return '${numbers.substring(0, 5)}-${numbers.substring(5, numbers.length > 8 ? 8 : numbers.length)}';
  }

  Future<void> _buscarEnderecoPorCep(String cep) async {
    final numbersOnly = cep.replaceAll(RegExp(r'\D'), '');
    if (numbersOnly.length != 8) return;

    try {
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$numbersOnly/json/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['erro'] == null) {
          setState(() {
            _rua = data['logradouro'] ?? '';
            _bairro = data['bairro'] ?? '';
            _ruaController.text = _rua;
            _bairroController.text = _bairro;
          });
          
          if (_rua.isNotEmpty) {
            await _buscarCoordenadas('$_rua, ${data['localidade']}, ${data['uf']}');
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar CEP: $e');
    }
  }

  Future<void> _buscarCoordenadas(String endereco) async {
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(endereco)}&limit=1'),
        headers: {'User-Agent': 'SkateFlow/1.0'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            _latitude = double.parse(data[0]['lat']);
            _longitude = double.parse(data[0]['lon']);
          });
        } else {
          setState(() {
            _latitude = -23.5505;
            _longitude = -46.6333;
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar coordenadas: $e');
      setState(() {
        _latitude = -23.5505;
        _longitude = -46.6333;
      });
    }
  }

  Future<void> _selecionarFoto(int index) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _fotos[index] = File(image.path);
      });
    }
  }

  Future<void> _salvarSolicitacao() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoria.isEmpty) {
      _mostrarSnackBar('Selecione uma categoria', Colors.red);
      return;
    }
    if (_latitude == null || _longitude == null) {
      setState(() {
        _latitude = -23.5505;
        _longitude = -46.6333;
      });
    }

    setState(() {
      _loading = true;
    });

    try {
      // Converter fotos para base64
      String? foto1Base64;
      String? foto2Base64;
      String? foto3Base64;

      if (_fotos[0] != null) {
        final bytes = await _fotos[0]!.readAsBytes();
        foto1Base64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }
      if (_fotos[1] != null) {
        final bytes = await _fotos[1]!.readAsBytes();
        foto2Base64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }
      if (_fotos[2] != null) {
        final bytes = await _fotos[2]!.readAsBytes();
        foto3Base64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }

      // Mapear categoria para ID (2=Bowl, 3=Street, 4=Park)
      int categoriaId;
      switch (_categoria.toLowerCase()) {
        case 'bowl':
          categoriaId = 2;
          break;
        case 'street':
          categoriaId = 3;
          break;
        case 'park':
          categoriaId = 4;
          break;
        default:
          categoriaId = 3; // Default street
      }

      final userId = _authService.currentUserId;
      if (userId == null) {
        _mostrarSnackBar('Usuário não autenticado', Colors.red);
        return;
      }

      final success = await LugarService.solicitarPista(
        nome: _nomeController.text,
        descricao: _descricaoController.text,
        tipo: _publica ? 'Pública' : 'Particular',
        cep: _cepController.text,
        rua: _rua,
        bairro: _bairro,
        numero: _numeroController.text,
        latitude: _latitude.toString(),
        longitude: _longitude.toString(),
        categoriaId: categoriaId,
        usuarioId: int.parse(userId),
        foto1Base64: foto1Base64,
        foto2Base64: foto2Base64,
        foto3Base64: foto3Base64,
      );

      if (success) {
        _mostrarSnackBar('Pista solicitada com sucesso! Aguarde aprovação.', Colors.green);
        widget.onClose();
      } else {
        _mostrarSnackBar('Erro ao enviar solicitação', Colors.red);
      }
    } catch (e) {
      print('Erro: $e');
      _mostrarSnackBar('Erro ao enviar solicitação: $e', Colors.red);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _mostrarSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isUserLoggedIn) {
      return AlertDialog(
        title: const Text('Login Necessário'),
        content: const Text('Você precisa estar logado para solicitar uma nova pista.'),
        actions: [
          TextButton(
            onPressed: widget.onClose,
            child: const Text('OK'),
          ),
        ],
      );
    }

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Solicitar Nova Pista',
                    style: GoogleFonts.lexend(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textColor,
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close, color: AppTheme.textColor),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fotos Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fotos da Pista *',
                              style: GoogleFonts.lexend(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: List.generate(3, (index) => 
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                                    child: GestureDetector(
                                      onTap: () => _selecionarFoto(index),
                                      child: Container(
                                        height: 100,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color(0xFFCBD5E0),
                                            width: 2,
                                            style: BorderStyle.solid,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          color: const Color(0xFFF8FAFC),
                                        ),
                                        child: _fotos[index] != null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Image.file(
                                                  _fotos[index]!,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.upload_file,
                                                    color: Color(0xFF64748B),
                                                    size: 24,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Foto ${index + 1}',
                                                    style: GoogleFonts.lexend(
                                                      fontSize: 12,
                                                      color: const Color(0xFF64748B),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Nome
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nome da Pista *',
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nomeController,
                            style: GoogleFonts.lexend(),
                            decoration: InputDecoration(
                              hintText: 'Digite o nome da pista',
                              hintStyle: GoogleFonts.lexend(
                                color: const Color(0xFF64748B),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira o nome da pista';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Descrição
                      TextFormField(
                        controller: _descricaoController,
                        maxLines: 3,
                        maxLength: AppConstants.maxDescriptionLength,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira uma descrição';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Categoria
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Categoria da Pista *',
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: _categorias.map((categoria) => 
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _categoria = _categoria == categoria ? '' : categoria;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _categoria == categoria ? AppTheme.primaryColor : Colors.white,
                                    border: Border.all(
                                      color: _categoria == categoria ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Text(
                                    categoria.toUpperCase(),
                                    style: GoogleFonts.lexend(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _categoria == categoria ? Colors.white : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                            ).toList(),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // CEP
                      TextFormField(
                        controller: _cepController,
                        decoration: const InputDecoration(
                          labelText: 'CEP',
                          border: OutlineInputBorder(),
                          hintText: '00000-000',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(8),
                        ],
                        onChanged: (value) {
                          final formatted = _formatCep(value);
                          if (formatted != value) {
                            _cepController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(offset: formatted.length),
                            );
                          }
                          if (formatted.length == 9) {
                            _buscarEnderecoPorCep(formatted);
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o CEP';
                          }
                          if (value.replaceAll(RegExp(r'\D'), '').length != 8) {
                            return 'CEP deve ter 8 dígitos';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Rua e Número
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Rua',
                                border: const OutlineInputBorder(),
                                fillColor: Colors.grey.shade100,
                                filled: true,
                              ),
                              controller: _ruaController,
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _numeroController,
                              decoration: const InputDecoration(
                                labelText: 'Número',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Número obrigatório';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Bairro
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Bairro',
                          border: const OutlineInputBorder(),
                          fillColor: Colors.grey.shade100,
                          filled: true,
                        ),
                        controller: _bairroController,
                        readOnly: true,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Switch Pista Privada
                      SwitchListTile(
                        title: const Text('Pista Privada'),
                        value: !_publica,
                        onChanged: (value) {
                          setState(() {
                            _publica = !value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onClose,
                      style: AppTheme.secondaryButtonStyle,
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _loading ? null : _salvarSolicitacao,
                      style: AppTheme.primaryButtonStyle,
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
                              'Solicitar Pista',
                              style: GoogleFonts.lexend(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}