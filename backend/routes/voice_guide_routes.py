"""Rotas para VoiceGuide AI - Sistema de Navegação Assistiva
Integração completa com Flutter para acessibilidade
"""

from flask import Blueprint, request, jsonify, current_app
import logging
import base64
from PIL import Image
import io
from datetime import datetime

logger = logging.getLogger(__name__)

# Criar blueprint para rotas do VoiceGuide
voice_guide_bp = Blueprint('voice_guide', __name__, url_prefix='/voice-guide')

@voice_guide_bp.route('/health', methods=['GET'])
def health_check():
    """Verificação de saúde do VoiceGuide Service"""
    try:
        voice_guide_service = current_app.voice_guide_service
        status = voice_guide_service.get_status()
        
        return jsonify({
            'success': True,
            'service': 'VoiceGuide AI',
            'status': 'healthy',
            'data': status,
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Erro no health check: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'service': 'VoiceGuide AI',
            'status': 'unhealthy',
            'timestamp': datetime.now().isoformat()
        }), 500

@voice_guide_bp.route('/analyze-environment', methods=['POST'])
def analyze_environment():
    """Analisa ambiente para navegação assistiva"""
    try:
        voice_guide_service = current_app.voice_guide_service
        data = request.get_json() or {}
        
        # Extrair parâmetros
        image_data = data.get('image_data')  # Base64
        context = data.get('context', '')
        
        logger.info(f"🔍 Analisando ambiente - Contexto: {context[:50]}...")
        
        # Realizar análise
        analysis_result = voice_guide_service.analyze_environment(
            image_data=image_data,
            context=context
        )
        
        return jsonify({
            'success': True,
            'data': analysis_result,
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Erro na análise do ambiente: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'message': 'Erro ao analisar ambiente',
            'timestamp': datetime.now().isoformat()
        }), 500

@voice_guide_bp.route('/navigation-instructions', methods=['POST'])
def generate_navigation_instructions():
    """Gera instruções de navegação personalizadas"""
    try:
        voice_guide_service = current_app.voice_guide_service
        data = request.get_json() or {}
        
        # Validar parâmetros obrigatórios
        destination = data.get('destination')
        if not destination:
            return jsonify({
                'success': False,
                'error': 'Destino é obrigatório',
                'timestamp': datetime.now().isoformat()
            }), 400
        
        current_analysis = data.get('current_analysis', '')
        
        logger.info(f"🧭 Gerando instruções para: {destination}")
        
        # Gerar instruções
        instructions_result = voice_guide_service.generate_navigation_instructions(
            destination=destination,
            current_analysis=current_analysis
        )
        
        return jsonify({
            'success': True,
            'data': instructions_result,
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Erro ao gerar instruções: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'message': 'Erro ao gerar instruções de navegação',
            'timestamp': datetime.now().isoformat()
        }), 500

@voice_guide_bp.route('/voice-command', methods=['POST'])
def process_voice_command():
    """Processa comando de voz para navegação"""
    try:
        voice_guide_service = current_app.voice_guide_service
        data = request.get_json() or {}
        
        # Validar comando
        command = data.get('command')
        if not command:
            return jsonify({
                'success': False,
                'error': 'Comando de voz é obrigatório',
                'timestamp': datetime.now().isoformat()
            }), 400
        
        logger.info(f"🗣️ Processando comando: {command[:50]}...")
        
        # Processar comando
        command_result = voice_guide_service.process_voice_command(command)
        
        return jsonify({
            'success': True,
            'data': command_result,
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Erro ao processar comando: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'message': 'Erro ao processar comando de voz',
            'timestamp': datetime.now().isoformat()
        }), 500

@voice_guide_bp.route('/emergency/activate', methods=['POST'])
def activate_emergency_mode():
    """Ativa modo de emergência"""
    try:
        voice_guide_service = current_app.voice_guide_service
        data = request.get_json() or {}
        
        context = data.get('context', 'Emergência ativada via aplicativo')
        
        logger.warning(f"🚨 EMERGÊNCIA ATIVADA: {context}")
        
        # Ativar modo emergência
        emergency_result = voice_guide_service.activate_emergency_mode(context)
        
        return jsonify({
            'success': True,
            'data': emergency_result,
            'priority': 'URGENT',
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Erro ao ativar emergência: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'message': 'Erro ao ativar modo emergência',
            'priority': 'URGENT',
            'timestamp': datetime.now().isoformat()
        }), 500

@voice_guide_bp.route('/emergency/deactivate', methods=['POST'])
def deactivate_emergency_mode():
    """Desativa modo de emergência"""
    try:
        voice_guide_service = current_app.voice_guide_service
        
        logger.info("✅ Desativando modo emergência")
        
        # Desativar modo emergência
        result = voice_guide_service.deactivate_emergency_mode()
        
        return jsonify({
            'success': True,
            'data': result,
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Erro ao desativar emergência: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'message': 'Erro ao desativar modo emergência',
            'timestamp': datetime.now().isoformat()
        }), 500

