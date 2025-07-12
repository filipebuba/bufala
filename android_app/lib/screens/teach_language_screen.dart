import 'package:flutter/material.dart';
import '../services/collaborative_learning_service.dart';
import '../models/collaborative_learning_models.dart';

class TeachLanguageScreen extends StatefulWidget {
  const TeachLanguageScreen({super.key});

  @override
  State<TeachLanguageScreen> createState() => _TeachLanguageScreenState();
}

class _TeachLanguageScreenState extends State<TeachLanguageScreen> {
  final _translationFormKey = GlobalKey<FormState>();
  String _translationPhraseId = '';
  String _translationText = '';
  String _translationTargetLanguage = '';
  String? _translationSubmitError;
  bool _translationSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  String _portugueseText = '';
  String _translatedText = '';
  String _targetLanguage = '';
  String _category = '';
  DifficultyLevel _difficulty = DifficultyLevel.basic;
  String? _submitError;
  bool _submitting = false;
  final CollaborativeLearningService _service = CollaborativeLearningService();
  TeacherProfile? _profile;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    // Exemplo: teacherId fixo, depois trocar para o usuário logado
    final result = await _service.getTeacherProfile('demo_teacher');
    if (result.success) {
      setState(() {
        _profile = result.data;
        _loading = false;
      });
    } else {
      setState(() {
        _error = result.error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ensine o Bu Fala'),
        backgroundColor: Colors.blue,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Erro: $_error'))
              : _profile == null
                  ? Center(
                      child: ElevatedButton(
                        onPressed: _loadProfile,
                        child: const Text('Criar/Carregar Perfil'),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.blue[100],
                                child: Icon(Icons.person,
                                    size: 40, color: Colors.blue[700]),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_profile!.name,
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold)),
                                  Text('ID: ${_profile!.id}',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text('Idiomas que ensina:',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: _profile!.languagesTeaching
                                .map((lang) => Chip(label: Text(lang)))
                                .toList(),
                          ),
                                                      var result;
                                                      if (_translationPhraseId.trim().isNotEmpty) {
                                                        result = await _service.submitTranslation(
                                                          phraseId: _translationPhraseId.trim(),
                                                          translatedText: _translationText,
                                                          targetLanguage: _translationTargetLanguage,
                                                          userId: _profile!.id,
                                                        );
                                                      } else {
                                                        // Caso contrário, envia como tradução colaborativa geral
                                                        result = await _service.teachPhrase(
                                                          teacherId: _profile!.id,
                                                          portugueseText: '',
                                                          translatedText: _translationText,
                                                          targetLanguage: _translationTargetLanguage,
                                                          category: 'colaborativa',
                                                          difficultyLevel: DifficultyLevel.basic,
                                                        );
                                                      }
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: _loadProfile,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Atualizar Perfil'),
                          ),
                          const SizedBox(height: 32),
                          const Divider(),
                          const SizedBox(height: 16),
                          Text('Colabore:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _submitting
                                ? null
                                : () {
                                    showDialog<void>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text(
                                            'Nova frase para ensinar'),
                                        content: Form(
                                          key: _formKey,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextFormField(
                                                  decoration: const InputDecoration(
                                                      labelText:
                                                          'Frase em Português'),
                                                  onChanged: (v) =>
                                                      _portugueseText = v,
                                                  validator: (v) =>
                                                      v == null || v.isEmpty
                                                          ? 'Obrigatório'
                                                          : null,
                                                ),
                                                TextFormField(
                                                  decoration:
                                                      const InputDecoration(
                                                          labelText:
                                                              'Tradução'),
                                                  onChanged: (v) =>
                                                      _translatedText = v,
                                                  validator: (v) =>
                                                      v == null || v.isEmpty
                                                          ? 'Obrigatório'
                                                          : null,
                                                ),
                                                TextFormField(
                                                  decoration: const InputDecoration(
                                                      labelText:
                                                          'Idioma alvo (ex: crioulo, francês)'),
                                                  onChanged: (v) =>
                                                      _targetLanguage = v,
                                                  validator: (v) =>
                                                      v == null || v.isEmpty
                                                          ? 'Obrigatório'
                                                          : null,
                                                ),
                                                TextFormField(
                                                  decoration: const InputDecoration(
                                                      labelText:
                                                          'Categoria (ex: saudação, comida)'),
                                                  onChanged: (v) =>
                                                      _category = v,
                                                  validator: (v) =>
                                                      v == null || v.isEmpty
                                                          ? 'Obrigatório'
                                                          : null,
                                                ),
                                                DropdownButtonFormField<
                                                    DifficultyLevel>(
                                                  value: _difficulty,
                                                  decoration:
                                                      const InputDecoration(
                                                          labelText:
                                                              'Dificuldade'),
                                                  items: DifficultyLevel.values
                                                      .map((d) =>
                                                          DropdownMenuItem(
                                                            value: d,
                                                            child: Text(d.name),
                                                          ))
                                                      .toList(),
                                                  onChanged: (d) {
                                                    if (d != null)
                                                      setState(() =>
                                                          _difficulty = d);
                                                  },
                                                ),
                                                if (_submitError != null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8),
                                                    child: Text(_submitError!,
                                                        style: const TextStyle(
                                                            color: Colors.red)),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            onPressed: _submitting
                                                ? null
                                                : () async {
                                                    if (_formKey.currentState
                                                            ?.validate() ??
                                                        false) {
                                                      setState(() {
                                                        _submitting = true;
                                                        _submitError = null;
                                                      });
                                                      final result =
                                                          await _service
                                                              .teachPhrase(
                                                        teacherId: _profile!.id,
                                                        portugueseText:
                                                            _portugueseText,
                                                        translatedText:
                                                            _translatedText,
                                                        targetLanguage:
                                                            _targetLanguage,
                                                        category: _category,
                                                        difficultyLevel:
                                                            _difficulty,
                                                      );
                                                      setState(() {
                                                        _submitting = false;
                                                      });
                                                      if (result.success) {
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                const SnackBar(
                                                                    content: Text(
                                                                        'Frase enviada com sucesso!')));
                                                      } else {
                                                        setState(() {
                                                          _submitError =
                                                              result.error;
                                                        });
                                                      }
                                                    }
                                                  },
                                            child: _submitting
                                                ? const SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2))
                                                : const Text('Enviar'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.add_comment),
                            label: const Text('Enviar frase para ensinar'),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _translationSubmitting
                                ? null
                                : () {
                                    showDialog<void>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text(
                                            'Nova tradução colaborativa'),
                                        content: Form(
                                          key: _translationFormKey,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextFormField(
                                                  decoration: const InputDecoration(
                                                      labelText:
                                                          'ID da frase (opcional)'),
                                                  onChanged: (v) =>
                                                      _translationPhraseId = v,
                                                ),
                                                TextFormField(
                                                  decoration:
                                                      const InputDecoration(
                                                          labelText:
                                                              'Tradução'),
                                                  onChanged: (v) =>
                                                      _translationText = v,
                                                  validator: (v) =>
                                                      v == null || v.isEmpty
                                                          ? 'Obrigatório'
                                                          : null,
                                                ),
                                                TextFormField(
                                                  decoration: const InputDecoration(
                                                      labelText:
                                                          'Idioma alvo (ex: crioulo, francês)'),
                                                  onChanged: (v) =>
                                                      _translationTargetLanguage =
                                                          v,
                                                  validator: (v) =>
                                                      v == null || v.isEmpty
                                                          ? 'Obrigatório'
                                                          : null,
                                                ),
                                                if (_translationSubmitError !=
                                                    null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8),
                                                    child: Text(
                                                        _translationSubmitError!,
                                                        style: const TextStyle(
                                                            color: Colors.red)),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            onPressed: _translationSubmitting
                                                ? null
                                                : () async {
                                                    if (_translationFormKey
                                                            .currentState
                                                            ?.validate() ??
                                                        false) {
                                                      setState(() {
                                                        _translationSubmitting =
                                                            true;
                                                        _translationSubmitError =
                                                            null;
                                                      });
                                                      // Usando teachPhrase para simular envio de tradução colaborativa
                                                      final result =
                                                          await _service
                                                              .teachPhrase(
                                                        teacherId: _profile!.id,
                                                        portugueseText: '',
                                                        translatedText:
                                                            _translationText,
                                                        targetLanguage:
                                                            _translationTargetLanguage,
                                                        category:
                                                            'colaborativa',
                                                        difficultyLevel:
                                                            DifficultyLevel
                                                                .basic,
                                                      );
                                                      setState(() {
                                                        _translationSubmitting =
                                                            false;
                                                      });
                                                      if (result.success) {
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                const SnackBar(
                                                                    content: Text(
                                                                        'Tradução enviada com sucesso!')));
                                                      } else {
                                                        setState(() {
                                                          _translationSubmitError =
                                                              result.error;
                                                        });
                                                      }
                                                    }
                                                  },
                                            child: _translationSubmitting
                                                ? const SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2))
                                                : const Text('Enviar'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.translate),
                            label: const Text('Enviar tradução colaborativa'),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog<void>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text(
                                      'Validar conteúdo de outro usuário'),
                                  content: const Text(
                                      'Funcionalidade colaborativa em breve!'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.verified_user),
                            label:
                                const Text('Validar conteúdo de outro usuário'),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
