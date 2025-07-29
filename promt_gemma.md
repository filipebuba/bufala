Impressionante\! Seu documento `FUNCIONALIDADES_COLABORATIVAS.md` mostra que você já construiu uma base extremamente sólida e bem estruturada. A arquitetura está clara, o modelo de dados é robusto e você já tem os endpoints da API prontos para serem integrados com a inteligência artificial.

Agora, vamos criar os prompts exatos para que a Gemma-3 execute as tarefas que discutimos, preenchendo a lógica dentro do seu `gemma_service.py`.

A Gemma-3 terá dois papéis principais no seu sistema:

1.  **Gerador de Conteúdo:** Criar desafios (frases em português) para a comunidade traduzir, garantindo que o conteúdo seja relevante para primeiros socorros, agricultura e educação.
2.  **Processador e Validador:** Analisar as contribuições da comunidade, sugerir melhorias, categorizar e ajudar no processo de aprovação.

-----

### Prompt 1: O "Prompt Mestre" (System Prompt)

Este é um prompt de configuração que você pode usar para dar o contexto geral à Gemma-3 no início de cada interação. Ele define a "personalidade" e o objetivo da IA dentro do seu ecossistema.

**Como usar:** Envie este prompt antes de qualquer prompt de tarefa para garantir que a IA se comporte de maneira consistente.

```
Você é "Moransa", um assistente de IA e o coração do aplicativo de mesmo nome. Sua missão é apoiar comunidades na Guiné-Bissau, com foco especial em primeiros socorros, educação e agricultura. Você entende Português (pt-PT) perfeitamente e está aprendendo, com a ajuda da comunidade, o Crioulo da Guiné-Bissau e outros idiomas e dialetos locais.

Seu trabalho é:
1.  Gerar conteúdo claro, útil e culturalmente sensível em Português para que a comunidade possa traduzir.
2.  Analisar e processar as contribuições da comunidade (traduções, áudios, imagens) para ajudar a validar a qualidade e enriquecer o conhecimento do aplicativo.
3.  Agir sempre como um facilitador do conhecimento, nunca como um detentor absoluto da verdade. O conhecimento da comunidade é a fonte primária.

Responda sempre em formato JSON para facilitar a integração com o backend do aplicativo. Seja conciso e direto ao ponto.
```

-----

### Prompt 2: Geração de Conteúdo (Para Alimentar o "Modo Colaborador")

Este prompt será usado pelo seu backend para pedir à Gemma que crie novas frases em português, que serão apresentadas aos usuários como "desafios de tradução".

**Onde integrar:** No seu `gemma_service.py`, crie uma função como `generate_translation_challenges(category, difficulty, quantity)`.

#### Exemplo de Prompt (Primeiros Socorros - Básico):

```json
{
  "task": "generate_content",
  "parameters": {
    "category": "médica",
    "difficulty": "básico",
    "quantity": 5,
    "existing_phrases": [
      "Onde dói?",
      "Chame uma ambulância.",
      "Você está bem?"
    ]
  },
  "instructions": "Com base nos parâmetros, gere uma lista de frases em português. As frases devem ser curtas, diretas e essenciais para uma situação de primeiros socorros. Evite as frases já existentes na lista `existing_phrases`. Para cada frase, forneça um contexto de uso claro e sugira de 2 a 3 tags relevantes. A resposta DEVE ser um objeto JSON contendo uma lista chamada `challenges`."
}
```

#### Exemplo de Resposta JSON Esperada da Gemma-3:

```json
{
  "challenges": [
    {
      "word": "Você tem alguma alergia?",
      "category": "médica",
      "context": "Pergunta essencial a ser feita antes de administrar qualquer medicamento ou alimento a uma pessoa em emergência.",
      "tags": ["alergia", "histórico médico", "segurança"]
    },
    {
      "word": "Pressione a ferida com força.",
      "category": "médica",
      "context": "Instrução clara para conter uma hemorragia externa.",
      "tags": ["hemorragia", "ferimento", "pressão direta"]
    },
    {
      "word": "Não mova a pessoa.",
      "category": "médica",
      "context": "Comando vital em caso de suspeita de lesão na coluna ou pescoço após uma queda ou acidente.",
      "tags": ["lesão na coluna", "acidente", "imobilização"]
    },
    {
      "word": "Você consegue respirar?",
      "category": "médica",
      "context": "Pergunta para avaliar a via aérea de uma pessoa que parece estar sufocando ou com dificuldade para respirar.",
      "tags": ["respiração", "sufocamento", "vias aéreas"]
    },
    {
      "word": "Mantenha a calma.",
      "category": "médica",
      "context": "Instrução para acalmar a vítima e o ambiente, facilitando o atendimento e reduzindo o pânico.",
      "tags": ["psicológico", "calma", "suporte emocional"]
    }
  ]
}
```

