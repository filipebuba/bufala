# 📖 Guia de Desenvolvimento - Bufala

## 🎯 Visão Geral do Projeto

O **Bufala** é um aplicativo Android offline desenvolvido especificamente para comunidades rurais da Guiné-Bissau. O foco é fornecer informações vitais sobre saúde, educação e agricultura sem depender de conectividade à internet.

## 🏗️ Arquitetura do Aplicativo

### Padrão de Arquitetura
- **Provider Pattern**: Gerenciamento de estado
- **Service Layer**: Lógica de negócio e dados offline
- **Screen-based Navigation**: Navegação por telas principais

### Estrutura de Pastas

```
lib/
├── main.dart                    # Ponto de entrada
├── providers/                   # Gerenciamento de estado
│   └── app_provider.dart       # Estado global (idioma, configurações)
├── services/                    # Camada de serviços
│   └── emergency_service.dart  # Dados offline (PT/Crioulo)
├── screens/                     # Telas da aplicação
│   ├── home_screen.dart        # Tela inicial
│   ├── emergency_screen.dart   # Emergências médicas
│   ├── education_screen.dart   # Conteúdo educacional
│   ├── agriculture_screen.dart # Informações agrícolas
│   └── settings_screen.dart    # Configurações
├── widgets/                     # Componentes reutilizáveis
│   └── (componentes customizados)
└── utils/                       # Utilitários
    └── app_colors.dart         # Paleta de cores
```

## 🛠️ Tecnologias e Dependências

### Dependências Principais

```yaml
# Estado e Navegação
provider: ^6.1.1              # Gerenciamento de estado

# Armazenamento Offline
hive: ^2.2.3                   # Banco NoSQL local
hive_flutter: ^1.1.0          # Integração Hive + Flutter
shared_preferences: ^2.2.2    # Preferências simples

# Internacionalização
flutter_localizations: sdk    # Suporte a múltiplos idiomas
intl: ^0.18.1                 # Formatação de data/hora

# Utilitários
path_provider: ^2.1.1         # Acesso a diretórios do sistema
cupertino_icons: ^1.0.6       # Ícones iOS/Material
```

### Dependências de Desenvolvimento

```yaml
flutter_test: sdk              # Testes unitários
flutter_lints: ^3.0.0         # Análise de código
hive_generator: ^2.0.1        # Geração de código Hive
build_runner: ^2.4.7          # Execução de geradores
```

## 🌐 Sistema de Idiomas

### Idiomas Suportados
- **Português (pt)**: Idioma oficial da Guiné-Bissau
- **Crioulo Guineense (gc)**: Idioma local mais falado

### Implementação

```dart
// Estrutura de dados multilíngue
Map<String, Map<String, String>> content = {
  'pt': {
    'title': 'Primeiros Socorros',
    'description': 'Instruções de emergência'
  },
  'gc': {
    'title': 'Primeiru Sukuru',
    'description': 'Instruson di emerjensia'
  }
};

// Uso no Provider
String getCurrentLanguage() => _currentLanguage;
void setLanguage(String language) {
  _currentLanguage = language;
  notifyListeners();
}
```

## 💾 Sistema de Dados Offline

### Hive Database

```dart
// Inicialização
await Hive.initFlutter();
await Hive.openBox('emergency_data');
await Hive.openBox('education_data');
await Hive.openBox('agriculture_data');

// Armazenamento
Box emergencyBox = Hive.box('emergency_data');
emergencyBox.put('childbirth_pt', childbirthDataPT);
emergencyBox.put('childbirth_gc', childbirthDataGC);

// Recuperação
Map<String, dynamic> data = emergencyBox.get('childbirth_pt');
```

### Estrutura de Dados

```dart
class EmergencyData {
  final String id;
  final String title;
  final String description;
  final List<String> steps;
  final String language;
  final String category;
  
  EmergencyData({
    required this.id,
    required this.title,
    required this.description,
    required this.steps,
    required this.language,
    required this.category,
  });
}
```

## 🎨 Sistema de Design

### Paleta de Cores

