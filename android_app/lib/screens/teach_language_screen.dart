import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/collaborative_learning_models.dart';
import '../services/collaborative_learning_service.dart';

class TeachLanguageScreen extends StatefulWidget {
  const TeachLanguageScreen({super.key});

  @override
  State<TeachLanguageScreen> createState() => _TeachLanguageScreenState();
}

class _TeachLanguageScreenState extends State<TeachLanguageScreen> {
  final _translationFormKey = GlobalKey<FormState>();
  final String _translationPhraseId = '';
  final String _translationText = '';
  final String _translationTargetLanguage = '';
  String? _translationSubmitError;
  final bool _translationSubmitting = false;
  
  // Upload de mídia
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  File? _selectedAudio;
  bool _isRecording = false;
  String? _audioBase64;
  String? _imageBase64;
  final _formKey = GlobalKey<FormState>();
  final String _portugueseText = '';
  final String _translatedText = '';
  final String _targetLanguage = '';
  final String _category = '';
  final DifficultyLevel _difficulty = DifficultyLevel.basic;
  String? _submitError;
  final bool _submitting = false;
  final CollaborativeLearningService _service = CollaborativeLearningService();
  TeacherProfile? _profile;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }
  
  // Métodos para upload de mídia
  Future<void> _pickImage() async {
    try {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        final image = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 70,
        );
        if (image != null) {
          final file = File(image.path);
          final bytes = await file.readAsBytes();
          setState(() {
            _selectedImage = file;
            _imageBase64 = base64Encode(bytes);
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de câmera necessária')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao capturar imagem: $e')),
      );
    }
  }
  
  Future<void> _pickImageFromGallery() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        final file = File(image.path);
        final bytes = await file.readAsBytes();
        setState(() {
          _selectedImage = file;
          _imageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar imagem: $e')),
      );
    }
  }
  
  Future<void> _startAudioRecording() async {
    try {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        setState(() {
          _isRecording = true;
        });
        // Simular gravação por 3 segundos
        await Future.delayed(const Duration(seconds: 3));
        setState(() {
          _isRecording = false;
          _audioBase64 = 'audio_simulado_base64'; // Placeholder
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Áudio gravado com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de microfone necessária')),
        );
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gravar áudio: $e')),
      );
    }
  }
  
  void _clearMedia() {
    setState(() {
      _selectedImage = null;
      _selectedAudio = null;
      _audioBase64 = null;
      _imageBase64 = null;
    });
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
  Widget build(BuildContext context) => Scaffold(
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
                          const Text('Idiomas que ensina:',
                              style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: _profile!.languagesTeaching
                                .map((lang) => Chip(label: Text(lang)))
                                .toList(),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: _loadProfile,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Atualizar Perfil'),
                          ),
                          const SizedBox(height: 32),
                          const Divider(),
                          const SizedBox(height: 16),
                          const Text('Colabore:',
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
                                                    if (d != null) {
                                                      setState(() =>
                                                          _difficulty = d);
                                                    }
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
                          const SizedBox(height: 20),
                          // Seção de Upload Multimodal
                          Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '📸 Upload Multimodal',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Adicione áudio e imagens para enriquecer suas contribuições:',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 16),
                                  // Botões de upload
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _pickImage,
                                        icon: const Icon(Icons.camera_alt),
                                        label: const Text('Câmera'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue[600],
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: _pickImageFromGallery,
                                        icon: const Icon(Icons.photo_library),
                                        label: const Text('Galeria'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[600],
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: _isRecording ? null : _startAudioRecording,
                                        icon: _isRecording 
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(Icons.mic),
                                        label: Text(_isRecording ? 'Gravando...' : 'Gravar Áudio'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _isRecording ? Colors.red[600] : Colors.purple[600],
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                      if (_selectedImage != null || _audioBase64 != null)
                                        ElevatedButton.icon(
                                          onPressed: _clearMedia,
                                          icon: const Icon(Icons.clear),
                                          label: const Text('Limpar'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[600],
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Preview da mídia selecionada
                                  if (_selectedImage != null) ...[
                                    const Text(
                                      '🖼️ Imagem selecionada:',
                                      style: TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 120,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _selectedImage!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  if (_audioBase64 != null) ...[
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.purple[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.purple[200]!),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.audiotrack, color: Colors.purple),
                                          SizedBox(width: 8),
                                          Text(
                                            '🎵 Áudio gravado com sucesso!',
                                            style: TextStyle(
                                              color: Colors.purple,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  // Botão de envio multimodal
                                  if (_selectedImage != null || _audioBase64 != null)
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          // Simular envio multimodal
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('📤 Conteúdo multimodal enviado com sucesso!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                          _clearMedia();
                                        },
                                        icon: const Icon(Icons.cloud_upload),
                                        label: const Text('Enviar Conteúdo Multimodal'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange[600],
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
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
