"""
Rotas relacionadas ao meio ambiente e sustentabilidade
"""

from flask import Blueprint, request, jsonify, g
from datetime import datetime
import logging
import random

from utils.decorators import timeout_handler, require_json

logger = logging.getLogger(__name__)

environmental_bp = Blueprint('environmental', __name__)

@environmental_bp.route('/environment/diagnosis', methods=['POST'])
@timeout_handler
@require_json
def environmental_diagnosis():
    """Diagnóstico ambiental e ecológico"""
    try:
        logger.info("🌍 Recebida requisição de diagnóstico ambiental")
        
        data = request.get_json()
        # Aceitar ambos 'prompt' e 'question' para compatibilidade
        prompt = data.get('prompt', data.get('question', '')).strip()
        language = data.get('language', 'pt-BR')
        environment_type = data.get('environment_type', 'geral')
        location = data.get('location', 'brasil')
        
        if not prompt:
            return jsonify({'error': 'Campo prompt é obrigatório'}), 400
        
        # Gerar análise ambiental
        response = g.gemma_service.generate_response(prompt, language, 'environmental')
        
        # Simulação de dados ambientais
        environmental_data = {
            'air_quality': random.choice(['boa', 'moderada', 'sensível']),
            'water_quality': random.choice(['excelente', 'boa', 'aceitável']),
            'soil_health': random.choice(['saudável', 'degradado', 'recuperando']),
            'biodiversity_level': random.choice(['alto', 'médio', 'baixo']),
            'carbon_footprint': random.choice(['baixo', 'moderado', 'alto'])
        }
        
        result = {
            'analysis': response,
            'environmental_data': environmental_data,
            'environment_type': environment_type,
            'location': location,
            'language': language,
            'recommendations': [
                'Implemente práticas de compostagem',
                'Use energia renovável quando possível',
                'Reduza o consumo de plástico descartável',
                'Plante espécies nativas da região'
            ],
            'impact_score': random.randint(60, 90),
            'timestamp': datetime.now().isoformat(),
            'status': 'success'
        }
        
        logger.info("✅ Diagnóstico ambiental gerado")
        return jsonify(result)
        
    except Exception as e:
        logger.error(f"❌ Erro no diagnóstico ambiental: {e}")
        return jsonify({
            'error': 'Erro interno do servidor',
            'message': 'Serviço ambiental temporariamente indisponível',
            'timestamp': datetime.now().isoformat(),
            'status': 'error'
        }), 500

@environmental_bp.route('/environment/recommendations', methods=['POST'])
@timeout_handler
@require_json
def environmental_recommendations():
    """Recomendações ambientais personalizadas"""
    try:
        logger.info("♻️ Recebida requisição de recomendações ambientais")
        
        data = request.get_json()
        user_profile = data.get('user_profile', {})
        focus_area = data.get('focus_area', 'geral')
        language = data.get('language', 'pt-BR')
        
        # Gerar recomendações baseadas no perfil
        prompt = f"Dê recomendações ambientais para {focus_area} considerando o perfil: {user_profile}"
        response = g.gemma_service.generate_response(prompt, language, 'environmental')
        
        # Recomendações categorizadas
        recommendations_by_category = {
            'energia': [
                'Use lâmpadas LED',
                'Desligue aparelhos da tomada',
                'Aproveite luz natural'
            ],
            'agua': [
                'Colete água da chuva',
                'Repare vazamentos rapidamente',
                'Use torneiras com temporizador'
            ],
            'residuos': [
                'Separe lixo reciclável',
                'Composte restos orgânicos',
                'Evite embalagens desnecessárias'
            ],
            'transporte': [
                'Use transporte público',
                'Prefira bicicleta para distâncias curtas',
                'Compartilhe caronas'
            ]
        }
        
        result = {
            'personalized_advice': response,
            'focus_area': focus_area,
            'recommendations_by_category': recommendations_by_category,
            'quick_actions': [
                'Plante uma árvore hoje',
                'Reduza banhos em 2 minutos',
                'Use sacola reutilizável'
            ],
            'environmental_impact': {
                'co2_reduction': f"{random.randint(5, 20)}kg/mês",
                'water_savings': f"{random.randint(100, 500)}L/mês",
                'waste_reduction': f"{random.randint(2, 10)}kg/mês"
            },
            'timestamp': datetime.now().isoformat(),
            'status': 'success'
        }
        
        logger.info("✅ Recomendações ambientais geradas")
        return jsonify(result)
        
    except Exception as e:
        logger.error(f"❌ Erro nas recomendações ambientais: {e}")
        return jsonify({
            'error': 'Erro interno do servidor',
            'message': 'Serviço de recomendações ambientais temporariamente indisponível',
            'timestamp': datetime.now().isoformat(),
            'status': 'error'
        }), 500

@environmental_bp.route('/plant/audio-diagnosis', methods=['POST'])
@timeout_handler
@require_json
def plant_audio_diagnosis():
    """Diagnóstico de plantas via áudio (preparado para IA multimodal)"""
    try:
        logger.info("🔊 Recebida requisição de diagnóstico de planta por áudio")
        
        data = request.get_json()
        audio_data = data.get('audio_data')
        plant_type = data.get('plant_type', 'desconhecida')
        user_id = data.get('user_id')
        
        if not audio_data:
            return jsonify({'error': 'Campo audio_data é obrigatório'}), 400
        
        # Simulação de diagnóstico (preparado para IA real)
        diagnosis = {
            'plant_type': plant_type,
            'disease_detected': random.choice(['Míldio', 'Ferrugem', 'Podridão', 'Saudável']),
            'confidence': round(random.uniform(0.7, 0.95), 2),
            'recommendation': 'Isolar planta, aplicar tratamento específico e monitorar evolução.',
            'audio_quality': random.choice(['excelente', 'boa', 'regular']),
            'treatment_steps': [
                'Remover partes afetadas',
                'Aplicar fungicida natural',
                'Melhorar ventilação',
                'Monitorar por 7 dias'
            ],
            'prevention_tips': [
                'Evitar excesso de água',
                'Manter boa circulação de ar',
                'Inspecionar regularmente'
            ],
            'status': 'simulated',
            'timestamp': datetime.now().isoformat(),
            'user_id': user_id
        }
        
        logger.info(f"✅ Diagnóstico por áudio simulado: {diagnosis['disease_detected']}")
        return jsonify(diagnosis)
        
    except Exception as e:
        logger.error(f"❌ Erro no diagnóstico por áudio: {e}")
        return jsonify({
            'error': 'Erro no processamento de áudio',
            'message': 'Serviço de diagnóstico por áudio temporariamente indisponível',
            'timestamp': datetime.now().isoformat(),
            'status': 'error'
        }), 500
