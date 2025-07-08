import 'package:flutter/material.dart';
import '../services/gemma3_backend_service.dart';

class TranslationButton extends StatefulWidget {

  const TranslationButton({
    required this.originalText, required this.fromLanguage, required this.languages, super.key,
  });
  final String originalText;
  final String fromLanguage;
  final List<Map<String, String>> languages;

  @override
  State<TranslationButton> createState() => _TranslationButtonState();
}

class _TranslationButtonState extends State<TranslationButton> {
  String? _translatedText;
  String? _selectedLanguage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.languages
        .firstWhere((l) => l['code'] != widget.fromLanguage)['code'];
  }

  Future<void> _translate() async {
    setState(() => _isLoading = true);
    final gemmaService = Gemma3BackendService();
    final translated = await gemmaService.translateText(
      text: widget.originalText,
      fromLanguage: widget.fromLanguage,
      toLanguage: _selectedLanguage!,
    );
    setState(() {
      _translatedText = translated;
      _isLoading = false;
    });
    _showTranslationModal();
  }

  void _showTranslationModal() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tradução'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Texto original:'),
            Text(widget.originalText, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            const Text('Tradução:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_translatedText != null)
              Text(
                _translatedText!,
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButton<String>(
          value: _selectedLanguage,
          items: widget.languages
              .where((l) => l['code'] != widget.fromLanguage)
              .map((lang) => DropdownMenuItem(
                    value: lang['code'],
                    child: Text(lang['name'] ?? lang['code']!),
                  ))
              .toList(),
          onChanged: (val) => setState(() => _selectedLanguage = val),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _translate,
          icon: const Icon(Icons.translate),
          label: const Text('Traduzir'),
        ),
      ],
    );
}
