"""
Decoradores utilitários para o backend
"""

import time
import logging
from functools import wraps
from flask import jsonify, request
from datetime import datetime

from config.settings import BackendConfig

logger = logging.getLogger(__name__)

def timeout_handler(func):
    """Decorador para adicionar timeout consistente a todas as rotas"""
    @wraps(func)
    def wrapper(*args, **kwargs):
        start_time = time.time()
        try:
            result = func(*args, **kwargs)
            elapsed_time = time.time() - start_time
            logger.info(f"⏱️ Rota {func.__name__} executada em {elapsed_time:.2f}s")
            return result
        except Exception as e:
            elapsed_time = time.time() - start_time
            logger.error(f"❌ Timeout/Erro na rota {func.__name__} após {elapsed_time:.2f}s: {e}")
            return jsonify({
                'error': 'Request timeout ou erro interno',
                'message': f'Operação excedeu tempo limite ou falhou: {str(e)[:100]}',
                'timestamp': datetime.now().isoformat(),
                'status': 'timeout'
            }), 408
    return wrapper

def require_json(func):
    """Decorador para garantir que o request seja JSON"""
    @wraps(func)
    def wrapper(*args, **kwargs):
        from flask import request
        if not request.is_json:
            return jsonify({'error': 'Content-Type deve ser application/json'}), 400
        return func(*args, **kwargs)
    return wrapper

def with_metrics(endpoint_name: str = None):
    """Decorador para coletar métricas de performance automaticamente"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            # Importar aqui para evitar dependência circular
            from utils.performance_metrics import get_metrics
            
            start_time = time.time()
            endpoint = endpoint_name or func.__name__
            success = False
            error_msg = None
            
            try:
                result = func(*args, **kwargs)
                success = True
                return result
                
            except Exception as e:
                error_msg = str(e)
                logger.error(f"❌ Erro em {endpoint}: {e}")
                raise
                
            finally:
                response_time = time.time() - start_time
                metrics = get_metrics()
                metrics.record_request(endpoint, response_time, success, error_msg)
                
        return wrapper
    return decorator

def log_request(func):
    """Decorador para logar requests"""
    @wraps(func)
    def wrapper(*args, **kwargs):
        from flask import request
        logger.info(f"📨 {request.method} {request.path} - {func.__name__}")
        return func(*args, **kwargs)
    return wrapper

def handle_api_errors(func):
    """Decorador para tratamento de erros de API"""
    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except Exception as e:
            logger.error(f"❌ Erro na API {func.__name__}: {e}")
            return jsonify({
                'error': 'Erro interno do servidor',
                'message': str(e),
                'timestamp': datetime.now().isoformat(),
                'function': func.__name__
            }), 500
    return wrapper

def log_request_response(func):
    """Decorador para logar request e response"""
    @wraps(func)
    def wrapper(*args, **kwargs):
        from flask import request
        start_time = time.time()
        
        logger.info(f"📨 {request.method} {request.path} - {func.__name__}")
        
        result = func(*args, **kwargs)
        
        elapsed_time = time.time() - start_time
        logger.info(f"📤 Resposta {func.__name__} em {elapsed_time:.2f}s")
        
        return result
    return wrapper
