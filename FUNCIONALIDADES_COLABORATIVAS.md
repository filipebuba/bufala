# Funcionalidades Colaborativas - Aplicativo Moransa

## Visão Geral
Este documento detalha as funcionalidades colaborativas implementadas no aplicativo Moransa, focado em ajudar comunidades da Guiné-Bissau com primeiros socorros, educação e agricultura.

## 1. Sistema de Contribuições de Idioma

### 1.1 Estrutura de Dados
**Arquivo:** `android_app/lib/models/language_contribution.dart`

O modelo `LanguageContribution` inclui:
- `id`: Identificador único da contribuição
- `word`: Palavra no idioma original
- `translation`: Tradução para outro idioma
- `language`: Código do idioma (ex: 'pt-PT', 'crioulo')
- `category`: Categoria da contribuição (médica, educacional, agrícola)
- `context`: Contexto de uso da palavra/frase
- `audioPath`: Caminho para arquivo de áudio
- `imagePath`: Caminho para imagem ilustrativa
- `contributorId`: ID do usuário que contribuiu
- `votes`: Sistema de votação (up/down)
- `tags`: Tags para categorização
- `metadata`: Dados adicionais
- `status`: Status da contribuição (pending, approved, rejected)

### 1.2 Interface de Contribuição
**Arquivo:** `android_app/lib/screens/collaborative_teaching_screen.dart`

Funcionalidades implementadas:
- Formulário para submissão de novas contribuições
- Campos para palavra, tradução, categoria e contexto
- Upload de áudio e imagem
- Validação de dados antes do envio
- Sistema de gamificação (XP e streaks)
- Exibição de contribuições da comunidade
- Sistema de votação em contribuições

### 1.3 API Backend
**Arquivo:** `backend/routes/collaborative_routes.py`

Endpoints implementados:
- `POST /collaborative/contribute`: Submissão de novas contribuições
- `GET /collaborative/contributions`: Listagem de contribuições
- `POST /collaborative/vote`: Sistema de votação
- `GET /collaborative/stats`: Estatísticas da comunidade
- `GET /collaborative/progress`: Progresso de aprendizado
- `POST /collaborative/validate-audio`: Validação de áudio
- `GET /collaborative/search`: Busca de contribuições
- `GET /collaborative/suggestions`: Sugestões de palavras

### 1.4 Validações Implementadas
**Arquivo:** `backend/utils/validators.py`

- Validação de códigos de idioma
- Sanitização de texto
- Validação de categorias
- Validação de formatos de áudio e imagem
- Validação de parâmetros de busca

## 2. Sistema de Ensino Colaborativo

### 2.1 Integração com Gemma-3
**Arquivo:** `backend/services/gemma_service.py`

Funcionalidades:
- Processamento de contribuições para ensino
- Geração de conteúdo educacional personalizado
- Suporte a múltiplos idiomas locais
- Adaptação de conteúdo por complexidade

### 2.2 Rota de Ensino
**Endpoint:** `POST /collaborative/teach-gemma`

Processa contribuições da comunidade para:
- Treinar o modelo com dados locais
- Melhorar traduções para idiomas locais
- Adaptar conteúdo ao contexto cultural

## 3. Sistema de Gamificação

### 3.1 Pontuação e Recompensas
**Arquivo:** `android_app/lib/services/gamification_service.dart`

Sistema implementado:
- Pontos XP por contribuições
- Sistema de streaks (sequências diárias)
- Níveis de usuário
- Conquistas e badges

### 3.2 Estatísticas da Comunidade
Monitoramento de:
- Total de contribuições
- Contribuições por idioma
- Usuários mais ativos
- Progresso coletivo

## 4. Comunicação Frontend-Backend

### 4.1 Serviços de API
**Arquivos:**
- `android_app/lib/services/backend_service.dart`
- `android_app/lib/services/integrated_api_service.dart`

Implementações:
- Cliente HTTP com Dio
- Interceptadores para logging
- Tratamento de erros
- Retry automático
- Cache de respostas

### 4.2 Configuração de Rede
- Suporte a conexões locais e remotas
- Configuração automática de endpoints
- Fallback para modo offline

## 5. Funcionalidades Específicas por Área

### 5.1 Área Médica
- Contribuições de termos médicos
- Traduções de sintomas
- Procedimentos de primeiros socorros
- Contexto de emergências

### 5.2 Área Educacional
- Vocabulário educacional
- Conceitos pedagógicos
- Material didático colaborativo
- Adaptação cultural de conteúdo

### 5.3 Área Agrícola
- Terminologia agrícola
- Técnicas de cultivo
- Proteção de culturas
- Conhecimento tradicional

## 6. Recursos de Acessibilidade

### 6.1 Suporte a Áudio
- Gravação de pronúncia
- Reprodução de áudio
- Validação de qualidade
- Compressão automática

### 6.2 Suporte Visual
- Upload de imagens
- Redimensionamento automático
- Formatos suportados
- Otimização para dispositivos móveis

## 7. Banco de Dados e Persistência

### 7.1 Armazenamento Local
- Cache de contribuições
- Dados offline
- Sincronização automática

### 7.2 Estrutura de Dados
- Contribuições organizadas por categoria
- Índices para busca rápida
- Backup automático

## 8. Segurança e Moderação

### 8.1 Validação de Conteúdo
- Filtros de conteúdo inadequado
- Validação de idiomas
- Verificação de qualidade

### 8.2 Sistema de Moderação
- Votação da comunidade
- Aprovação de contribuições
- Relatório de problemas

## 9. Configurações e Personalização

### 9.1 Idiomas Suportados
- Português (pt-PT)
- Crioulo da Guiné-Bissau
- Outros idiomas locais
- Configuração automática

### 9.2 Preferências do Usuário
- Idioma preferido
- Categorias de interesse
- Notificações
- Modo offline

## 10. Status Atual da Implementação

### ✅ Funcionalidades Completas
- Modelo de dados para contribuições
- Interface de submissão
- API backend completa
- Sistema de validação
- Gamificação básica
- Comunicação frontend-backend

### 🔄 Em Desenvolvimento
- Integração completa com Gemma-3
- Sistema de moderação avançado
- Sincronização offline
- Analytics detalhados

### 📋 Próximos Passos
- Testes de integração
- Otimização de performance
- Expansão de idiomas
- Interface de administração

---

**Nota:** Este documento reflete o estado atual das funcionalidades colaborativas implementadas no aplicativo Moransa, focando especificamente nas capacidades de contribuição comunitária para construção de conhecimento local em saúde, educação e agricultura.