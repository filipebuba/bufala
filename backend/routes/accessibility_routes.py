"""
Rotas para VoiceGuide AI - Sistema de Acessibilidade
"""

from flask import Blueprint, request, jsonify, g
from datetime import datetime
import logging
import base64

from utils.decorators import timeout_handler, require_json

logger = logging.getLogger(__name__)

accessibility_bp = Blueprint('accessibility', __name__)

# ==========================================
# ROTAS PARA DEFICIÊNCIA VISUAL
# ==========================================

@accessibility_bp.route('/accessibility/visual/describe', methods=['POST'])
@timeout_handler
def describe_environment():
    """Descrever ambiente usando câmera para deficientes visuais"""
    try:
        logger.info("👁️ Requisição de descrição visual")
        
        # Obter descrição do ambiente
        description = g.accessibility_service.describe_environment()
        
        return jsonify({
            'description': description,
            'type': 'visual_description',
            'timestamp': datetime.now().isoformat(),
            'status': 'success'
        })
        
    except Exception as e:
        logger.error(f"❌ Erro na descrição visual: {e}")
        return jsonify({
            'error': 'Erro no sistema de descrição visual',
            'message': str(e),
            'timestamp': datetime.now().isoformat(),
            'status': 'error'
        }), 500

@accessibility_bp.route('/accessibility/navigation/voice', methods=['POST'])
@timeout_handler
@require_json
def voice_navigation():
    """Navegação por comando de voz para deficientes visuais"""
    try:
        logger.info("🗣️ Comando de navegação por voz")
        
        data = request.get_json()
        voice_command = data.get('command', '').strip()
        
        if not voice_command:
            return jsonify({'error': 'Comando de voz é obrigatório'}), 400
        
        # Processar comando de navegação
        navigation_response = g.accessibility_service.navigate_with_voice(voice_command)
        
        return jsonify({
            'navigation_instructions': navigation_response,
            'original_command': voice_command,
            'type': 'voice_navigation',
            'timestamp': datetime.now().isoformat(),
            'status': 'success'
        })
        
    except Exception as e:
        logger.error(f"❌ Erro na navegação por voz: {e}")
        return jsonify({
            'error': 'Erro no sistema de navegação',
            'message': str(e),
            'timestamp': datetime.now().isoformat(),
            'status': 'error'
        }), 500

# ==========================================
# ROTAS PARA SURDO E MUDO
# ==========================================

@accessibility_bp.route('/accessibility/transcription/start', methods=['POST'])
@timeout_handler
def start_transcription():
    """Iniciar transcrição contínua para surdos"""
    try:
        logger.info("🎤 Iniciando transcrição contínua")
        
        result = g.accessibility_service.start_continuous_transcription()
        
        return jsonify({
            'message': result,
            'transcription_active': True,
            'type': 'transcription_control',
            'timestamp': datetime.now().isoformat(),
            'status': 'success'
        })
        
    except Exception as e:
        logger.error(f"❌ Erro ao iniciar transcrição: {e}")
        return jsonify({
            'error': 'Erro ao iniciar transcrição',
            'message': str(e),
            'timestamp': datetime.now().isoformat(),
            'status': 'error'
        }), 500

@accessibility_bp.route('/accessibility/transcription/stop', methods=['POST'])
@timeout_handler
def stop_transcription():
    """Parar transcrição contínua"""
    try:
        logger.info("🛑 Parando transcrição contínua")
        
        g.accessibility_service.stop_continuous_transcription()
        
        return jsonify({
            'message': 'Transcrição parada com sucesso',
            'transcription_active': False,
            'type': 'transcription_control',
            'timestamp': datetime.now().isoformat(),
            'status': 'success'
        })
        
    except Exception as e:
        logger.error(f"❌ Erro ao parar transcrição: {e}")
        return jsonify({
            'error': 'Erro ao parar transcrição',
            'message': str(e),
            'timestamp': datetime.now().isoformat(),
            'status': 'error'
        }), 500

@accessibility_bp.route('/accessibility/transcription/recent', methods=['GET'])
@timeout_handler
def get_recent_transcriptions():
    """Obter transcrições recentes"""
    try:
        logger.info("📝 Obtendo transcrições recentes")
        
        limit = request.args.get('limit', 10, type=int)
        transcriptions = g.accessibility_service.get_recent_transcriptions(limit)
        
        return jsonify({
            'transcriptions': transcriptions,
            'count': len(transcriptions),
            'type': 'transcription_history',
            'timestamp': datetime.now().isoformat(),
            'status': 'success'
        })
        
    except Exception as e:
        logger.error(f"❌ Erro ao obter transcrições: {e}")
        return jsonify({
            'error': 'Erro ao obter transcrições',
            'message': str(e),
            'timestamp': datetime.now().isoformat(),
            'status': 'error'
        }), 500

