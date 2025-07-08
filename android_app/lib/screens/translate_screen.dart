import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _textController = TextEditingController();

  String _fromLanguage = 'pt-BR';
  String _toLanguage = 'crioulo-gb';
  bool _isLoading = false;
  String _translatedText = '';

  final List<Map<String, String>> _languages = [
    {'code': 'pt-BR', 'name': 'Português', 'flag': '🇧🇷'},
    {'code': 'crioulo-gb', 'name': 'Crioulo', 'flag': '🇬🇼'},
  ];

  Future<void> _translateText() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite algum texto para traduzir'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _translatedText = '';
    });

    try {
      final response = await _apiService.translateText(
        text: _textController.text,
        sourceLanguage: _fromLanguage,
        targetLanguage: _toLanguage,
      );

      setState(() {
        if (response.success && response.data != null) {
          _translatedText = response.data!;
        } else {
          _translatedText =
              'Erro na tradução: ${response.error ?? "Problema na comunicação"}';
        }
      });
    } catch (e) {
      setState(() {
        _translatedText = 'Erro de conexão: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _fromLanguage;
      _fromLanguage = _toLanguage;
      _toLanguage = temp;

      // Se há tradução, swap também o texto
      if (_translatedText.isNotEmpty && !_translatedText.startsWith('Erro')) {
        final tempText = _textController.text;
        _textController.text = _translatedText;
        _translatedText = tempText;
      }
    });
  }

  Widget _buildLanguageSelector({
    required String selectedLanguage,
    required Function(String) onChanged,
    required String label,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
            ),
            child: DropdownButton<String>(
              value: selectedLanguage,
              isExpanded: true,
              underline: Container(),
              items: _languages
                  .map((lang) => DropdownMenuItem(
                        value: lang['code'],
                        child: Row(
                          children: [
                            Text(lang['flag']!,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(lang['name']!),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (value) => onChanged(value!),
            ),
          ),
        ],
      );

  Widget _buildQuickPhrases() {
    final phrases = _fromLanguage == 'pt-BR'
        ? {
            'Olá, como está?': 'Cumprimento básico',
            'Obrigado pela ajuda': 'Agradecimento',
            'Onde fica o hospital?': 'Localização médica',
            'Quanto custa isso?': 'Pergunta de preço',
            'Preciso de ajuda': 'Pedido de socorro',
            'Bom dia': 'Saudação matinal',
          }
        : {
            'Ola, kuma bu ku sta?': 'Cumprimento básico',
            'Obrigadu pa djuda': 'Agradecimento',
            'Undi ki ta ospital?': 'Localização médica',
            'Kuantu ki kosta isu?': 'Pergunta de preço',
            'N\'misti djuda': 'Pedido de socorro',
            'Bon dia': 'Saudação matinal',
          };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frases Comuns:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...phrases.entries.map((entry) => Card(
              margin: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                dense: true,
                title: Text(entry.key, style: const TextStyle(fontSize: 14)),
                subtitle: Text(entry.value,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                trailing: const Icon(Icons.arrow_forward, size: 16),
                onTap: () {
                  _textController.text = entry.key;
                  _translateText();
                },
              ),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Tradutor Bu Fala'),
          backgroundColor: AppColors.translation,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.translation,
                      AppColors.translation.withValues(alpha: 0.7)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.translate, size: 48, color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      'Tradutor Português ↔ Crioulo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tradução inteligente com Gemma-3n',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Seletores de idioma
              Row(
                children: [
                  Expanded(
                    child: _buildLanguageSelector(
                      selectedLanguage: _fromLanguage,
                      onChanged: (value) =>
                          setState(() => _fromLanguage = value),
                      label: 'De:',
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _swapLanguages,
                    icon: const Icon(Icons.swap_horiz),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          AppColors.translation.withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildLanguageSelector(
                      selectedLanguage: _toLanguage,
                      onChanged: (value) => setState(() => _toLanguage = value),
                      label: 'Para:',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Campo de texto original
              const Text(
                'Texto para traduzir:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Digite o texto aqui...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Botão de tradução
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _translateText,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.translation,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Traduzir',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Resultado da tradução
              if (_translatedText.isNotEmpty) ...[
                const Text(
                  'Tradução:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    border: Border.all(
                        color: AppColors.translation.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _translatedText,
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Frases comuns
              _buildQuickPhrases(),
            ],
          ),
        ),
      );

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
