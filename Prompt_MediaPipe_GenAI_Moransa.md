# Prompt Elaborado: Integração MediaPipe GenAI no Projeto Moransa
## Implementação Avançada com Gemma 3n E2B e E4B

## 🎯 Contexto do Projeto

**Projeto**: Moransa - Assistente de IA para Comunidades Rurais da Guiné-Bissau  
**Objetivo**: Migrar do backend Ollama/Gemma 3n para execução nativa com MediaPipe GenAI  
**Plataformas**: Android e iOS  
**Modelos**: Gemma 3n E2B e E4B com arquitetura MatFormer  
**Inovação**: Primeira implementação offline completa do Gemma 3n para idiomas locais africanos

## 🧠 Arquitetura Avançada do Gemma 3n

### Inovações Técnicas Fundamentais

#### 1. **Per-Layer Embeddings (PLE)**
- **Conceito**: Parâmetros de embedding gerados e armazenados em cache separadamente
- **Benefício**: Redução significativa do consumo de VRAM
- **Implementação**: Descarregamento inteligente para CPU liberando VRAM do acelerador
- **Resultado**: E2B (5B parâmetros) → 2GB VRAM efetiva | E4B (8B parâmetros) → 3GB VRAM efetiva

#### 2. **Arquitetura Matryoshka Transformer (MatFormer)**
- **Funcionalidade**: Aninhamento de submodelos (E4B contém E2B funcional)
- **Inferência Elástica**: Troca em tempo real entre E4B ↔ E2B baseada em recursos
- **Método Mix-n-Match**: Criação de modelos personalizados entre E2B e E4B
- **Adaptação Dinâmica**: Ajuste de dimensão oculta e pulo seletivo de camadas

#### 3. **Carregamento Condicional de Parâmetros**
- **Modalidades Seletivas**: Carregamento apenas dos parâmetros necessários (texto/visão/áudio)
- **Otimização de Memória**: Redução dinâmica do número total de parâmetros
- **Flexibilidade**: Capacidade "ramped up or ramped down" baseada no dispositivo

### Capacidades Multimodais Avançadas

#### **Processamento de Áudio**
- **Codificador**: Universal Speech Model (USM)
- **Performance**: 1 token a cada 160ms (≈6 tokens/segundo)
- **Idiomas Otimizados**: Português, Espanhol, Francês, Italiano
- **Funcionalidades**: Reconhecimento de voz e tradução em tempo real

#### **Processamento Visual**
- **Codificador**: MobileNet-V5 de alto desempenho
- **Resoluções Suportadas**: 256x256, 512x512, 768x768 pixels
- **Performance**: Até 60 quadros por segundo (Google Pixel)
- **Capacidades**: Análise de vídeo em tempo real e experiências interativas

#### **Contexto Expandido**
- **Janela de Contexto**: 32.000 tokens
- **Aplicação**: Análise de grandes volumes de dados e processamento complexo

## 📋 Estrutura Atual do Projeto

### Backend (Python/Flask)
```
backend/
├── app.py                    # Aplicação principal Flask
├── services/
│   ├── gemma_service.py      # Serviço atual Ollama/Gemma 3n
│   ├── health_service.py     # Monitoramento de saúde
│   ├── model_selector.py     # Seleção inteligente de modelos
│   └── intelligent_model_selector.py # Seleção baseada em domínio
├── routes/
│   ├── medical_routes.py     # Emergências médicas
│   ├── education_routes.py   # Conteúdo educacional
│   ├── agriculture_routes.py # Consultoria agrícola
│   ├── translation_routes.py # Tradução multimodal
│   ├── accessibility_routes.py # Acessibilidade
│   └── multimodal_routes.py  # Processamento multimodal
└── config/
    ├── settings.py           # Configurações do Gemma 3n + quantização
    └── system_prompts.py     # Prompts especializados
```

### Frontend (Flutter)
```
android_app/
├── lib/
│   ├── main.dart
│   ├── services/
│   │   ├── api_client.dart
│   │   ├── offline_ai_service.dart
│   │   └── google_ai_edge_service.dart  # Placeholder existente
│   ├── screens/
│   │   ├── emergency_detail_screen.dart
│   │   ├── education_screen.dart
│   │   └── agriculture_screen.dart
│   └── utils/
├── pubspec.yaml              # Dependências Flutter
├── android/
│   └── app/build.gradle.kts  # Configurações Android
└── assets/
    ├── models/               # Diretório para modelos .task
    ├── audio/                # Áudios em Crioulo/Português
    └── emergency/            # Dados de emergência
```

## 🚀 Objetivo da Migração

### De: Backend Centralizado (Atual)
- ✅ Ollama + Gemma 3n rodando em servidor
- ✅ Flutter fazendo requisições HTTP
- ✅ Seleção inteligente de modelos (E2B/E4B)
- ✅ Suporte multimodal via backend
- ❌ Dependência de rede local
- ❌ Latência de comunicação (~2s)
- ❌ Consumo de bateria por rede

### Para: Execução Nativa (Objetivo)
- 🎯 MediaPipe GenAI executando no dispositivo
- 🎯 Gemma 3n E2B/E4B nativos com MatFormer
- 🎯 Per-Layer Embeddings (PLE) otimizado
- 🎯 Inferência elástica E2B ↔ E4B
- 🎯 Carregamento condicional de parâmetros
- 🎯 Zero dependência de rede
- 🎯 Latência ultra-baixa (~200ms)
- 🎯 Processamento multimodal nativo (60 FPS)

## 📱 Especificações Técnicas Avançadas

