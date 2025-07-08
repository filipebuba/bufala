"""
Rotas relacionadas à tradução
"""

from flask import Blueprint, request, jsonify, g
from datetime import datetime
import logging

from utils.decorators import timeout_handler, require_json

logger = logging.getLogger(__name__)

translation_bp = Blueprint('translation', __name__)

@translation_bp.route('/translate', methods=['POST'])
@timeout_handler
@require_json
def translate_text():
    """Traduzir texto entre idiomas"""
    try:
        logger.info("🌐 Recebida requisição de tradução")
        
        data = request.get_json()
        text = data.get('text', '').strip()
        source_language = data.get('source_language', 'auto')
        target_language = data.get('target_language', 'pt-BR')
        
        if not text:
            return jsonify({'error': 'Campo text é obrigatório'}), 400
        
        # Formatação específica para tradução
        translate_prompt = f"Traduza o seguinte texto de {source_language} para {target_language}: {text}"
        
        # Gerar tradução
        response = g.gemma_service.generate_response(translate_prompt, target_language, 'translate')
        
        result = {
            'translated_text': response,
            'source_language': source_language,
            'target_language': target_language,
            'original_text': text,
            'confidence': 0.85,  # Simulado
            'timestamp': datetime.now().isoformat(),
            'status': 'success'
        }
        
        logger.info("✅ Tradução gerada")
        return jsonify(result)
        
    except Exception as e:
        logger.error(f"❌ Erro na tradução: {e}")
        return jsonify({
            'error': 'Erro interno do servidor',
            'message': 'Serviço de tradução temporariamente indisponível',
            'timestamp': datetime.now().isoformat(),
            'status': 'error'
        }), 500