@voice_guide_bp.route('/settings/language', methods=['POST'])
def set_language():
    """Define idioma do sistema"""
    try:
        voice_guide_service = current_app.voice_guide_service
        data = request.get_json() or {}
        
        # Validar idioma
        language_code = data.get('language_code')
        if not language_code:
            return jsonify({
                'success': False,
                'error': 'Código do idioma é obrigatório',
                'timestamp': datetime.now().isoformat()
            }), 400
        
        logger.info(f"🌐 Alterando idioma para: {language_code}")
        
        # Definir idioma
        result = voice_guide_service.set_language(language_code)
        
        return jsonify({
            'success': True,
            'data': result,
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Erro ao definir idioma: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'message': 'Erro ao definir idioma',
            'timestamp': datetime.now().isoformat()
        }), 500

@voice_guide_bp.route('/settings/languages', methods=['GET'])
def get_supported_languages():
    """Retorna idiomas suportados"""
    try:
        voice_guide_service = current_app.voice_guide_service
        
        return jsonify({
            'success': True,
            'data': {
                'supported_languages': voice_guide_service.supported_languages,
                'current_language': voice_guide_service.current_language
            },
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Erro ao obter idiomas: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'message': 'Erro ao obter idiomas suportados',
            'timestamp': datetime.now().isoformat()
        }), 500

@voice_guide_bp.route('/history', methods=['GET'])
def get_navigation_history():
    """Retorna histórico de navegação"""
    try:
        voice_guide_service = current_app.voice_guide_service
        
        # Parâmetros opcionais
        limit = request.args.get('limit', 10, type=int)
        limit = min(max(1, limit), 50)  # Entre 1 e 50
        
        history = voice_guide_service.get_navigation_history(limit)
        
        return jsonify({
            'success': True,
            'data': {
                'history': history,
                'count': len(history),
                'limit': limit
            },
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Erro ao obter histórico: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'message': 'Erro ao obter histórico de navegação',
            'timestamp': datetime.now().isoformat()
        }), 500

@voice_guide_bp.route('/status', methods=['GET'])
def get_status():
    """Retorna status completo do sistema"""
    try:
        voice_guide_service = current_app.voice_guide_service
        status = voice_guide_service.get_status()
        
        return jsonify({
            'success': True,
            'data': status,
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Erro ao obter status: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'message': 'Erro ao obter status do sistema',
            'timestamp': datetime.now().isoformat()
        }), 500

# Rota combinada para análise rápida (ambiente + instruções)
@voice_guide_bp.route('/quick-navigation', methods=['POST'])
def quick_navigation():
    """Análise rápida do ambiente + instruções de navegação"""
    try:
        voice_guide_service = current_app.voice_guide_service
        data = request.get_json() or {}
        
        # Validar destino
        destination = data.get('destination')
        if not destination:
            return jsonify({
                'success': False,
                'error': 'Destino é obrigatório',
                'timestamp': datetime.now().isoformat()
            }), 400
        
        image_data = data.get('image_data')
        context = data.get('context', f'Navegação rápida para {destination}')
        
        logger.info(f"⚡ Navegação rápida para: {destination}")
        
        # 1. Analisar ambiente
        analysis_result = voice_guide_service.analyze_environment(
            image_data=image_data,
            context=context
        )
        
        # 2. Gerar instruções baseadas na análise
        instructions_result = voice_guide_service.generate_navigation_instructions(
            destination=destination,
            current_analysis=analysis_result['analysis']
        )
        
        # Combinar resultados
        combined_result = {
            'environment_analysis': analysis_result,
            'navigation_instructions': instructions_result,
            'quick_summary': {
                'destination': destination,
                'emergency_detected': analysis_result.get('emergency_detected', False),
                'step_count': len(instructions_result.get('steps', [])),
                'estimated_time': instructions_result.get('estimated_time', 'N/A'),
                'safety_alerts': instructions_result.get('safety_alerts', [])
            }
        }
        
        return jsonify({
            'success': True,
            'data': combined_result,
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Erro na navegação rápida: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'message': 'Erro na navegação rápida',
            'timestamp': datetime.now().isoformat()
        }), 500

# Tratamento de erros específicos do blueprint
@voice_guide_bp.errorhandler(404)
def not_found(error):
    return jsonify({
        'success': False,
        'error': 'Endpoint não encontrado',
        'message': 'Verifique a URL e tente novamente',
        'timestamp': datetime.now().isoformat()
    }), 404

@voice_guide_bp.errorhandler(405)
def method_not_allowed(error):
    return jsonify({
        'success': False,
        'error': 'Método não permitido',
        'message': 'Verifique o método HTTP usado',
        'timestamp': datetime.now().isoformat()
    }), 405

@voice_guide_bp.errorhandler(500)
def internal_error(error):
    return jsonify({
        'success': False,
        'error': 'Erro interno do servidor',
        'message': 'Erro inesperado no VoiceGuide Service',
        'timestamp': datetime.now().isoformat()
    }), 500