### Dependências Atuais (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.4.0                 # HTTP client atual - MIGRAR
  connectivity_plus: ^5.0.2   # Verificação de rede - MANTER
  provider: ^6.1.1            # State management
  hive: ^2.2.3               # Storage local
  camera: ^0.10.5+5          # Câmera para multimodal
  image_picker: ^1.1.2       # Seleção de imagens
  flutter_tts: ^3.8.5        # Text-to-Speech
  audioplayers: ^5.2.1       # Reprodução de áudio
  # ADICIONAR:
  mediapipe_genai: ^0.1.0    # MediaPipe GenAI
  device_info_plus: ^9.1.0   # Info do dispositivo para adaptação
  path_provider: ^2.1.1      # Acesso a diretórios locais
```

### Configurações Android Avançadas (build.gradle.kts)
```kotlin
android {
    namespace = "com.example.android_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"
    
    defaultConfig {
        applicationId = "com.example.android_app"
        minSdk = 24  // AUMENTAR para suporte MediaPipe
        targetSdk = flutter.targetSdkVersion
        
        ndk {
            abiFilters += listOf("arm64-v8a", "x86_64") // Otimizar para 64-bit
        }
    }
    
    aaptOptions {
        noCompress += "tflite"
        noCompress += "lite"
        noCompress += "task"  // ADICIONAR para modelos .task
    }
    
    // CONFIGURAÇÕES AVANÇADAS PARA MEDIAPIPE
    packagingOptions {
        pickFirst "**/libc++_shared.so"
        pickFirst "**/libjsc.so"
    }
}

dependencies {
    implementation 'com.google.mediapipe:tasks-genai:0.10.8'
    implementation 'com.google.mediapipe:framework:0.10.8'
    implementation 'org.tensorflow:tensorflow-lite:2.13.0'
    implementation 'org.tensorflow:tensorflow-lite-gpu:2.13.0'
}
```

### Configurações iOS Avançadas (Podfile)
```ruby
# Configuração mínima iOS
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!
  
  # MediaPipe GenAI
  pod 'MediaPipeTasksGenAI', '~> 0.10.8'
  pod 'TensorFlowLiteObjC', '~> 2.13.0'
  
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

# Configurações de build
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    # Configurações específicas para MediaPipe
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

## 🎯 Casos de Uso Específicos do Moransa

### 1. Emergências Médicas (Crítico)
**Contexto**: Mulher em trabalho de parto em aldeia remota  
**Input**: Texto/Áudio em Português/Crioulo descrevendo sintomas  
**Output**: Orientações de primeiros socorros estruturadas  
**Modelo**: Gemma 3n E4B (máxima precisão)  
**Temperature**: 0.2-0.3 (determinístico)  
**Latência Alvo**: <500ms (crítico para emergências)

```dart
// Implementação atual que precisa ser migrada
Future<String> handleEmergency(String symptoms, String emergencyType) async {
  final response = await dio.post(
    'http://10.0.2.2:5000/api/medical/emergency',
    data: {
      'prompt': symptoms,
      'emergencyType': emergencyType,
      'language': 'pt',
      'useCreole': false
    }
  );
  return response.data['ai_guidance'];
}
```

### 2. Educação Adaptativa
**Contexto**: Criação de material didático sem internet  
**Input**: Tópico educacional + nível de dificuldade  
**Output**: Conteúdo educacional culturalmente adaptado  
**Modelo**: Gemma 3n E2B (eficiência)  
**Temperature**: 0.6-0.7 (criativo mas controlado)  
**Otimização**: Carregamento condicional (apenas texto)

### 3. Consultoria Agrícola Multimodal
**Contexto**: Análise de pragas via imagem da cultura  
**Input**: Imagem (768x768) + descrição do problema + áudio  
**Output**: Diagnóstico + recomendações de tratamento  
**Modelo**: Gemma 3n E2B (análise multimodal)  
**Temperature**: 0.4 (precisão técnica)  
**Processamento**: MobileNet-V5 + USM + MatFormer

### 4. Tradução Cultural Avançada
**Contexto**: Tradução Português ↔ Crioulo preservando contexto  
**Input**: Texto + contexto cultural + áudio (USM)  
**Output**: Tradução culturalmente sensível + síntese de voz  
**Modelo**: Gemma 3n E2B (processamento de linguagem)  
**Temperature**: 0.5 (equilíbrio precisão/naturalidade)  
**Performance**: 6 tokens/segundo para áudio

## 🛠️ Implementação Avançada

### Etapa 1: Configuração do Ambiente com Native Assets

**Para Flutter (Experimental):**
```bash
# Habilitar native-assets (experimental)
flutter config --enable-native-assets
flutter channel master  # Necessário para native-assets
```

**Para Android:**
```gradle
// build.gradle (app) - Configuração completa
dependencies {
    implementation 'com.google.mediapipe:tasks-genai:0.10.8'
    implementation 'com.google.mediapipe:framework:0.10.8'
    implementation 'org.tensorflow:tensorflow-lite:2.13.0'
    implementation 'org.tensorflow:tensorflow-lite-gpu:2.13.0'
    implementation 'org.tensorflow:tensorflow-lite-support:0.4.4'
}
```

**Para iOS:**
```ruby
# Podfile - Configuração completa
pod 'MediaPipeTasksGenAI', '~> 0.10.8'
pod 'TensorFlowLiteObjC', '~> 2.13.0'
pod 'TensorFlowLiteSelectTfOps', '~> 2.13.0'
```

### Etapa 2: Download e Integração dos Modelos .task

