# 🎵 Guia de Teste: Áudio do Gemma-3n

## ✅ STATUS ATUAL

**✅ Backend:** Rodando em `http://localhost:5000`
**✅ Flutter:** Compilado e conectado
**✅ Gemma-3n:** Ativo via Ollama (gemma3n:e2b)
**✅ Logs de Debug:** Implementados

---

## 🧪 Como Testar a Funcionalidade

### **1. Acessar a Tela de Teste**

1. **Abrir o aplicativo Moransa**
2. **No menu principal, procurar:**
   - "Teste Gemma-3n Meditação" (cartão roxo)
3. **Tocar no cartão** para acessar a tela de teste

### **2. Configurar uma Sessão de Teste**

**Configurações Recomendadas:**
- **Tipo:** `Breathing` ou `Meditation`
- **Duração:** `5 minutos` (para teste rápido)
- **Prompt Personalizado:** `"Preciso relaxar após um dia difícil"`

### **3. Iniciar a Sessão**

1. **Tocar em "Iniciar Sessão"**
2. **Aguardar o processamento** (pode levar 30-60 segundos)
3. **Observar os logs** no terminal do Flutter

---

## 📊 Logs de Debug para Monitorar

### **Backend (Terminal Python):**
```
✅ Gemma-3n gerou instruções estruturadas para síntese de áudio
✅ JSON estruturado extraído com sucesso do Gemma-3n
🎯 Resposta gerada usando Gemma-3n (gemma3n:e2b) via Ollama local
```

### **Frontend (Terminal Flutter):**
```
📊 Dados da sessão recebidos: [session_id, audio_content, pattern, ...]
🎯 Reproduzindo sessão gerada por: gemma3n
📝 Audio content disponível: true
📝 Narration text disponível: true
📝 Tamanho do texto: XXX caracteres
🗣️ TTS reproduzindo: [Texto gerado pelo Gemma-3n]...
📖 Usando narração completa do Gemma-3n
```

---

## 🔍 Diagnóstico de Problemas

### **Se o texto NÃO está sendo reproduzido:**

**1. Verificar Logs do Backend:**
- ❌ Se não aparecer "Gemma-3n gerou instruções"
- ❌ Se aparecer erros de JSON parsing
- ❌ Se o Ollama não responder

**2. Verificar Logs do Frontend:**
- ❌ Se "Audio content disponível: false"
- ❌ Se "Narration text disponível: false"
- ❌ Se não aparecer "🗣️ TTS reproduzindo"

**3. Verificar TTS:**
- ❌ Se aparecer "❌ Erro ao falar"
- ❌ Se o volume do dispositivo estiver baixo
- ❌ Se o TTS não estiver configurado

---

## 🎯 Fluxo Esperado (Funcionando Corretamente)

### **Sequência Normal:**

1. **Usuário inicia sessão** → Requisição para backend
2. **Backend chama Gemma-3n** → Gera instruções estruturadas
3. **Backend retorna JSON** → Com `narration_text` completo
4. **Frontend recebe dados** → Processa `audio_content`
5. **TTS reproduz texto** → Áudio gerado pelo Gemma-3n
6. **Padrão de respiração** → Ciclos conforme especificado

### **Logs de Sucesso:**
```
✅ Backend: "Gemma-3n gerou instruções estruturadas"
✅ Frontend: "Reproduzindo sessão gerada por: gemma3n"
✅ Frontend: "Narration text disponível: true"
✅ Frontend: "🗣️ TTS reproduzindo: [texto]..."
✅ Frontend: "📖 Usando narração completa do Gemma-3n"
```

---

## 🛠️ Comandos de Monitoramento

### **Terminal Backend (Python):**
```bash
# Verificar se está rodando
ps aux | grep python

# Ver logs em tempo real
tail -f backend.log
```

### **Terminal Flutter:**
```bash
# Verificar status
flutter doctor

# Logs detalhados
flutter logs
```

### **Ollama:**
```bash
# Verificar modelos
ollama list

# Testar modelo diretamente
ollama run gemma3n:e2b "Gere uma sessão de meditação de 5 minutos"
```

---

## 📱 Teste Alternativo (Tela Principal)

**Se a tela de teste não funcionar:**

1. **Ir para "Wellness Coaching"**
2. **Escolher "Respiração Guiada"**
3. **Configurar:**
   - Duração: 5 minutos
   - Prompt: "Relaxamento profundo"
4. **Iniciar sessão**
5. **Monitorar logs**

---

## 🎵 Confirmação de Funcionamento

**✅ O Gemma-3n está gerando áudio quando:**

1. **Logs mostram:** "Gemma-3n gerou instruções estruturadas"
2. **Frontend recebe:** Texto com 200+ caracteres
3. **TTS reproduz:** Narração personalizada e contextualizada
4. **Conteúdo é:** Específico para Guiné-Bissau e culturalmente adaptado
5. **Áudio inclui:** Instruções de respiração detalhadas

**❌ Problemas comuns:**
- Texto genérico (não personalizado)
- Fallback para instruções básicas
- Erro de parsing JSON
- TTS não reproduz

---

## 📞 Próximos Passos

**Se tudo funcionar:**
- ✅ Gemma-3n está gerando áudio corretamente
- ✅ Sistema está operacional
- ✅ Pronto para uso em produção

**Se houver problemas:**
- 🔧 Verificar logs específicos
- 🔧 Testar componentes individualmente
- 🔧 Ajustar configurações conforme necessário

---

**🎯 OBJETIVO:** Confirmar que o Gemma-3n está gerando texto personalizado que é convertido em áudio via TTS, atendendo ao requisito de "áudio gerado pelo Gemma-3n".