"""
Serviço Gemma com Fallback Instantâneo
Para garantir respostas rápidas quando o modelo demora
"""

import os
import logging
import torch
import time
import threading
from transformers import AutoProcessor, AutoModelForImageTextToText
from config.settings import BackendConfig
from utils.fallback_responses import FallbackResponseGenerator

logger = logging.getLogger(__name__)

class InstantGemmaService:
    """Serviço Gemma com fallback instantâneo para garantir respostas rápidas"""
    
    def __init__(self):
        self.processor = None
        self.model = None
        self.is_initialized = False
        self.fallback_generator = FallbackResponseGenerator()
        self.max_wait_time = 15  # Máximo 15 segundos de espera
        self.initialize()
    
    def initialize(self):
        """Inicializar modelo com prioridade para velocidade"""
        try:
            logger.info("⚡ Inicializando Instant Gemma Service...")
            
            if not os.path.exists(BackendConfig.MODEL_PATH):
                logger.error(f"❌ Modelo não encontrado: {BackendConfig.MODEL_PATH}")
                return False
            
            start_time = time.time()
            
            # Carregar apenas se não demorar muito
            def load_model():
                try:
                    # Carregar processor
                    self.processor = AutoProcessor.from_pretrained(
                        BackendConfig.MODEL_PATH,
                        local_files_only=True,
                        trust_remote_code=True
                    )
                    
                    # Carregar modelo
                    self.model = AutoModelForImageTextToText.from_pretrained(
                        BackendConfig.MODEL_PATH,
                        torch_dtype="auto",
                        device_map="auto", 
                        local_files_only=True,
                        trust_remote_code=True
                    )
                    return True
                except Exception as e:
                    logger.error(f"❌ Erro no carregamento: {e}")
                    return False
            
            # Tentar carregar com timeout
            result = [False]
            def loader():
                result[0] = load_model()
            
            thread = threading.Thread(target=loader)
            thread.daemon = True
            thread.start()
            thread.join(timeout=30)  # Máximo 30s para carregar
            
            load_time = time.time() - start_time
            
            if thread.is_alive() or not result[0]:
                logger.warning(f"⚠️ Carregamento demorou mais que 30s ou falhou, usando apenas fallback")
                self.is_initialized = True  # Funciona apenas com fallback
                return True
            
            self.is_initialized = True
            logger.info(f"✅ Instant Gemma carregado em {load_time:.2f}s!")
            return True
            
        except Exception as e:
            logger.error(f"❌ Erro na inicialização: {e}")
            self.is_initialized = True  # Sempre funciona com fallback
            return True
    
    def generate_response(self, prompt, language='pt-BR', subject='general'):
        """Gerar resposta com limite de tempo rigoroso"""
        try:
            if not self.is_initialized:
                return self._smart_fallback_response(prompt, language, subject)
            
            # Se o modelo não carregou, usar fallback direto
            if not self.model or not self.processor:
                return self._smart_fallback_response(prompt, language, subject)
            
            # Tentar geração com timeout muito restrito
            start_time = time.time()
            result = [None]
            exception = [None]
            
            def generate():
                try:
                    formatted_prompt = self._format_prompt(prompt, language, subject)
                    
                    input_ids = self.processor(
                        text=formatted_prompt, 
                        return_tensors="pt"
                    ).to(self.model.device, dtype=self.model.dtype)
                    
                    # Configurações muito agressivas para velocidade
                    outputs = self.model.generate(
                        **input_ids, 
                        max_new_tokens=64,      # Muito pequeno
                        min_new_tokens=10,
                        do_sample=False,        # Greedy para velocidade
                        temperature=1.0,
                        disable_compile=True
                    )
                    
                    text = self.processor.batch_decode(
                        outputs,
                        skip_special_tokens=True,
                        clean_up_tokenization_spaces=True
                    )
                    
                    result[0] = text[0]
                    
                except Exception as e:
                    exception[0] = e
            
            thread = threading.Thread(target=generate)
            thread.daemon = True
            thread.start()
            thread.join(timeout=self.max_wait_time)  # 15 segundos MAX
            
            generation_time = time.time() - start_time
            
            if thread.is_alive() or exception[0] or not result[0]:
                logger.warning(f"⚠️ Geração demorou mais que {self.max_wait_time}s ou falhou, usando fallback inteligente")
                return self._smart_fallback_response(prompt, language, subject)
            
            # Limpar resposta
            response = result[0]
            if self._format_prompt(prompt, language, subject) in response:
                response = response.replace(self._format_prompt(prompt, language, subject), "").strip()
            
            if len(response) < 10:
                return self._smart_fallback_response(prompt, language, subject)
            
            logger.info(f"✅ Resposta do modelo gerada em {generation_time:.2f}s")
            return f"{response}\n\n[Gemma-3n • {generation_time:.1f}s]"
            
        except Exception as e:
            logger.error(f"❌ Erro na geração: {e}")
            return self._smart_fallback_response(prompt, language, subject)
    
    def _smart_fallback_response(self, prompt, language, subject):
        """Resposta inteligente e rápida baseada no assunto"""
        start_time = time.time()
        
        # Respostas específicas para agricultura
        if subject == 'agriculture':
            response = self._agriculture_smart_response(prompt)
        elif subject == 'medical':
            response = self._medical_smart_response(prompt)
        elif subject == 'education':
            response = self._education_smart_response(prompt)
        else:
            response = self._general_smart_response(prompt)
        
        generation_time = time.time() - start_time
        logger.info(f"✅ Resposta inteligente gerada em {generation_time:.3f}s")
        
        return f"{response}\n\n[Bu Fala AI • {generation_time:.3f}s]"
    
    def _agriculture_smart_response(self, prompt):
        """Respostas inteligentes para agricultura"""
        prompt_lower = prompt.lower()
        
        # Respostas específicas para culturas
        if 'arroz' in prompt_lower:
            if any(word in prompt_lower for word in ['plantar', 'plantio', 'como']):
                return """**Cultivo de Arroz na Guiné-Bissau**

🌾 **Preparação do Solo:**
- Escolha terrenos baixos, próximos a fontes de água
- Faça sulcos de 20-30cm de profundidade
- Adicione matéria orgânica (esterco ou compostagem)

💧 **Irrigação:**
- O arroz precisa de solo encharcado durante o crescimento
- Mantenha 5-10cm de água nos campos
- Drene apenas na colheita

🌱 **Plantio:**
- Época ideal: Início das chuvas (maio-junho)
- Faça mudas em viveiros primeiro
- Transplante após 20-30 dias

⚠️ **Cuidados:**
- Controle ervas daninhas manualmente
- Observe pragas como a broca do colmo
- Colha quando os grãos estiverem dourados (4-6 meses)"""

            elif any(word in prompt_lower for word in ['problema', 'doença', 'praga']):
                return """**Problemas Comuns no Arroz**

🐛 **Pragas:**
- **Broca do colmo**: Use controle biológico, plante variedades resistentes
- **Gafanhotos**: Coleta manual, uso de extratos de nim
- **Ratos**: Armadilhas, controle da vegetação ao redor

🦠 **Doenças:**
- **Queima das folhas**: Evite excesso de nitrogênio, melhore drenagem
- **Manchas foliares**: Use sementes tratadas, rotação de culturas

🌾 **Deficiências:**
- **Amarelamento**: Pode ser falta de nitrogênio ou ferro
- **Crescimento lento**: Verifique pH do solo (ideal 5.5-6.5)

💡 **Prevenção:**
- Use variedades adaptadas ao clima local
- Mantenha espaçamento adequado entre plantas
- Faça rotação com leguminosas"""

        elif 'milho' in prompt_lower:
            return """**Cultivo de Milho Tradicional**

🌽 **Preparação:**
- Escolha solos bem drenados e férteis
- Faça sulcos de 3-5cm de profundidade
- Espaçamento: 80cm entre fileiras, 20cm entre plantas

🌧️ **Época de Plantio:**
- Início das chuvas (maio-junho)
- Também possível no final das chuvas (setembro-outubro)

🌱 **Cuidados:**
- Primeira sacha aos 15-20 dias
- Segunda sacha aos 35-40 dias
- Adube com esterco ou compostagem

🌾 **Colheita:**
- 3-4 meses após plantio
- Quando espigas estão secas e grãos duros
- Seque bem antes de armazenar"""

        elif 'caju' in prompt_lower:
            return """**Cultivo de Caju**

🥜 **Plantio:**
- Época seca (novembro-março)
- Covas de 40x40x40cm
- Espaçamento: 8x8m ou 10x10m

🌳 **Cuidados:**
- Irrigação nos primeiros 2 anos
- Poda de formação e limpeza
- Controle de ervas daninhas

🍎 **Produção:**
- Inicia aos 3-4 anos
- Pico produtivo: 7-20 anos
- Colheita: março-junho"""

        # Resposta geral para agricultura
        return """**Conselhos Agrícolas para a Guiné-Bissau**

🌍 **Princípios Fundamentais:**
- Trabalhe com o clima, não contra ele
- Use variedades locais adaptadas
- Pratique agricultura sustentável

🌧️ **Época das Chuvas (maio-outubro):**
- Ideal para arroz, milho, amendoim
- Mantenha boa drenagem
- Controle erosão com terraceamento

☀️ **Época Seca (novembro-abril):**
- Cultive com irrigação: hortaliças
- Prepare o solo para próxima estação
- Plante árvores frutíferas

💡 **Dicas Importantes:**
- Faça compostagem com restos orgânicos
- Use rotação de culturas
- Consulte técnicos agrícolas locais
- Forme grupos de produtores para compartilhar conhecimento"""
    
    def _medical_smart_response(self, prompt):
        """Respostas inteligentes para saúde"""
        return """**Informação de Saúde**

⚠️ **IMPORTANTE**: Esta informação é apenas educativa. Sempre consulte um profissional de saúde para diagnóstico e tratamento.

🏥 **Para sua pergunta sobre saúde:**
- Procure o centro de saúde mais próximo
- Em emergências, vá imediatamente ao hospital
- Mantenha cartão de vacinação atualizado
- Pratique prevenção: higiene, alimentação saudável, exercícios

📞 **Emergência Médica**: Ligue para o serviço de urgência local ou vá ao hospital mais próximo."""
    
    def _education_smart_response(self, prompt):
        """Respostas inteligentes para educação"""
        return """**Dicas de Aprendizado**

📚 **Métodos Eficazes de Estudo:**
- Organize um cronograma de estudos
- Faça resumos e mapas mentais
- Pratique exercícios regularmente
- Estude em grupo quando possível

🎯 **Para Aprender Melhor:**
- Encontre seu horário mais produtivo
- Use diferentes fontes de informação
- Ensine outros para fixar o conhecimento
- Faça pausas regulares

💡 **Recursos Úteis:**
- Biblioteca local ou comunitária
- Grupos de estudo
- Professores e mentores
- Material didático adaptado ao seu nível"""
    
    def _general_smart_response(self, prompt):
        """Resposta geral inteligente"""
        return """**Informação Útil**

Esta é uma resposta rápida para sua pergunta. Para informações mais específicas e detalhadas, recomendo:

🔍 **Pesquise em fontes confiáveis:**
- Consulte especialistas da área
- Use bibliotecas e centros de informação
- Participe de comunidades locais

💡 **Considere seu contexto:**
- Suas necessidades específicas
- Recursos disponíveis
- Condições locais da Guiné-Bissau

📞 **Busque ajuda quando necessário:**
- Profissionais qualificados
- Serviços públicos
- Organizações comunitárias"""
    
    def _format_prompt(self, prompt, language, subject):
        """Formatar prompt de forma muito simples"""
        if subject == 'agriculture':
            return f"Agricultura: {prompt}"
        elif subject == 'medical':
            return f"Saúde: {prompt}"
        elif subject == 'education':
            return f"Educação: {prompt}"
        else:
            return prompt
    
    def get_status(self):
        """Status do serviço instantâneo"""
        return {
            'service_type': 'instant_gemma',
            'initialized': self.is_initialized,
            'model_loaded': self.model is not None,
            'processor_loaded': self.processor is not None,
            'max_wait_time': self.max_wait_time,
            'fallback_intelligent': True,
            'model_path': BackendConfig.MODEL_PATH,
            'optimizations': [
                'instant_fallback',
                'timeout_protection', 
                'smart_responses',
                'agriculture_specialized'
            ],
            'version': 'instant-gemma-v1'
        }
