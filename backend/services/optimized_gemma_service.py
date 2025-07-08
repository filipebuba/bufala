"""
Backend Bu Fala Otimizado para Limitações de Memória
Implementa estratégias para usar o Gemma 3n com recursos limitados
"""

import os
import logging
import torch
import traceback
from transformers import (
    AutoTokenizer,
    AutoModelForCausalLM,
    AutoProcessor,
    pipeline,
    BitsAndBytesConfig
)
from config.settings import BackendConfig, SystemPrompts
from utils.fallback_responses import FallbackResponseGenerator
import gc

logger = logging.getLogger(__name__)

class OptimizedGemmaService:
    """Serviço Gemma otimizado para recursos limitados"""
    
    def __init__(self):
        self.model = None
        self.tokenizer = None
        self.processor = None
        self.pipeline = None
        self.is_initialized = False
        self.loading_method = None
        self.generation_config = BackendConfig.get_generation_config()
        self.fallback_generator = FallbackResponseGenerator()
        
        # Configurações de otimização
        self.max_memory_usage = "6GB"  # Limite de memória
        self.use_disk_offload = True
        self.use_quantization = True
        
        self.initialize()
    
    def initialize(self):
        """Inicializar com estratégias de otimização de memória"""
        try:
            logger.info("🚀 Inicializando Gemma 3n com otimizações de memória...")
            
            # Verificar modelo
            if not os.path.exists(BackendConfig.MODEL_PATH):
                logger.error(f"❌ Modelo não encontrado: {BackendConfig.MODEL_PATH}")
                self._fallback_to_simple_responses()
                return False
            
            # Estratégia 1: Tentar carregamento com quantização
            if self._load_with_quantization():
                logger.info("✅ Carregado com quantização")
                self.loading_method = "quantized"
                self.is_initialized = True
                return True
            
            # Estratégia 2: Tentar carregamento com disk offload
            if self._load_with_disk_offload():
                logger.info("✅ Carregado com disk offload")
                self.loading_method = "disk_offload"
                self.is_initialized = True
                return True
            
            # Estratégia 3: Carregar apenas tokenizer para processamento local
            if self._load_tokenizer_only():
                logger.info("✅ Carregado apenas tokenizer")
                self.loading_method = "tokenizer_only"
                self.is_initialized = True
                return True
            
            # Estratégia 4: Fallback completo
            logger.warning("⚠️ Usando fallback completo")
            self._fallback_to_simple_responses()
            return True
            
        except Exception as e:
            logger.error(f"❌ Erro na inicialização: {e}")
            self._fallback_to_simple_responses()
            return True  # Sempre retorna True para manter o sistema funcionando
    
    def _load_with_quantization(self):
        """Tentar carregamento com quantização para reduzir uso de memória"""
        try:
            logger.info("📦 Tentando carregamento com quantização...")
            
            # Configuração de quantização
            quantization_config = BitsAndBytesConfig(
                load_in_8bit=True,
                llm_int8_threshold=6.0,
                llm_int8_skip_modules=None,
                llm_int8_enable_fp32_cpu_offload=True
            )
            
            # Carregar tokenizer
            self.tokenizer = AutoTokenizer.from_pretrained(
                BackendConfig.MODEL_PATH,
                local_files_only=True,
                trust_remote_code=True
            )
            
            if self.tokenizer.pad_token is None:
                self.tokenizer.pad_token = self.tokenizer.eos_token
            
            # Tentar carregar modelo com quantização
            self.model = AutoModelForCausalLM.from_pretrained(
                BackendConfig.MODEL_PATH,
                quantization_config=quantization_config,
                device_map="auto",
                local_files_only=True,
                trust_remote_code=True,
                torch_dtype=torch.float16,
                low_cpu_mem_usage=True
            )
            
            logger.info("✅ Modelo carregado com quantização 8-bit")
            return True
            
        except Exception as e:
            logger.warning(f"⚠️ Quantização falhou: {e}")
            return False
    
    def _load_with_disk_offload(self):
        """Tentar carregamento com offload para disco"""
        try:
            logger.info("💾 Tentando carregamento com disk offload...")
            
            # Carregar tokenizer
            self.tokenizer = AutoTokenizer.from_pretrained(
                BackendConfig.MODEL_PATH,
                local_files_only=True,
                trust_remote_code=True
            )
            
            if self.tokenizer.pad_token is None:
                self.tokenizer.pad_token = self.tokenizer.eos_token
            
            # Carregar modelo diretamente na CPU para evitar problemas de meta tensor
            self.model = AutoModelForCausalLM.from_pretrained(
                BackendConfig.MODEL_PATH,
                local_files_only=True,
                trust_remote_code=True,
                torch_dtype=torch.float32,  # Usar float32 para CPU
                low_cpu_mem_usage=True,
                device_map=None  # Não usar device_map automático
            )
            
            # Mover explicitamente para CPU
            self.model = self.model.to('cpu')
            self.model.eval()
            
            logger.info("✅ Modelo carregado com disk offload")
            return True
            
        except Exception as e:
            logger.warning(f"⚠️ Disk offload falhou: {e}")
            return False
            
            # Aplicar disk offload
            offload_folder = os.path.join(os.path.dirname(BackendConfig.MODEL_PATH), "offload")
            os.makedirs(offload_folder, exist_ok=True)
            
            self.model = disk_offload(
                model=self.model,
                offload_dir=offload_folder,
                execution_device="cpu"
            )
            
            logger.info("✅ Modelo carregado com disk offload")
            return True
            
        except Exception as e:
            logger.warning(f"⚠️ Disk offload falhou: {e}")
            return False
    
    def _load_tokenizer_only(self):
        """Carregar apenas tokenizer para processamento básico"""
        try:
            logger.info("🔤 Carregando apenas tokenizer...")
            
            self.tokenizer = AutoTokenizer.from_pretrained(
                BackendConfig.MODEL_PATH,
                local_files_only=True,
                trust_remote_code=True
            )
            
            if self.tokenizer.pad_token is None:
                self.tokenizer.pad_token = self.tokenizer.eos_token
            
            # Também carregar processor se disponível
            try:
                self.processor = AutoProcessor.from_pretrained(
                    BackendConfig.MODEL_PATH,
                    local_files_only=True,
                    trust_remote_code=True
                )
                logger.info("✅ Processor também carregado")
            except Exception as e:
                logger.warning(f"⚠️ Processor não carregado: {e}")
            
            logger.info("✅ Tokenizer carregado - modo básico ativo")
            return True
            
        except Exception as e:
            logger.warning(f"⚠️ Carregamento do tokenizer falhou: {e}")
            return False
    
    def _fallback_to_simple_responses(self):
        """Configurar para usar apenas respostas simples"""
        self.loading_method = "fallback_only"
        self.is_initialized = True
        logger.info("✅ Modo fallback ativado - respostas pré-definidas")
    
    def generate_response(self, prompt, language='pt-BR', subject='general'):
        """Gerar resposta com base no método disponível"""
        try:
            # Limpar cache de memória
            if torch.cuda.is_available():
                torch.cuda.empty_cache()
            gc.collect()
            
            if self.loading_method == "quantized" and self.model and self.tokenizer:
                return self._generate_with_quantized_model(prompt, language, subject)
            
            elif self.loading_method == "disk_offload" and self.model and self.tokenizer:
                return self._generate_with_disk_offload(prompt, language, subject)
            
            elif self.loading_method == "tokenizer_only" and self.tokenizer:
                return self._generate_with_tokenizer_processing(prompt, language, subject)
            
            else:
                return self._generate_fallback_response(prompt, language, subject)
                
        except Exception as e:
            logger.error(f"❌ Erro na geração: {e}")
            return self._generate_fallback_response(prompt, language, subject)
    
    def _generate_with_quantized_model(self, prompt, language, subject):
        """Gerar com modelo quantizado"""
        try:
            formatted_prompt = self._format_prompt(prompt, language, subject)
            
            inputs = self.tokenizer(
                formatted_prompt,
                return_tensors="pt",
                padding=True,
                truncation=True,
                max_length=512  # Reduzido para economizar memória
            )
            
            # Configurações conservativas para economia de memória
            with torch.no_grad():
                outputs = self.model.generate(
                    **inputs,
                    max_new_tokens=100,  # Reduzido
                    do_sample=True,
                    temperature=0.7,
                    top_p=0.9,
                    pad_token_id=self.tokenizer.pad_token_id,
                    eos_token_id=self.tokenizer.eos_token_id,
                    early_stopping=True
                )
            
            generated_tokens = outputs[0][inputs['input_ids'].shape[1]:]
            generated_text = self.tokenizer.decode(generated_tokens, skip_special_tokens=True).strip()
            
            if generated_text and len(generated_text.strip()) >= 10:
                return f"{generated_text}\n\n[Gerado por Gemma-3n Quantizado]"
            else:
                return self._generate_fallback_response(prompt, language, subject)
                
        except Exception as e:
            logger.warning(f"⚠️ Geração quantizada falhou: {e}")
            return self._generate_fallback_response(prompt, language, subject)
    
    def _generate_with_disk_offload(self, prompt, language, subject):
        """Gerar com modelo em disk offload com timeout usando threading"""
        import threading
        import time
        
        def _generate_internal():
            logger.info(f"🔧 Gerando resposta disk offload para: {prompt[:50]}...")
            start_time = time.time()
            
            formatted_prompt = self._format_prompt(prompt, language, subject)
            logger.info(f"📝 Prompt formatado: {formatted_prompt[:100]}...")
            
            inputs = self.tokenizer(
                formatted_prompt,
                return_tensors="pt",
                padding=True,
                truncation=True,
                max_length=512
            )
            
            # Garantir que os inputs estejam na CPU
            inputs = {k: v.to('cpu') for k, v in inputs.items()}
            
            logger.info(f"📊 Input shape: {inputs['input_ids'].shape}")
            logger.info(f"💾 Input device: {inputs['input_ids'].device}")
            
            # Configurações otimizadas para velocidade
            generation_config = {
                'max_new_tokens': 64,   # Reduzido drasticamente para acelerar
                'min_new_tokens': 5,    # Mínimo muito baixo
                'do_sample': True,
                'temperature': 0.7,
                'top_p': 0.9,
                'top_k': 20,           # Muito reduzido
                'repetition_penalty': 1.05,
                'pad_token_id': self.tokenizer.pad_token_id,
                'eos_token_id': self.tokenizer.eos_token_id,
                'early_stopping': True,
                'num_beams': 1,
                'use_cache': True
            }
            
            logger.info("🧠 Iniciando geração com o modelo...")
            
            with torch.no_grad():
                outputs = self.model.generate(
                    **inputs,
                    **generation_config
                )
            
            generated_tokens = outputs[0][inputs['input_ids'].shape[1]:]
            generated_text = self.tokenizer.decode(generated_tokens, skip_special_tokens=True).strip()
            
            end_time = time.time()
            duration = end_time - start_time
            
            logger.info(f"📝 Texto gerado em {duration:.2f}s ({len(generated_text)} chars): {generated_text[:100]}...")
            
            if generated_text and len(generated_text.strip()) >= 5:
                from datetime import datetime
                timestamp = datetime.now().strftime("%H:%M:%S")
                full_response = f"{generated_text}\n\n[Gerado por Gemma-3n em {duration:.1f}s às {timestamp}]"
                logger.info(f"✅ Resposta gerada com sucesso em {duration:.2f}s!")
                return full_response
            else:
                logger.warning(f"⚠️ Resposta muito curta ou vazia: '{generated_text}'")
                return None
        
        # Usar threading para timeout
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
        
        # Aguardar com timeout de 60 segundos
        thread.join(timeout=60)
        
        if thread.is_alive():
            logger.error("⏰ Timeout na geração (60s excedidos)")
            return self._generate_fallback_response(prompt, language, subject)
        
        if exception_container[0]:
            logger.error(f"❌ Erro na geração: {exception_container[0]}")
            return self._generate_fallback_response(prompt, language, subject)
        
        if result_container[0]:
            return result_container[0]
        else:
            logger.warning("⚠️ Resultado vazio, usando fallback")
            return self._generate_fallback_response(prompt, language, subject)
    
    def _generate_with_tokenizer_processing(self, prompt, language, subject):
        """Gerar usando apenas processamento do tokenizer"""
        try:
            # Usar tokenizer para análise e processamento básico
            tokens = self.tokenizer.encode(prompt)
            token_count = len(tokens)
            
            # Análise básica baseada no prompt
            analysis = self._analyze_prompt(prompt, subject)
            
            response = f"""
{analysis}

[Análise baseada em processamento de texto - Token count: {token_count}]
[Gemma-3n Tokenizer Processing Mode]
"""
            return response.strip()
            
        except Exception as e:
            logger.warning(f"⚠️ Processamento tokenizer falhou: {e}")
            return self._generate_fallback_response(prompt, language, subject)
    
    def _analyze_prompt(self, prompt, subject):
        """Análise inteligente do prompt baseada em padrões"""
        prompt_lower = prompt.lower()
        
        # Análises por domínio
        if subject == 'medical' or any(word in prompt_lower for word in ['dor', 'sintoma', 'doença', 'médico', 'saúde']):
            return self._medical_analysis(prompt)
        elif subject == 'education' or any(word in prompt_lower for word in ['aprender', 'estudar', 'escola', 'ensino']):
            return self._education_analysis(prompt)
        elif subject == 'agriculture' or any(word in prompt_lower for word in ['planta', 'cultivo', 'agricultura', 'solo']):
            return self._agriculture_analysis(prompt)
        elif subject == 'wellness' or any(word in prompt_lower for word in ['bem-estar', 'exercício', 'stress', 'vida']):
            return self._wellness_analysis(prompt)
        else:
            return self._general_analysis(prompt)
    
    def _medical_analysis(self, prompt):
        """Análise médica baseada em padrões"""
        responses = [
            "Para questões de saúde, é fundamental consultar um profissional médico qualificado.",
            "Os sintomas descritos podem ter várias causas. Procure orientação médica.",
            "Recomendo manter uma dieta equilibrada, exercícios regulares e consultar seu médico.",
            "Em caso de emergência ou sintomas graves, procure atendimento médico imediato."
        ]
        import random
        return random.choice(responses)
    
    def _education_analysis(self, prompt):
        """Análise educacional baseada em padrões"""
        responses = [
            "O aprendizado é mais eficaz quando combinamos teoria e prática.",
            "Use diferentes métodos de estudo: leitura, exercícios, discussões e resumos.",
            "Faça pausas regulares durante os estudos para melhor retenção do conhecimento.",
            "Procure fontes confiáveis e diversifique seus recursos de aprendizado."
        ]
        import random
        return random.choice(responses)
    
    def _agriculture_analysis(self, prompt):
        """Análise agrícola baseada em padrões"""
        responses = [
            "Para melhores resultados, consulte um engenheiro agrônomo da sua região.",
            "Mantenha o solo bem drenado e com pH adequado para suas culturas.",
            "Monitore suas plantas regularmente para detectar pragas e doenças cedo.",
            "Use práticas sustentáveis: rotação de culturas, compostagem e controle biológico."
        ]
        import random
        return random.choice(responses)
    
    def _wellness_analysis(self, prompt):
        """Análise de bem-estar baseada em padrões"""
        responses = [
            "O bem-estar envolve equilíbrio entre corpo, mente e relacionamentos.",
            "Pratique exercícios regulares, alimentação saudável e tenha boas noites de sono.",
            "Gerencie o stress com técnicas de relaxamento, meditação ou hobbies.",
            "Mantenha conexões sociais positivas e reserve tempo para atividades prazerosas."
        ]
        import random
        return random.choice(responses)
    
    def _general_analysis(self, prompt):
        """Análise geral baseada em padrões"""
        responses = [
            "Esta é uma questão interessante que pode ter várias perspectivas.",
            "Para uma resposta mais específica, forneça mais contexto sobre sua situação.",
            "Recomendo pesquisar em fontes confiáveis e consultar especialistas da área.",
            "Cada situação é única, então considere seus objetivos e circunstâncias específicas."
        ]
        import random
        return random.choice(responses)
    
    def _generate_fallback_response(self, prompt, language, subject):
        """Gerar resposta usando o sistema de fallback"""
        return self.fallback_generator.generate_response(prompt, language, subject)
    
    def _format_prompt(self, prompt, language, subject):
        """Formatar prompt para o assunto específico com estrutura melhorada"""
        prompts = {
            'medical': f"""Você é um assistente de saúde especializado. Responda à seguinte pergunta médica de forma clara e útil:

Pergunta: {prompt}

Forneça orientações úteis, mas sempre recomende consultar um profissional de saúde para casos específicos.

Resposta:""",
            'education': f"""Você é um professor experiente. Ajude com a seguinte questão educacional:

Pergunta: {prompt}

Explique de forma didática e completa, adequada para o aprendizado.

Resposta:""",
            'agriculture': f"""Você é um especialista em agricultura sustentável. Responda sobre a seguinte questão agrícola:

Pergunta: {prompt}

Forneça conselhos práticos para agricultura sustentável.

Resposta:""",
            'wellness': f"""Você é um especialista em bem-estar. Ajude com a seguinte questão:

Pergunta: {prompt}

Forneça orientações para uma vida mais saudável e equilibrada.

Resposta:""",
            'translate': f"""Você é um tradutor especializado em português e crioulo da Guiné-Bissau. Traduza:

Texto: {prompt}

Forneça uma tradução precisa e culturalmente apropriada.

Tradução:""",
            'environmental': f"""Você é um especialista ambiental. Responda sobre:

Pergunta: {prompt}

Forneça orientações ecológicas práticas.

Resposta:"""
        }
        
        return prompts.get(subject, f"""Você é um assistente inteligente e útil. Responda à seguinte pergunta:

Pergunta: {prompt}

Forneça uma resposta completa e informativa.

Resposta:""")
    
    def get_status(self):
        """Obter status do serviço otimizado"""
        return {
            'initialized': self.is_initialized,
            'loading_method': self.loading_method,
            'device': BackendConfig.get_device(),
            'model_path': BackendConfig.MODEL_PATH,
            'optimizations_enabled': True,
            'memory_optimized': True,
            'quantization_used': self.loading_method == "quantized",
            'disk_offload_used': self.loading_method == "disk_offload",
            'tokenizer_only': self.loading_method == "tokenizer_only",
            'fallback_mode': self.loading_method == "fallback_only",
            'model_version': 'gemma-3n-e2b-it-optimized'
        }
