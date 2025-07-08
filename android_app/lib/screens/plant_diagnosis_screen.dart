import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/environmental_api_service.dart';

class PlantDiagnosisScreen extends StatefulWidget {
  const PlantDiagnosisScreen({required this.apiService, super.key, this.userId});
  final EnvironmentalApiService apiService;
  final String? userId;

  @override
  State<PlantDiagnosisScreen> createState() => _PlantDiagnosisScreenState();
}

class _PlantDiagnosisScreenState extends State<PlantDiagnosisScreen> {
  File? _imageFile;
  String? _diagnosisResult;
  bool _loading = false;
  String? _error;
  final TextEditingController _plantTypeController = TextEditingController();
  bool _isFromCamera = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _diagnosisResult = null;
        _error = null;
        _isFromCamera = false;
      });
    }
  }

  Future<void> _pickImageFromCameraAndDiagnose() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _diagnosisResult = null;
        _error = null;
        _isFromCamera = true;
      });
      await _diagnose();
    }
  }

  Future<void> _diagnose() async {
    if (_imageFile == null) return;
    setState(() {
      _loading = true;
      _diagnosisResult = null;
      _error = null;
    });
    try {
      final bytes = await _imageFile!.readAsBytes();
      final imageBase64 = base64Encode(bytes);
      final result = await widget.apiService.analyzePlantImage(
        imageBase64: imageBase64,
        plantType: _plantTypeController.text.isNotEmpty
            ? _plantTypeController.text
            : null,
        userId: widget.userId,
      );
      setState(() {
        _diagnosisResult =
            const JsonEncoder.withIndent('  ').convert(result['diagnosis']);
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao diagnosticar: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Diagnóstico de Plantas (Imagem)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _plantTypeController,
              decoration: const InputDecoration(
                labelText: 'Tipo de planta (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_imageFile != null) Image.file(_imageFile!, height: 180) else Container(
                    height: 180,
                    color: Colors.grey[200],
                    child:
                        const Center(child: Text('Nenhuma imagem selecionada')),
                  ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('Selecionar da Galeria'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickImageFromCameraAndDiagnose,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Usar Câmera (Diagnóstico Imediato)'),
            ),
            const SizedBox(height: 16),
            if (_imageFile != null && !_isFromCamera)
              ElevatedButton(
                onPressed: !_loading ? _diagnose : null,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Diagnosticar'),
              ),
            const SizedBox(height: 24),
            if (_diagnosisResult != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(_diagnosisResult!,
                          style: const TextStyle(fontFamily: 'monospace')),
                    ),
                  ),
                ),
              ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
}
