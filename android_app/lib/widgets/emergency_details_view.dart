import 'package:flutter/material.dart';

import '../models/crisis_response_models.dart';
import '../widgets/translation_button.dart';
// import '../utils/app_colors.dart';

class EmergencyDetailsView extends StatelessWidget {
  const EmergencyDetailsView(
      {required this.crisis, required this.language, super.key});
  final CrisisResponseData crisis;
  final String language;

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TranslationButton(
              originalText: crisis.description,
              fromLanguage: language,
              languages: const [
                {'code': 'pt-BR', 'name': 'Português', 'flag': '🇧🇷'},
                {'code': 'crioulo-gb', 'name': 'Crioulo', 'flag': '🇬🇼'},
                {'code': 'en', 'name': 'Inglês', 'flag': '🇬🇧'},
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          crisis.description,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        const Text(
          'Instruções:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        ...crisis.instructions.map((i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('• $i', style: const TextStyle(fontSize: 14)),
            )),
      ],
    );
}