```dart
class AppColors {
  // Cores Primárias
  static const Color primary = Color(0xFF2E7D32);      // Verde
  static const Color secondary = Color(0xFF1976D2);    // Azul
  static const Color accent = Color(0xFFFF6F00);       // Laranja
  
  // Cores por Seção
  static const Color emergency = Color(0xFFD32F2F);    // Vermelho
  static const Color education = Color(0xFF1976D2);    // Azul
  static const Color agriculture = Color(0xFF388E3C);  // Verde
  
  // Cores de Suporte
  static const Color background = Color(0xFFF5F5F5);   // Cinza claro
  static const Color surface = Color(0xFFFFFFFF);      // Branco
  static const Color onSurface = Color(0xFF212121);    // Preto
}
```

### Componentes Reutilizáveis

```dart
// Card de Informação
Widget buildInfoCard({
  required String title,
  required String description,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return Card(
    elevation: 4,
    child: ListTile(
      leading: Icon(icon, color: color, size: 32),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(description),
      onTap: onTap,
    ),
  );
}
```

## 🧪 Testes e Qualidade

### Estrutura de Testes

```
test/
├── unit/                        # Testes unitários
│   ├── services/
│   │   └── emergency_service_test.dart
│   └── providers/
│       └── app_provider_test.dart
├── widget/                      # Testes de widget
│   ├── screens/
│   │   └── home_screen_test.dart
│   └── widgets/
└── integration/                 # Testes de integração
    └── app_test.dart
```

### Comandos de Teste

```bash
# Executar todos os testes
flutter test

# Testes com cobertura
flutter test --coverage

# Testes específicos
flutter test test/unit/services/emergency_service_test.dart
```

## 🚀 Build e Deploy

### Configurações de Build

```bash
# Debug (desenvolvimento)
flutter build apk --debug

# Release (produção)
flutter build apk --release

# Split por arquitetura (otimizado)
flutter build apk --split-per-abi

# Bundle para Play Store
flutter build appbundle --release
```

### Configurações Android

```gradle
// android/app/build.gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.bufala.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

## 📱 Funcionalidades Implementadas

### 🚨 Emergências Médicas
- Assistência ao parto
- Tratamento de febre
- Cuidados com ferimentos
- Instruções em PT/Crioulo

### 📚 Educação
- Matemática básica
- Língua portuguesa
- Educação em saúde
- Vocabulário bilíngue

### 🌱 Agricultura
- Proteção de culturas
- Calendário de plantio
- Técnicas sazonais
- Remédios naturais

## 🔮 Roadmap Futuro

### Versão 1.1
- [ ] Mais conteúdo em Crioulo
- [ ] Áudio para instruções
- [ ] Modo noturno
- [ ] Backup/restore de dados

### Versão 1.2
- [ ] Reconhecimento de voz
- [ ] Tradução automática
- [ ] Sincronização entre dispositivos
- [ ] Conteúdo veterinário

### Versão 2.0
- [ ] IA local para Crioulo
- [ ] Marketplace comunitário
- [ ] Previsão meteorológica
- [ ] Mais idiomas locais

## 🤝 Contribuição

### Como Contribuir

1. **Fork** o repositório
2. **Crie** uma branch para sua feature
3. **Implemente** as mudanças
4. **Teste** thoroughly
5. **Submeta** um Pull Request

### Padrões de Código

```bash
# Análise de código
flutter analyze

# Formatação
flutter format .

# Linting
flutter pub run dart_code_metrics:metrics analyze lib
```

### Convenções

- **Nomes de arquivos**: snake_case
- **Classes**: PascalCase
- **Variáveis**: camelCase
- **Constantes**: UPPER_SNAKE_CASE
- **Comentários**: Português para lógica específica da Guiné-Bissau

## 📞 Suporte e Comunidade

- **Issues**: Para bugs e sugestões
- **Discussions**: Para dúvidas gerais
- **Wiki**: Documentação detalhada
- **Releases**: Versões estáveis

---

**Desenvolvido com ❤️ para a comunidade da Guiné-Bissau** 🇬🇼