**Modelos Necessários:**
- `gemma-3n-e2b.task` (~4GB) - Para educação, agricultura, tradução
- `gemma-3n-e4b.task` (~6GB) - Para medicina, emergências
- `gemma-3n-multimodal.task` (~5GB) - Para análise de imagem/áudio

**Estrutura de Assets:**
```
assets/models/
├── gemma-3n-e2b.task
├── gemma-3n-e4b.task
├── gemma-3n-multimodal.task
├── model_config.json
└── tokenizer/
    ├── vocab.txt
    └── special_tokens.json
```

**Configuração pubspec.yaml:**
```yaml
flutter:
  assets:
    - assets/models/
    - assets/models/tokenizer/
    - assets/audio/
    - assets/emergency/
```

### Etapa 3: Serviço MediaPipe Avançado

**Criar:** `lib/services/mediapipe_gemma_service.dart`

```dart
import 'dart:typed_data';
import 'dart:io';
import 'package:mediapipe_genai/mediapipe_genai.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';

class MediaPipeGemmaService {
  LlmInference? _e2bModel;
  LlmInference? _e4bModel;
  LlmInference? _multimodalModel;
  
  bool _isInitialized = false;
  String? _currentLoadedModel;
  
  // Configurações adaptativas baseadas no dispositivo
  late DeviceConfig _deviceConfig;
  
  /// Inicialização inteligente dos modelos
  Future<void> initializeModels() async {
    if (_isInitialized) return;
    
    try {
      // Detectar capacidades do dispositivo
      _deviceConfig = await _detectDeviceCapabilities();
      
      // Copiar modelos .task dos assets para storage local
      await _copyModelsToLocalStorage();
      
      // Carregar modelo inicial baseado nas capacidades
      await _loadInitialModel();
      
      _isInitialized = true;
      print('✅ MediaPipe Gemma Service inicializado com sucesso');
    } catch (e) {
      print('❌ Erro na inicialização: $e');
      throw Exception('Falha na inicialização do MediaPipe: $e');
    }
  }
  
  /// Detecção avançada de capacidades do dispositivo
  Future<DeviceConfig> _detectDeviceCapabilities() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      final memoryGB = _estimateMemoryFromDevice(androidInfo);
      
      return DeviceConfig(
        platform: 'android',
        memoryGB: memoryGB,
        supportsGPU: androidInfo.version.sdkInt >= 24,
        preferredModel: memoryGB >= 6 ? 'E4B' : 'E2B',
        maxTokens: memoryGB >= 6 ? 1024 : 512,
        enableBothModels: memoryGB >= 8,
      );
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      final memoryGB = _estimateMemoryFromiOS(iosInfo);
      
      return DeviceConfig(
        platform: 'ios',
        memoryGB: memoryGB,
        supportsGPU: true, // iOS sempre suporta Metal
        preferredModel: memoryGB >= 4 ? 'E4B' : 'E2B',
        maxTokens: memoryGB >= 6 ? 1024 : 512,
        enableBothModels: memoryGB >= 6,
      );
    }
    
    throw UnsupportedError('Plataforma não suportada');
  }
  
  /// Cópia inteligente de modelos dos assets
  Future<void> _copyModelsToLocalStorage() async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${appDir.path}/models');
    
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    
    // Lista de modelos para copiar baseado nas capacidades
    final modelsToCopy = _getModelsForDevice();
    
    for (final modelName in modelsToCopy) {
      final localPath = '${modelsDir.path}/$modelName';
      final localFile = File(localPath);
      
      if (!await localFile.exists()) {
        print('📥 Copiando $modelName para storage local...');
        final assetData = await DefaultAssetBundle.of(context)
            .load('assets/models/$modelName');
        await localFile.writeAsBytes(assetData.buffer.asUint8List());
        print('✅ $modelName copiado com sucesso');
      }
    }
  }
  
  /// Seleção inteligente baseada no contexto e recursos
  Future<String> generateResponse({
    required String prompt,
    required String context, // 'medical', 'education', 'agriculture', 'translation'
    required String language, // 'pt', 'crioulo'
    double? temperature,
    int? maxTokens,
    Uint8List? imageData,
    String? audioPath,
  }) async {
    if (!_isInitialized) {
      await initializeModels();
    }
    
    try {
      // Seleção inteligente do modelo baseada no contexto
      final selectedModel = await _selectModelForContext(context, imageData, audioPath);
      
      // Configurar parâmetros baseados no contexto
      final config = _getConfigForContext(context, temperature, maxTokens);
      
      // Preparar prompt especializado
      final specializedPrompt = _buildSpecializedPrompt(prompt, context, language);
      
      // Executar inferência
      final response = await _executeInference(
        model: selectedModel,
        prompt: specializedPrompt,
        config: config,
        imageData: imageData,
        audioPath: audioPath,
      );
      
      return response;
    } catch (e) {
      print('❌ Erro na geração de resposta: $e');
      throw Exception('Falha na geração: $e');
    }
  }
  
  /// Análise multimodal avançada
  Future<String> analyzeMultimodal({
    String? text,
    Uint8List? imageData,
    String? audioPath,
    String context = 'general',
  }) async {
    if (!_isInitialized) {
      await initializeModels();
    }
    
    // Carregar modelo multimodal se necessário
    await _ensureMultimodalModelLoaded();
    
    try {
      // Preparar inputs multimodais
      final multimodalInput = await _prepareMultimodalInput(
        text: text,
        imageData: imageData,
        audioPath: audioPath,
      );
      
      // Executar análise multimodal
      final result = await _multimodalModel!.generateResponse(
        prompt: multimodalInput,
        maxTokens: _deviceConfig.maxTokens,
      );
      
      return result;
    } catch (e) {
      print('❌ Erro na análise multimodal: $e');
      throw Exception('Falha na análise multimodal: $e');
    }
  }
  
  /// Inferência elástica - troca dinâmica entre E2B e E4B
  Future<LlmInference> _selectModelForContext(
    String context, 
    Uint8List? imageData, 
    String? audioPath
  ) async {
    // Determinar complexidade da tarefa
    final isComplexTask = _isComplexTask(context, imageData, audioPath);
    final needsHighPrecision = _needsHighPrecision(context);
    
    if (needsHighPrecision || isComplexTask) {
      // Usar E4B para máxima precisão
      return await _ensureE4BLoaded();
    } else {
      // Usar E2B para eficiência
      return await _ensureE2BLoaded();
    }
  }
  
  /// Carregamento condicional de parâmetros
  Future<LlmInference> _ensureE2BLoaded() async {
    if (_e2bModel == null || _currentLoadedModel != 'E2B') {
      // Descarregar outros modelos para liberar memória
      await _unloadUnusedModels('E2B');
      
      final modelPath = await _getModelPath('gemma-3n-e2b.task');
      _e2bModel = await LlmInference.createFromModelPath(modelPath);
      _currentLoadedModel = 'E2B';
      
      print('✅ Modelo E2B carregado (2GB VRAM efetiva)');
    }
    return _e2bModel!;
  }
  
  Future<LlmInference> _ensureE4BLoaded() async {
    if (_e4bModel == null || _currentLoadedModel != 'E4B') {
      // Verificar se o dispositivo suporta E4B
      if (!_deviceConfig.enableBothModels && _deviceConfig.memoryGB < 6) {
        print('⚠️ Dispositivo com memória limitada, usando E2B');
        return await _ensureE2BLoaded();
      }
      
      // Descarregar outros modelos para liberar memória
      await _unloadUnusedModels('E4B');
      
      final modelPath = await _getModelPath('gemma-3n-e4b.task');
      _e4bModel = await LlmInference.createFromModelPath(modelPath);
      _currentLoadedModel = 'E4B';
      
      print('✅ Modelo E4B carregado (3GB VRAM efetiva)');
    }
    return _e4bModel!;
  }
  
  /// Determinar se a tarefa é complexa
  bool _isComplexTask(String context, Uint8List? imageData, String? audioPath) {
    // Tarefas multimodais são consideradas complexas
    if (imageData != null || audioPath != null) return true;
    
    // Contextos que requerem alta precisão
    if (context == 'medical' || context == 'emergency') return true;
    
    return false;
  }
  
  bool _needsHighPrecision(String context) {
    return context == 'medical' || context == 'emergency';
  }
  
  /// Configurações específicas por contexto
  InferenceConfig _getConfigForContext(String context, double? temperature, int? maxTokens) {
    switch (context) {
      case 'medical':
      case 'emergency':
        return InferenceConfig(
          temperature: temperature ?? 0.2,
          maxTokens: maxTokens ?? 512,
          topP: 0.9,
          topK: 40,
        );
      case 'education':
        return InferenceConfig(
          temperature: temperature ?? 0.7,
          maxTokens: maxTokens ?? 1024,
          topP: 0.95,
          topK: 50,
        );
      case 'agriculture':
        return InferenceConfig(
          temperature: temperature ?? 0.4,
          maxTokens: maxTokens ?? 768,
          topP: 0.9,
          topK: 45,
        );
      case 'translation':
        return InferenceConfig(
          temperature: temperature ?? 0.5,
          maxTokens: maxTokens ?? 512,
          topP: 0.92,
          topK: 40,
        );
      default:
        return InferenceConfig(
          temperature: temperature ?? 0.6,
          maxTokens: maxTokens ?? 512,
          topP: 0.9,
          topK: 40,
        );
    }
  }
  
  /// Cache inteligente de respostas
  final Map<String, CachedResponse> _responseCache = {};
  
  String? getCachedResponse(String prompt, String context) {
    final key = '${context}:${prompt.hashCode}';
    final cached = _responseCache[key];
    
    if (cached != null && !cached.isExpired) {
      print('📋 Resposta encontrada no cache');
      return cached.response;
    }
    
    return null;
  }
  
  void cacheResponse(String prompt, String context, String response) {
    final key = '${context}:${prompt.hashCode}';
    _responseCache[key] = CachedResponse(
      response: response,
      timestamp: DateTime.now(),
      ttl: Duration(hours: 1), // TTL baseado no contexto
    );
  }
  
  /// Limpeza de memória e recursos
  Future<void> dispose() async {
    await _e2bModel?.close();
    await _e4bModel?.close();
    await _multimodalModel?.close();
    
    _e2bModel = null;
    _e4bModel = null;
    _multimodalModel = null;
    _isInitialized = false;
    
    print('🧹 MediaPipe Gemma Service limpo');
  }
}

// Classes auxiliares
class DeviceConfig {
  final String platform;
  final int memoryGB;
  final bool supportsGPU;
  final String preferredModel;
  final int maxTokens;
  final bool enableBothModels;
  
  DeviceConfig({
    required this.platform,
    required this.memoryGB,
    required this.supportsGPU,
    required this.preferredModel,
    required this.maxTokens,
    required this.enableBothModels,
  });
}

class InferenceConfig {
  final double temperature;
  final int maxTokens;
  final double topP;
  final int topK;
  
  InferenceConfig({
    required this.temperature,
    required this.maxTokens,
    required this.topP,
    required this.topK,
  });
}

class CachedResponse {
  final String response;
  final DateTime timestamp;
  final Duration ttl;
  
  CachedResponse({
    required this.response,
    required this.timestamp,
    required this.ttl,
  });
  
  bool get isExpired => DateTime.now().difference(timestamp) > ttl;
}
```

