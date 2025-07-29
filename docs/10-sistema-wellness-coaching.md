# 🧘‍♀️ Sistema de Wellness Coaching - Moransa

## 📋 Visão Geral

O Sistema de Wellness Coaching é um módulo abrangente de bem-estar mental, físico e social do aplicativo Moransa, especialmente adaptado para as necessidades culturais e sociais da Guiné-Bissau. O sistema utiliza inteligência artificial (Gemma-3n) para fornecer coaching personalizado, análise de humor, sessões de meditação guiada e monitoramento de bem-estar.

## 🎯 Objetivos Principais

- **Bem-estar Mental**: Suporte psicológico e emocional personalizado
- **Prevenção**: Identificação precoce de problemas de saúde mental
- **Acessibilidade**: Funcionalidades offline para comunidades remotas
- **Cultura Local**: Adaptação às tradições e valores da Guiné-Bissau
- **Empoderamento**: Ferramentas para autocuidado e desenvolvimento pessoal

## 🏗️ Arquitetura do Sistema

```
┌─────────────────────────────────────────────────────────────┐
│                    Sistema de Wellness Coaching             │
├─────────────────────────────────────────────────────────────┤
│  Frontend (Flutter)                                         │
│  ├── Tela Principal de Coaching                             │
│  ├── Análise de Humor                                       │
│  ├── Respiração Guiada                                      │
│  ├── Análise de Voz                                         │
│  ├── Diário de Bem-estar                                    │
│  └── Perfil de Wellness                                     │
├─────────────────────────────────────────────────────────────┤
│  Backend (Python/Flask)                                     │
│  ├── wellness_routes.py                                     │
│  ├── Análise com Gemma-3n                                   │
│  ├── Processamento de Voz                                   │
│  └── Geração de Conteúdo                                    │
├─────────────────────────────────────────────────────────────┤
│  Serviços de IA                                             │
│  ├── Gemma-3n (Coaching e Análise)                         │
│  ├── Análise de Voz                                         │
│  ├── Text-to-Speech                                         │
│  └── Processamento de Áudio                                 │
└─────────────────────────────────────────────────────────────┘
```

## 🔧 Componentes Técnicos

### Backend (Python/Flask)

#### Arquivo Principal: `wellness_routes.py`

**Rotas Principais:**

1. **`POST /wellness`** - Conteúdo de bem-estar personalizado
2. **`POST /wellness/mood-analysis`** - Análise de humor com IA
3. **`POST /wellness/coaching`** - Coaching personalizado
4. **`POST /wellness/guided-meditation`** - Sessões de meditação
5. **`POST /wellness/voice-analysis`** - Análise de voz para bem-estar
6. **`POST /chat`** - Chat genérico com IA

#### Funcionalidades do Backend:

```python
# Exemplo de análise de humor
@wellness_bp.route('/wellness/mood-analysis', methods=['POST'])
def mood_analysis():
    """
    Análise profissional de humor usando Gemma-3
    Parâmetros:
    - mood: string (happy, calm, neutral, sad, anxious, angry, tired, motivated)
    - intensity: integer (1-10)
    - description: string (descrição adicional)
    - user_profile: object (perfil do usuário)
    - language: string (português, crioulo, ambos)
    """
    # Processamento com Gemma-3n
    # Retorna insights, recomendações, técnicas de enfrentamento
```

```python
# Exemplo de coaching personalizado
@wellness_bp.route('/wellness/coaching', methods=['POST'])
def wellness_coaching():
    """
    Coaching de bem-estar adaptado à Guiné-Bissau
    Parâmetros:
    - prompt: string (questão de bem-estar)
    - mood: string (estado de humor)
    - stress_level: integer (1-10)
    - concerns: array (preocupações principais)
    - support_type: string (emocional, prático, espiritual, social)
    - cultural_context: string (contexto cultural)
    """
    # Geração de orientação personalizada
    # Estratégias de enfrentamento culturalmente apropriadas
```

### Frontend (Flutter)

#### Telas Principais:

1. **`wellness_coaching_screen.dart`** - Tela principal com dashboard
2. **`mood_tracking_screen.dart`** - Análise e rastreamento de humor
3. **`voice_guided_breathing_screen.dart`** - Respiração guiada por voz
4. **`daily_wellness_screen.dart`** - Métricas diárias de bem-estar
5. **`wellness_profile_setup_screen.dart`** - Configuração de perfil
6. **`voice_analysis_screen.dart`** - Análise de voz para bem-estar

#### Modelos de Dados:

