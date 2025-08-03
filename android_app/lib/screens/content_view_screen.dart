import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/offline_learning_models.dart';
import '../utils/app_colors.dart';
import '../widgets/translation_button.dart';

class ContentViewScreen extends StatefulWidget {
  const ContentViewScreen({required this.content, super.key});
  final OfflineLearningContent content;

  @override
  State<ContentViewScreen> createState() => _ContentViewScreenState();
}

class _ContentViewScreenState extends State<ContentViewScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  double _progress = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('pt-BR');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1);
    await _flutterTts.setPitch(1);

    _flutterTts.setStartHandler(() {
      setState(() {
        _isPlaying = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isPlaying = false;
        _progress = 1.0;
      });
    });

    _flutterTts.setProgressHandler((text, start, end, word) {
      setState(() {
        _progress = end / text.length;
      });
    });
  }

  Future<void> _toggleSpeech() async {
    if (_isPlaying) {
      await _flutterTts.stop();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _flutterTts.speak(widget.content.content);
    }
  }

  IconData _getContentIcon() {
    switch (widget.content.type) {
      case 'lesson':
        return Icons.school;
      case 'practice':
        return Icons.edit;
      case 'emergency':
        return Icons.emergency;
      case 'health_guide':
        return Icons.health_and_safety;
      case 'practical':
        return Icons.build;
      case 'ai_generated':
        return Icons.psychology;
      default:
        return Icons.book;
    }
  }

  Color _getContentColor() {
    switch (widget.content.subject.toLowerCase()) {
      case 'alfabetização':
        return Colors.blue;
      case 'matemática':
        return Colors.orange;
      case 'saúde':
        return Colors.red;
      case 'agricultura':
        return Colors.green;
      default:
        return AppColors.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.content.title),
          backgroundColor: _getContentColor(),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
              onPressed: _toggleSpeech,
              tooltip: _isPlaying ? 'Parar áudio' : 'Reproduzir áudio',
            ),
          ],
        ),
        body: Column(
          children: [
            if (_isPlaying)
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(_getContentColor()),
              ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabeçalho do conteúdo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getContentColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getContentColor().withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getContentIcon(),
                            size: 40,
                            color: _getContentColor(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.content.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.content.subject} • Nível ${widget.content.level}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Descrição
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.content.description,
                              style: const TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botão de tradução
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TranslationButton(
                          originalText: widget.content.content,
                          fromLanguage: widget.content.languages.isNotEmpty
                              ? widget.content.languages.first
                              : 'pt-BR',
                          languages: const [
                            {'code': 'pt-BR', 'name': 'Português', 'flag': '🇧🇷'},
                            {'code': 'crioulo-gb', 'name': 'Crioulo', 'flag': '🇬🇼'},
                            {'code': 'en', 'name': 'Inglês', 'flag': '🇬🇧'},
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Conteúdo principal
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.content.content,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.6,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Informações adicionais
                    if (widget.content.metadata.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informações adicionais:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...widget.content.metadata.entries.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '• ${entry.key}: ${entry.value}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _toggleSpeech,
          backgroundColor: _getContentColor(),
          child: Icon(
            _isPlaying ? Icons.stop : Icons.play_arrow,
            color: Colors.white,
          ),
        ),
      );

  @override
  void dispose() {
    _flutterTts.stop();
    _scrollController.dispose();
    super.dispose();
  }
}
