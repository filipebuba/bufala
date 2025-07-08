import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/environmental_api_service.dart';

class BiodiversityScreen extends StatefulWidget {
  const BiodiversityScreen({required this.api, super.key});
  final EnvironmentalApiService api;

  @override
  State<BiodiversityScreen> createState() => _BiodiversityScreenState();
}

class _BiodiversityScreenState extends State<BiodiversityScreen> {
  File? _image;
  Map<String, dynamic>? _result;
  bool _loading = false;

  Future<void> _pickImageAndSend() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;
    setState(() {
      _loading = true;
      _result = null;
    });
    _image = File(picked.path);
    final bytes = await _image!.readAsBytes();
    final base64img = base64Encode(bytes);
    // Exemplo de localização fixa (substitua por GPS real)
    final location = {'lat': 11.8, 'lng': -15.6};
    final resp = await widget.api
        .trackBiodiversity(imageBase64: base64img, location: location);
    setState(() {
      _loading = false;
      if (resp['status'] == 'success' && resp['result'] != null) {
        _result = Map<String, dynamic>.from(resp['result'] as Map);
      } else {
        _result = {'error': resp['error']?.toString() ?? 'Erro desconhecido'};
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Rastreamento de Biodiversidade')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_image != null) Image.file(_image!, height: 150),
            ElevatedButton(
              onPressed: _loading ? null : _pickImageAndSend,
              child: const Text('Enviar Foto e Localização'),
            ),
            if (_loading) const CircularProgressIndicator(),
            if (_result != null) ...[
              const SizedBox(height: 16),
              if (_result!['species'] != null)
                ...(_result!['species'] as List<dynamic>).map((s) => Text(
                      '${s['name'] ?? ''} (${s['type'] ?? ''}) - Confiança: ${(s['confidence'] ?? '').toString()}',
                      style: const TextStyle(fontSize: 16),
                    )),
              if (_result!['error'] != null)
                Text(_result!['error']?.toString() ?? '',
                    style: const TextStyle(fontSize: 16, color: Colors.red)),
            ]
          ],
        ),
      ),
    );
}