### Etapa 4: Migração Inteligente dos Endpoints

**Substituir chamadas HTTP por execução local:**

```dart
// ANTES (HTTP)
Future<String> getEmergencyGuidance(String symptoms) async {
  final response = await dio.post('/api/medical/emergency', ...);
  return response.data['ai_guidance'];
}

// DEPOIS (MediaPipe com Inferência Elástica)
Future<String> getEmergencyGuidance(String symptoms) async {
  // Cache check primeiro
  final cached = _mediaPipeService.getCachedResponse(symptoms, 'medical');
  if (cached != null) return cached;
  
  final response = await _mediaPipeService.generateResponse(
    prompt: symptoms,
    context: 'medical', // Automaticamente seleciona E4B
    language: 'pt',
    temperature: 0.2, // Máxima precisão para medicina
  );
  
  // Cache para uso futuro
  _mediaPipeService.cacheResponse(symptoms, 'medical', response);
  
  return response;
}

// Análise agrícola multimodal
Future<String> analyzeAgriculturalProblem({
  required String description,
  Uint8List? cropImage,
  String? audioDescription,
}) async {
  return await _mediaPipeService.analyzeMultimodal(
    text: description,
    imageData: cropImage, // Processado via MobileNet-V5
    audioPath: audioDescription, // Processado via USM
    context: 'agriculture',
  );
}
```

