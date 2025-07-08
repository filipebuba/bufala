"""
Rotas relacionadas a bem-estar e wellness coaching
"""

from flask import Blueprint, request, jsonify, g
from datetime import datetime
import logging

from utils.decorators import timeout_handler, require_json

logger = logging.getLogger(__name__)

wellness_bp = Blueprint('wellness', __name__)

@wellness_bp.route('/wellness/coaching', methods=['POST'])
@timeout_handler
@require_json
def wellness_coaching():
    """Serviço de coaching de bem-estar"""
    try:
        logger.info("🧘 Recebida requisição de wellness coaching")
        
        data = request.get_json()
        # Aceitar ambos 'prompt' e 'question' para compatibilidade
        prompt = data.get('prompt', data.get('question', '')).strip()
        language = data.get('language', 'pt-BR')
        session_type = data.get('session_type', 'general')
        user_data = data.get('user_data', {})
        
        if not prompt:
            return jsonify({'error': 'Campo prompt ou question é obrigatório'}), 400
        
        # Gerar resposta de coaching
        coaching_response = g.gemma_service.generate_response(prompt, language, 'wellness')
        
        # Gerar recomendações adicionais
        fallback_gen = g.gemma_service.fallback_generator
        recommendations = fallback_gen.generate_wellness_recommendations(session_type, user_data)
        progress_score = fallback_gen.calculate_progress_score(user_data)
        
        result = {
            'response': coaching_response,
            'session_type': session_type,
            'recommendations': recommendations,
            'progress_score': progress_score,
            'wellness_tips': [
                'Pratique gratidão diariamente',
                'Mantenha conexões sociais saudáveis',
                'Reserve tempo para relaxamento'
            ],
            'language': language,
            'timestamp': datetime.now().isoformat(),
            'status': 'success'
        }
        
        logger.info("✅ Coaching de wellness gerado com sucesso")
        return jsonify(result)
        
    except Exception as e:
        logger.error(f"❌ Erro no wellness coaching: {e}")
        return jsonify({
            'error': 'Erro interno do servidor',
            'message': 'Serviço de wellness coaching temporariamente indisponível',
            'fallback_advice': 'Pratique respiração profunda e procure ajuda se necessário',
            'timestamp': datetime.now().isoformat(),
            'status': 'error'
        }), 500

@wellness_bp.route('/wellness/voice-analysis', methods=['POST'])
@timeout_handler
@require_json
def voice_analysis():
    """Análise de voz para bem-estar"""
    try:
        logger.info("🎤 Recebida requisição de análise vocal")
        
        data = request.get_json()
        voice_data = data.get('voice_data', {})
        language = data.get('language', 'pt-BR')
        
        # Análise simulada (preparado para IA real)
        fallback_gen = g.gemma_service.fallback_generator
        voice_analysis_result = fallback_gen.generate_voice_analysis_fallback()
        
        # Gerar recomendações baseadas na análise
        recommendations = []
        if voice_analysis_result.get('stress_level') == 'moderado':
            recommendations.extend([
                'Pratique técnicas de respiração',
                'Faça pausas regulares durante o dia',
                'Considere atividades relaxantes'
            ])
        
        result = {
            'analysis': voice_analysis_result,
            'recommendations': recommendations,
            'insights': [
                'Sua voz reflete seu estado emocional',
                'Mudanças graduais são mais sustentáveis',
                'O autocuidado é fundamental'
            ],
            'timestamp': datetime.now().isoformat(),
            'status': 'success'
        }
        
        logger.info("✅ Análise vocal concluída")
        return jsonify(result)
        
    except Exception as e:
        logger.error(f"❌ Erro na análise vocal: {e}")
        return jsonify({'error': 'Erro interno do servidor'}), 500

@wellness_bp.route('/wellness/daily-metrics', methods=['POST'])
@timeout_handler
@require_json
def daily_metrics():
    """Análise de métricas diárias de bem-estar"""
    try:
        logger.info("📊 Recebida requisição de métricas diárias")
        
        data = request.get_json()
        metrics = data.get('metrics', {})
        language = data.get('language', 'pt-BR')
        
        # Análise das métricas
        fallback_gen = g.gemma_service.fallback_generator
        wellness_analysis = fallback_gen.generate_metrics_analysis_fallback(metrics)
        
        # Calcular tendências simuladas
        trends = {
            'mood_trend': 'estável',
            'energy_trend': 'melhorando',
            'stress_trend': 'diminuindo',
            'overall_trend': 'positivo'
        }
        
        # Gerar recomendações personalizadas
        recommendations = [
            'Continue mantendo sua rotina atual',
            'Adicione 10 minutos de atividade física',
            'Pratique mindfulness antes de dormir'
        ]
        
        result = {
            'wellness_analysis': wellness_analysis,
            'trends': trends,
            'recommendations': recommendations,
            'weekly_summary': {
                'best_day': 'Terça-feira',
                'improvement_area': 'Qualidade do sono',
                'strength': 'Consistência nos exercícios'
            },
            'timestamp': datetime.now().isoformat(),
            'status': 'success'
        }
        
        logger.info("✅ Métricas diárias analisadas")
        return jsonify(result)
        
    except Exception as e:
        logger.error(f"❌ Erro nas métricas diárias: {e}")
        return jsonify({'error': 'Erro interno do servidor'}), 500
