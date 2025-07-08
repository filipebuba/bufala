# 🌟 Bu Fala - Conexão Integrada Backend + Flutter

## 📋 Visão Geral

Este documento descreve a conexão completa e otimizada entre o backend modular Bu Fala e o aplicativo Flutter, especialmente projetada para comunidades remotas da Guiné-Bissau.

## 🏗️ Arquitetura da Conexão

### Backend Modular
- **Localização**: `backend/app.py`
- **Porta**: 5000
- **Serviços**: Médico, Educacional, Agrícola, Bem-estar, Acessibilidade
- **IA**: Gemma-3n com suporte a idiomas locais (Crioulo, Mandinka, Fula)

### Flutter App
- **Localização**: `android_app/`
- **Serviços de Conexão**: Múltiplas camadas de abstração
- **Fallback**: Sistema robusto para áreas sem internet

## 🔧 Componentes da Conexão

### 1. Serviços de Backend (`android_app/lib/services/`)

#### `api_service.dart`
- **Função**: Interface principal unificada
- **Compatibilidade**: Retroativa com código existente
- **Recursos**: Delegação inteligente entre serviços

#### `modular_backend_service.dart`
- **Função**: Conexão direta com backend modular
- **Recursos**: 
  - Retry automático
  - Cache inteligente
  - Métricas de performance
  - Suporte multimodal

#### `enhanced_api_service.dart`
- **Função**: Camada de integração avançada
- **Recursos**:
  - Monitoramento de estado
  - Fallback automático
  - Sistema de eventos
  - Otimizações para áreas remotas

#### `smart_api_service.dart`
- **Função**: Serviço legado otimizado
- **Recursos**: Mantido para compatibilidade

#### `connection_state.dart`
- **Função**: Gerenciamento de estado da conexão
- **Recursos**:
  - Monitoramento em tempo real
  - Métricas de qualidade
  - Detecção de problemas

#### `retry_interceptor.dart`
- **Função**: Interceptors personalizados para Dio
- **Recursos**:
  - Retry inteligente
  - Logging detalhado
  - Cache de requisições

#### `backend_connection_config.dart`
- **Função**: Configurações centralizadas
- **Recursos**: Timeouts, endpoints, fallbacks

### 2. Teste de Conectividade

#### `test_connection.dart`
- **Função**: Interface para testar todas as conexões
- **Recursos**:
  - Teste de internet
  - Health check do backend
  - Teste de todos os serviços
  - Monitoramento em tempo real

## 🚀 Como Iniciar o Sistema

### Opção 1: Script Automático (Recomendado)

```powershell
# Execute no PowerShell como Administrador
powershell -ExecutionPolicy Bypass -File start_bufala.ps1
```

Este script:
- ✅ Verifica Python e Flutter
- 📦 Instala dependências automaticamente
- 🚀 Inicia o backend
- 📱 Oferece iniciar o Flutter
- 🔍 Monitora o status dos serviços

### Opção 2: Manual

#### 1. Iniciar Backend
```bash
# Opção A: Script Python
python start_backend.py

# Opção B: Manual
cd backend
pip install -r requirements.txt
python app.py
```

#### 2. Iniciar Flutter
```bash
cd android_app
flutter pub get
flutter run
```

#### 3. Testar Conectividade
```bash
# No diretório android_app
flutter run lib/test_connection.dart
```

## 🔍 Verificação de Status

### URLs de Verificação
- **Backend Health**: http://localhost:5000/health
- **API Docs**: http://localhost:5000/docs
- **Teste Médico**: http://localhost:5000/medical
- **Teste Educacional**: http://localhost:5000/education
- **Teste Agrícola**: http://localhost:5000/agriculture

### Comandos de Teste
```bash
# Teste rápido do backend
curl http://localhost:5000/health

# Teste de consulta médica
curl -X POST http://localhost:5000/medical \
  -H "Content-Type: application/json" \
  -d '{"question": "Como tratar febre?", "language": "pt-BR"}'
```

## 📱 Uso no Flutter