### Etapa 5: Otimizações Avançadas

#### **Gerenciamento Inteligente de Memória:**
```dart
class AdvancedModelManager {
  static const int MAX_MEMORY_USAGE_MB = 4096; // 4GB limite
  
  /// Carregar modelo baseado em contexto e recursos disponíveis
  Future<void> loadModelForContext(String context) async {
    final currentMemory = await _getCurrentMemoryUsage();
    
    if (currentMemory > MAX_MEMORY_USAGE_MB * 0.8) {
      // Liberar memória antes de carregar novo modelo
      await _freeUnusedMemory();
    }
    
    switch (context) {
      case 'medical':
      case 'emergency':
        await _loadE4BModel(); // Máxima precisão
        break;
      case 'education':
      case 'agriculture':
      case 'translation':
        await _loadE2BModel(); // Eficiência
        break;
      default:
        // Inferência elástica baseada em recursos
        final availableMemory = MAX_MEMORY_USAGE_MB - currentMemory;
        if (availableMemory > 3072) { // 3GB disponível
          await _loadE4BModel();
        } else {
          await _loadE2BModel();
        }
    }
  }
  
  /// Carregamento condicional de parâmetros por modalidade
  Future<void> configureModalityParameters({
    bool enableVision = false,
    bool enableAudio = false,
    bool enableText = true,
  }) async {
    final config = ModalityConfig(
      vision: enableVision,
      audio: enableAudio,
      text: enableText,
    );
    
    // Carregar apenas os parâmetros necessários
    await _currentModel?.configureModalities(config);
    
    print('🎛️ Modalidades configuradas: '
          'Visão: $enableVision, Áudio: $enableAudio, Texto: $enableText');
  }
}
```

#### **Cache Avançado com Estratégias Inteligentes:**
```dart
class IntelligentResponseCache {
  final Map<String, CachedResponse> _cache = {};
  final int maxCacheSize = 1000;
  
  /// Cache com TTL baseado no contexto
  void cacheResponse(String prompt, String context, String response) {
    final ttl = _getTTLForContext(context);
    final key = _generateCacheKey(prompt, context);
    
    // Implementar LRU se cache estiver cheio
    if (_cache.length >= maxCacheSize) {
      _evictLeastRecentlyUsed();
    }
    
    _cache[key] = CachedResponse(
      response: response,
      timestamp: DateTime.now(),
      ttl: ttl,
      accessCount: 1,
    );
  }
  
  Duration _getTTLForContext(String context) {
    switch (context) {
      case 'medical':
        return Duration(minutes: 30); // Cache curto para medicina
      case 'education':
        return Duration(hours: 24); // Cache longo para educação
      case 'agriculture':
        return Duration(hours: 12); // Cache médio para agricultura
      default:
        return Duration(hours: 1);
    }
  }
}
```

## 🎯 Prompts Especializados Avançados

### Medicina (Temperature: 0.2, Modelo: E4B)
```
Você é um assistente médico especializado em primeiros socorros para comunidades rurais da Guiné-Bissau.
Utilize o conhecimento médico mais preciso disponível, considerando recursos limitados e contexto local.

CONTEXTO CULTURAL:
- Comunidade rural da Guiné-Bissau
- Recursos médicos limitados
- Possível barreira linguística (Português/Crioulo)
- Urgência médica real

Sintomas: {symptoms}
Tipo de emergência: {emergencyType}
Idioma preferido: {language}

RESPONDA COM ESTRUTURA CLARA:
1. 🚨 AVALIAÇÃO INICIAL (gravidade 1-10)
2. 🏃‍♂️ PASSOS IMEDIATOS (máximo 5 ações)
3. 🧰 MATERIAIS NECESSÁRIOS (disponíveis localmente)
4. ⚠️ SINAIS DE ALERTA (quando buscar ajuda urgente)
5. 🔄 CUIDADOS CONTÍNUOS (até chegada de ajuda)

IMPORTANTE:
- Use linguagem simples e direta
- SEMPRE recomende procurar ajuda médica profissional
- Considere medicina tradicional local quando apropriado
- Forneça orientações que salvem vidas
```