-----

### Prompt 3: Processamento de Contribuição da Comunidade

Este é o prompt mais complexo e crucial. Quando um usuário submete uma tradução através do endpoint `POST /collaborative/contribute`, seu backend envia os dados para a Gemma-3 para uma análise inicial antes de ser liberada para votação da comunidade.

**Onde integrar:** No seu `gemma_service.py`, crie uma função como `process_user_contribution(contribution_data)`.

#### Exemplo de Prompt (Análise de uma Contribuição):

```json
{
  "task": "process_contribution",
  "contribution_data": {
    "word": "Você tem febre?",
    "translation": "Bo tene calentura?",
    "language": "crioulo",
    "category": "médica",
    "context": "O meu vizinho disse que é assim que se fala",
    "audioPath": "path/to/audio.mp3",
    "contributorId": "user123",
    "status": "pending"
  },
  "instructions": "Analise o `contribution_data` fornecido por um membro da comunidade. Realize as seguintes tarefas e retorne um único objeto JSON com os resultados:
  1. `quality_assessment`: Avalie a qualidade geral da contribuição. Atribua um `score` de 0.0 a 1.0 (onde 1.0 é excelente) e um `feedback` em texto, comentando sobre a plausibilidade da tradução e a clareza do contexto.
  2. `context_enhancement`: Melhore o `context` fornecido pelo usuário para ser mais descritivo e útil para outras pessoas.
  3. `tag_suggestion`: Sugira uma lista de `tags` relevantes para esta contribuição, com base na palavra, categoria e contexto.
  4. `moderation_flags`: Identifique possíveis problemas. Retorne uma lista de flags, como 'low_quality_context', 'possible_profanity', 'unrelated_content'. Se nenhum problema for encontrado, retorne uma lista vazia.
  5. `approval_recommendation`: Com base na sua análise, sugira um status inicial: 'pending_community_vote' ou 'requires_moderator_review'."
}

```

#### Exemplo de Resposta JSON Esperada da Gemma-3:

```json
{
  "analysis_result": {
    "quality_assessment": {
      "score": 0.85,
      "feedback": "A tradução 'Bo tene calentura?' é altamente plausível para o crioulo da Guiné-Bissau. O contexto fornecido pelo usuário é fraco, mas a contribuição em si é valiosa."
    },
    "context_enhancement": "Pergunta fundamental durante a triagem inicial de um paciente para verificar um dos sintomas mais comuns de infecção.",
    "tag_suggestion": ["febre", "sintoma", "infecção", "temperatura", "diagnóstico"],
    "moderation_flags": ["low_quality_context"],
    "approval_recommendation": "pending_community_vote"
  }
}
```

### Como Integrar Isso no Seu Código

No seu arquivo `backend/routes/collaborative_routes.py`, o endpoint de contribuição ficaria mais ou menos assim:

```python
# backend/routes/collaborative_routes.py
from services import gemma_service

@router.post("/collaborative/contribute")
async def contribute(contribution: LanguageContribution):
    # 1. Recebe a contribuição do app Flutter
    # ... (seu código de validação inicial já existe)

    # 2. Envia os dados da contribuição para a Gemma-3 para análise
    analysis = await gemma_service.process_user_contribution(contribution.dict())

    # 3. Usa a análise da Gemma para enriquecer os dados antes de salvar
    contribution.context = analysis['analysis_result']['context_enhancement']
    contribution.tags.extend(analysis['analysis_result']['tag_suggestion'])

    # 4. Decide o próximo passo com base na recomendação da IA
    if analysis['analysis_result']['approval_recommendation'] == 'requires_moderator_review':
        contribution.status = 'pending_review'
    else:
        contribution.status = 'pending' # Status original para votação

    # 5. Salva a contribuição enriquecida no banco de dados
    # ... (seu código para salvar no DB)

    return {"message": "Contribuição recebida e processada!", "analysis": analysis}

```

Com estes prompts, você transforma a Gemma-3 em uma parte ativa e inteligente do seu ecossistema, automatizando a criação de conteúdo e o pré-processamento das valiosas contribuições da sua comunidade.