"""VoiceGuide AI Service - Sistema de Navegação Assistiva Integrado
Combina funcionalidades do VoiceGuide AI com o sistema de acessibilidade existente
"""

import logging
import time
import threading
import queue
from datetime import datetime
from typing import Optional, Dict, List, Any
from PIL import Image
import base64
import io

logger = logging.getLogger(__name__)

class VoiceGuideService:
    """Serviço integrado de navegação assistiva usando Gemma 3n"""
    
    def __init__(self, gemma_service):
        self.gemma_service = gemma_service
        self.is_active = False
        self.current_destination = None
        self.last_analysis_time = 0
        self.analysis_interval = 3  # segundos
        
        # Estado da navegação
        self.navigation_history = []
        self.emergency_mode = False
        
        # Configurações de idioma
        self.current_language = 'pt-BR'
        self.supported_languages = {
            'pt-BR': 'português brasileiro',
            'crioulo-gb': 'crioulo da Guiné-Bissau',
            'en-US': 'inglês americano',
            'fr-FR': 'francês',
            'es-ES': 'espanhol'
        }
        
        logger.info("VoiceGuide Service inicializado")
    
    # ==========================================
    # ANÁLISE DE AMBIENTE E NAVEGAÇÃO
    # ==========================================
    
    def analyze_environment(self, image_data: str = None, context: str = "") -> Dict[str, Any]:
        """Analisa o ambiente para navegação assistiva
        
        Args:
            image_data: Imagem em base64 (opcional)
            context: Contexto adicional para análise
            
        Returns:
            Análise completa do ambiente
        """
        try:
            logger.info("🔍 Analisando ambiente para navegação")
            
            # Prompt base para análise de ambiente
            base_prompt = f"""Você é um assistente de navegação para pessoas com deficiência visual.
Descreva o ambiente de forma clara e concisa em {self.supported_languages.get(self.current_language, 'português')}, focando em:

1. 🚧 Obstáculos e perigos imediatos
2. 🛤️ Caminhos livres e seguros
3. 🏛️ Pontos de referência importantes
4. 🧭 Direções específicas (esquerda, direita, frente, atrás)
5. 📏 Estimativas de distância quando possível

Seja específico sobre posições e use linguagem clara para navegação por áudio."""
            
            if context:
                prompt = f"{base_prompt}\n\nContexto específico: {context}"
            else:
                prompt = base_prompt
            
            # Se há imagem, incluir na análise
            if image_data:
                prompt += "\n\nAnalise a imagem fornecida e descreva o ambiente visível."
            
            # Gerar análise usando Gemma
            analysis = self.gemma_service.ask_gemma(prompt, context="navegacao_visual")
            
            # Estruturar resposta
            result = {
                'analysis': self._clean_response(analysis),
                'timestamp': datetime.now().isoformat(),
                'language': self.current_language,
                'context': context,
                'emergency_detected': self._detect_emergency_keywords(analysis),
                'navigation_suggestions': self._extract_navigation_suggestions(analysis)
            }
            
            # Adicionar ao histórico
            self.navigation_history.append(result)
            
            # Manter apenas últimas 50 análises
            if len(self.navigation_history) > 50:
                self.navigation_history = self.navigation_history[-50:]
            
            logger.info(f"✅ Análise concluída: {len(analysis)} caracteres")
            return result
            
        except Exception as e:
            logger.error(f"❌ Erro na análise do ambiente: {e}")
            return {
                'analysis': 'Não foi possível analisar o ambiente no momento. Tenha cuidado ao se mover.',
                'timestamp': datetime.now().isoformat(),
                'error': str(e),
                'emergency_detected': True
            }
    
    def generate_navigation_instructions(self, destination: str, current_analysis: str = "") -> Dict[str, Any]:
        """Gera instruções de navegação personalizadas
        
        Args:
            destination: Destino desejado
            current_analysis: Análise atual do ambiente
            
        Returns:
            Instruções de navegação detalhadas
        """
        try:
            logger.info(f"🧭 Gerando instruções para: {destination}")
            
            prompt = f"""Como assistente de navegação para pessoas com deficiência visual, 
gere instruções claras e seguras em {self.supported_languages.get(self.current_language, 'português')}.

Situação atual:
- Ambiente: {current_analysis if current_analysis else 'Análise não disponível'}
- Destino: {destination}

Forneça instruções que sejam:
✅ Passo a passo e sequenciais
✅ Específicas sobre direções (quantos passos, qual direção)
✅ Alertas sobre obstáculos
✅ Pontos de verificação para confirmar o caminho
✅ Instruções de segurança

Formato: Liste cada passo numerado de forma clara."""
            
            instructions = self.gemma_service.ask_gemma(prompt, context="instrucoes_navegacao")
            
            result = {
                'instructions': self._clean_response(instructions),
                'destination': destination,
                'timestamp': datetime.now().isoformat(),
                'language': self.current_language,
                'steps': self._extract_steps(instructions),
                'estimated_time': self._estimate_navigation_time(instructions),
                'safety_alerts': self._extract_safety_alerts(instructions)
            }
            
            # Definir destino atual
            self.current_destination = destination
            
            logger.info(f"✅ Instruções geradas: {len(result['steps'])} passos")
            return result
            
        except Exception as e:
            logger.error(f"❌ Erro ao gerar instruções: {e}")
            return {
                'instructions': 'Não foi possível gerar instruções no momento. Peça ajuda a alguém próximo.',
                'error': str(e),
                'destination': destination,
                'timestamp': datetime.now().isoformat()
            }
    
    def process_voice_command(self, command: str) -> Dict[str, Any]:
        """Processa comando de voz para navegação
        
        Args:
            command: Comando de voz reconhecido
            
        Returns:
            Resposta processada do comando
        """
        try:
            logger.info(f"🗣️ Processando comando: {command}")
            
            # Detectar tipo de comando
            command_lower = command.lower()
            
            if any(word in command_lower for word in ['emergência', 'socorro', 'ajuda', 'perigo']):
                return self._handle_emergency_command(command)
            elif any(word in command_lower for word in ['onde', 'localização', 'posição']):
                return self._handle_location_command(command)
            elif any(word in command_lower for word in ['ir', 'navegar', 'caminho', 'direção']):
                return self._handle_navigation_command(command)
            elif any(word in command_lower for word in ['descrever', 'ambiente', 'ao redor']):
                return self._handle_description_command(command)
            else:
                return self._handle_general_command(command)
                
        except Exception as e:
            logger.error(f"❌ Erro ao processar comando: {e}")
            return {
                'response': 'Desculpe, não consegui processar o comando. Tente novamente.',
                'error': str(e),
                'timestamp': datetime.now().isoformat()
            }
    
    # ==========================================
    # MODO EMERGÊNCIA
    # ==========================================
    
    def activate_emergency_mode(self, context: str = "") -> Dict[str, Any]:
        """Ativa modo de emergência
        
        Args:
            context: Contexto da emergência
            
        Returns:
            Instruções de emergência
        """
        try:
            logger.warning("🚨 MODO EMERGÊNCIA ATIVADO")
            self.emergency_mode = True
            
            prompt = f"""MODO EMERGÊNCIA ATIVADO!

Você é um assistente de emergência para pessoa com deficiência visual.
Forneça instruções IMEDIATAS de segurança em {self.supported_languages.get(self.current_language, 'português')}:

1. 🛑 Como parar e se posicionar com segurança
2. 📞 Como pedir ajuda (números de emergência)
3. 🔊 Como chamar atenção de pessoas próximas
4. 🧭 Como se orientar até encontrar ajuda

Contexto: {context if context else 'Situação de emergência não especificada'}

Seja DIRETO, CLARO e URGENTE!"""
            
            emergency_response = self.gemma_service.ask_gemma(prompt, context="emergencia")
            
            result = {
                'emergency_instructions': self._clean_response(emergency_response),
                'emergency_contacts': {
                    'police': '190',
                    'medical': '192',
                    'fire': '193',
                    'general': '199'
                },
                'timestamp': datetime.now().isoformat(),
                'context': context,
                'priority': 'URGENT',
                'mode': 'emergency'
            }
            
            logger.warning(f"🚨 Instruções de emergência geradas")
            return result
            
        except Exception as e:
            logger.error(f"❌ Erro no modo emergência: {e}")
            return {
                'emergency_instructions': 'EMERGÊNCIA: Pare onde está, chame por ajuda gritando SOCORRO, ligue 190 para polícia ou 192 para médico.',
                'error': str(e),
                'timestamp': datetime.now().isoformat(),
                'priority': 'URGENT'
            }
    
    def deactivate_emergency_mode(self) -> Dict[str, Any]:
        """Desativa modo de emergência"""
        self.emergency_mode = False
        logger.info("✅ Modo emergência desativado")
        return {
            'message': 'Modo emergência desativado. Sistema voltou ao normal.',
            'timestamp': datetime.now().isoformat(),
            'mode': 'normal'
        }
    
    # ==========================================
    # CONFIGURAÇÕES E STATUS
    # ==========================================
    
    def set_language(self, language_code: str) -> Dict[str, Any]:
        """Define idioma do sistema
        
        Args:
            language_code: Código do idioma (ex: 'pt-BR', 'crioulo-gb')
        """
        if language_code in self.supported_languages:
            self.current_language = language_code
            logger.info(f"🌐 Idioma alterado para: {self.supported_languages[language_code]}")
            return {
                'message': f'Idioma alterado para {self.supported_languages[language_code]}',
                'language': language_code,
                'timestamp': datetime.now().isoformat()
            }
        else:
            return {
                'error': f'Idioma {language_code} não suportado',
                'supported_languages': list(self.supported_languages.keys()),
                'timestamp': datetime.now().isoformat()
            }
    
    def get_status(self) -> Dict[str, Any]:
        """Retorna status completo do sistema"""
        return {
            'service': 'VoiceGuide AI - Navegação Assistiva',
            'active': self.is_active,
            'emergency_mode': self.emergency_mode,
            'current_destination': self.current_destination,
            'current_language': self.current_language,
            'navigation_history_count': len(self.navigation_history),
            'last_analysis': self.navigation_history[-1]['timestamp'] if self.navigation_history else None,
            'supported_languages': list(self.supported_languages.keys()),
            'features': {
                'environment_analysis': True,
                'voice_navigation': True,
                'emergency_mode': True,
                'multilingual_support': True,
                'offline_processing': True,
                'real_time_guidance': True
            },
            'gemma_status': getattr(self.gemma_service, 'is_initialized', True),
            'timestamp': datetime.now().isoformat()
        }
    
    def get_navigation_history(self, limit: int = 10) -> List[Dict[str, Any]]:
        """Retorna histórico de navegação
        
        Args:
            limit: Número máximo de registros
        """
        return self.navigation_history[-limit:] if self.navigation_history else []
    
    # ==========================================
    # MÉTODOS AUXILIARES PRIVADOS
    # ==========================================
    
    def _clean_response(self, response: str) -> str:
        """Limpa e formata resposta do modelo"""
        if not response:
            return "Resposta não disponível."
        
        # Remover caracteres especiais desnecessários
        cleaned = response.strip()
        
        # Garantir que termine com pontuação
        if cleaned and not cleaned.endswith(('.', '!', '?')):
            cleaned += '.'
        
        return cleaned
    
    def _detect_emergency_keywords(self, text: str) -> bool:
        """Detecta palavras-chave de emergência"""
        emergency_keywords = [
            'perigo', 'cuidado', 'atenção', 'risco', 'emergência',
            'obstáculo', 'bloqueado', 'perigoso', 'inseguro'
        ]
        text_lower = text.lower()
        return any(keyword in text_lower for keyword in emergency_keywords)
    
    def _extract_navigation_suggestions(self, analysis: str) -> List[str]:
        """Extrai sugestões de navegação da análise"""
        suggestions = []
        lines = analysis.split('\n')
        
        for line in lines:
            line = line.strip()
            if any(word in line.lower() for word in ['direção', 'caminho', 'vá', 'siga', 'vire']):
                suggestions.append(line)
        
        return suggestions[:5]  # Máximo 5 sugestões
    
    def _extract_steps(self, instructions: str) -> List[str]:
        """Extrai passos numerados das instruções"""
        steps = []
        lines = instructions.split('\n')
        
        for line in lines:
            line = line.strip()
            if line and (line[0].isdigit() or line.startswith(('•', '-', '*'))):
                steps.append(line)
        
        return steps
    
    def _estimate_navigation_time(self, instructions: str) -> str:
        """Estima tempo de navegação baseado nas instruções"""
        step_count = len(self._extract_steps(instructions))
        estimated_minutes = max(1, step_count * 0.5)  # 30 segundos por passo
        return f"{estimated_minutes:.1f} minutos"
    
    def _extract_safety_alerts(self, instructions: str) -> List[str]:
        """Extrai alertas de segurança das instruções"""
        alerts = []
        text_lower = instructions.lower()
        
        safety_keywords = ['cuidado', 'atenção', 'perigo', 'obstáculo', 'risco']
        lines = instructions.split('\n')
        
        for line in lines:
            if any(keyword in line.lower() for keyword in safety_keywords):
                alerts.append(line.strip())
        
        return alerts[:3]  # Máximo 3 alertas
    
    def _handle_emergency_command(self, command: str) -> Dict[str, Any]:
        """Processa comando de emergência"""
        return self.activate_emergency_mode(f"Comando de voz: {command}")
    
    def _handle_location_command(self, command: str) -> Dict[str, Any]:
        """Processa comando de localização"""
        analysis = self.analyze_environment(context="Solicitação de localização atual")
        return {
            'response': f"Sua localização atual: {analysis['analysis']}",
            'type': 'location',
            'timestamp': datetime.now().isoformat()
        }
    
    def _handle_navigation_command(self, command: str) -> Dict[str, Any]:
        """Processa comando de navegação"""
        # Extrair destino do comando
        destination = command.replace('ir para', '').replace('navegar para', '').strip()
        if not destination:
            destination = "destino não especificado"
        
        instructions = self.generate_navigation_instructions(destination)
        return {
            'response': instructions['instructions'],
            'type': 'navigation',
            'destination': destination,
            'timestamp': datetime.now().isoformat()
        }
    
    def _handle_description_command(self, command: str) -> Dict[str, Any]:
        """Processa comando de descrição"""
        analysis = self.analyze_environment(context="Solicitação de descrição do ambiente")
        return {
            'response': analysis['analysis'],
            'type': 'description',
            'timestamp': datetime.now().isoformat()
        }
    
    def _handle_general_command(self, command: str) -> Dict[str, Any]:
        """Processa comando geral"""
        prompt = f"""Como assistente de navegação para pessoa com deficiência visual,
responda a esta solicitação em {self.supported_languages.get(self.current_language, 'português')}:

"{command}"

Forneça uma resposta útil e relacionada à navegação ou acessibilidade."""
        
        response = self.gemma_service.ask_gemma(prompt, context="comando_geral")
        
        return {
            'response': self._clean_response(response),
            'type': 'general',
            'command': command,
            'timestamp': datetime.now().isoformat()
        }