Você tem toda a razão\! A gamificação é o que transforma um aplicativo útil em uma experiência viciante e motivadora. É o motor que incentiva o retorno diário e a participação contínua. Se as pessoas adoram se desafiar, vamos dar a elas desafios dinâmicos, personalizados e recompensadores, criados pela IA.

A Gemma-3 pode atuar como o seu "Mestre do Jogo" (Game Master), tornando o sistema de recompensas muito mais interessante do que uma simples contagem de pontos.

### O Papel da IA como "Mestre do Jogo"

1.  **Criar Desafios Dinâmicos:** Em vez de apenas dar pontos por cada contribuição, a IA criará "Missões" ou "Desafios" específicos (diários, semanais, pessoais).
2.  **Gerar Notificações e Recompensas:** A IA escreverá as mensagens de parabéns, notificações de subida de nível e descrições de conquistas, tornando-as mais pessoais e menos robóticas.
3.  **Adaptar à Comunidade:** A IA pode analisar o progresso da comunidade e criar "Eventos Comunitários" para focar em áreas que precisam de mais contribuições.

-----

### Prompt 1: Geração de Desafios Pessoais e Comunitários

Este prompt é para criar as "missões" que aparecerão para o usuário. O seu backend pode chamar esta função diariamente para cada usuário ativo ou quando um usuário pedir um novo desafio.

**Onde integrar:** No seu backend, crie uma rota como `GET /gamification/challenge` que chama uma função `gemma_service.generate_challenge(user_data)`.

#### Exemplo de Prompt (Gerador de Missões):

```json
{
  "task": "generate_gamification_challenge",
  "user_data": {
    "user_id": "user789",
    "user_name": "Mariama",
    "level": 4,
    "xp_to_next_level": 150,
    "current_streak": 2,
    "preferred_categories": ["médica", "educacional"],
    "contribution_count_today": 0
  },
  "community_status": {
    "most_needed_category": "agrícola",
    "active_community_event": null
  },
  "instructions": "Você é o 'Mestre do Jogo' do app Moransa. Com base nos dados do usuário e no status da comunidade, crie UM desafio personalizado e engajante. O desafio deve ser claro, com um objetivo definido. Considere os seguintes tipos de desafio:
  - 'Streak Saver': Se o usuário não contribuiu hoje e tem uma sequência ativa.
  - 'Category Explorer': Incentive o usuário a contribuir em uma categoria que ele usa pouco, especialmente se for a mais necessitada pela comunidade.
  - 'Level Up Push': Se o usuário está perto de subir de nível.
  - 'Community Hero': Um desafio alinhado a um evento comunitário.

  Retorne um único objeto JSON com os campos: `challenge_type`, `title` (um nome criativo para o desafio), `description` (o que o usuário precisa fazer), e `xp_reward` (sugira uma quantidade de pontos de experiência como recompensa)."
}
```

#### Exemplo de Resposta JSON Esperada da Gemma-3:

```json
{
  "challenge": {
    "challenge_type": "Category Explorer",
    "title": "Exploradora dos Campos",
    "description": "Mariama, sua sabedoria em saúde e educação é incrível! Mas os nossos campos precisam de você. Contribua com 3 novas traduções na categoria 'agrícola' e ajude a nossa comunidade a crescer.",
    "xp_reward": 75
  }
}
```

-----

### Prompt 2: Geração de Mensagens de Recompensa e Notificações

Este prompt é para dar "sabor" às conquistas do usuário. Em vez de uma notificação genérica "Você subiu de nível", a IA cria algo memorável.

**Onde integrar:** No seu backend, após uma ação que resulte em recompensa (subir de nível, completar uma sequência, ganhar um badge), chame uma função como `gemma_service.generate_reward_message(event_data)`.

#### Exemplo de Prompt (Mensagens de Celebração):

```json
{
  "task": "generate_reward_message",
  "event_data": {
    "event_type": "level_up",
    "user_name": "Amilcar",
    "new_level": 5,
    "new_level_title": "Guardião do Conhecimento"
  },
  "instructions": "Você é o 'Mestre do Jogo'. Com base no evento, crie uma mensagem de celebração para o usuário. A mensagem deve ser curta, inspiradora e reforçar a importância da contribuição dele para a comunidade. Retorne um objeto JSON com `title` e `body` para ser usado em uma notificação ou pop-up no app."
}
```

#### Exemplo de Resposta JSON Esperada da Gemma-3:

```json
{
  "notification": {
    "title": "Parabéns, Amilcar!",
    "body": "Você alcançou o Nível 5 e agora é um 'Guardião do Conhecimento'! Cada palavra que você ensina ao Moransa ilumina o caminho para toda a nossa comunidade. Continue brilhando!"
  }
}
```

-----

### Prompt 3: Criação de Conquistas e Badges

Use a IA para criar os nomes, descrições e até sugestões de ícones para as suas conquistas (badges). Isso torna a coleção de badges muito mais rica.

**Onde integrar:** Você pode usar isso como uma ferramenta de desenvolvimento para pré-popular seu banco de dados de conquistas, ou até mesmo gerar badges dinamicamente no futuro.

#### Exemplo de Prompt (Criador de Badges):

```json
{
  "task": "create_badge",
  "badge_criteria": "Fazer a primeira contribuição de áudio validada na categoria 'Primeiros Socorros'",
  "instructions": "Você é o 'Mestre do Jogo'. Com base no critério, crie uma conquista (badge). Retorne um objeto JSON com `name` (nome criativo), `description` (texto que explica e motiva), e `icon_suggestion` (descreva uma imagem simples para o ícone do badge)."
}
```

#### Exemplo de Resposta JSON Esperada da Gemma-3:

```json
{
  "badge": {
    "name": "A Voz que Salva",
    "description": "Por emprestar sua voz para ensinar uma frase crucial de primeiros socorros. Sua clareza pode ser a ajuda que alguém precisava ouvir.",
    "icon_suggestion": "Um coração no centro com ondas sonoras saindo dele."
  }
}
```

### Exemplo de Fluxo de Integração

1.  **Usuário abre o app.** O `android_app/lib/services/gamification_service.dart` faz uma chamada à API do backend (`GET /gamification/challenge`).
2.  **Backend recebe a chamada.** A rota chama a função `gemma_service.generate_challenge()` com os dados do usuário.
3.  **Gemma-3 responde** com o JSON do desafio (ex: "Exploradora dos Campos").
4.  **Backend envia o desafio** para o app Flutter, que o exibe em um card bonito na tela inicial.
5.  **Usuário completa o desafio** (faz 3 contribuições em 'agricultura').
6.  **Backend valida as contribuições.** Ao confirmar o sucesso, ele chama a função `gemma_service.generate_reward_message()` para o XP ganho.
7.  **Gemma-3 responde** com uma mensagem de parabéns.
8.  **Backend envia a mensagem** como uma notificação push para o app, que a exibe para o usuário, criando um ciclo de feedback positivo e motivador.