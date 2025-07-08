"""
Rotas relacionadas à agricultura
"""

from flask import Blueprint, request, jsonify, g
from datetime import datetime
import logging

from utils.decorators import timeout_handler, require_json

logger = logging.getLogger(__name__)

agriculture_bp = Blueprint('agriculture', __name__)

@agriculture_bp.route('/agriculture', methods=['POST'])
@timeout_handler
@require_json
def agricultural_guidance():
    """Fornecer orientações agrícolas"""
    try:
        logger.info("🌱 Recebida requisição agrícola")
        
        data = request.get_json()
        # Aceitar ambos 'prompt' e 'question' para compatibilidade
        prompt = data.get('prompt', data.get('question', '')).strip()
        language = data.get('language', 'pt-BR')
        crop_type = data.get('crop_type', 'geral')
        region = data.get('region', 'brasil')
        
        if not prompt:
            return jsonify({'error': 'Campo prompt ou question é obrigatório'}), 400
        
        # Gerar resposta agrícola usando o DocsGemmaService
        response = g.gemma_service.generate_response(prompt, language, 'agriculture')
        
        result = {
            'answer': response,  # Mudando de 'response' para 'answer' para compatibilidade
            'response': response,  # Mantendo ambos para compatibilidade
            'type': 'agricultural_guidance',
            'crop_type': crop_type,
            'region': region,
            'language': language,
            'farming_tips': [
                'Monitore a umidade do solo regularmente',
                'Use práticas de agricultura sustentável',
                'Faça rotação de culturas quando possível'
            ],
            'timestamp': datetime.now().isoformat(),
            'status': 'success'
        }
        
        logger.info("✅ Orientação agrícola gerada")
        return jsonify(result)
        
    except Exception as e:
        logger.error(f"❌ Erro na orientação agrícola: {e}")
        return jsonify({
            'error': 'Erro interno do servidor',
            'message': 'Serviço agrícola temporariamente indisponível',
            'timestamp': datetime.now().isoformat(),
            'status': 'error'
        }), 500