### Exemplo Básico
```dart
import 'package:bufala/services/api_service.dart';

// Instância única
final apiService = ApiService();

// Verificar conectividade
final isConnected = await apiService.hasInternetConnection();

// Consulta médica
final response = await apiService.askMedicalQuestion(
  'Como tratar dor de cabeça?',
  language: 'pt-BR',
);

// Consulta em Crioulo
final responseCreole = await apiService.askMedicalQuestion(
  'Kuma ku trata dor di kabesa?',
  language: 'crioulo-gb',
);
```

### Monitoramento de Conexão
```dart
import 'package:bufala/services/connection_state.dart';

// Monitor de conexão
final monitor = ConnectionMonitor();
monitor.startMonitoring();

// Escutar mudanças de estado
monitor.connectionStream.listen((state) {
  print('Conectado: ${state.isConnected}');
  print('Qualidade: ${state.quality}');
  print('Tempo de resposta: ${state.responseTime}ms');
});
```

## 🌍 Suporte a Idiomas Locais

### Idiomas Suportados
- **Português**: `pt-BR`
- **Crioulo da Guiné-Bissau**: `crioulo-gb`
- **Mandinka**: `mandinka`
- **Fula**: `fula`

### Exemplo de Uso
```dart
// Consulta em diferentes idiomas
final responses = await Future.wait([
  apiService.askMedicalQuestion('Como tratar malária?', language: 'pt-BR'),
  apiService.askMedicalQuestion('Kuma ku trata malaria?', language: 'crioulo-gb'),
  apiService.askMedicalQuestion('Malaria ye kuma?', language: 'mandinka'),
]);
```

## 🔧 Configurações Avançadas

### Timeouts
- **Conexão**: 45 segundos
- **Recebimento**: 8 minutos (para IA)
- **Retry**: 3 tentativas com delay progressivo

### Cache
- **Duração**: 5 minutos para consultas GET
- **Limpeza**: Automática
- **Fallback**: Dados offline quando disponíveis

### Logging
- **Nível**: Debug em desenvolvimento
- **Destino**: Console e arquivo
- **Formato**: Estruturado com timestamps

## 🚨 Solução de Problemas

### Backend Não Inicia
1. Verificar Python 3.8+
2. Instalar dependências: `pip install -r requirements.txt`
3. Verificar porta 5000 livre
4. Executar: `python backend/app.py`

### Flutter Não Conecta
1. Verificar backend rodando: http://localhost:5000/health
2. Executar teste: `flutter run lib/test_connection.dart`
3. Verificar logs no console
4. Tentar diferentes URLs no `api_service_fixed.dart`

### Problemas de Rede
1. Verificar conectividade: `ping localhost`
2. Testar portas: `netstat -an | findstr 5000`
3. Verificar firewall
4. Usar modo offline do app

### Erros de IA
1. Verificar modelo Gemma instalado
2. Verificar memória disponível
3. Reduzir tamanho das consultas
4. Usar fallback offline

## 📊 Monitoramento e Métricas

### Métricas Coletadas
- Tempo de resposta por endpoint
- Taxa de sucesso/falha
- Uso de cache
- Qualidade da conexão
- Erros por categoria

### Dashboard de Status
Use `test_connection.dart` para visualizar:
- Status da conexão em tempo real
- Resultados de todos os testes
- Métricas de performance
- Histórico de erros

## 🔮 Próximos Passos

### Melhorias Planejadas
1. **Sincronização Offline**: Cache inteligente para áreas sem internet
2. **Compressão**: Reduzir uso de dados
3. **P2P**: Compartilhamento entre dispositivos
4. **Edge AI**: IA local para consultas básicas
5. **Métricas Avançadas**: Analytics de uso

### Contribuições
Para contribuir com melhorias na conexão:
1. Fork o repositório
2. Crie branch para sua feature
3. Teste com `test_connection.dart`
4. Submeta pull request

## 📞 Suporte

Para problemas específicos:
1. Execute `test_connection.dart`
2. Colete logs do backend e Flutter
3. Documente passos para reproduzir
4. Abra issue no repositório

---

**Bu Fala** - Conectando comunidades através da tecnologia 🌍❤️