import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:record/record.dart'; // Temporariamente desabilitado
import '../services/environmental_api_service.dart';
import '../config/app_config.dart';

class PlantDiagnosisScreen extends StatefulWidget {
  const PlantDiagnosisScreen({super.key});

  @override
  _PlantDiagnosisScreenState createState() => _PlantDiagnosisScreenState();
}

class _PlantDiagnosisScreenState extends State<PlantDiagnosisScreen>
    with TickerProviderStateMixin {
  File? _image;
  final picker = ImagePicker();
  final TextEditingController _plantTypeController = TextEditingController();
  // final Record _audioRecorder = Record(); // Temporariamente desabilitado
  late EnvironmentalApiService _apiService;
  
  bool _isLoading = false;
  bool _isRecording = false;
  bool _hasRecording = false;
  String? _audioPath;
  Map<String, dynamic>? _diagnosisResult;
  String? _error;
  String _analysisMode = 'image'; // 'image' ou 'audio'
  
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _apiService = EnvironmentalApiService(baseUrl: AppConfig.apiBaseUrl);
    _pulseController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    
    XFile? pickedFile;
    
    // Verificar se está rodando na web
     if (kIsWeb) {
       // Para web, usar source gallery (funciona como file picker)
       pickedFile = await picker.pickImage(source: ImageSource.gallery);
     } else {
      // Para mobile, usar ImageSource.gallery
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
    }
    
    if (pickedFile != null) {
      if (kIsWeb) {
        // Para web, criar arquivo temporário
        final bytes = await pickedFile.readAsBytes();
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(bytes);
        
        setState(() {
          _image = tempFile;
          _diagnosisResult = null;
          _error = null;
        });
      } else {
         // Para mobile, usar o arquivo diretamente
         setState(() {
           _image = File(pickedFile!.path);
           _diagnosisResult = null;
           _error = null;
         });
       }
    }
  }

  @override
  void dispose() {
    _plantTypeController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    // _audioRecorder.dispose(); // Temporariamente desabilitado
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.camera.request();
    await Permission.storage.request();
  }

  Future getImage(ImageSource source) async {
    await _requestPermissions();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _diagnosisResult = null;
        _error = null;
        _analysisMode = 'image';
      }
    });
  }

  Future<void> _startRecording() async {
    // Funcionalidade de áudio temporariamente desabilitada
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de áudio em desenvolvimento'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _stopRecording() async {
    // Funcionalidade de áudio temporariamente desabilitada
  }

  Future<void> _analyzeImage() async {
    if (_image == null) {
      setState(() {
        _error = 'Por favor, selecione uma imagem primeiro.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    _fadeController.forward();

    try {
      final bytes = await _image!.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final result = await _apiService.analyzePlantImage(
        imageBase64: base64Image,
        plantType: _plantTypeController.text.isNotEmpty ? _plantTypeController.text : null,
      );
      
      setState(() {
        _diagnosisResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao analisar a imagem: $e';
        _isLoading = false;
      });
    }
    
    _fadeController.reverse();
  }

  Future<void> _analyzeAudio() async {
    // Funcionalidade de áudio temporariamente desabilitada
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Análise de áudio em desenvolvimento'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          '🌱 Diagnóstico de Plantas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF2E7D32),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Identifique problemas em suas plantas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Use imagem ou descrição por áudio para diagnóstico preciso',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            
            _buildModeSelector(),
            _buildPlantTypeInput(),
            
            if (_analysisMode == 'image') _buildImageAnalysis(),
            if (_analysisMode == 'audio') _buildAudioAnalysis(),
            
            if (_error != null) _buildErrorMessage(),
            if (_diagnosisResult != null) _buildDiagnosisResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.grey[100],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _analysisMode = 'image'),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: _analysisMode == 'image' ? Color(0xFF2E7D32) : Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      color: _analysisMode == 'image' ? Colors.white : Colors.grey[600],
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Imagem',
                      style: TextStyle(
                        color: _analysisMode == 'image' ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _analysisMode = 'audio'),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: _analysisMode == 'audio' ? Color(0xFF2E7D32) : Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mic,
                      color: _analysisMode == 'audio' ? Colors.white : Colors.grey[600],
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Áudio',
                      style: TextStyle(
                        color: _analysisMode == 'audio' ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageAnalysis() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!, width: 2),
            color: Colors.grey[50],
          ),
          child: _image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    _image!,
                    fit: BoxFit.cover,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Adicione uma foto da planta',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => getImage(ImageSource.camera),
                icon: Icon(Icons.camera_alt, color: Colors.white),
                label: Text('Câmera', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2E7D32),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => getImage(ImageSource.gallery),
                icon: Icon(Icons.photo_library, color: Color(0xFF2E7D32)),
                label: Text('Galeria', style: TextStyle(color: Color(0xFF2E7D32))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Color(0xFF2E7D32)),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_image != null) ...[
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _analyzeImage,
            child: _isLoading
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Analisando...', style: TextStyle(color: Colors.white)),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.analytics, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Analisar Imagem', style: TextStyle(color: Colors.white)),
                    ],
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2E7D32),
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAudioAnalysis() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isRecording
                  ? [Color(0xFFE8F5E8), Color(0xFFC8E6C9)]
                  : [Colors.grey[50]!, Colors.grey[100]!],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isRecording ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording ? Color(0xFF2E7D32) : Colors.grey[300],
                        boxShadow: _isRecording
                            ? [
                                BoxShadow(
                                  color: Color(0xFF2E7D32).withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        size: 40,
                        color: _isRecording ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              Text(
                _isRecording
                    ? 'Gravando... Descreva os problemas da planta'
                    : _hasRecording
                        ? 'Gravação concluída'
                        : 'Toque para gravar descrição',
                style: TextStyle(
                  color: _isRecording ? Color(0xFF2E7D32) : Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isRecording ? _stopRecording : _startRecording,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                _isRecording ? 'Parar Gravação' : 'Iniciar Gravação',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isRecording ? Colors.red[600] : Color(0xFF2E7D32),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (_hasRecording && !_isRecording) ...[
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _analyzeAudio,
            child: _isLoading
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Analisando...', style: TextStyle(color: Colors.white)),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.analytics, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Analisar Áudio', style: TextStyle(color: Colors.white)),
                    ],
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2E7D32),
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlantTypeInput() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: TextField(
        controller: _plantTypeController,
        decoration: InputDecoration(
          labelText: 'Tipo de planta (opcional)',
          hintText: 'Ex: tomate, milho, arroz, mandioca...',
          prefixIcon: Icon(Icons.eco, color: Color(0xFF2E7D32)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600]),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisResults() {
    if (_diagnosisResult == null) return SizedBox.shrink();
    
    final diagnosis = _diagnosisResult!['diagnosis'] ?? {};
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.only(top: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF1F8E9), Color(0xFFE8F5E8)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                color: Color(0xFF2E7D32),
              ),
              child: Row(
                children: [
                  Icon(Icons.analytics, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Resultado do Diagnóstico',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_analysisMode == 'audio' && diagnosis['audio_transcription'] != null) ...[
                    _buildResultSection(
                      'Transcrição do Áudio',
                      Icons.record_voice_over,
                      diagnosis['audio_transcription'],
                    ),
                    SizedBox(height: 16),
                  ],
                  if (diagnosis['plant_identification'] != null)
                    _buildPlantIdentification(diagnosis['plant_identification']),
                  SizedBox(height: 16),
                  if (diagnosis['health_assessment'] != null)
                    _buildHealthAssessment(diagnosis['health_assessment']),
                  SizedBox(height: 16),
                  if (diagnosis['symptoms_identified'] != null)
                    _buildSymptomsIdentified(diagnosis['symptoms_identified']),
                  SizedBox(height: 16),
                  if (diagnosis['probable_diagnosis'] != null)
                    _buildProbableDiagnosis(diagnosis['probable_diagnosis']),
                  SizedBox(height: 16),
                  if (diagnosis['recommendations'] != null)
                    _buildRecommendations(diagnosis['recommendations']),
                  SizedBox(height: 16),
                  if (diagnosis['local_resources'] != null)
                    _buildLocalResources(diagnosis['local_resources']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection(String title, IconData icon, String content) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Color(0xFF2E7D32), size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantIdentification(Map<String, dynamic> identification) {
    return _buildResultSection(
      'Identificação da Planta',
      Icons.eco,
      '${identification['name'] ?? 'Não identificada'}\n'
      'Nome científico: ${identification['scientific_name'] ?? 'N/A'}\n'
      'Família: ${identification['family'] ?? 'N/A'}',
    );
  }

  Widget _buildHealthAssessment(Map<String, dynamic> assessment) {
    final score = assessment['health_score'] ?? 0;
    final status = assessment['status'] ?? 'Desconhecido';
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety, color: Color(0xFF2E7D32), size: 20),
              SizedBox(width: 8),
              Text(
                'Avaliação de Saúde',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: $status',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Score de Saúde',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: score / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        score >= 70 ? Colors.green : score >= 40 ? Colors.orange : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: score >= 70 ? Colors.green[100] : score >= 40 ? Colors.orange[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${score.toInt()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: score >= 70 ? Colors.green[700] : score >= 40 ? Colors.orange[700] : Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsIdentified(List<dynamic> symptoms) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange[600], size: 20),
              SizedBox(width: 8),
              Text(
                'Sintomas Identificados',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...symptoms.map((symptom) => Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.fiber_manual_record, size: 8, color: Colors.orange[600]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    symptom.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildProbableDiagnosis(Map<String, dynamic> diagnosis) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services, color: Colors.red[600], size: 20),
              SizedBox(width: 8),
              Text(
                'Diagnóstico Provável',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            diagnosis['condition'] ?? 'Não determinado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red[700],
            ),
          ),
          if (diagnosis['description'] != null) ...[
            SizedBox(height: 8),
            Text(
              diagnosis['description'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ],
          if (diagnosis['severity'] != null) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getSeverityColor(diagnosis['severity']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getSeverityColor(diagnosis['severity'])),
              ),
              child: Text(
                'Severidade: ${diagnosis['severity']}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _getSeverityColor(diagnosis['severity']),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendations(Map<String, dynamic> recommendations) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue[600], size: 20),
              SizedBox(width: 8),
              Text(
                'Recomendações',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (recommendations['immediate_actions'] != null) ...[
            Text(
              'Ações Imediatas:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.blue[700],
              ),
            ),
            SizedBox(height: 8),
            ...(recommendations['immediate_actions'] as List).map((action) => Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.arrow_right, size: 16, color: Colors.blue[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      action.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
            SizedBox(height: 12),
          ],
          if (recommendations['long_term_care'] != null) ...[
            Text(
              'Cuidados a Longo Prazo:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.blue[700],
              ),
            ),
            SizedBox(height: 8),
            ...(recommendations['long_term_care'] as List).map((care) => Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.arrow_right, size: 16, color: Colors.blue[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      care.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildLocalResources(Map<String, dynamic> resources) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.green[600], size: 20),
              SizedBox(width: 8),
              Text(
                'Recursos Locais',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (resources['available_treatments'] != null) ...[
            Text(
              'Tratamentos Disponíveis na Região:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.green[700],
              ),
            ),
            SizedBox(height: 8),
            ...(resources['available_treatments'] as List).map((treatment) => Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.eco, size: 16, color: Colors.green[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      treatment.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
            SizedBox(height: 12),
          ],
          if (resources['local_contacts'] != null) ...[
            Text(
              'Contatos Locais:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.green[700],
              ),
            ),
            SizedBox(height: 8),
            ...(resources['local_contacts'] as List).map((contact) => Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.contact_phone, size: 16, color: Colors.green[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      contact.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'baixa':
      case 'low':
        return Colors.green;
      case 'média':
      case 'medium':
        return Colors.orange;
      case 'alta':
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
