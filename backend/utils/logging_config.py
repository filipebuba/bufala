"""
Configuração de logging para o Bu Fala Backend
"""

import logging
import sys
from config.settings import BackendConfig

def setup_logging():
    """Configurar sistema de logging"""
    
    # Configurar formato
    formatter = logging.Formatter(BackendConfig.LOG_FORMAT)
    
    # Configurar handler do console
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(formatter)
    
    # Configurar logger principal
    root_logger = logging.getLogger()
    root_logger.setLevel(getattr(logging, BackendConfig.LOG_LEVEL))
    root_logger.addHandler(console_handler)
    
    # Configurar loggers específicos
    loggers = [
        'werkzeug',  # Flask
        'urllib3',   # Requests
        'transformers',  # HuggingFace
        'torch',     # PyTorch
    ]
    
    for logger_name in loggers:
        logger = logging.getLogger(logger_name)
        logger.setLevel(logging.WARNING)  # Reduzir verbosidade
    
    return root_logger
