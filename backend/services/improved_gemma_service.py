"""
Serviço Gemma 3n otimizado baseado na implementação bem-sucedida do Kaggle
"""

import logging
import traceback
import gc
import torch
import threading
import time
from datetime import datetime
from transformers import AutoProcessor, AutoModelForImageTextToText

from config.settings import BackendConfig

logger = logging.getLogger(__name__)

class ImprovedGemmaService:
    """Serviço Gemma 3n melhorado baseado na implementação de sucesso"""
    
    def __init__(self):
        self.processor = None
        self.model = None
        self.is_initialized = False
        self.loading_method = "improved"
        
        # Tentar inicializar
        self._initialize()
    
    def _initialize(self):
        """Inicializar o serviço com a nova abordagem"""
        try:
            logger.info("🚀 Inicializando Gemma 3n com abordagem melhorada...")
            
            # Carregar processor
            logger.info("📦 Carregando processor...")
            self.processor = AutoProcessor.from_pretrained(
                BackendConfig.MODEL_PATH,
                local_files_only=True,
                trust_remote_code=True
            )
            
            # Carregar modelo multimodal
            logger.info("🧠 Carregando modelo multimodal...")
            self.model = AutoModelForImageTextToText.from_pretrained(
                BackendConfig.MODEL_PATH,
                torch_dtype="auto",  # Deixar PyTorch decidir o melhor tipo
                device_map="auto",   # Distribuição automática de dispositivos
                local_files_only=True,
                trust_remote_code=True,
                low_cpu_mem_usage=True
            )
            
            self.is_initialized = True
            logger.info("✅ Modelo Gemma 3n carregado com sucesso!")
            logger.info(f"📊 Dispositivo do modelo: {self.model.device}")
            logger.info(f"📊 Tipo de dados: {self.model.dtype}")
            
        except Exception as e:
            logger.error(f"❌ Erro na inicialização: {e}")
            logger.error(f"❌ Traceback: {traceback.format_exc()}")
            self.is_initialized = False
    
    def generate_response(self, prompt, language='pt-BR', subject='general'):
        """Gerar resposta usando a nova abordagem"""
        if not self.is_initialized:
            logger.warning("⚠️ Modelo não inicializado, usando fallback")
            return self._generate_fallback_response(prompt, language, subject)
        
        try:
            return self._generate_with_improved_method(prompt, language, subject)
        except Exception as e:
            logger.error(f"❌ Erro na geração: {e}")
            return self._generate_fallback_response(prompt, language, subject)
    
    def _generate_with_improved_method(self, prompt, language, subject):
        """Gerar usando o método melhorado com timeout"""
        
        def _generate_internal():
            logger.info(f"🔧 Gerando resposta melhorada para: {prompt[:50]}...")
            start_time = time.time()
            
            # Formatar prompt
            formatted_prompt = self._format_prompt(prompt, language, subject)
            logger.info(f"📝 Prompt formatado: {formatted_prompt[:100]}...")
            
            # Processar entrada (como no exemplo de sucesso)
            inputs = self.processor(
                text=formatted_prompt, 
                return_tensors="pt"
            ).to(self.model.device, dtype=self.model.dtype)
            
            logger.info(f"📊 Input shape: {list(inputs.values())[0].shape}")
            logger.info(f"💾 Input device: {list(inputs.values())[0].device}")
            
            # Gerar resposta (usando configurações do exemplo de sucesso)
            logger.info("🧠 Iniciando geração...")
            with torch.no_grad():
                outputs = self.model.generate(
                    **inputs,
                    max_new_tokens=256,  # Aumentado para respostas mais completas
                    disable_compile=True,  # Chave do sucesso!
                    do_sample=True,
                    temperature=0.7,
                    top_p=0.9,
                    pad_token_id=self.processor.tokenizer.pad_token_id if hasattr(self.processor, 'tokenizer') else None
                )
            
            # Decodificar resposta
            text = self.processor.batch_decode(
                outputs,
                skip_special_tokens=True,  # Mudança: skip_special_tokens=True
                clean_up_tokenization_spaces=True  # Mudança: limpar espaços
            )
            
            generated_text = text[0] if text else ""
            
            # Remover o prompt original da resposta
            if formatted_prompt in generated_text:
                generated_text = generated_text.replace(formatted_prompt, "").strip()
            
            end_time = time.time()
            duration = end_time - start_time
            
            logger.info(f"📝 Texto gerado em {duration:.2f}s ({len(generated_text)} chars)")
            logger.info(f"📄 Preview: {generated_text[:200]}...")
            
            if generated_text and len(generated_text.strip()) >= 10:
                timestamp = datetime.now().strftime("%H:%M:%S")
                full_response = f"{generated_text.strip()}\n\n[Gerado por Gemma-3n Melhorado em {duration:.1f}s às {timestamp}]"
                logger.info(f"✅ Resposta gerada com sucesso em {duration:.2f}s!")
                return full_response
            else:
                logger.warning(f"⚠️ Resposta muito curta: '{generated_text[:100]}'")
                return None
        
        # Usar threading para timeout de 45 segundos
        result_container = [None]
        exception_container = [None]
        
        def wrapper():
            try:
                result_container[0] = _generate_internal()
            except Exception as e:
                exception_container[0] = e
        
        thread = threading.Thread(target=wrapper)
        thread.daemon = True
        thread.start()
        thread.join(timeout=45)  # 45 segundos de timeout
        
        if thread.is_alive():
            logger.error("⏰ Timeout na geração (45s excedidos)")
            return self._generate_fallback_response(prompt, language, subject)
        
        if exception_container[0]:
            logger.error(f"❌ Erro na geração: {exception_container[0]}")
            return self._generate_fallback_response(prompt, language, subject)
        
        if result_container[0]:
            return result_container[0]
        else:
            logger.warning("⚠️ Resultado vazio, usando fallback")
            return self._generate_fallback_response(prompt, language, subject)
    
    def _format_prompt(self, prompt, language, subject):
        """Formatar prompt de acordo com o contexto"""
        context_map = {
            'medical': 'Você é um assistente médico especializado em saúde comunitária.',
            'agriculture': 'Você é um especialista em agricultura sustentável e cultivos tropicais.',
            'education': 'Você é um educador especializado em ensino adaptativo.',
            'general': 'Você é um assistente útil e informativo.'
        }
        
        context = context_map.get(subject, context_map['general'])
        
        if language.startswith('crioulo') or language == 'crp':
            context += " Responda em crioulo da Guiné-Bissau."
        else:
            context += " Responda em português brasileiro."
        
        return f"{context}\n\nPergunta: {prompt}\n\nResposta:"
    
    def _generate_fallback_response(self, prompt, language, subject):
        """Gerar resposta de fallback"""
        fallback_responses = {
            'agriculture': {
                'pt-BR': 'Para questões agrícolas, recomendo: verificar a qualidade do solo, usar sementes certificadas, e seguir práticas sustentáveis. Consulte um agrônomo local para orientações específicas.',
                'crioulo': 'Pa kestion di agrikultura, i misti: verifika tera, uza siminti bon, i sigui pratika sustentavel. Fala ku agronomo di zona pa orientason.'
            },
            'medical': {
                'pt-BR': 'Para questões médicas, é importante procurar orientação profissional. Em caso de emergência, procure o hospital mais próximo.',
                'crioulo': 'Pa kestion di saude, i misti buskada orientason profisional. Si e emerjensia, bai na hospital mas perto.'
            },
            'general': {
                'pt-BR': 'Desculpe, não consegui processar sua solicitação no momento. Tente novamente em alguns instantes.',
                'crioulo': 'Diskulpa, n kapa prosesu bo pedidu agora. Tenta fali dja dja.'
            }
        }
        
        lang_key = 'crioulo' if language.startswith('crioulo') or language == 'crp' else 'pt-BR'
        subject_responses = fallback_responses.get(subject, fallback_responses['general'])
        
        return f"{subject_responses[lang_key]}\n\n[Resposta de emergência - Serviço temporariamente indisponível]"
    
    def get_status(self):
        """Obter status do serviço"""
        return {
            'initialized': self.is_initialized,
            'loading_method': self.loading_method,
            'model_available': self.model is not None,
            'processor_available': self.processor is not None,
            'device': str(self.model.device) if self.model else 'N/A',
            'dtype': str(self.model.dtype) if self.model else 'N/A'
        }