```dart
// Perfil de bem-estar
class WellnessProfile {
  final String userId;
  final String name;
  final int age;
  final List<String> concerns;
  final List<String> goals;
  final Map<String, double> baselineMetrics;
  final DateTime createdAt;
  final DateTime updatedAt;
}

// Resultado de análise de voz
class VoiceAnalysisResult {
  final double stressLevel;
  final double energyLevel;
  final double emotionalStability;
  final String moodState;
  final double confidence;
  final List<String> emotionalIndicators;
  final Map<String, double> voiceFeatures;
  final DateTime timestamp;
}

// Sessão de coaching
class CoachingSession {
  final String sessionId;
  final String userId;
  final String type; // 'breathing', 'meditation', 'voice_check', 'mood_tracking'
  final DateTime startTime;
  DateTime? endTime;
  final Map<String, dynamic> sessionData;
  final List<String> recommendations;
  double progressScore;
}

// Métricas diárias
class DailyWellnessMetrics {
  final DateTime date;
  final double moodRating; // 1-10
  final double stressLevel; // 0-1
  final double energyLevel; // 0-1
  final int sleepHours;
  final List<String> activities;
  final String notes;
  final VoiceAnalysisResult? voiceAnalysis;
}
```

## 📱 Funcionalidades Principais

### 1. Dashboard de Wellness

**Componentes:**
- Seção de boas-vindas personalizada
- Card de pontuação de bem-estar
- Ações rápidas (respiração, meditação, análise de voz)
- Seção de progresso com gráficos
- Recomendações personalizadas
- Histórico de sessões recentes

**Características:**
- Interface com abas (Dashboard, Análise Voz, Coaching, Diário)
- Atualização em tempo real dos dados
- Integração com perfil do usuário
- Sistema de gamificação com metas e conquistas

### 2. Análise de Humor

**Funcionalidades:**
- Seleção de humor com emojis interativos
- Escala de intensidade (1-10)
- Campo para descrição adicional
- Análise profissional com IA
- Recomendações personalizadas
- Técnicas de enfrentamento
- Exercícios sugeridos

**Opções de Humor:**
- 😊 Feliz
- 😌 Calmo
- 😐 Neutro
- 😔 Triste
- 😰 Ansioso
- 😡 Irritado
- 😴 Cansado
- 🤗 Motivado

### 3. Respiração Guiada por Voz

**Características:**
- Sessões personalizadas (5-60 minutos)
- Tipos: respiração, meditação, relaxamento
- Instruções de voz geradas por IA
- Animações visuais sincronizadas
- Padrões de respiração customizáveis
- Áudio com Text-to-Speech

**Padrões de Respiração:**
- 4-7-8 (Relaxamento)
- 4-4-4-4 (Respiração Quadrada)
- 3-2-6 (Respiração Calmante)
- Personalizado baseado na sessão

### 4. Análise de Voz para Bem-estar

**Métricas Analisadas:**
- Indicadores de estresse
- Níveis de energia
- Estabilidade emocional
- Variação de tom
- Taxa de fala
- Humor detectado

**Resultados:**
- Análise detalhada do estado emocional
- Recomendações específicas
- Dicas de bem-estar personalizadas
- Nível de confiança da análise

### 5. Diário de Bem-estar

**Métricas Diárias:**
- Avaliação de humor (1-10)
- Nível de energia (1-10)
- Nível de estresse (1-10)
- Qualidade do sono
- Horas de sono
- Minutos de exercício
- Minutos de meditação

**Atividades de Bem-estar:**
- Caminhada
- Exercício físico
- Meditação
- Leitura
- Tempo na natureza
- Socialização
- Hobby
- Respiração profunda
- Música relaxante
- Banho relaxante

**Sentimentos:**
- Feliz, Calmo, Ansioso, Estressado
- Motivado, Cansado, Grato, Irritado
- Confiante, Preocupado, Energizado, Triste

### 6. Coaching Personalizado

**Tipos de Suporte:**
- **Emocional**: Apoio psicológico e emocional
- **Prático**: Soluções para problemas do dia a dia
- **Espiritual**: Orientação baseada em valores e crenças
- **Social**: Melhoria de relacionamentos e conexões

**Áreas de Bem-estar:**
- **Mental**: Saúde psicológica e emocional
- **Físico**: Atividade física e saúde corporal
- **Social**: Relacionamentos e conexões comunitárias
- **Nutricional**: Alimentação saudável e local

## 🌍 Adaptação Cultural

### Contexto da Guiné-Bissau

