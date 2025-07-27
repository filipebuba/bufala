from flask import Blueprint, request, jsonify
from services.model_selector import ModelSelector
from services.gemma_service import GemmaService
from config.settings import BackendConfig
import logging
from typing import Dict, Any

logger = logging.getLogger(__name__)

# Criar blueprint para gerenciamento de modelos
model_management_bp = Blueprint('model_management', __name__, url_prefix='/api/models')

# Cache global para instâncias de serviços
_service_cache = {}

@model_management_bp.route('/status', methods=['GET'])
def get_models_status():
    """Obter status de todos os modelos disponíveis"""
    try:
        # Obter configuração automática do sistema
        system_config = ModelSelector.auto_configure_for_system()
        
        # Verificar disponibilidade dos modelos
        model_status = {}
        for model in ModelSelector.FOURBIT_MODELS:
            model_info = ModelSelector.get_model_info(model)
            model_status[model] = {
                'available': True,  # Assumir disponível (seria verificado em produção)
                'ram_requirement_gb': model_info.get('ram_requirement_gb', 0),
                'is_quantized': model_info.get('is_quantized', False),
                'is_instruct': model_info.get('is_instruct', False),
                'config': model_info.get('config', {})
            }
        
        return jsonify({
            'success': True,
            'system_resources': system_config['system_resources'],
            'selected_model': system_config['selected_model'],
            'fallback_models': system_config['fallback_models'],
            'available_models': model_status,
            'quantization_settings': system_config['quantization_settings']
        })
        
    except Exception as e:
        logger.error(f"Erro ao obter status dos modelos: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@model_management_bp.route('/select', methods=['POST'])
def select_model():
    """Selecionar modelo baseado em critérios específicos"""
    try:
        data = request.get_json() or {}
        
        domain = data.get('domain', 'general')
        task_complexity = data.get('task_complexity', 'medium')
        prefer_accuracy = data.get('prefer_accuracy', True)
        force_model = data.get('force_model')
        
        if force_model:
            if not ModelSelector.validate_model_availability(force_model):
                return jsonify({
                    'success': False,
                    'error': f'Modelo {force_model} não está disponível'
                }), 400
            
            selected_model = force_model
            model_config = ModelSelector.get_model_info(force_model).get('config', {})
        else:
            if domain != 'general':
                selected_model, model_config = ModelSelector.get_model_for_domain(domain)
            else:
                selected_model, model_config = ModelSelector.select_optimal_model(
                    task_complexity=task_complexity,
                    prefer_accuracy=prefer_accuracy
                )
        
        return jsonify({
            'success': True,
            'selected_model': selected_model,
            'model_config': model_config,
            'selection_criteria': {
                'domain': domain,
                'task_complexity': task_complexity,
                'prefer_accuracy': prefer_accuracy,
                'forced': bool(force_model)
            }
        })
        
    except Exception as e:
        logger.error(f"Erro ao selecionar modelo: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@model_management_bp.route('/load', methods=['POST'])
def load_model():
    """Carregar um modelo específico"""
    try:
        data = request.get_json() or {}
        
        model_name = data.get('model_name')
        domain = data.get('domain', 'general')
        
        if not model_name:
            return jsonify({
                'success': False,
                'error': 'Nome do modelo é obrigatório'
            }), 400
        
        if not ModelSelector.validate_model_availability(model_name):
            return jsonify({
                'success': False,
                'error': f'Modelo {model_name} não está disponível'
            }), 400
        
        # Criar nova instância do serviço com o modelo específico
        service_key = f"{model_name}_{domain}"
        
        try:
            service = GemmaService(domain=domain, force_model=model_name)
            _service_cache[service_key] = service
            
            return jsonify({
                'success': True,
                'message': f'Modelo {model_name} carregado com sucesso',
                'model_info': {
                    'name': service.model_name,
                    'domain': domain,
                    'loaded': service.model_loaded,
                    'config': service.model_config
                },
                'service_key': service_key
            })
            
        except Exception as load_error:
            logger.error(f"Erro ao carregar modelo {model_name}: {load_error}")
            return jsonify({
                'success': False,
                'error': f'Falha ao carregar modelo: {str(load_error)}'
            }), 500
        
    except Exception as e:
        logger.error(f"Erro no endpoint de carregamento: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@model_management_bp.route('/test', methods=['POST'])
def test_model():
    """Testar um modelo com prompt de exemplo"""
    try:
        data = request.get_json() or {}
        
        model_name = data.get('model_name')
        domain = data.get('domain', 'general')
        test_prompt = data.get('prompt', 'Olá, como você pode ajudar?')
        
        if not model_name:
            return jsonify({
                'success': False,
                'error': 'Nome do modelo é obrigatório'
            }), 400
        
        # Usar serviço em cache ou criar novo
        service_key = f"{model_name}_{domain}"
        
        if service_key in _service_cache:
            service = _service_cache[service_key]
        else:
            service = GemmaService(domain=domain, force_model=model_name)
            _service_cache[service_key] = service
        
        # Testar geração
        start_time = time.time()
        result = service.generate_response(test_prompt, domain)
        end_time = time.time()
        
        return jsonify({
            'success': True,
            'test_result': {
                'prompt': test_prompt,
                'response': result.get('response', ''),
                'generation_time': end_time - start_time,
                'model_info': result.get('model_info', {}),
                'metadata': result.get('metadata', {})
            }
        })
        
    except Exception as e:
        logger.error(f"Erro ao testar modelo: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@model_management_bp.route('/optimize', methods=['POST'])
def optimize_for_system():
    """Otimizar configuração de modelos para o sistema atual"""
    try:
        data = request.get_json() or {}
        
        target_domains = data.get('domains', ['general', 'medical', 'education', 'agriculture'])
        max_models = data.get('max_models', 3)
        
        # Obter recursos do sistema
        resources = ModelSelector.get_system_resources()
        
        # Selecionar modelos otimizados para cada domínio
        optimized_config = {}
        selected_models = set()
        
        for domain in target_domains:
            model, config = ModelSelector.get_model_for_domain(domain)
            
            # Verificar se o modelo cabe nos recursos disponíveis
            ram_required = ModelSelector.MODEL_RAM_REQUIREMENTS.get(model, 8.0)
            
            if ram_required <= resources.available_ram_gb and len(selected_models) < max_models:
                optimized_config[domain] = {
                    'model': model,
                    'config': config,
                    'ram_requirement': ram_required
                }
                selected_models.add(model)
            else:
                # Buscar alternativa menor
                for fallback_model in ModelSelector.get_fallback_chain():
                    fallback_ram = ModelSelector.MODEL_RAM_REQUIREMENTS.get(fallback_model, 8.0)
                    if fallback_ram <= resources.available_ram_gb and fallback_model not in selected_models:
                        optimized_config[domain] = {
                            'model': fallback_model,
                            'config': ModelSelector.get_model_info(fallback_model).get('config', {}),
                            'ram_requirement': fallback_ram,
                            'is_fallback': True
                        }
                        selected_models.add(fallback_model)
                        break
        
        return jsonify({
            'success': True,
            'system_resources': {
                'total_ram_gb': resources.total_ram_gb,
                'available_ram_gb': resources.available_ram_gb,
                'gpu_memory_gb': resources.gpu_memory_gb,
                'has_cuda': resources.has_cuda
            },
            'optimized_config': optimized_config,
            'total_models': len(selected_models),
            'estimated_ram_usage': sum(
                config['ram_requirement'] for config in optimized_config.values()
            )
        })
        
    except Exception as e:
        logger.error(f"Erro ao otimizar configuração: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@model_management_bp.route('/cache/clear', methods=['POST'])
def clear_model_cache():
    """Limpar cache de modelos carregados"""
    try:
        global _service_cache
        
        # Limpar cache
        cleared_count = len(_service_cache)
        _service_cache.clear()
        
        return jsonify({
            'success': True,
            'message': f'Cache limpo. {cleared_count} serviços removidos.'
        })
        
    except Exception as e:
        logger.error(f"Erro ao limpar cache: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@model_management_bp.route('/health', methods=['GET'])
def health_check():
    """Verificação de saúde do sistema de modelos"""
    try:
        import time
        
        # Verificar recursos do sistema
        resources = ModelSelector.get_system_resources()
        
        # Verificar modelos em cache
        cached_models = list(_service_cache.keys())
        
        # Status geral
        health_status = {
            'status': 'healthy',
            'timestamp': time.time(),
            'system_resources': {
                'ram_usage_percent': ((resources.total_ram_gb - resources.available_ram_gb) / resources.total_ram_gb) * 100,
                'available_ram_gb': resources.available_ram_gb,
                'has_cuda': resources.has_cuda,
                'gpu_memory_gb': resources.gpu_memory_gb
            },
            'cached_models': cached_models,
            'total_available_models': len(ModelSelector.FOURBIT_MODELS)
        }
        
        # Verificar se há problemas
        if resources.available_ram_gb < 2.0:
            health_status['status'] = 'warning'
            health_status['warnings'] = ['RAM disponível baixa']
        
        return jsonify({
            'success': True,
            'health': health_status
        })
        
    except Exception as e:
        logger.error(f"Erro na verificação de saúde: {e}")
        return jsonify({
            'success': False,
            'error': str(e),
            'health': {
                'status': 'unhealthy',
                'error': str(e)
            }
        }), 500

# Adicionar import necessário
import time