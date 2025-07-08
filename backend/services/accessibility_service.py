"""
Serviço de Acessibilidade - VoiceGuide AI
Sistema completo para deficiência visual, surdo e mudo
"""

import logging
import time
from datetime import datetime
from typing import List, Dict, Any

logger = logging.getLogger(__name__)

class AccessibilityService:
    """Serviço de acessibilidade usando Gemma 3n"""
    
    def __init__(self, gemma_service):
        self.gemma_service = gemma_service
        self.transcription_active = False
        self.transcription_history = []
        self.source_language = 'pt-BR'
        self.target_language = 'crioulo-gb'
        
    # ==========================================
    # FUNCIONALIDADES PARA DEFICIÊNCIA VISUAL
    # ==========================================
    
    def describe_environment(self) -> str:
        """Descrever ambiente para deficientes visuais"""
        try:
            logger.info("👁️ Gerando descrição do ambiente")
            
            prompt = """Descreva o ambiente ao redor como se fosse para uma pessoa com deficiência visual. 
            Inclua detalhes sobre:
            - Objetos importantes próximos
            - Possíveis obstáculos
            - Direções para navegação segura
            - Sons ambiente relevantes
            
            Seja claro, conciso e útil para navegação."""
            
            description = self.gemma_service.ask_gemma(prompt, context="acessibilidade")
            
            return self._clean_response(description)
            
        except Exception as e:
            logger.error(f"❌ Erro na descrição visual: {e}")
            return "Desculpe, não foi possível descrever o ambiente no momento. Tenha cuidado ao se mover."
    
    def navigate_with_voice(self, voice_command: str) -> str:
        """Processar comando de voz para navegação"""
        try:
            logger.info(f"🗣️ Processando comando: {voice_command}")
            
            prompt = f"""Como assistente de navegação para pessoa com deficiência visual, 
            interprete este comando de voz e forneça instruções claras e seguras:
            
            Comando: "{voice_command}"
            
            Responda com:
            - Instruções específicas e seguras
            - Avisos sobre possíveis obstáculos
            - Direções claras (esquerda, direita, frente)
            - Confirmação do destino se necessário"""
            
            response = self.gemma_service.ask_gemma(prompt, context="navegacao")
            
            return self._clean_response(response)
            
        except Exception as e:
            logger.error(f"❌ Erro na navegação por voz: {e}")
            return "Desculpe, não consegui processar o comando. Repita por favor."
    
    # ==========================================
    # FUNCIONALIDADES PARA SURDO E MUDO
    # ==========================================
    
    def start_continuous_transcription(self) -> str:
        """Iniciar transcrição contínua"""
        try:
            logger.info("🎤 Iniciando transcrição contínua")
            self.transcription_active = True
            
            return "Transcrição iniciada! Todas as falas serão convertidas em texto em tempo real."
            
        except Exception as e:
            logger.error(f"❌ Erro ao iniciar transcrição: {e}")
            return "Erro ao iniciar transcrição."
    
    def stop_continuous_transcription(self):
        """Parar transcrição contínua"""
        try:
            logger.info("🛑 Parando transcrição")
            self.transcription_active = False
            
        except Exception as e:
            logger.error(f"❌ Erro ao parar transcrição: {e}")
    
    def transcribe_audio(self, audio_text: str) -> Dict[str, Any]:
        """Transcrever áudio simulado (em produção usaria speech-to-text)"""
        try:
            logger.info("📝 Transcrevendo áudio")
            
            # Em produção, aqui usaria um modelo de speech-to-text
            # Por agora, vamos simular com processamento de texto
            
            transcription = {
                'text': audio_text,
                'confidence': 0.95,
                'timestamp': datetime.now().isoformat(),
                'language': self.source_language
            }
            
            # Adicionar ao histórico
            self.transcription_history.append(transcription)
            
            # Manter apenas últimas 100 transcrições
            if len(self.transcription_history) > 100:
                self.transcription_history = self.transcription_history[-100:]
            
            return transcription
            
        except Exception as e:
            logger.error(f"❌ Erro na transcrição: {e}")
            return {
                'text': 'Erro na transcrição',
                'confidence': 0.0,
                'timestamp': datetime.now().isoformat(),
                'error': str(e)
            }
    
    def translate_text(self, text: str, source_lang: str, target_lang: str) -> str:
        """Traduzir texto usando Gemma 3n"""
        try:
            logger.info(f"🔄 Traduzindo: {source_lang} → {target_lang}")
            
            # Mapear códigos de idioma para nomes
            language_names = {
                'pt-BR': 'português brasileiro',
                'crioulo-gb': 'crioulo da Guiné-Bissau',
                'en-US': 'inglês americano'
            }
            
            source_name = language_names.get(source_lang, source_lang)
            target_name = language_names.get(target_lang, target_lang)
            
            prompt = f"""Traduza o seguinte texto de {source_name} para {target_name}.
            Mantenha o significado original e use linguagem natural:
            
            Texto: "{text}"
            
            Tradução:"""
            
            response = self.gemma_service.ask_gemma(prompt, context="traducao")
            translated = self._clean_response(response)
            
            return translated
            
        except Exception as e:
            logger.error(f"❌ Erro na tradução: {e}")
            return text  # Retorna texto original em caso de erro
    
    def get_recent_transcriptions(self, limit: int = 10) -> List[Dict[str, Any]]:
        """Obter transcrições recentes"""
        try:
            return self.transcription_history[-limit:]
        except Exception as e:
            logger.error(f"❌ Erro ao obter transcrições: {e}")
            return []
    
    def set_languages(self, source_lang: str, target_lang: str):
        """Configurar idiomas padrão"""
        try:
            self.source_language = source_lang
            self.target_language = target_lang
            logger.info(f"🌐 Idiomas configurados: {source_lang} → {target_lang}")
        except Exception as e:
            logger.error(f"❌ Erro ao configurar idiomas: {e}")
    
    # ==========================================
    # FUNCIONALIDADES GERAIS
    # ==========================================
    
    def get_status(self) -> Dict[str, Any]:
        """Status do sistema de acessibilidade"""
        try:
            return {
                'service': 'VoiceGuide AI - Acessibilidade',
                'transcription_active': self.transcription_active,
                'transcription_count': len(self.transcription_history),
                'source_language': self.source_language,
                'target_language': self.target_language,
                'gemma_initialized': self.gemma_service.is_initialized if hasattr(self.gemma_service, 'is_initialized') else True,
                'features': {
                    'visual_assistance': True,
                    'voice_navigation': True,
                    'continuous_transcription': True,
                    'real_time_translation': True,
                    'offline_processing': True
                },
                'supported_languages': [
                    'pt-BR',
                    'crioulo-gb', 
                    'en-US'
                ]
            }
        except Exception as e:
            logger.error(f"❌ Erro ao obter status: {e}")
            return {'error': str(e)}
    
    def _clean_response(self, response: str) -> str:
        """Limpar resposta do Gemma removendo metadados"""
        try:
            # Remover marcadores do Gemma
            if '[Docs Gemma •' in response:
                response = response.split('[Docs Gemma •')[0].strip()
            
            if '[Fallback Response' in response:
                response = response.split('[Fallback Response')[0].strip()
            
            return response.strip()
            
        except Exception as e:
            logger.error(f"❌ Erro ao limpar resposta: {e}")
            return response