**Elementos Culturais Integrados:**
- Sabedoria tradicional e provérbios locais
- Práticas espirituais e religiosas
- Valores comunitários e familiares
- Medicina tradicional complementar
- Línguas locais (Crioulo, Balanta, Fula, etc.)

**Recursos Comunitários:**
- Centros de saúde locais
- Grupos de apoio comunitário
- Líderes religiosos e tradicionais
- Organizações não governamentais
- Programas de saúde pública

**Recomendações Culturalmente Apropriadas:**
- Uso de alimentos locais para nutrição
- Atividades comunitárias tradicionais
- Práticas espirituais locais
- Conexão com a natureza
- Apoio da família estendida

## 🔄 Fluxo de Dados

### Estrutura de Comunicação

```json
// Exemplo de requisição para análise de humor
{
  "mood": "anxious",
  "intensity": 7,
  "description": "Estou me sentindo ansioso por causa do trabalho",
  "user_profile": {
    "name": "Maria",
    "goals": ["reduzir estresse", "melhorar sono"]
  },
  "language": "português"
}

// Exemplo de resposta
{
  "success": true,
  "data": {
    "insights": "A ansiedade pode ser uma resposta natural...",
    "recommendations": "• Pratique técnicas de relaxamento...\n• Identifique pensamentos ansiosos...",
    "coping_techniques": "• Técnica de grounding 5-4-3-2-1\n• Respiração diafragmática...",
    "exercises": "• Respiração quadrada (4-4-4-4)\n• Meditação mindfulness...",
    "mood_score": 65,
    "risk_level": "medium"
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Integração com Gemma-3n

**Prompts Especializados:**
- Análise psicológica empática
- Recomendações culturalmente apropriadas
- Técnicas de enfrentamento práticas
- Orientação adaptada ao contexto local

**Fallbacks Inteligentes:**
- Respostas pré-definidas quando IA não disponível
- Conteúdo baseado em templates
- Recomendações básicas de bem-estar
- Recursos comunitários locais

## 🎮 Gamificação e Engajamento

### Sistema de Pontuação
- Pontos por sessões de meditação
- Conquistas por consistência
- Badges por marcos de progresso
- Ranking de bem-estar comunitário

### Metas e Objetivos
- Metas diárias de bem-estar
- Desafios semanais
- Objetivos de longo prazo
- Celebração de conquistas

## 📊 Métricas e Monitoramento

### Indicadores de Progresso
- Pontuação de bem-estar geral
- Tendências de humor ao longo do tempo
- Frequência de uso das funcionalidades
- Eficácia das recomendações

### Relatórios Personalizados
- Resumos semanais de progresso
- Insights sobre padrões de bem-estar
- Recomendações baseadas em dados
- Alertas para mudanças significativas

## 🔒 Privacidade e Segurança

### Proteção de Dados
- Dados de saúde mental criptografados
- Armazenamento local prioritário
- Anonimização de dados sensíveis
- Conformidade com padrões de privacidade

### Detecção de Emergências
- Identificação de palavras-chave de risco
- Recursos de emergência imediatos
- Encaminhamento para profissionais
- Protocolos de segurança ativados

## 🚀 Casos de Uso Práticos

### Cenário 1: Trabalhador Rural com Estresse
**Situação**: Agricultor preocupado com a colheita
**Solução**: 
- Análise de humor personalizada
- Técnicas de respiração para reduzir ansiedade
- Recomendações baseadas na cultura local
- Conexão com recursos comunitários

### Cenário 2: Mãe com Ansiedade Pós-parto
**Situação**: Nova mãe enfrentando desafios emocionais
**Solução**:
- Coaching especializado em maternidade
- Sessões de meditação adaptadas
- Apoio emocional culturalmente sensível
- Recursos de saúde mental local

### Cenário 3: Jovem com Problemas de Autoestima
**Situação**: Adolescente com baixa autoconfiança
**Solução**:
- Análise de voz para detectar padrões emocionais
- Exercícios de autocompaixão
- Técnicas de desenvolvimento pessoal
- Apoio da comunidade jovem

## 🛠️ Implementação Técnica

### Dependências Backend
```python
# requirements.txt
flask>=2.0.0
gemma-service>=1.0.0
numpy>=1.21.0
scipy>=1.7.0
librosa>=0.8.0  # Para análise de áudio
speech-recognition>=3.8.0
pyttsx3>=2.90  # Text-to-Speech
```

### Dependências Frontend
```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^0.13.5
  audio_session: ^0.1.13
  just_audio: ^0.9.32
  record: ^4.4.4
  permission_handler: ^10.2.0
  flutter_tts: ^3.6.3
  charts_flutter: ^0.12.0
  shared_preferences: ^2.0.18
