import 'package:flutter/material.dart';
import '../models/collaborative_learning_models.dart' as models;
import '../services/collaborative_learning_service.dart';

/// Tela para validar traduções de outros usuários
class ValidationScreen extends StatefulWidget {

  const ValidationScreen({
    required this.validatorId, super.key,
    this.targetLanguage = '',
  });
  final String validatorId;
  final String targetLanguage;

  @override
  State<ValidationScreen> createState() => _ValidationScreenState();
}

class _ValidationScreenState extends State<ValidationScreen> {
  final CollaborativeLearningService _service = CollaborativeLearningService();
  final TextEditingController _commentController = TextEditingController();

  List<models.UserTranslation> _translations = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadTranslationsToValidate();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadTranslationsToValidate() async {
    setState(() => _isLoading = true);

    final response = await _service.getTranslationsToValidate(
      validatorId: widget.validatorId,
      targetLanguage: widget.targetLanguage,
      limit: 10,
    );

    if (response.success && response.data != null) {
      setState(() {
        _translations = response.data!;
        _currentIndex = 0;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Nenhuma tradução para validar no momento');
    }
  }

  Future<void> _submitValidation(bool isCorrect) async {
    if (_translations.isEmpty) return;

    setState(() => _isSubmitting = true);

    final translation = _translations[_currentIndex];
    final response = await _service.validateTranslation(
      translationId: translation.id,
      validatorId: widget.validatorId,
      isCorrect: isCorrect,
      comment: _commentController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (response.success) {
      _showSuccessSnackBar(isCorrect
          ? 'Tradução aprovada! +50 pontos 🎉'
          : 'Feedback enviado! +50 pontos 📝');
      _nextTranslation();
    } else {
      _showErrorSnackBar('Erro ao enviar validação');
    }
  }

  void _nextTranslation() {
    _commentController.clear();
    if (_currentIndex + 1 >= _translations.length) {
      _loadTranslationsToValidate();
    } else {
      setState(() => _currentIndex++);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('✅ Validar Traduções'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _translations.isEmpty
              ? _buildEmptyState()
              : _buildValidationInterface(),
    );

  Widget _buildEmptyState() => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma tradução para validar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Volte mais tarde ou tente outro idioma',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadTranslationsToValidate,
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );

  Widget _buildValidationInterface() {
    final translation = _translations[_currentIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progresso
          _buildProgressIndicator(),
          const SizedBox(height: 24),

          // Informações do professor
          _buildTeacherInfo(translation),
          const SizedBox(height: 24),

          // Frase original e tradução
          _buildTranslationComparison(translation),
          const SizedBox(height: 24),

          // Campo de comentário
          _buildCommentField(),
          const SizedBox(height: 24),

          // Botões de validação
          _buildValidationButtons(),
          const SizedBox(height: 16),

          // Botão pular
          _buildSkipButton(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Text(
            'Validação ${_currentIndex + 1} de ${_translations.length}',
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            '+50 pontos',
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

  Widget _buildTeacherInfo(models.UserTranslation translation) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade200,
            child: Text(
              translation.teacherName.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translation.teacherName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Ensinou em ${translation.createdDate.day}/${translation.createdDate.month}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

  Widget _buildTranslationComparison(models.UserTranslation translation) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Avalie esta tradução:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Frase original
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Português:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '"Como você está?"', // TODO: Obter texto original da frase
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Tradução proposta
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tradução proposta:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '"${translation.translatedText}"',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (translation.pronunciationGuide.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Pronúncia: ${translation.pronunciationGuide}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

  Widget _buildCommentField() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comentário (opcional):',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _commentController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Explique por que está certa/errada, sugira melhorias...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.comment),
          ),
        ),
      ],
    );

  Widget _buildValidationButtons() => Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : () => _submitValidation(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Incorreta',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : () => _submitValidation(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Correta',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );

  Widget _buildSkipButton() => SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: _nextTranslation,
        child: const Text(
          'Pular esta validação',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
}
