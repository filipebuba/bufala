"""
Rotas relacionadas à saúde geral (health check)
"""

from flask import Blueprint, jsonify, g
from datetime import datetime
import logging

from utils.performance_metrics import get_metrics

logger = logging.getLogger(__name__)

health_bp = Blueprint('health', __name__)

@health_bp.route('/health', methods=['GET', 'OPTIONS'])
def health_check():
    """Verificar saúde do sistema"""
    try:
        logger.info("🏥 Health check solicitado")
        
        # Obter status do serviço Gemma
        gemma_status = g.gemma_service.get_status() if hasattr(g, 'gemma_service') else None
        
        health_data = {
            'status': 'healthy',
            'timestamp': datetime.now().isoformat(),
            'service': 'Bu Fala Backend Modularizado',
            'version': '2.0.0',
            'gemma_service': gemma_status,
            'features': {
                'pipeline_api': gemma_status.get('loading_method') == 'pipeline' if gemma_status else False,
                'chat_templates': gemma_status.get('loading_method') == 'chat_template' if gemma_status else False,
                'traditional_optimized': gemma_status.get('loading_method') == 'traditional' if gemma_status else False,
                'context_validation': True,
                'production_optimizations': gemma_status.get('optimizations_enabled') if gemma_status else False
            },
            'endpoints': [
                '/health',
                '/medical',
                '/education', 
                '/agriculture',
                '/wellness/coaching',
                '/wellness/voice-analysis',
                '/wellness/daily-metrics',
                '/translate',
                '/environment/diagnosis',
                '/environment/recommendations',
                '/multimodal/image/analyze',
                '/multimodal/image/medical',
                '/multimodal/audio/transcribe',
                '/multimodal/capabilities',
                '/multimodal/test/image',
                '/multimodal/batch/analyze'
            ]
        }
        
        logger.info("✅ Health check concluído com sucesso")
        return jsonify(health_data)
        
    except Exception as e:
        logger.error(f"❌ Erro no health check: {e}")
        return jsonify({
            'status': 'unhealthy',
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

@health_bp.route('/metrics', methods=['GET'])
def get_performance_metrics():
    """Obter métricas de performance detalhadas"""
    try:
        logger.info("📊 Requisição de métricas de performance")
        
        metrics = get_metrics()
        performance_report = metrics.get_performance_report()
        
        return jsonify({
            'success': True,
            'metrics': performance_report,
            'collected_at': datetime.now().isoformat()
        })
        
    except Exception as e:
        logger.error(f"❌ Erro ao obter métricas: {e}")
        return jsonify({
            'success': False,
            'error': 'Erro ao coletar métricas de performance',
            'message': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

@health_bp.route('/metrics/reset', methods=['POST'])
def reset_performance_metrics():
    """Resetar métricas de performance"""
    try:
        logger.info("🔄 Resetando métricas de performance")
        
        metrics = get_metrics()
        metrics.reset_metrics()
        
        return jsonify({
            'success': True,
            'message': 'Métricas resetadas com sucesso',
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        logger.error(f"❌ Erro ao resetar métricas: {e}")
        return jsonify({
            'success': False,
            'error': 'Erro ao resetar métricas',
            'message': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500
