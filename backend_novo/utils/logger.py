#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Utilitário de Logging para Bu Fala Backend
Hackathon Gemma 3n
"""

import logging
import sys
from datetime import datetime
from config.settings import BackendConfig

def setup_logger():
    """Configurar sistema de logging"""
    
    # Configurar formato de log
    formatter = logging.Formatter(
        fmt=BackendConfig.LOG_FORMAT,
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    
    # Configurar handler para console
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(formatter)
    console_handler.setLevel(getattr(logging, BackendConfig.LOG_LEVEL))
    
    # Configurar logger raiz
    root_logger = logging.getLogger()
    root_logger.setLevel(getattr(logging, BackendConfig.LOG_LEVEL))
    
    # Limpar handlers existentes
    root_logger.handlers.clear()
    
    # Adicionar handler
    root_logger.addHandler(console_handler)
    
    # Configurar loggers específicos
    logging.getLogger('werkzeug').setLevel(logging.WARNING)
    logging.getLogger('urllib3').setLevel(logging.WARNING)
    logging.getLogger('requests').setLevel(logging.WARNING)
    
    # Log inicial
    logger = logging.getLogger(__name__)
    logger.info("Sistema de logging configurado")
    logger.info(f"Nível de log: {BackendConfig.LOG_LEVEL}")

def get_logger(name: str) -> logging.Logger:
    """Obter logger com nome específico"""
    return logging.getLogger(name)