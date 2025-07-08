"""
Rotas relacionadas a orientações médicas
"""

from flask import Blueprint, request, jsonify, g
from datetime import datetime
import logging

from utils.decorators import timeout_handler, with_metrics

logger = logging.getLogger(__name__)

medical_bp = Blueprint('medical', __name__)

@medical_bp.route('/medical', methods=['POST'])
@timeout_handler
@with_metrics('medical')
def medical_guidance():
    """Fornecer orientações médicas gerais"""
    try:
        logger.info("🏥 Recebida requisição médica")
        
        # Validar request
        if not request.is_json:
            return jsonify({'error': 'Content-Type deve ser application/json'}), 400
        
        data = request.get_json()
        # Aceitar ambos 'prompt' e 'question' para compatibilidade
        prompt = data.get('prompt', data.get('question', '')).strip()
        language = data.get('language', 'pt-BR')
        
        if not prompt:
            return jsonify({'error': 'Campo prompt ou question é obrigatório'}), 400
        
        # Gerar resposta médica
        response = g.gemma_service.generate_response(prompt, language, 'medical')
        
        result = {
            'response': response,
            'type': 'medical_guidance',
            'language': language,
            'disclaimer': 'Esta é uma orientação geral. Sempre consulte um profissional de saúde.',
            'timestamp': datetime.now().isoformat(),
            'status': 'success'
        }
        
        logger.info("✅ Orientação médica gerada com sucesso")
        return jsonify(result)
        
    except Exception as e:
        logger.error(f"❌ Erro na orientação médica: {e}")
        return jsonify({
            'error': 'Erro interno do servidor',
            'message': 'Serviço médico temporariamente indisponível',
            'timestamp': datetime.now().isoformat(),
            'status': 'error'
        }), 500
