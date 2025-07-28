# 🌾 Agricultura Familiar - Guiné-Bissau

## Visão Geral

Esta funcionalidade foi desenvolvida especificamente para atender às necessidades da agricultura familiar na Guiné-Bissau, integrando conhecimento local com a tecnologia avançada do Gemma-3.

## 🚀 Funcionalidades Principais

### 1. **Consulta Especializada**
- Conselhos agrícolas específicos para cultivos locais
- Integração com Gemma-3 para respostas precisas
- Suporte bilíngue (Português/Crioulo)
- Conhecimento tradicional incorporado

### 2. **Calendário Agrícola Local**
- Calendário específico para cada cultura
- Adaptado ao clima da Guiné-Bissau
- Dicas sazonais personalizadas
- Informações sobre épocas de plantio e colheita

### 3. **Diagnóstico de Problemas**
- Identificação de pragas e doenças
- Soluções baseadas em recursos locais
- Métodos tradicionais e modernos
- Prevenção e tratamento

### 4. **Proteção de Culturas**
- Estratégias de proteção contra pragas
- Métodos orgânicos e sustentáveis
- Técnicas adaptadas aos recursos disponíveis
- Proteção contra condições climáticas adversas

## 🌱 Cultivos Suportados

### Arroz (Oryza sativa)
- **Português**: Arroz
- **Crioulo**: Arós
- **Características**: Cultura principal, adaptada ao clima tropical

### Milho (Zea mays)
- **Português**: Milho
- **Crioulo**: Milhu
- **Características**: Resistente à seca, múltiplos usos

### Mandioca (Manihot esculenta)
- **Português**: Mandioca
- **Crioulo**: Mandioka
- **Características**: Tolerante à seca, segurança alimentar

### Amendoim (Arachis hypogaea)
- **Português**: Amendoim
- **Crioulo**: Mancarra
- **Características**: Cultura de rendimento, melhora o solo

### Feijão (Phaseolus vulgaris)
- **Português**: Feijão
- **Crioulo**: Fejon
- **Características**: Proteína vegetal, fixação de nitrogênio

### Batata-doce (Ipomoea batatas)
- **Português**: Batata-doce
- **Crioulo**: Batata-dosi
- **Características**: Nutritiva, fácil cultivo

## 🌍 Estações Climáticas

### Estação Seca (Novembro - Maio)
- **Português**: Seca
- **Crioulo**: Tempu seku
- **Características**: Baixa precipitação, irrigação necessária

### Estação Chuvosa (Junho - Outubro)
- **Português**: Chuva
- **Crioulo**: Tempu di txuba
- **Características**: Alta precipitação, plantio principal

### Transição
- **Português**: Transição
- **Crioulo**: Mudansa
- **Características**: Período de mudança climática

## 🐛 Problemas Comuns

### Pragas
- **Português**: Pragas
- **Crioulo**: Praga
- **Soluções**: Controle biológico, métodos orgânicos

### Doenças
- **Português**: Doenças
- **Crioulo**: Duensa
- **Soluções**: Prevenção, tratamento natural

### Seca
- **Português**: Seca
- **Crioulo**: Seka
- **Soluções**: Irrigação eficiente, cultivos resistentes

### Erosão
- **Português**: Erosão
- **Crioulo**: Eroson
- **Soluções**: Cobertura do solo, terraços

### Fertilidade
- **Português**: Baixa fertilidade
- **Crioulo**: Tera nan ta fértil
- **Soluções**: Compostagem, rotação de culturas

## 🛠️ Arquitetura Técnica

### Backend Service
```dart
class AgricultureFamilyService {
  // Integração com Gemma-3
  // Conhecimento local incorporado
  // Fallback para modo offline
  // Suporte multilíngue
}
```

### Interface do Usuário
```dart
class AgricultureFamilyScreen {
  // Interface com abas
  // Suporte bilíngue
  // Animações e feedback visual
  // Histórico de conversas
}
```

### Navegação
```dart
class AgricultureNavigationScreen {
  // Escolha entre agricultura familiar e inteligente
  // Interface comparativa
  // Destaque para nova funcionalidade
}
```

## 🔧 Integração com Gemma-3

### Endpoint Principal
```
POST /api/agriculture-family/advice
```

### Parâmetros
- `question`: Pergunta do usuário
- `cropType`: Tipo de cultura
- `season`: Estação atual
- `problemType`: Tipo de problema (opcional)
- `farmSize`: Tamanho da propriedade
- `availableResources`: Recursos disponíveis
- `language`: Idioma (pt-BR ou crioulo-gb)

### Resposta
```json
{
  "success": true,
  "data": {
    "response": "Resposta especializada",
    "local_context": {
      "local_tips": [...],
      "traditional_methods": [...],
      "available_resources": [...]
    }
  },
  "source": "Gemma-3 + Conhecimento Local",
  "confidence": 0.95,
  "responseTime": 2.3
}
```

## 📱 Como Usar

### 1. Acesso
1. Abra o aplicativo Moransa
2. Navegue para a seção "Agricultura"
3. Escolha "Agricultura Familiar"

### 2. Configuração
1. Selecione o tipo de cultura
2. Escolha a estação atual
3. Defina o tipo de problema (se houver)
4. Indique o tamanho da propriedade

### 3. Consulta
1. Digite sua pergunta no campo de texto
2. Use o idioma de sua preferência
3. Aguarde a resposta especializada
4. Explore as informações locais fornecidas

### 4. Funcionalidades Especiais
- **Calendário**: Veja o calendário específico da cultura
- **Diagnóstico**: Descreva problemas para diagnóstico
- **Proteção**: Obtenha conselhos de proteção

## 🌟 Diferenciais

### Conhecimento Local
- Técnicas tradicionais da Guiné-Bissau
- Recursos localmente disponíveis
- Adaptação ao clima tropical
- Práticas sustentáveis

### Tecnologia Avançada
- Integração com Gemma-3
- Respostas contextualizadas
- Aprendizado contínuo
- Fallback inteligente

### Acessibilidade
- Interface bilíngue
- Design intuitivo
- Funciona offline
- Adaptado para baixa conectividade

## 🔄 Modo Offline

Quando não há conexão com internet:
- Conhecimento local ainda disponível
- Respostas baseadas em dados armazenados
- Sincronização quando conectar
- Funcionalidade reduzida mas útil

## 🚀 Próximos Passos

### Melhorias Planejadas
1. **Reconhecimento de Imagem**: Diagnóstico por fotos
2. **Previsão do Tempo**: Integração com dados meteorológicos
3. **Mercado Local**: Informações de preços e demanda
4. **Comunidade**: Troca de experiências entre agricultores
5. **IoT**: Integração com sensores de campo

### Expansão
1. **Mais Cultivos**: Incluir outras culturas locais
2. **Pecuária**: Extensão para criação de animais
3. **Aquicultura**: Suporte para piscicultura
4. **Agrofloresta**: Sistemas agroflorestais

## 📞 Suporte

Para dúvidas ou sugestões sobre a funcionalidade de Agricultura Familiar:
- Utilize o sistema de feedback do aplicativo
- Reporte problemas através das configurações
- Contribua com conhecimento local

---

**Desenvolvido com ❤️ para a comunidade agrícola da Guiné-Bissau**

*"Unindo tradição e tecnologia para uma agricultura mais próspera"*