@accessibility_bp.route('/accessibility/translation/translate', methods=['POST'])
@timeout_handler
@require_json
def translate_text():
    """Traduzir texto em tempo real"""
    try:
        logger.info("🔄 Tradução em tempo real")
        
        data = request.get_json()
        text = data.get('text', '').strip()
        source_lang = data.get('source_language', 'pt-BR')
        target_lang = data.get('target_language', 'crioulo-gb')
        
        if not text:
            return jsonify({'error': 'Texto é obrigatório'}), 400
        
        # Traduzir texto
        translated_text = g.accessibility_service.translate_text(text, source_lang, target_lang)
        
        return jsonify({
            'original_text': text,
            'translated_text': translated_text,
            'source_language': source_lang,
            'target_language': target_lang,
            'type': 'translation',
            'timestamp': datetime.now().isoformat(),
            'status': 'success'
        })
        
    except Exception as e:
        logger.error(f"❌ Erro na tradução: {e}")
        return jsonify({
            'error': 'Erro no sistema de tradução',
            'message': str(e),
            'timestamp': datetime.now().isoformat(),
            'status': 'error'
        }), 500

@accessibility_bp.route('/accessibility/translation/languages', methods=['POST'])
@timeout_handler
@require_json
def set_translation_languages():
    """Configurar idiomas para tradução"""
    try:
        logger.info("🌐 Configurando idiomas de tradução")
        
        data = request.get_json()
        source_lang = data.get('source_language', 'pt-BR')
        target_lang = data.get('target_language', 'crioulo-gb')
        
        # Configurar idiomas
        g.accessibility_service.set_languages(source_lang, target_lang)
        
        return jsonify({
            'message': 'Idiomas configurados com sucesso',
            'source_language': source_lang,
            'target_language': target_lang,
            'type': 'language_config',
            'timestamp': datetime.now().isoformat(),
            'status': 'success'
        })
        
    except Exception as e:
        logger.error(f"❌ Erro ao configurar idiomas: {e}")
        return jsonify({
            'error': 'Erro ao configurar idiomas',
            'message': str(e),
            'timestamp': datetime.now().isoformat(),
            'status': 'error'
        }), 500

# ==========================================
# ROTAS DE CONTROLE E STATUS
# ==========================================

@accessibility_bp.route('/accessibility/status', methods=['GET'])
@timeout_handler
def get_accessibility_status():
    """Status do sistema de acessibilidade"""
    try:
        logger.info("📊 Verificando status de acessibilidade")
        
        status = g.accessibility_service.get_status()
        
        return jsonify({
            'accessibility_status': status,
            'timestamp': datetime.now().isoformat(),
            'status': 'success'
        })
        
    except Exception as e:
        logger.error(f"❌ Erro ao verificar status: {e}")
        return jsonify({
            'error': 'Erro ao verificar status do sistema',
            'message': str(e),
            'timestamp': datetime.now().isoformat(),
            'status': 'error'
        }), 500

@accessibility_bp.route('/accessibility/help', methods=['GET'])
@timeout_handler
def get_accessibility_help():
    """Obter ajuda sobre funcionalidades de acessibilidade"""
    try:
        help_info = {
            'visual_impairment': {
                'features': [
                    'Descrição de ambiente por câmera',
                    'Navegação por comando de voz',
                    'Feedback sonoro em tempo real',
                    'Instruções de navegação detalhadas'
                ],
                'endpoints': [
                    '/accessibility/visual/describe',
                    '/accessibility/navigation/voice'
                ]
            },
            'deaf_mute': {
                'features': [
                    'Transcrição contínua de fala',
                    'Tradução simultânea offline',
                    'Interface visual clara',
                    'Histórico de conversas',
                    'Múltiplos idiomas suportados'
                ],
                'endpoints': [
                    '/accessibility/transcription/start',
                    '/accessibility/transcription/stop',
                    '/accessibility/transcription/recent',
                    '/accessibility/translation/translate',
                    '/accessibility/translation/languages'
                ]
            },
            'supported_languages': [
                'pt-BR (Português Brasileiro)',
                'crioulo-gb (Crioulo da Guiné-Bissau)',
                'en-US (Inglês Americano)'
            ],
            'offline_capabilities': [
                'Processamento de linguagem com Gemma 3n',
                'Reconhecimento de voz local',
                'Tradução sem internet',
                'Descrição visual offline'
            ]
        }
        
        return jsonify({
            'help': help_info,
            'timestamp': datetime.now().isoformat(),
            'status': 'success'
        })
        
    except Exception as e:
        logger.error(f"❌ Erro ao obter ajuda: {e}")
        return jsonify({
            'error': 'Erro ao obter informações de ajuda',
            'message': str(e),
            'timestamp': datetime.now().isoformat(),
            'status': 'error'
        }), 500
