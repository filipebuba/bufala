# 🚀 Guia de Instalação e Execução - Bufala App

## 📋 Pré-requisitos

### Sistema Operacional
- Windows 10/11 (64-bit)
- Pelo menos 4GB de RAM
- 10GB de espaço livre em disco

### Ferramentas Necessárias
- Git para Windows
- Android Studio ou VS Code
- Dispositivo Android ou Emulador

## 🛠️ Instalação do Flutter

### Passo 1: Download do Flutter SDK

1. **Acesse o site oficial**: https://flutter.dev/docs/get-started/install/windows
2. **Baixe o Flutter SDK** para Windows
3. **Extraia o arquivo** para `C:\flutter` (recomendado)

### Passo 2: Configurar Variáveis de Ambiente

1. **Abra as Configurações do Sistema**:
   - Pressione `Win + R`, digite `sysdm.cpl` e pressione Enter
   - Clique em "Variáveis de Ambiente"

2. **Adicione o Flutter ao PATH**:
   - Em "Variáveis do Sistema", encontre e selecione "Path"
   - Clique em "Editar" → "Novo"
   - Adicione: `C:\flutter\bin`
   - Clique "OK" em todas as janelas

### Passo 3: Verificar Instalação

```bash
# Abra o Prompt de Comando ou PowerShell
flutter doctor
```

Este comando verificará se há problemas na instalação.

## 📱 Configuração do Android

### Opção 1: Android Studio (Recomendado)

1. **Baixe e instale** o Android Studio
2. **Execute o Android Studio** e siga o assistente de configuração
3. **Instale o Android SDK** (será solicitado automaticamente)
4. **Configure um emulador**:
   - Tools → AVD Manager
   - Create Virtual Device
   - Escolha um dispositivo (ex: Pixel 4)
   - Selecione uma API level (recomendado: API 30+)

### Opção 2: VS Code

1. **Instale o VS Code**
2. **Instale as extensões**:
   - Flutter
   - Dart
3. **Configure o Android SDK** manualmente

## 🏃‍♂️ Executando o Aplicativo Bufala

### Passo 1: Navegar para o Projeto

```bash
# Abra o terminal/prompt de comando
cd c:\Users\fbg67\Desktop\bufala\android_app
```

### Passo 2: Instalar Dependências

```bash
# Baixa todas as dependências do projeto
flutter pub get
```

### Passo 3: Verificar Dispositivos Disponíveis

```bash
# Lista dispositivos conectados e emuladores
flutter devices
```

### Passo 4: Executar o App

```bash
# Executa o app no dispositivo/emulador padrão
flutter run
```

**Ou especifique um dispositivo:**

```bash
# Para emulador Android
flutter run -d android

# Para dispositivo específico (use o ID do flutter devices)
flutter run -d <device-id>
```

## 📦 Compilando APK para Distribuição

### APK de Debug (Desenvolvimento)

```bash
# Gera APK de debug (mais rápido)
flutter build apk --debug
```

### APK de Release (Produção)

```bash
# Gera APK otimizado para distribuição
flutter build apk --release
```

### APK Split por Arquitetura (Menor tamanho)

```bash
# Gera APKs separados para cada arquitetura
flutter build apk --split-per-abi
```

### Localização dos APKs

Os APKs gerados estarão em:
```
c:\Users\fbg67\Desktop\bufala\android_app\build\app\outputs\flutter-apk\
```

## 🔧 Comandos Úteis

### Limpeza do Projeto

```bash
# Limpa arquivos de build
flutter clean

# Reinstala dependências
flutter pub get
```

### Hot Reload (Durante Desenvolvimento)

- **Hot Reload**: Pressione `r` no terminal
- **Hot Restart**: Pressione `R` no terminal
- **Quit**: Pressione `q` no terminal

### Verificação de Problemas

```bash
# Verifica problemas na configuração
flutter doctor -v

# Analisa o projeto
flutter analyze

# Executa testes
flutter test
```

## 📱 Instalação no Dispositivo Android

### Via USB (Desenvolvimento)

1. **Ative as Opções de Desenvolvedor** no Android:
   - Configurações → Sobre o telefone
   - Toque 7 vezes em "Número da versão"

2. **Ative a Depuração USB**:
   - Configurações → Opções de desenvolvedor
   - Ative "Depuração USB"

3. **Conecte o dispositivo** via USB
4. **Execute**: `flutter run`

### Via APK (Distribuição)

1. **Copie o APK** para o dispositivo
2. **Ative "Fontes desconhecidas"** nas configurações
3. **Instale o APK** tocando no arquivo

## 🚨 Solução de Problemas Comuns

### Erro: "Flutter not found"
- Verifique se o Flutter está no PATH
- Reinicie o terminal/prompt

### Erro: "No connected devices"
- Verifique se o emulador está rodando
- Verifique se o dispositivo USB está conectado
- Execute: `flutter devices`

### Erro: "Gradle build failed"
- Execute: `flutter clean`
- Execute: `flutter pub get`
- Tente novamente: `flutter run`

### Erro: "Android SDK not found"
- Instale o Android Studio
- Configure o Android SDK
- Execute: `flutter doctor --android-licenses`

## 📊 Estrutura do Projeto Bufala

```
android_app/
├── lib/
│   ├── main.dart              # Ponto de entrada
│   ├── screens/               # Telas do app
│   │   ├── home_screen.dart
│   │   ├── emergency_screen.dart
│   │   ├── education_screen.dart
│   │   ├── agriculture_screen.dart
│   │   └── settings_screen.dart
│   ├── services/              # Serviços offline
│   │   └── emergency_service.dart
│   ├── providers/             # Gerenciamento de estado
│   │   └── app_provider.dart
│   └── utils/                 # Utilitários
│       └── app_colors.dart
├── pubspec.yaml               # Dependências
└── build/                     # Arquivos compilados
```

## 🌟 Funcionalidades do Bufala

- **🚨 Emergências**: Primeiros socorros em PT/Crioulo
- **📚 Educação**: Conteúdo educacional offline
- **🌱 Agricultura**: Calendário e dicas agrícolas
- **⚙️ Configurações**: Alternância de idiomas
- **💾 Offline**: Funciona sem internet

## 📞 Suporte

Para problemas ou dúvidas:
1. Verifique este guia primeiro
2. Execute `flutter doctor` para diagnóstico
3. Consulte a documentação oficial do Flutter
4. Reporte issues específicas do Bufala

---

**Bufala** - Tecnologia a serviço da comunidade guineense 🇬🇼