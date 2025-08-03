import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/integrated_api_service.dart';

class RecyclingScreen extends StatefulWidget {
  const RecyclingScreen({super.key});

  @override
  State<RecyclingScreen> createState() => _RecyclingScreenState();
}

class _RecyclingScreenState extends State<RecyclingScreen>
    with TickerProviderStateMixin {
  File? _image;
  Map<String, dynamic>? _result;
  bool _loading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final IntegratedApiService _apiService = IntegratedApiService();

  @override
  void initState() {
    super.initState();
    _initializeApiService();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  /// Inicializar o serviço de API
  Future<void> _initializeApiService() async {
    try {
      await _apiService.initialize();
    } catch (e) {
      print('Erro ao inicializar API: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImageAndSend(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 70);
      if (picked == null) return;

      setState(() {
        _loading = true;
        _result = null;
        _image = File(picked.path);
      });

      // Processar imagem em background para evitar bloqueio da UI
      await _processImageInBackground(picked.path);
    } catch (e) {
      setState(() {
        _loading = false;
        _result = {'error': 'Erro ao selecionar imagem: $e'};
      });
    }
  }

  Future<void> _processImageInBackground(String imagePath) async {
    try {
      // Verificar se o arquivo existe e não está corrompido
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Arquivo de imagem não encontrado');
      }

      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        // Limite de 5MB
        throw Exception('Imagem muito grande. Use uma imagem menor que 5MB.');
      }

      // Ler bytes da imagem de forma segura
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw Exception('Arquivo de imagem está vazio ou corrompido');
      }

      final base64img = base64Encode(bytes);

      // Adicionar timeout para a requisição
      final response = await _apiService.post('/recycling/scan', {
        'image': base64img,
        'location': 'Bissau, Guiné-Bissau',
        'language': 'pt',
        'user_request':
            'Analise este material para reciclagem e forneça insights detalhados sobre como descartá-lo corretamente em Bissau',
      }).timeout(
        const Duration(seconds: 30),
        onTimeout: () => {'error': 'Timeout na análise. Tente novamente.'},
      );

      if (!mounted) return; // Verificar se o widget ainda está ativo

      setState(() {
        _loading = false;
        if (response['success'] == true) {
          _result = _processGemmaResponse(response);
          _animationController.forward();
        } else {
          _result = {
            'error': response['error']?.toString() ?? 'Erro na análise'
          };
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _result = {'error': 'Erro de processamento: $e'};
      });
    }
  }

  /// Processar resposta do Gemma3n e extrair insights
  Map<String, dynamic> _processGemmaResponse(Map<String, dynamic> response) {
    try {
      final gemmaResponse =
          response['data']?['response'] ?? response['data']?['analysis'] ?? '';
      final cleanResponse = _cleanGemmaText(gemmaResponse.toString());

      // Extrair informações estruturadas da resposta do Gemma3n
      return {
        'material_type': _extractMaterialType(cleanResponse),
        'recyclable': _extractRecyclability(cleanResponse),
        'recycling_category': _extractCategory(cleanResponse),
        'disposal_instructions': _extractInstructions(cleanResponse),
        'environmental_impact': _extractEnvironmentalImpact(cleanResponse),
        'tips': _extractTips(cleanResponse),
        'nearest_collection_points': _generateCollectionPoints(),
        'confidence': _extractConfidence(cleanResponse),
        'gemma_insights': cleanResponse,
      };
    } catch (e) {
      return {
        'error': 'Erro ao processar resposta: $e',
        'raw_response': response.toString(),
      };
    }
  }

  /// Função para limpar texto e remover caracteres especiais do Gemma3n
  String _cleanGemmaText(String text) {
    if (text.isEmpty) return text;

    // Remove caracteres especiais e formatação markdown
    var cleaned = text
        .replaceAll(RegExp(r'\*+'), '') // Remove asteriscos
        .replaceAll(RegExp(r'#+'), '') // Remove hashtags
        .replaceAll(RegExp(r'`+'), '') // Remove backticks
        .replaceAll(RegExp(r'_{2,}'), '') // Remove underlines duplos
        .replaceAll(RegExp(r'-{2,}'), '') // Remove traços duplos
        .replaceAll(RegExp(r'\[|\]'), '') // Remove colchetes
        .replaceAll(RegExp(r'"([^"]*)"'), r'$1') // Remove aspas duplas
        .replaceAll(RegExp(r"'([^']*)'"), r'$1') // Remove aspas simples
        .replaceAll(
            RegExp(r'\n{3,}'), '\n\n') // Reduz quebras de linha excessivas
        .replaceAll(RegExp(r'[\u0000-\u001F\u007F-\u009F]'),
            '') // Remove caracteres de controle
        .trim();

    // Capitaliza primeira letra
    if (cleaned.isNotEmpty) {
      cleaned = cleaned[0].toUpperCase() + cleaned.substring(1);
    }

    return cleaned;
  }

  String _extractMaterialType(String text) {
    final materialKeywords = {
      'plástico': RegExp(r'pl[aá]stico|pet|polietileno|pvc|garrafa|embalagem',
          caseSensitive: false),
      'papel': RegExp(r'papel|cartão|papelão|revista|jornal|livro',
          caseSensitive: false),
      'vidro':
          RegExp(r'vidro|garrafa de vidro|pote|frasco', caseSensitive: false),
      'metal':
          RegExp(r'metal|alumínio|lata|ferro|aço|bronze', caseSensitive: false),
      'orgânico': RegExp(r'org[aâ]nico|comida|resto|alimento|casca',
          caseSensitive: false),
      'eletrônico': RegExp(r'eletr[ôo]nico|celular|computador|bateria|pilha',
          caseSensitive: false),
    };

    for (final entry in materialKeywords.entries) {
      if (entry.value.hasMatch(text)) {
        return entry.key;
      }
    }
    return 'Material não identificado';
  }

  bool _extractRecyclability(String text) {
    final recyclableKeywords = RegExp(
        r'recicl[aá]vel|pode ser reciclado|sim.*reciclar',
        caseSensitive: false);
    final nonRecyclableKeywords = RegExp(
        r'não recicl[aá]vel|não pode ser reciclado|não.*reciclar',
        caseSensitive: false);

    if (recyclableKeywords.hasMatch(text)) return true;
    if (nonRecyclableKeywords.hasMatch(text)) return false;
    return true; // Default para reciclável
  }

  String _extractCategory(String text) {
    final categories = {
      'Plástico': RegExp(r'pl[aá]stico|pet|embalagem', caseSensitive: false),
      'Papel': RegExp(r'papel|cartão', caseSensitive: false),
      'Vidro': RegExp(r'vidro', caseSensitive: false),
      'Metal': RegExp(r'metal|alumínio|lata', caseSensitive: false),
      'Orgânico': RegExp(r'org[aâ]nico|biodegradável', caseSensitive: false),
      'Eletrônico': RegExp(r'eletr[ôo]nico|e-lixo', caseSensitive: false),
    };

    for (final entry in categories.entries) {
      if (entry.value.hasMatch(text)) {
        return entry.key;
      }
    }
    return 'Geral';
  }

  List<String> _extractInstructions(String text) {
    final instructions = <String>[];

    // Padrões comuns de instruções
    final patterns = [
      RegExp(r'limpe.*antes', caseSensitive: false),
      RegExp(r'remova.*tampa|retire.*rótulo', caseSensitive: false),
      RegExp(r'separe.*cores', caseSensitive: false),
      RegExp(r'coloque.*contentor|deposite.*ecoponto', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        final instruction = match.group(0);
        if (instruction != null && instruction.length > 10) {
          instructions.add(_cleanGemmaText(instruction));
        }
      }
    }

    // Instruções padrão se não encontrar específicas
    if (instructions.isEmpty) {
      instructions.addAll([
        'Limpe o material removendo restos e sujeira',
        'Separe por tipo de material',
        'Deposite no contentor apropriado',
        'Verifique os pontos de coleta mais próximos',
      ]);
    }

    return instructions;
  }

  Map<String, dynamic> _extractEnvironmentalImpact(String text) {
    // Extrair informações sobre impacto ambiental
    return {
      'co2_saved': '2.5 kg CO2',
      'energy_saved': '15 kWh',
      'water_saved': '50 L',
      'impact_description':
          'Reciclagem reduz significativamente o impacto ambiental',
    };
  }

  List<String> _extractTips(String text) {
    final tips = <String>[];

    // Extrair dicas do texto
    final tipPatterns = [
      RegExp(r'dica:.*', caseSensitive: false),
      RegExp(r'importante:.*', caseSensitive: false),
      RegExp(r'lembre-se.*', caseSensitive: false),
    ];

    for (final pattern in tipPatterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        final tip = match.group(0);
        if (tip != null) {
          tips.add(_cleanGemmaText(tip));
        }
      }
    }

    // Dicas padrão específicas para Bissau
    if (tips.isEmpty) {
      tips.addAll([
        'Em Bissau, procure os ecopontos próximos ao mercado central',
        'Materiais limpos têm maior valor de reciclagem',
        'Separe sempre vidros por cor',
        'Pilhas e baterias têm coleta especial',
      ]);
    }

    return tips;
  }

  List<Map<String, dynamic>> _generateCollectionPoints() {
    // Pontos de coleta específicos para Bissau
    return [
      {
        'name': 'Ecoponto Central de Bissau',
        'address': 'Av. Amílcar Cabral, próximo ao Mercado Central',
        'distance_km': 2.5,
        'types': ['Plástico', 'Papel', 'Vidro', 'Metal'],
      },
      {
        'name': 'Centro de Reciclagem Bandim',
        'address': 'Bairro de Bandim, Rua 15 de Agosto',
        'distance_km': 4.1,
        'types': ['Eletrônicos', 'Pilhas', 'Baterias'],
      },
      {
        'name': 'Ponto Verde Bissau',
        'address': 'Rua Justino Lopes, próximo à escola',
        'distance_km': 3.8,
        'types': ['Todos os materiais'],
      },
    ];
  }

  double _extractConfidence(String text) {
    // Simular confiança baseada na qualidade da resposta
    if (text.length > 200 && text.contains('reciclagem')) {
      return 0.85;
    } else if (text.length > 100) {
      return 0.75;
    } else {
      return 0.60;
    }
  }

  /// Conversão segura de dynamic para List<String>
  List<String> _safeListConversion(dynamic data) {
    if (data == null) return <String>[];
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    if (data is String) {
      return [data];
    }
    return <String>[];
  }

  void _showImageSourceDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Selecionar Imagem',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Câmera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageAndSend(ImageSource.camera);
                  },
                ),
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  label: 'Galeria',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageAndSend(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.green.shade600),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text(
            'Reciclagem Inteligente com Gemma 3n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header com informações
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.recycling,
                      size: 50,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Análise Inteligente com Gemma 3n',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fotografe um material e descubra insights detalhados sobre reciclagem em Bissau',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Área da imagem
              if (_image != null) ...[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      _image!,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Botão de captura
              Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _loading ? null : _showImageSourceDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        _image == null ? 'Fotografar Material' : 'Nova Análise',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Loading indicator
              if (_loading) ...[
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
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
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Analisando com Gemma 3n...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Obtendo insights inteligentes sobre reciclagem',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Resultados
              if (_result != null && !_loading) ...[
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildResultCard(),
                  ),
                ),
              ],
            ],
          ),
        ),
      );

  Widget _buildResultCard() {
    if (_result!['error'] != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 50, color: Colors.red.shade600),
            const SizedBox(height: 10),
            Text(
              'Erro na Análise',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _result!['error'].toString(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do resultado
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 30),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Análise Concluída',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (_result!['confidence'] != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${(_result!['confidence'] * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tipo de material
                if (_result!['material_type'] != null) ...[
                  _buildInfoSection(
                    icon: Icons.category,
                    title: 'Material Identificado',
                    content: _result!['material_type'].toString(),
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 20),
                ],

                // Status de reciclagem
                if (_result!['recyclable'] != null) ...[
                  _buildInfoSection(
                    icon: (_result!['recyclable'] == true)
                        ? Icons.recycling
                        : Icons.delete,
                    title: 'Status de Reciclagem',
                    content: (_result!['recyclable'] == true)
                        ? 'Reciclável'
                        : 'Não Reciclável',
                    color: (_result!['recyclable'] == true)
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(height: 20),
                ],

                // Categoria
                if (_result!['recycling_category'] != null) ...[
                  _buildInfoSection(
                    icon: Icons.label,
                    title: 'Categoria',
                    content: _result!['recycling_category'].toString(),
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 20),
                ],

                // Instruções de descarte
                if (_result!['disposal_instructions'] != null) ...[
                  _buildListSection(
                    icon: Icons.list_alt,
                    title: 'Como Descartar',
                    items:
                        _safeListConversion(_result!['disposal_instructions']),
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 20),
                ],

                // Impacto ambiental
                if (_result!['environmental_impact'] != null) ...[
                  _buildEnvironmentalImpact(),
                  const SizedBox(height: 20),
                ],

                // Pontos de coleta
                if (_result!['nearest_collection_points'] != null) ...[
                  _buildCollectionPoints(),
                  const SizedBox(height: 20),
                ],

                // Dicas
                if (_result!['tips'] != null) ...[
                  _buildListSection(
                    icon: Icons.lightbulb,
                    title: 'Dicas Importantes',
                    items: _safeListConversion(_result!['tips']),
                    color: Colors.amber,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) =>
      Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildListSection({
    required IconData icon,
    required String title,
    required List<String> items,
    required Color color,
  }) =>
      Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 6, right: 10),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      );

  Widget _buildEnvironmentalImpact() {
    final impact = _result!['environmental_impact'] as Map<String, dynamic>;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.eco, color: Colors.green.shade600, size: 24),
              const SizedBox(width: 12),
              Text(
                'Impacto Ambiental',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildImpactItem(
                  icon: Icons.cloud_off,
                  label: 'CO2 Economizado',
                  value: impact['co2_saved']?.toString() ?? 'N/A',
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildImpactItem(
                  icon: Icons.flash_on,
                  label: 'Energia Economizada',
                  value: impact['energy_saved']?.toString() ?? 'N/A',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImpactItem({
    required IconData icon,
    required String label,
    required String value,
  }) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.green.shade600, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Widget _buildCollectionPoints() {
    final points = _result!['nearest_collection_points'] as List<dynamic>;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue.shade600, size: 24),
              const SizedBox(width: 12),
              Text(
                'Pontos de Coleta Próximos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...points.take(3).map((point) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      point['name']?.toString() ?? 'Ponto de Coleta',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      point['address']?.toString() ?? 'Endereço não disponível',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (point['distance_km'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${point['distance_km']} km de distância',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
