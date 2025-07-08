"""
Rotas relacionadas à educação
"""

from flask import Blueprint, request, jsonify, g
from datetime import datetime
import logging

from utils.decorators import timeout_handler, require_json, with_metrics

logger = logging.getLogger(__name__)

education_bp = Blueprint('education', __name__)

@education_bp.route('/education', methods=['POST'])
@timeout_handler
@require_json
@with_metrics('education')
def educational_guidance():
    """Fornecer orientações educacionais"""
    try:
        logger.info("📚 Recebida requisição educacional")
        
        data = request.get_json()
        # Aceitar ambos 'prompt' e 'question' para compatibilidade
        prompt = data.get('prompt', data.get('question', '')).strip()
        language = data.get('language', 'pt-BR')
        subject = data.get('subject', 'geral')
        level = data.get('level', 'intermediario')
        
        if not prompt:
            return jsonify({'error': 'Campo prompt ou question é obrigatório'}), 400
        
        # Gerar resposta educacional
        response = g.gemma_service.generate_response(prompt, language, 'education')
        
        result = {
            'response': response,
            'type': 'educational_guidance',
            'subject': subject,
            'level': level,
            'language': language,
            'study_tips': [
                'Faça pausas regulares durante os estudos',
                'Use técnicas de repetição espaçada',
                'Pratique com exercícios variados'
            ],
            'timestamp': datetime.now().isoformat(),
            'status': 'success'
        }
        
        logger.info("✅ Orientação educacional gerada")
        return jsonify(result)
        
    except Exception as e:
        logger.error(f"❌ Erro na orientação educacional: {e}")
        return jsonify({
            'error': 'Erro interno do servidor',
            'message': 'Serviço educacional temporariamente indisponível',
            'timestamp': datetime.now().isoformat(),
            'status': 'error'
        }), 500
