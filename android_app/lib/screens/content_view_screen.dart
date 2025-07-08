import 'package:flutter/material.dart';

import '../models/offline_learning_models.dart';
import '../utils/app_colors.dart';
import '../widgets/translation_button.dart';

class ContentViewScreen extends StatelessWidget {
  const ContentViewScreen({required this.content, super.key});
  final OfflineLearningContent content;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(content.title),
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TranslationButton(
                    originalText: content.description,
                    fromLanguage: content.languages.isNotEmpty
                        ? content.languages.first
                        : 'pt-BR',
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
                content.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Conteúdo em desenvolvimento',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
