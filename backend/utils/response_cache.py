"""
Sistema de Cache para o Backend Bu Fala
Implementa cache em memória e persistente para otimizar performance
"""

import os
import json
import hashlib
import time
import logging
from typing import Dict, Any, Optional, Tuple
from datetime import datetime, timedelta
import threading

logger = logging.getLogger(__name__)

class ResponseCache:
    """Sistema de cache para respostas do modelo"""
    
    def __init__(self, 
                 max_memory_size: int = 100,
                 cache_ttl_hours: int = 24,
                 cache_dir: str = "cache"):
        self.max_memory_size = max_memory_size
        self.cache_ttl = timedelta(hours=cache_ttl_hours)
        self.cache_dir = cache_dir
        
        # Cache em memória (mais rápido)
        self.memory_cache: Dict[str, Dict[str, Any]] = {}
        self.access_times: Dict[str, datetime] = {}
        self.lock = threading.RLock()
        
        # Estatísticas
        self.stats = {
            'hits': 0,
            'misses': 0,
            'memory_hits': 0,
            'disk_hits': 0,
            'saves': 0,
            'evictions': 0
        }
        
        # Criar diretório de cache
        self._ensure_cache_dir()
        
        logger.info(f"🗄️ Cache inicializado: max_size={max_memory_size}, ttl={cache_ttl_hours}h")
    
    def _ensure_cache_dir(self):
        """Garantir que o diretório de cache existe"""
        try:
            os.makedirs(self.cache_dir, exist_ok=True)
        except Exception as e:
            logger.warning(f"⚠️ Erro ao criar diretório de cache: {e}")
    
    def _generate_cache_key(self, prompt: str, language: str, subject: str) -> str:
        """Gerar chave única para cache"""
        # Normalizar entrada
        normalized = f"{prompt.lower().strip()}_{language}_{subject}"
        # Hash para chave consistente
        return hashlib.md5(normalized.encode()).hexdigest()
    
    def _is_expired(self, timestamp: datetime) -> bool:
        """Verificar se entrada está expirada"""
        return datetime.now() - timestamp > self.cache_ttl
    
    def _get_cache_file_path(self, cache_key: str) -> str:
        """Obter caminho do arquivo de cache"""
        return os.path.join(self.cache_dir, f"{cache_key}.json")
    
    def _load_from_disk(self, cache_key: str) -> Optional[Dict[str, Any]]:
        """Carregar entrada do cache em disco"""
        try:
            file_path = self._get_cache_file_path(cache_key)
            if not os.path.exists(file_path):
                return None
            
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # Verificar se não expirou
            cached_time = datetime.fromisoformat(data['timestamp'])
            if self._is_expired(cached_time):
                os.remove(file_path)  # Limpar arquivo expirado
                return None
            
            self.stats['disk_hits'] += 1
            return data
            
        except Exception as e:
            logger.debug(f"Erro ao carregar cache do disco: {e}")
            return None
    
    def _save_to_disk(self, cache_key: str, data: Dict[str, Any]):
        """Salvar entrada no cache em disco"""
        try:
            file_path = self._get_cache_file_path(cache_key)
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
                
        except Exception as e:
            logger.debug(f"Erro ao salvar cache no disco: {e}")
    
    def _evict_old_entries(self):
        """Remover entradas antigas do cache em memória"""
        if len(self.memory_cache) <= self.max_memory_size:
            return
        
        # Ordenar por tempo de acesso (LRU)
        sorted_keys = sorted(
            self.access_times.items(),
            key=lambda x: x[1]
        )
        
        # Remover entradas mais antigas
        entries_to_remove = len(self.memory_cache) - self.max_memory_size + 10
        for key, _ in sorted_keys[:entries_to_remove]:
            if key in self.memory_cache:
                del self.memory_cache[key]
            if key in self.access_times:
                del self.access_times[key]
            self.stats['evictions'] += 1
        
        logger.debug(f"🗑️ Cache: removidas {entries_to_remove} entradas antigas")
    
    def get(self, prompt: str, language: str = 'pt-BR', subject: str = 'general') -> Optional[str]:
        """Buscar resposta no cache"""
        cache_key = self._generate_cache_key(prompt, language, subject)
        
        with self.lock:
            # 1. Verificar cache em memória primeiro
            if cache_key in self.memory_cache:
                entry = self.memory_cache[cache_key]
                cached_time = datetime.fromisoformat(entry['timestamp'])
                
                if not self._is_expired(cached_time):
                    # Atualizar tempo de acesso
                    self.access_times[cache_key] = datetime.now()
                    self.stats['hits'] += 1
                    self.stats['memory_hits'] += 1
                    
                    logger.debug(f"🎯 Cache hit (memória): {cache_key[:8]}...")
                    return entry['response']
                else:
                    # Remover entrada expirada
                    del self.memory_cache[cache_key]
                    if cache_key in self.access_times:
                        del self.access_times[cache_key]
            
            # 2. Verificar cache em disco
            disk_entry = self._load_from_disk(cache_key)
            if disk_entry:
                # Promover para cache em memória
                self.memory_cache[cache_key] = disk_entry
                self.access_times[cache_key] = datetime.now()
                self.stats['hits'] += 1
                
                logger.debug(f"🎯 Cache hit (disco): {cache_key[:8]}...")
                return disk_entry['response']
            
            # Cache miss
            self.stats['misses'] += 1
            logger.debug(f"❌ Cache miss: {cache_key[:8]}...")
            return None
    
    def set(self, prompt: str, response: str, language: str = 'pt-BR', subject: str = 'general'):
        """Salvar resposta no cache"""
        cache_key = self._generate_cache_key(prompt, language, subject)
        
        cache_entry = {
            'prompt': prompt,
            'response': response,
            'language': language,
            'subject': subject,
            'timestamp': datetime.now().isoformat(),
            'cache_key': cache_key
        }
        
        with self.lock:
            # Salvar em memória
            self.memory_cache[cache_key] = cache_entry
            self.access_times[cache_key] = datetime.now()
            
            # Salvar em disco (assíncrono)
            self._save_to_disk(cache_key, cache_entry)
            
            # Limpar cache se necessário
            self._evict_old_entries()
            
            self.stats['saves'] += 1
            logger.debug(f"💾 Cache salvo: {cache_key[:8]}...")
    
    def clear(self):
        """Limpar todo o cache"""
        with self.lock:
            self.memory_cache.clear()
            self.access_times.clear()
            
            # Limpar arquivos de cache
            try:
                if os.path.exists(self.cache_dir):
                    for filename in os.listdir(self.cache_dir):
                        if filename.endswith('.json'):
                            os.remove(os.path.join(self.cache_dir, filename))
            except Exception as e:
                logger.warning(f"⚠️ Erro ao limpar cache em disco: {e}")
            
            logger.info("🗑️ Cache limpo completamente")
    
    def get_stats(self) -> Dict[str, Any]:
        """Obter estatísticas do cache"""
        with self.lock:
            total_requests = self.stats['hits'] + self.stats['misses']
            hit_rate = (self.stats['hits'] / total_requests * 100) if total_requests > 0 else 0
            
            return {
                'total_requests': total_requests,
                'hits': self.stats['hits'],
                'misses': self.stats['misses'],
                'hit_rate_percent': round(hit_rate, 2),
                'memory_hits': self.stats['memory_hits'],
                'disk_hits': self.stats['disk_hits'],
                'saves': self.stats['saves'],
                'evictions': self.stats['evictions'],
                'memory_entries': len(self.memory_cache),
                'max_memory_size': self.max_memory_size,
                'cache_ttl_hours': self.cache_ttl.total_seconds() / 3600
            }
    
    def cleanup_expired(self):
        """Limpar entradas expiradas (manutenção)"""
        with self.lock:
            # Limpar memória
            expired_keys = []
            for key, entry in self.memory_cache.items():
                cached_time = datetime.fromisoformat(entry['timestamp'])
                if self._is_expired(cached_time):
                    expired_keys.append(key)
            
            for key in expired_keys:
                del self.memory_cache[key]
                if key in self.access_times:
                    del self.access_times[key]
            
            # Limpar disco
            try:
                if os.path.exists(self.cache_dir):
                    for filename in os.listdir(self.cache_dir):
                        if filename.endswith('.json'):
                            file_path = os.path.join(self.cache_dir, filename)
                            try:
                                with open(file_path, 'r', encoding='utf-8') as f:
                                    data = json.load(f)
                                cached_time = datetime.fromisoformat(data['timestamp'])
                                if self._is_expired(cached_time):
                                    os.remove(file_path)
                            except Exception:
                                continue
            except Exception as e:
                logger.warning(f"⚠️ Erro na limpeza de cache: {e}")
            
            logger.info(f"🧹 Cache: removidas {len(expired_keys)} entradas expiradas")

# Instância global do cache
_global_cache = None

def get_cache() -> ResponseCache:
    """Obter instância global do cache"""
    global _global_cache
    if _global_cache is None:
        _global_cache = ResponseCache()
    return _global_cache

def clear_global_cache():
    """Limpar cache global"""
    global _global_cache
    if _global_cache:
        _global_cache.clear()
        _global_cache = None
