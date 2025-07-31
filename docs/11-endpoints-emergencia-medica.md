# Endpoints de Emergência Médica - Moransa Backend

Este documento descreve os novos endpoints específicos para emergências médicas, criados para atender às necessidades das comunidades rurais da Guiné-Bissau.

## Visão Geral

Os endpoints de emergência foram desenvolvidos para fornecer orientações rápidas e precisas em situações críticas, utilizando o modelo Gemma3n para gerar respostas inteligentes e contextualmente apropriadas.

## Endpoints Disponíveis

### 1. Emergência Médica Geral
**Endpoint:** `POST /api/medical/emergency/medical`

**Descrição:** Para situações que requerem atendimento médico imediato.

**Parâmetros:**
```json
{
  "symptoms": ["dor no peito", "falta de ar"],
  "description": "Pessoa com dor forte no peito",
  "severity": "alta"
}
```

**Resposta:**
```json
{
  "success": true,
  "data": {
    "type": "emergencia_medica",
    "ai_guidance": "Orientações detalhadas do Gemma3n...",
    "immediate_actions": [
      "Mantenha a calma e avalie a situação",
      "Verifique sinais vitais (respiração, pulso)",
      "Posicione a pessoa adequadamente",
      "Procure ajuda médica IMEDIATAMENTE"
    ],
    "warning": "EMERGÊNCIA MÉDICA: Tempo é crucial. Aja rapidamente.",
    "gemma_used": true
  },
  "timestamp": "2025-07-31T04:09:18.063255"
}
```

### 2. Parto de Emergência
**Endpoint:** `POST /api/medical/emergency/childbirth`

**Descrição:** Assistência para partos em locais remotos sem acesso a hospital.

**Parâmetros:**
```json
{
  "stage": "trabalho_parto",
  "complications": ["sangramento"],
  "location": "casa"
}
```

**Estágios disponíveis:**
- `inicio` - Início do trabalho de parto
- `trabalho_parto` - Trabalho de parto ativo
- `nascimento` - Momento do nascimento
- `pos_parto` - Pós-parto

**Resposta:**
```json
{
  "success": true,
  "data": {
    "type": "parto_emergencia",
    "stage": "trabalho_parto",
    "ai_guidance": "Orientações detalhadas do Gemma3n...",
    "essential_steps": [
      "Ajude a mãe a encontrar posição confortável",
      "Encoraje respiração profunda e calma",
      "Não force o processo",
      "Prepare-se para o nascimento",
      "Mantenha higiene rigorosa"
    ],
    "materials_needed": [
      "Panos limpos ou toalhas",
      "Água fervida (se possível)",
      "Tesoura limpa (para cordão)",
      "Barbante ou fio limpo",
      "Cobertor para o bebê"
    ],
    "warning": "PARTO DE EMERGÊNCIA: Mantenha calma e higiene. Procure ajuda médica assim que possível.",
    "gemma_used": true
  },
  "timestamp": "2025-07-31T04:09:18.063255"
}
```

### 3. Acidentes
**Endpoint:** `POST /api/medical/emergency/accident`

**Descrição:** Primeiros socorros para acidentes diversos.

**Parâmetros:**
```json
{
  "accident_type": "queda",
  "injuries": ["ferimento na cabeça", "dor nas costas"],
  "consciousness": "consciente",
  "location": "aldeia"
}
```

**Estados de consciência:**
- `consciente` - Pessoa está acordada e responsiva
- `inconsciente` - Pessoa não responde
- `confuso` - Pessoa responde mas está confusa

**Resposta:**
```json
{
  "success": true,
  "data": {
    "type": "acidente",
    "accident_type": "queda",
    "ai_guidance": "Orientações detalhadas do Gemma3n...",
    "priority_actions": [
      "1. SEGURANÇA: Avalie se o local é seguro",
      "2. CONSCIÊNCIA: Verifique se a vítima responde",
      "3. RESPIRAÇÃO: Confirme se está respirando",
      "4. SANGRAMENTO: Controle hemorragias visíveis",
      "5. AJUDA: Chame socorro médico"
    ],
    "warning": "ACIDENTE: Não mova a vítima se suspeitar de lesão na coluna.",
    "gemma_used": true
  },
  "timestamp": "2025-07-31T04:09:18.063255"
}
```

