#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Serviço de Saúde do Sistema Bu Fala
Hackathon Gemma 3n
"""

import logging
import psutil
import platform
from datetime import datetime
from typing import Dict, Any, Optional

class HealthService:
    """Serviço para monitoramento de saúde do sistema"""
    
    def __init__(self, gemma_service=None):
        self.logger = logging.getLogger(__name__)
        self.gemma_service = gemma_service
        self.start_time = datetime.now()
    
    def get_system_health(self) -> Dict[str, Any]:
        """Obter status completo de saúde do sistema"""
        try:
            # Informações básicas do sistema
            system_info = {
                'platform': platform.system(),
                'platform_version': platform.version(),
                'architecture': platform.architecture()[0],
                'processor': platform.processor(),
                'python_version': platform.python_version()
            }
            
            # Informações de memória
            memory = psutil.virtual_memory()
            memory_info = {
                'total_gb': round(memory.total / (1024**3), 2),
                'available_gb': round(memory.available / (1024**3), 2),
                'used_gb': round(memory.used / (1024**3), 2),
                'percentage': memory.percent
            }
            
            # Informações de CPU
            cpu_info = {
                'count': psutil.cpu_count(),
                'usage_percent': psutil.cpu_percent(interval=1),
                'frequency_mhz': psutil.cpu_freq().current if psutil.cpu_freq() else None
            }
            
            # Informações de disco
            disk = psutil.disk_usage('/')
            disk_info = {
                'total_gb': round(disk.total / (1024**3), 2),
                'used_gb': round(disk.used / (1024**3), 2),
                'free_gb': round(disk.free / (1024**3), 2),
                'percentage': round((disk.used / disk.total) * 100, 2)
            }
            
            # Status do serviço Gemma
            gemma_status = None
            if self.gemma_service:
                gemma_status = self.gemma_service.get_health_status()
            
            # Tempo de atividade
            uptime = datetime.now() - self.start_time
            uptime_info = {
                'seconds': uptime.total_seconds(),
                'formatted': str(uptime).split('.')[0]  # Remove microsegundos
            }
            
            # Status geral
            status = self._determine_overall_status(memory_info, cpu_info, disk_info, gemma_status)
            
            return {
                'status': status,
                'timestamp': datetime.now().isoformat(),
                'uptime': uptime_info,
                'system': system_info,
                'memory': memory_info,
                'cpu': cpu_info,
                'disk': disk_info,
                'gemma_service': gemma_status,
                'services': {
                    'backend': 'running',
                    'gemma': 'running' if gemma_status and (gemma_status.get('ollama_available') or gemma_status.get('model_loaded')) else 'fallback'
                }
            }
            
        except Exception as e:
            self.logger.error(f"Erro ao obter status de saúde: {e}")
            return {
                'status': 'error',
                'error': str(e),
                'timestamp': datetime.now().isoformat()
            }
    
    def _determine_overall_status(
        self,
        memory_info: Dict[str, Any],
        cpu_info: Dict[str, Any],
        disk_info: Dict[str, Any],
        gemma_status: Optional[Dict[str, Any]]
    ) -> str:
        """Determinar status geral do sistema"""
        
        # Verificar recursos críticos
        if memory_info['percentage'] > 90:
            return 'critical'
        
        if cpu_info['usage_percent'] > 90:
            return 'critical'
        
        if disk_info['percentage'] > 95:
            return 'critical'
        
        # Verificar recursos em alerta
        if memory_info['percentage'] > 80 or cpu_info['usage_percent'] > 80 or disk_info['percentage'] > 85:
            return 'warning'
        
        # Verificar se o serviço Gemma está funcionando
        if gemma_status:
            if not (gemma_status.get('ollama_available') or gemma_status.get('model_loaded')):
                return 'degraded'
        
        return 'healthy'
    
    def get_quick_status(self) -> Dict[str, Any]:
        """Obter status rápido do sistema"""
        try:
            memory = psutil.virtual_memory()
            cpu_percent = psutil.cpu_percent(interval=0.1)
            
            gemma_available = False
            if self.gemma_service:
                status = self.gemma_service.get_health_status()
                gemma_available = status.get('ollama_available', False) or status.get('model_loaded', False)
            
            return {
                'status': 'healthy' if memory.percent < 80 and cpu_percent < 80 else 'warning',
                'memory_percent': memory.percent,
                'cpu_percent': cpu_percent,
                'gemma_available': gemma_available,
                'timestamp': datetime.now().isoformat()
            }
            
        except Exception as e:
            self.logger.error(f"Erro ao obter status rápido: {e}")
            return {
                'status': 'error',
                'error': str(e),
                'timestamp': datetime.now().isoformat()
            }
    
    def check_dependencies(self) -> Dict[str, Any]:
        """Verificar dependências do sistema"""
        dependencies = {
            'torch': False,
            'transformers': False,
            'requests': False,
            'flask': False,
            'psutil': False
        }
        
        # Verificar cada dependência
        for dep in dependencies.keys():
            try:
                __import__(dep)
                dependencies[dep] = True
            except ImportError:
                dependencies[dep] = False
        
        # Verificar CUDA se disponível
        cuda_available = False
        try:
            import torch
            cuda_available = torch.cuda.is_available()
        except ImportError:
            pass
        
        return {
            'dependencies': dependencies,
            'cuda_available': cuda_available,
            'all_dependencies_met': all(dependencies.values()),
            'timestamp': datetime.now().isoformat()
        }