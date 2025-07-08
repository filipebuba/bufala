"""
Serviço Gemma simplificado para sistemas com recursos limitados
"""

import os
import logging
from datetime import datetime
from config.settings import BackendConfig
from utils.fallback_responses import FallbackResponseGenerator

logger = logging.getLogger(__name__)

class GemmaServiceSimplified:
    """Versão simplificada do serviço Gemma para fallback"""
    
    def __init__(self):
        self.is_initialized = False
        self.loading_method = "simplified"
        self.fallback_generator = FallbackResponseGenerator()
        
        # Verificar se deve usar modo simplificado
        self.simple_mode = os.getenv('BU_FALA_SIMPLE_MODE', 'false').lower() == 'true'
        
        if self.simple_mode:
            logger.info("🔄 Iniciando Gemma em modo simplificado (sem carregamento de modelo)")
            self.is_initialized = True
        else:
            logger.info("🚀 Modo normal - tentando carregar modelo Gemma")
            self._try_load_model()
    
    def _try_load_model(self):
        """Tentar carregar modelo com timeout"""
        try:
            # Verificar se modelo existe
            if not os.path.exists(BackendConfig.MODEL_PATH):
                logger.warning(f"⚠️ Modelo não encontrado: {BackendConfig.MODEL_PATH}")
                self.simple_mode = True
                self.is_initialized = True
                return
            
            # Carregar apenas em modo simplificado por enquanto
            logger.info("💡 Usando modo simplificado por questões de performance")
            self.simple_mode = True
            self.is_initialized = True
            
        except Exception as e:
            logger.error(f"❌ Erro ao carregar modelo: {e}")
            logger.info("🔄 Fallback para modo simplificado")
            self.simple_mode = True
            self.is_initialized = True
    
    def generate_response(self, prompt, language='pt-BR', subject='general'):
        """Gerar resposta (simplificada ou com modelo)"""
        try:
            if not prompt or not prompt.strip():
                return "Por favor, forneça uma pergunta ou texto para análise."
            
            if self.simple_mode:
                return self._generate_simplified_response(prompt, language, subject)
            else:
                # Aqui seria a geração com modelo real
                return self._generate_simplified_response(prompt, language, subject)
                
        except Exception as e:
            logger.error(f"❌ Erro na geração: {e}")
            return self.fallback_generator.generate_response(prompt, language, subject)
    
    def _generate_simplified_response(self, prompt, language, subject):
        """Gerar resposta simplificada baseada em templates"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        
        # Respostas específicas por domínio
        domain_responses = {
            'medical': f"""
Com base na sua consulta médica: "{prompt[:100]}..."

🏥 **Orientações Gerais:**
• Esta é uma análise preliminar baseada em padrões comuns
• Sempre consulte um médico profissional para diagnóstico adequado
• Em caso de emergência, procure atendimento médico imediato

💡 **Recomendações:**
• Mantenha hábitos saudáveis (alimentação, exercícios, sono)
• Faça exames preventivos regulares
• Monitore sintomas e procure ajuda quando necessário

⚠️ **IMPORTANTE:** Este sistema não substitui consulta médica profissional.

[Resposta gerada pelo Bu Fala - Modo Simplificado às {timestamp}]
""",
            
            'education': f"""
Sobre sua questão educacional: "{prompt[:100]}..."

📚 **Orientações de Aprendizagem:**
• Divida o conteúdo em partes menores para melhor absorção
• Pratique regularmente para fixar o conhecimento
• Use diferentes métodos de estudo (visual, auditivo, prático)

🎯 **Dicas de Estudo:**
• Crie resumos e mapas mentais
• Faça exercícios práticos
• Busque explicações em fontes confiáveis

💡 **Para aprofundar:** Consulte livros, artigos acadêmicos e professores especializados.

[Resposta educacional às {timestamp}]
""",
            
            'agriculture': f"""
Sobre sua questão agrícola: "{prompt[:100]}..."

🌱 **Orientações Gerais de Cultivo:**
• Prepare o solo adequadamente antes do plantio
• Monitore irrigação e drenagem regularmente
• Use práticas sustentáveis de manejo

🚜 **Boas Práticas:**
• Rotação de culturas para manter fertilidade do solo
• Controle integrado de pragas e doenças
• Manejo adequado de nutrientes

🌿 **Sustentabilidade:** Considere técnicas orgânicas e preservação ambiental.

[Orientação agrícola às {timestamp}]
""",
            
            'wellness': f"""
Sobre seu bem-estar: "{prompt[:100]}..."

💪 **Orientações de Wellness:**
• Mantenha equilíbrio entre trabalho e descanso
• Pratique atividades físicas regularmente
• Cuide da saúde mental e emocional

🧘 **Práticas Recomendadas:**
• Meditação e técnicas de relaxamento
• Alimentação balanceada e hidratação
• Sono de qualidade (7-8 horas por noite)

🌟 **Lembre-se:** Pequenas mudanças diárias podem ter grande impacto na qualidade de vida.

[Orientação de bem-estar às {timestamp}]
""",
            
            'environmental': f"""
Sobre a questão ambiental: "{prompt[:100]}..."

🌍 **Orientações Ambientais:**
• Pratique os 3 Rs: Reduzir, Reutilizar, Reciclar
• Economize água e energia no dia a dia
• Prefira transporte sustentável quando possível

♻️ **Ações Sustentáveis:**
• Separação adequada de resíduos
• Uso consciente de recursos naturais
• Apoio a iniciativas de preservação

🌱 **Impacto Positivo:** Cada ação individual contribui para um futuro mais sustentável.

[Orientação ambiental às {timestamp}]
"""
        }
        
        # Obter resposta específica ou usar resposta geral
        if subject in domain_responses:
            return domain_responses[subject]
        else:
            return f"""
Sobre sua pergunta: "{prompt[:100]}..."

💡 **Resposta Geral:**
Obrigado por usar o Bu Fala! Estou funcionando em modo simplificado no momento, mas posso fornecer orientações básicas sobre diversos temas.

🎯 **Para respostas mais específicas:**
• Use as áreas especializadas (médica, educação, agricultura, wellness)
• Formule perguntas mais específicas
• O sistema completo com IA estará disponível em breve

📞 **Suporte:** Para questões complexas, consulte profissionais especializados na área.

[Resposta geral às {timestamp}]
"""
    
    def get_status(self):
        """Obter status do serviço"""
        return {
            'initialized': self.is_initialized,
            'loading_method': self.loading_method,
            'device': 'cpu',
            'model_path': BackendConfig.MODEL_PATH if hasattr(BackendConfig, 'MODEL_PATH') else 'N/A',
            'optimizations_enabled': False,
            'simple_mode': self.simple_mode,
            'multimodal_capable': False,
            'supports_image_analysis': False,
            'supports_audio_processing': False,
            'model_version': 'simplified-fallback',
            'performance_mode': 'optimized'
        }