### 4. Intoxicação/Envenenamento
**Endpoint:** `POST /api/medical/emergency/poisoning`

**Descrição:** Casos de envenenamento ou intoxicação.

**Parâmetros:**
```json
{
  "poison_type": "planta tóxica",
  "symptoms": ["náusea", "vômito"],
  "time_since_exposure": "30 minutos",
  "amount": "pequena quantidade"
}
```

**Resposta:**
```json
{
  "success": true,
  "data": {
    "type": "intoxicacao",
    "poison_type": "planta tóxica",
    "ai_guidance": "Orientações detalhadas do Gemma3n...",
    "immediate_actions": [
      "Remova a pessoa da fonte de exposição",
      "Verifique sinais vitais",
      "NÃO induza vômito sem orientação",
      "Se consciente, dê água (se orientado)",
      "Chame ajuda médica URGENTEMENTE"
    ],
    "do_not_do": [
      "Não induza vômito se a pessoa engoliu produtos corrosivos",
      "Não dê leite ou óleo",
      "Não deixe a pessoa sozinha",
      "Não espere os sintomas piorarem"
    ],
    "warning": "INTOXICAÇÃO: Tempo é crucial. Contate centro de intoxicações se disponível.",
    "gemma_used": true
  },
  "timestamp": "2025-07-31T04:09:18.063255"
}
```

## Características Especiais

### Integração com Gemma3n
- Todos os endpoints utilizam o modelo Gemma3n para gerar respostas contextualizadas
- Temperatura baixa (0.1) para garantir respostas precisas em emergências
- Prompts específicos para comunidades rurais da Guiné-Bissau

### Sistema de Fallback
- Se o Gemma3n não estiver disponível, o sistema fornece respostas básicas pré-definidas
- Garante que sempre haverá orientações disponíveis, mesmo sem IA

### Adaptação Cultural
- Orientações específicas para recursos limitados
- Instruções usando materiais disponíveis localmente
- Linguagem clara e acessível em português

## Códigos de Erro

- `400` - Dados JSON inválidos ou campos obrigatórios ausentes
- `500` - Erro interno do servidor

## Exemplos de Uso

### Teste com curl (Linux/Mac)
```bash
curl -X POST http://localhost:5000/api/medical/emergency/medical \
  -H "Content-Type: application/json" \
  -d '{
    "symptoms": ["dor no peito", "falta de ar"],
    "description": "Pessoa com dor forte no peito",
    "severity": "alta"
  }'
```

### Teste com PowerShell (Windows)
```powershell
Invoke-WebRequest -Uri "http://localhost:5000/api/medical/emergency/medical" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body '{
    "symptoms": ["dor no peito", "falta de ar"],
    "description": "Pessoa com dor forte no peito",
    "severity": "alta"
  }'
```

## Considerações de Segurança

- **IMPORTANTE:** Estas orientações não substituem atendimento médico profissional
- Sempre procure ajuda médica especializada quando disponível
- Use as orientações como primeiros socorros até a chegada de ajuda profissional
- Em caso de dúvida, priorize a segurança e chame ajuda médica

## Integração com o App Flutter

Os endpoints estão integrados com o aplicativo Flutter Moransa e podem ser acessados através da tela de "Medicina & Emergência" no app.

## Logs e Monitoramento

Todos os endpoints geram logs detalhados para monitoramento e debugging:
- Requisições recebidas
- Respostas do Gemma3n
- Erros e exceções
- Tempo de resposta

---

**Desenvolvido para o Hackathon Gemma 3n**  
**Projeto Moransa - Ajudando comunidades rurais da Guiné-Bissau**