### Educação (Temperature: 0.7, Modelo: E2B)
```
Você é um educador especializado em criar conteúdo para comunidades rurais da Guiné-Bissau.
Adapte todo conteúdo para o contexto local, usando exemplos práticos e culturalmente relevantes.

CONTEXTO EDUCACIONAL:
- Comunidade rural da Guiné-Bissau
- Recursos educacionais limitados
- Aprendizado prático e visual preferido
- Conexão com vida cotidiana essencial

Tópico: {topic}
Nível de dificuldade: {level}
Idioma: {language}
Idade dos alunos: {age_group}

CRIE MATERIAL INCLUINDO:
1. 📚 EXPLICAÇÃO SIMPLES (conceitos fundamentais)
2. 🌍 EXEMPLOS LOCAIS (contexto da Guiné-Bissau)
3. 🎯 ATIVIDADES PRÁTICAS (sem recursos complexos)
4. 🔗 CONEXÕES COM A VIDA COTIDIANA
5. 🎮 ELEMENTO LÚDICO (tornar aprendizado divertido)

ADAPTAÇÕES CULTURAIS:
- Use referências locais (plantas, animais, tradições)
- Considere conhecimento tradicional
- Inclua valores comunitários
- Respeite diversidade linguística
```

### Agricultura (Temperature: 0.4, Modelo: E2B + Multimodal)
```
Você é um consultor agrícola especializado nas condições da Guiné-Bissau.
Forneça conselhos práticos adaptados ao clima tropical e recursos locais disponíveis.

CONTEXTO AGRÍCOLA:
- Clima tropical da Guiné-Bissau
- Agricultura de subsistência predominante
- Recursos financeiros limitados
- Conhecimento tradicional valioso

Problema: {problem}
Cultura: {crop}
Estação: {season}
Recursos disponíveis: {available_resources}

[SE IMAGEM FORNECIDA: Analise a imagem usando MobileNet-V5 para identificar pragas, doenças ou problemas]
[SE ÁUDIO FORNECIDO: Processe descrição falada usando USM]

FORNEÇA ANÁLISE COMPLETA:
1. 🔍 DIAGNÓSTICO DO PROBLEMA
   - Identificação precisa
   - Causas prováveis
   - Gravidade (1-10)

2. 🛠️ SOLUÇÕES COM RECURSOS LOCAIS
   - Tratamentos orgânicos
   - Materiais disponíveis localmente
   - Técnicas tradicionais eficazes

3. 🛡️ PREVENÇÃO FUTURA
   - Práticas preventivas
   - Calendário de cuidados
   - Rotação de culturas

4. 📅 CRONOGRAMA DE AÇÕES
   - Ações imediatas (hoje)
   - Ações de curto prazo (1 semana)
   - Ações de longo prazo (1 mês+)

CONSIDERAÇÕES ESPECIAIS:
- Sustentabilidade ambiental
- Custo-benefício
- Conhecimento tradicional local
- Mudanças climáticas
```

## 📊 Configurações de Performance Avançadas

### Especificações Detalhadas por Modelo

| Característica | Gemma 3n E2B | Gemma 3n E4B | Multimodal |
|----------------|--------------|--------------|------------|
| **Parâmetros Brutos** | 5B | 8B | 6B |
| **VRAM Efetiva** | 2GB | 3GB | 2.5GB |
| **RAM Mínima** | 2GB | 3GB | 3GB |
| **Contextos Ideais** | Educação, Agricultura, Tradução | Medicina, Emergências | Análise Multimodal |
| **Temperature Range** | 0.4-0.7 | 0.2-0.3 | 0.3-0.6 |
| **Max Tokens** | 512-1024 | 512-1024 | 768 |
| **Modalidades** | Texto | Texto | Texto + Imagem + Áudio |
| **Latência Alvo** | <300ms | <500ms | <800ms |
| **Throughput** | 15 tokens/s | 12 tokens/s | 10 tokens/s |

### Configurações Adaptativas Avançadas

```dart
class AdvancedAdaptiveConfig {
  static Future<ModelConfig> getOptimalConfigForDevice() async {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    final memoryGB = await _getActualDeviceMemory();
    final cpuCores = await _getCPUCores();
    final gpuInfo = await _getGPUInfo();
    
    // Configuração baseada em múltiplos fatores
    if (memoryGB >= 8 && cpuCores >= 8 && gpuInfo.isHighEnd) {
      return ModelConfig(
        preferredModel: 'E4B',
        enableInferenceElastic: true,
        maxTokens: 1024,
        enableBothModels: true,
        enableMultimodal: true,
        cacheSize: 1000,
        quantization: QuantizationType.none,
      );
    } else if (memoryGB >= 4 && cpuCores >= 6) {
      return ModelConfig(
        preferredModel: 'E2B',
        enableInferenceElastic: true,
        maxTokens: 768,
        enableBothModels: false,
        enableMultimodal: true,
        cacheSize: 500,
        quantization: QuantizationType.int8,
      );
    } else {
      return ModelConfig(
        preferredModel: 'E2B',
        enableInferenceElastic: false,
        maxTokens: 512,
        enableBothModels: false,
        enableMultimodal: false,
        cacheSize: 200,
        quantization: QuantizationType.int4,
      );
    }
  }
  
  /// Configuração dinâmica baseada no contexto de uso
  static InferenceConfig getDynamicConfig(String context, DeviceConfig device) {
    final baseConfig = _getBaseConfigForContext(context);
    
    // Ajustar baseado nas capacidades do dispositivo
    if (device.memoryGB < 4) {
      baseConfig.maxTokens = (baseConfig.maxTokens * 0.7).round();
      baseConfig.temperature *= 0.9; // Mais determinístico para economizar recursos
    }
    
    if (!device.supportsGPU) {
      baseConfig.enableParallelProcessing = false;
    }
    
    return baseConfig;
  }
}
```