```

### Configuração de Ambiente
```bash
# Variáveis de ambiente
GEMMA_MODEL_PATH=/models/gemma-3n
WELLNESS_CACHE_SIZE=1000
VOICE_ANALYSIS_ENABLED=true
TTS_LANGUAGE=pt-BR
CULTURAL_CONTEXT=guinea_bissau
```

## 🧪 Testes e Validação

### Testes Unitários
- Validação de análise de humor
- Testes de geração de conteúdo
- Verificação de fallbacks
- Testes de integração com IA

### Testes de Interface
- Usabilidade em diferentes dispositivos
- Acessibilidade para usuários com deficiências
- Performance em conexões lentas
- Modo offline funcional

### Validação Comunitária
- Testes com usuários reais da Guiné-Bissau
- Feedback sobre adequação cultural
- Validação de eficácia das recomendações
- Ajustes baseados no uso real

## 📈 Roadmap de Desenvolvimento

### Fase 1: Funcionalidades Básicas ✅
- [x] Dashboard de wellness
- [x] Análise de humor
- [x] Respiração guiada
- [x] Perfil de usuário
- [x] Integração com Gemma-3n

### Fase 2: Funcionalidades Avançadas 🔄
- [ ] Análise de voz completa
- [ ] Diário de bem-estar
- [ ] Relatórios de progresso
- [ ] Sistema de gamificação
- [ ] Modo offline robusto

### Fase 3: Expansão e Otimização 📋
- [ ] Suporte a múltiplas línguas locais
- [ ] IA treinada com dados locais
- [ ] Integração com profissionais de saúde
- [ ] Programa de mentoria comunitária
- [ ] Análise preditiva de bem-estar

## 🤝 Integração com Outros Módulos

### Sistema de Saúde
- Compartilhamento de dados de bem-estar mental
- Alertas para profissionais de saúde
- Histórico integrado de saúde

### Sistema Educacional
- Bem-estar de estudantes e professores
- Técnicas de manejo de estresse acadêmico
- Apoio emocional para aprendizagem

### Sistema Agrícola
- Bem-estar de trabalhadores rurais
- Manejo de estresse relacionado à agricultura
- Apoio durante períodos de safra

## 📞 Recursos de Emergência

### Detecção Automática
- Palavras-chave de risco suicida
- Padrões de comportamento preocupantes
- Níveis críticos de estresse

### Recursos Disponíveis
- Linha direta de crise
- Contatos de emergência
- Centros de saúde mental
- Líderes comunitários
- Organizações de apoio

## 🎯 Conclusão

O Sistema de Wellness Coaching do Moransa representa uma abordagem inovadora e culturalmente sensível para o bem-estar mental na Guiné-Bissau. Combinando tecnologia avançada de IA com sabedoria tradicional local, o sistema oferece:

### Características Únicas
- **Adaptação Cultural**: Profundamente enraizado na cultura da Guiné-Bissau
- **IA Empática**: Gemma-3n treinado para coaching culturalmente apropriado
- **Acessibilidade**: Funciona offline em comunidades remotas
- **Holístico**: Aborda bem-estar mental, físico e social
- **Comunitário**: Integra recursos e apoio da comunidade local

### Impacto Esperado
- **Prevenção**: Identificação precoce de problemas de saúde mental
- **Empoderamento**: Ferramentas para autocuidado e desenvolvimento
- **Acessibilidade**: Cuidados de saúde mental em áreas remotas
- **Sustentabilidade**: Modelo baseado na comunidade e cultura local
- **Inovação**: Pioneiro em IA para bem-estar cultural

### Próximos Passos
1. **Validação Comunitária**: Testes extensivos com usuários locais
2. **Treinamento de IA**: Refinamento com dados culturais específicos
3. **Parcerias Locais**: Colaboração com profissionais de saúde
4. **Expansão Linguística**: Suporte completo a línguas locais
5. **Pesquisa Científica**: Estudos de eficácia e impacto

O sistema não apenas oferece tecnologia avançada, mas cria uma ponte entre a inovação digital e a sabedoria ancestral, proporcionando cuidados de saúde mental verdadeiramente inclusivos e culturalmente apropriados para a Guiné-Bissau.

---

*"O bem-estar mental é um direito humano fundamental. Nossa tecnologia deve servir não apenas para inovar, mas para curar, conectar e empoderar comunidades."*

**Sistema Moransa - Tecnologia a serviço da humanidade** 🌍❤️