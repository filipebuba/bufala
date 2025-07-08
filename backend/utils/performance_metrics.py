"""
Sistema de Métricas de Performance para o Backend Bu Fala
Coleta e monitora métricas de performance em tempo real
"""

import time
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional
from collections import defaultdict, deque
import threading
import statistics

logger = logging.getLogger(__name__)

class PerformanceMetrics:
    """Sistema de coleta e análise de métricas de performance"""
    
    def __init__(self, max_history: int = 1000):
        self.max_history = max_history
        self.lock = threading.RLock()
        
        # Métricas de endpoints
        self.endpoint_metrics = defaultdict(lambda: {
            'total_requests': 0,
            'successful_requests': 0,
            'failed_requests': 0,
            'response_times': deque(maxlen=max_history),
            'error_rates': deque(maxlen=max_history),
            'last_request': None
        })
        
        # Métricas do modelo
        self.model_metrics = {
            'generation_times': deque(maxlen=max_history),
            'token_counts': deque(maxlen=max_history),
            'cache_hits': 0,
            'cache_misses': 0,
            'fallback_uses': 0,
            'loading_method_usage': defaultdict(int)
        }
        
        # Métricas do sistema
        self.system_metrics = {
            'start_time': datetime.now(),
            'total_uptime': 0,
            'memory_usage': deque(maxlen=max_history),
            'cpu_usage': deque(maxlen=max_history)
        }
        
        logger.info("📊 Sistema de métricas inicializado")
    
    def record_request(self, endpoint: str, response_time: float, success: bool, error: Optional[str] = None):
        """Registrar métricas de uma requisição"""
        with self.lock:
            metrics = self.endpoint_metrics[endpoint]
            
            # Atualizar contadores
            metrics['total_requests'] += 1
            if success:
                metrics['successful_requests'] += 1
            else:
                metrics['failed_requests'] += 1
            
            # Registrar tempo de resposta
            metrics['response_times'].append(response_time)
            
            # Calcular taxa de erro recente (últimos 100 requests)
            recent_total = min(100, metrics['total_requests'])
            recent_failures = min(100, metrics['failed_requests'])
            error_rate = (recent_failures / recent_total) * 100 if recent_total > 0 else 0
            metrics['error_rates'].append(error_rate)
            
            # Timestamp da última requisição
            metrics['last_request'] = datetime.now()
            
            logger.debug(f"📊 Métrica registrada: {endpoint} - {response_time:.2f}s - {'✅' if success else '❌'}")
    
    def record_generation(self, generation_time: float, token_count: int, method: str, from_cache: bool = False):
        """Registrar métricas de geração do modelo"""
        with self.lock:
            if from_cache:
                self.model_metrics['cache_hits'] += 1
            else:
                self.model_metrics['cache_misses'] += 1
                self.model_metrics['generation_times'].append(generation_time)
                self.model_metrics['token_counts'].append(token_count)
                self.model_metrics['loading_method_usage'][method] += 1
    
    def record_fallback(self):
        """Registrar uso de fallback"""
        with self.lock:
            self.model_metrics['fallback_uses'] += 1
    
    def get_endpoint_stats(self, endpoint: str) -> Dict[str, Any]:
        """Obter estatísticas de um endpoint específico"""
        with self.lock:
            if endpoint not in self.endpoint_metrics:
                return {}
            
            metrics = self.endpoint_metrics[endpoint]
            response_times = list(metrics['response_times'])
            
            if not response_times:
                return {
                    'total_requests': 0,
                    'avg_response_time': 0,
                    'success_rate': 0
                }
            
            return {
                'total_requests': metrics['total_requests'],
                'successful_requests': metrics['successful_requests'],
                'failed_requests': metrics['failed_requests'],
                'success_rate': (metrics['successful_requests'] / metrics['total_requests']) * 100,
                'avg_response_time': statistics.mean(response_times),
                'min_response_time': min(response_times),
                'max_response_time': max(response_times),
                'p50_response_time': statistics.median(response_times),
                'p95_response_time': statistics.quantiles(response_times, n=20)[18] if len(response_times) > 10 else max(response_times),
                'current_error_rate': metrics['error_rates'][-1] if metrics['error_rates'] else 0,
                'last_request': metrics['last_request'].isoformat() if metrics['last_request'] else None
            }
    
    def get_model_stats(self) -> Dict[str, Any]:
        """Obter estatísticas do modelo"""
        with self.lock:
            generation_times = list(self.model_metrics['generation_times'])
            token_counts = list(self.model_metrics['token_counts'])
            
            total_requests = self.model_metrics['cache_hits'] + self.model_metrics['cache_misses']
            cache_hit_rate = (self.model_metrics['cache_hits'] / total_requests * 100) if total_requests > 0 else 0
            
            stats = {
                'total_generations': len(generation_times),
                'cache_hits': self.model_metrics['cache_hits'],
                'cache_misses': self.model_metrics['cache_misses'],
                'cache_hit_rate': round(cache_hit_rate, 2),
                'fallback_uses': self.model_metrics['fallback_uses'],
                'loading_method_usage': dict(self.model_metrics['loading_method_usage'])
            }
            
            if generation_times:
                stats.update({
                    'avg_generation_time': statistics.mean(generation_times),
                    'min_generation_time': min(generation_times),
                    'max_generation_time': max(generation_times),
                    'p95_generation_time': statistics.quantiles(generation_times, n=20)[18] if len(generation_times) > 10 else max(generation_times)
                })
            
            if token_counts:
                stats.update({
                    'avg_tokens_per_generation': statistics.mean(token_counts),
                    'total_tokens_generated': sum(token_counts)
                })
            
            return stats
    
    def get_system_stats(self) -> Dict[str, Any]:
        """Obter estatísticas do sistema"""
        with self.lock:
            uptime = datetime.now() - self.system_metrics['start_time']
            
            return {
                'start_time': self.system_metrics['start_time'].isoformat(),
                'uptime_seconds': uptime.total_seconds(),
                'uptime_hours': uptime.total_seconds() / 3600,
                'uptime_days': uptime.days
            }
    
    def get_all_endpoints_summary(self) -> Dict[str, Any]:
        """Obter resumo de todos os endpoints"""
        with self.lock:
            summary = {}
            total_requests = 0
            total_successes = 0
            all_response_times = []
            
            for endpoint, metrics in self.endpoint_metrics.items():
                summary[endpoint] = self.get_endpoint_stats(endpoint)
                total_requests += metrics['total_requests']
                total_successes += metrics['successful_requests']
                all_response_times.extend(list(metrics['response_times']))
            
            overall_stats = {
                'total_endpoints': len(self.endpoint_metrics),
                'total_requests': total_requests,
                'overall_success_rate': (total_successes / total_requests * 100) if total_requests > 0 else 0
            }
            
            if all_response_times:
                overall_stats.update({
                    'overall_avg_response_time': statistics.mean(all_response_times),
                    'overall_p95_response_time': statistics.quantiles(all_response_times, n=20)[18] if len(all_response_times) > 10 else max(all_response_times)
                })
            
            return {
                'overall': overall_stats,
                'endpoints': summary
            }
    
    def get_performance_report(self) -> Dict[str, Any]:
        """Gerar relatório completo de performance"""
        return {
            'timestamp': datetime.now().isoformat(),
            'system': self.get_system_stats(),
            'model': self.get_model_stats(),
            'endpoints': self.get_all_endpoints_summary()
        }
    
    def reset_metrics(self):
        """Resetar todas as métricas"""
        with self.lock:
            self.endpoint_metrics.clear()
            self.model_metrics = {
                'generation_times': deque(maxlen=self.max_history),
                'token_counts': deque(maxlen=self.max_history),
                'cache_hits': 0,
                'cache_misses': 0,
                'fallback_uses': 0,
                'loading_method_usage': defaultdict(int)
            }
            self.system_metrics['start_time'] = datetime.now()
            
            logger.info("📊 Métricas resetadas")

# Instância global das métricas
_global_metrics = None

def get_metrics() -> PerformanceMetrics:
    """Obter instância global das métricas"""
    global _global_metrics
    if _global_metrics is None:
        _global_metrics = PerformanceMetrics()
    return _global_metrics

def reset_global_metrics():
    """Resetar métricas globais"""
    global _global_metrics
    if _global_metrics:
        _global_metrics.reset_metrics()
