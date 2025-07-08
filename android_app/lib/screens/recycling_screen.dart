import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/environmental_api_service.dart';

class RecyclingScreen extends StatefulWidget {
  const RecyclingScreen({required this.api, super.key});
  final EnvironmentalApiService api;

  @override
  State<RecyclingScreen> createState() => _RecyclingScreenState();
}

class _RecyclingScreenState extends State<RecyclingScreen> {
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
    final resp = await widget.api.scanRecycling(imageBase64: base64img);
    setState(() {
      _loading = false;
      if (resp['status'] == 'success') {
        _result = Map<String, dynamic>.from(resp);
      } else {
        _result = {'error': resp['error']?.toString() ?? 'Erro desconhecido'};
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Reciclagem Inteligente')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_image != null) Image.file(_image!, height: 150),
            ElevatedButton(
              onPressed: _loading ? null : _pickImageAndSend,
              child: const Text('Enviar Foto para Reciclagem'),
            ),
            if (_loading) const CircularProgressIndicator(),
            if (_result != null) ...[
              const SizedBox(height: 16),
              if (_result!['materials'] != null)
                ...(_result!['materials'] as List<dynamic>).map((m) => Text(
                      'Material: ${m['type'] ?? ''} (Confiança: ${(m['confidence'] ?? '').toString()})',
                      style: const TextStyle(fontSize: 16),
                    )),
              if (_result!['tips'] != null)
                ...(_result!['tips'] as List<dynamic>).map((t) => Text(
                      'Dica: $t',
                      style: const TextStyle(
                          fontSize: 16, fontStyle: FontStyle.italic),
                    )),
              if (_result!['gamification'] != null)
                Text('Gamificação: ${_result!['gamification'].toString()}',
                    style: const TextStyle(fontSize: 16)),
              if (_result!['error'] != null)
                Text(_result!['error']?.toString() ?? '',
                    style: const TextStyle(fontSize: 16, color: Colors.red)),
            ]
          ],
        ),
      ),
    );
}