## 🧪 Testes e Validação Avançados

### Testes de Funcionalidade Multimodal

```dart
void main() {
  group('MediaPipe Gemma Service - Testes Avançados', () {
    late MediaPipeGemmaService service;
    
    setUp(() async {
      service = MediaPipeGemmaService();
      await service.initializeModels();
    });
    
    group('Testes de Inferência Elástica', () {
      test('Deve usar E4B para emergências médicas', () async {
        final response = await service.generateResponse(
          prompt: 'Mulher em trabalho de parto com complicações',
          context: 'medical',
          language: 'pt',
        );
        
        expect(response, isNotEmpty);
        expect(response, contains('primeiros socorros'));
        expect(response, contains('procurar ajuda médica'));
        expect(service.currentModel, equals('E4B'));
      });
      
      test('Deve usar E2B para educação', () async {
        final response = await service.generateResponse(
          prompt: 'Ensinar matemática básica para crianças',
          context: 'education',
          language: 'pt',
        );
        
        expect(response, contains('exemplo'));
        expect(response, contains('atividade'));
        expect(service.currentModel, equals('E2B'));
      });
    });
    
    group('Testes Multimodais', () {
      test('Deve analisar imagem agrícola', () async {
        final imageBytes = await _loadTestImage('crop_disease.jpg');
        
        final response = await service.analyzeMultimodal(
          text: 'Folhas do arroz estão amarelando',
          imageData: imageBytes,
          context: 'agriculture',
        );
        
        expect(response, contains('diagnóstico'));
        expect(response, contains('tratamento'));
      });
      
      test('Deve processar áudio em Crioulo', () async {
        final audioPath = await _getTestAudioPath('crioulo_sample.wav');
        
        final response = await service.analyzeMultimodal(
          audioPath: audioPath,
          context: 'translation',
        );
        
        expect(response, isNotEmpty);
      });
    });
    
    group('Testes de Performance', () {
      test('Latência deve ser menor que 500ms para emergências', () async {
        final stopwatch = Stopwatch()..start();
        
        await service.generateResponse(
          prompt: 'Teste de emergência',
          context: 'medical',
          language: 'pt',
        );
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });
      
      test('Cache deve funcionar corretamente', () async {
        const prompt = 'Teste de cache';
        const context = 'education';
        
        // Primeira chamada
        final response1 = await service.generateResponse(
          prompt: prompt,
          context: context,
          language: 'pt',
        );
        
        // Segunda chamada (deve usar cache)
        final stopwatch = Stopwatch()..start();
        final response2 = await service.generateResponse(
          prompt: prompt,
          context: context,
          language: 'pt',
        );
        stopwatch.stop();
        
        expect(response1, equals(response2));
        expect(stopwatch.elapsedMilliseconds, lessThan(50)); // Cache hit
      });
    });
    
    tearDown(() async {
      await service.dispose();
    });
  });
}
```

### Testes de Performance e Stress

```dart
class AdvancedPerformanceTest {
  static Future<void> runComprehensiveTests() async {
    await testInferenceSpeed();
    await testMemoryUsage();
    await testConcurrentRequests();
    await testModelSwitching();
    await testMultimodalPerformance();
  }
  
  static Future<void> testInferenceSpeed() async {
    final service = MediaPipeGemmaService();
    await service.initializeModels();
    
    final contexts = ['medical', 'education', 'agriculture', 'translation'];
    final results = <String, List<int>>{};
    
    for (final context in contexts) {
      final times = <int>[];
      
      for (int i = 0; i < 10; i++) {
        final stopwatch = Stopwatch()..start();
        
        await service.generateResponse(
          prompt: 'Teste de velocidade $i',
          context: context,
          language: 'pt',
        );
        
        stopwatch.stop();
        times.add(stopwatch.elapsedMilliseconds);
      }
      
      results[context] = times;
    }
    
    // Análise dos resultados
    for (final entry in results.entries) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      final min = entry.value.reduce(math.min);
      final max = entry.value.reduce(math.max);
      
      print('📊 ${entry.key}: Avg: ${avg.toStringAsFixed(1)}ms, '
            'Min: ${min}ms, Max: ${max}ms');
    }
  }
  
  static Future<void> testMemoryUsage() async {
    final service = MediaPipeGemmaService();
    
    final memoryBefore = await _getCurrentMemoryUsage();
    await service.initializeModels();
    final memoryAfterInit = await _getCurrentMemoryUsage();
    
    // Teste com diferentes modelos
    await service.generateResponse(
      prompt: 'Teste de memória E2B',
      context: 'education',
      language: 'pt',
    );
    final memoryE2B = await _getCurrentMemoryUsage();
    
    await service.generateResponse(
      prompt: 'Teste de memória E4B',
      context: 'medical',
      language: 'pt',
    );
    final memoryE4B = await _getCurrentMemoryUsage();
    
    print('💾 Uso de Memória:');
    print('   Inicial: ${memoryBefore}MB');
    print('   Após inicialização: ${memoryAfterInit}MB');
    print('   Com E2B: ${memoryE2B}MB');
    print('   Com E4B: ${memoryE4B}MB');
    print('   Overhead E2B: ${memoryE2B - memoryAfterInit}MB');
    print('   Overhead E4B: ${memoryE4B - memoryAfterInit}MB');
  }
  
  static Future<void> testConcurrentRequests() async {
    final service = MediaPipeGemmaService();
    await service.initializeModels();
    
    final futures = <Future<String>>[];
    final stopwatch = Stopwatch()..start();
    
    // Executar 5 requisições concorrentes
    for (int i = 0; i < 5; i++) {
      futures.add(service.generateResponse(
        prompt: 'Requisição concorrente $i',
        context: 'education',
        language: 'pt',
      ));
    }
    
    final results = await Future.wait(futures);
    stopwatch.stop();
    
    print('🔄 Teste de Concorrência:');
    print('   ${results.length} requisições em ${stopwatch.elapsedMilliseconds}ms');
    print('   Média por requisição: ${stopwatch.elapsedMilliseconds / results.length}ms');
  }
}
```

