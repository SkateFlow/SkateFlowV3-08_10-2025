import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pista_request.dart';
import '../services/pista_request_service.dart';
import '../constants/app_constants.dart';

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
  final _pistaRequestService = PistaRequestService();
  
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _cepController = TextEditingController();
  final _numeroController = TextEditingController();
  
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
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            _latitude = double.parse(data[0]['lat']);
            _longitude = double.parse(data[0]['lon']);
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar coordenadas: $e');
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

    setState(() {
      _loading = true;
    });

    try {
      // Converter fotos para base64
      final fotosBase64 = <String>[];
      for (final foto in _fotos) {
        if (foto != null) {
          final bytes = await foto.readAsBytes();
          final base64String = base64Encode(bytes);
          fotosBase64.add('data:image/jpeg;base64,$base64String');
        }
      }

      final request = PistaRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nome: _nomeController.text,
        descricao: _descricaoController.text,
        categoria: _categoria,
        cep: _cepController.text,
        rua: _rua,
        bairro: _bairro,
        numero: _numeroController.text,
        latitude: _latitude,
        longitude: _longitude,
        publica: _publica,
        fotos: fotosBase64,
        dataSolicitacao: DateTime.now(),
        usuarioId: widget.isUserLoggedIn ? 'user_id' : null,
      );

      await _pistaRequestService.addRequest(request);
      
      _mostrarSnackBar('Solicitação enviada com sucesso!', Colors.green);
      widget.onClose();
    } catch (e) {
      _mostrarSnackBar('Erro ao enviar solicitação', Colors.red);
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
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(AppConstants.primaryBlue),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Solicitar Nova Pista',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close, color: Colors.white),
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
                      // Fotos
                      const Text(
                        'Fotos da Pista',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 80,
                        child: Row(
                          children: List.generate(3, (index) => 
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                                child: GestureDetector(
                                  onTap: () => _selecionarFoto(index),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: _fotos[index] != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.file(
                                              _fotos[index]!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add_photo_alternate, color: Colors.grey),
                                              Text('Foto', style: TextStyle(fontSize: 12)),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Nome
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome da Pista',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o nome da pista';
                          }
                          return null;
                        },
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
                      const Text(
                        'Categoria da Pista',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _categorias.map((categoria) => 
                          ChoiceChip(
                            label: Text(categoria.toUpperCase()),
                            selected: _categoria == categoria,
                            onSelected: (selected) {
                              setState(() {
                                _categoria = selected ? categoria : '';
                              });
                            },
                            selectedColor: const Color(AppConstants.primaryBlue),
                            labelStyle: TextStyle(
                              color: _categoria == categoria ? Colors.white : Colors.black,
                            ),
                          ),
                        ).toList(),
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
                              controller: TextEditingController(text: _rua),
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
                        controller: TextEditingController(text: _bairro),
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
                        activeThumbColor: const Color(AppConstants.primaryBlue),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onClose,
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _loading ? null : _salvarSolicitacao,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(AppConstants.primaryBlue),
                        foregroundColor: Colors.white,
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
                          : const Text('Solicitar Pista'),
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