## 🎯 Resultados Esperados

### Funcionalidades Migradas com Inovações
- ✅ **Emergências médicas** com Gemma 3n E4B nativo + inferência elástica
- ✅ **Educação adaptativa** com Gemma 3n E2B + carregamento condicional
- ✅ **Consultoria agrícola multimodal** com MobileNet-V5 + USM
- ✅ **Tradução cultural** Português ↔ Crioulo com processamento de áudio
- ✅ **Sistema de acessibilidade** por voz com reconhecimento em tempo real
- ✅ **Análise ambiental** com processamento de vídeo a 60 FPS

### Melhorias de Performance Revolucionárias
- 🚀 **Latência ultra-baixa**: ~2s → ~200ms (10x mais rápido)
- 📱 **Funcionamento 100% offline** com capacidades completas
- 🔋 **Menor consumo de bateria** (eliminação de comunicação de rede)
- 💾 **Uso eficiente de memória** com PLE e MatFormer
- ⚡ **Inferência elástica** E2B ↔ E4B baseada em contexto
- 🎯 **Carregamento condicional** de parâmetros por modalidade
- 📊 **Processamento multimodal** nativo (60 FPS para vídeo)

### Impacto Social Transformador
- 🏥 **Orientações médicas instantâneas** em emergências críticas
- 🎓 **Educação personalizada** sem dependência de internet
- 🌾 **Consultoria agrícola visual** com análise de imagens em tempo real
- 🗣️ **Preservação e promoção** do Crioulo da Guiné-Bissau
- ♿ **Acessibilidade avançada** com reconhecimento de voz
- 🌍 **Sustentabilidade ambiental** com análise de biodiversidade

## 📋 Checklist de Implementação Avançado

### Fase 1: Configuração Base
- [ ] Configurar MediaPipe GenAI no projeto Flutter
- [ ] Habilitar native-assets (experimental)
- [ ] Configurar build.gradle.kts com dependências completas
- [ ] Configurar Podfile para iOS
- [ ] Baixar e integrar modelos Gemma 3n E2B, E4B e Multimodal

### Fase 2: Implementação Core
- [ ] Criar serviço MediaPipe nativo avançado
- [ ] Implementar detecção de capacidades do dispositivo
- [ ] Implementar inferência elástica E2B ↔ E4B
- [ ] Implementar carregamento condicional de parâmetros
- [ ] Implementar cache inteligente de respostas

### Fase 3: Migração de Funcionalidades
- [ ] Migrar endpoints de emergência médica
- [ ] Migrar sistema educacional
- [ ] Migrar consultoria agrícola multimodal
- [ ] Migrar sistema de tradução com áudio
- [ ] Migrar sistema de acessibilidade

### Fase 4: Otimizações Avançadas
- [ ] Implementar gerenciamento inteligente de memória
- [ ] Otimizar processamento multimodal (MobileNet-V5 + USM)
- [ ] Implementar quantização adaptativa
- [ ] Configurar processamento de vídeo a 60 FPS
- [ ] Otimizar para diferentes arquiteturas (ARM64, x86_64)

### Fase 5: Testes e Validação
- [ ] Criar testes automatizados completos
- [ ] Validar performance em dispositivos reais
- [ ] Testar inferência elástica
- [ ] Testar capacidades multimodais
- [ ] Benchmark de latência e throughput

### Fase 6: Documentação e Deploy
- [ ] Documentar APIs nativas
- [ ] Criar guias de troubleshooting
- [ ] Treinar equipe de desenvolvimento
- [ ] Preparar para produção
- [ ] Monitoramento e analytics

---

## 🎯 Objetivo Final Revolucionário

**Transformar o Moransa em um assistente de IA verdadeiramente revolucionário**, executando Gemma 3n nativamente em dispositivos Android e iOS com:

- **Arquitetura MatFormer** com inferência elástica
- **Per-Layer Embeddings (PLE)** para eficiência máxima
- **Carregamento condicional** de parâmetros por modalidade
- **Processamento multimodal nativo** (MobileNet-V5 + USM)
- **Performance superior** mantendo todas as funcionalidades atuais
- **Zero dependência de rede** para operação em áreas remotas

## 💡 Foco Especial: Inovação Técnica + Impacto Social

**Preservar e amplificar a missão social do projeto** - salvar vidas em comunidades rurais da Guiné-Bissau através de:

- **Tecnologia de IA de ponta** acessível e culturalmente adaptada
- **Primeira implementação offline completa** do Gemma 3n para idiomas locais africanos
- **Inovações arquitetônicas** que democratizam o acesso à IA avançada
- **Sustentabilidade tecnológica** para comunidades com recursos limitados

**Esta implementação representa um marco na democratização da IA para comunidades marginalizadas, combinando inovação técnica de ponta com impacto social transformador.**