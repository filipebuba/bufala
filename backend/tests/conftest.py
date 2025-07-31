#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Configuração de testes para Moransa Backend
Fixtures e configurações compartilhadas
"""

import pytest
import os
import sys
import tempfile
import shutil
from unittest.mock import Mock, patch, MagicMock
from flask import Flask

# Adicionar o diretório backend ao path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app import create_app
from config.settings import BackendConfig
from services.gemma_service import GemmaService
from services.health_service import HealthService

@pytest.fixture(scope='session')
def test_config():
    """Configuração de teste"""
    return {
        'TESTING': True,
        'DEBUG': False,
        'HOST': '127.0.0.1',
        'PORT': 5001,
        'USE_OLLAMA': False,  # Desabilitar Ollama nos testes
        'LOG_LEVEL': 'ERROR',  # Reduzir logs durante testes
        'REQUEST_TIMEOUT': 10,  # Timeout menor para testes
    }

@pytest.fixture(scope='session')
def app(test_config):
    """Fixture da aplicação Flask para testes"""
    # Configurar variáveis de ambiente para testes
    os.environ['TESTING'] = 'true'
    os.environ['USE_OLLAMA'] = 'false'
    
    # Criar aplicação de teste
    app = create_app()
    app.config.update(test_config)
    
    # Configurar contexto de aplicação
    with app.app_context():
        yield app

@pytest.fixture(scope='function')
def client(app):
    """Cliente de teste Flask"""
    return app.test_client()

@pytest.fixture(scope='function')
def runner(app):
    """Runner de comandos CLI"""
    return app.test_cli_runner()

@pytest.fixture
def mock_gemma_service():
    """Mock do serviço Gemma"""
    mock_service = Mock(spec=GemmaService)
    
    # Configurar métodos mock
    mock_service.get_health_status.return_value = {
        'status': 'healthy',
        'ollama_available': False,
        'model_loaded': True,
        'model_name': 'gemma3n:test',
        'timestamp': '2024-01-01T00:00:00Z'
    }
    
    mock_service.generate_response.return_value = {
        'response': 'Resposta de teste do modelo Gemma',
        'model_used': 'gemma3n:test',
        'processing_time': 0.5,
        'tokens_used': 50,
        'confidence': 0.95
    }
    
    mock_service.analyze_multimodal.return_value = {
        'analysis': 'Análise multimodal de teste',
        'modalities': ['text', 'image'],
        'confidence': 0.9,
        'processing_time': 1.2
    }
    
    return mock_service

@pytest.fixture
def mock_health_service():
    """Mock do serviço de saúde"""
    mock_service = Mock(spec=HealthService)
    
    mock_service.analyze_symptoms.return_value = {
        'diagnosis': 'Possível resfriado comum',
        'severity': 'low',
        'recommendations': [
            'Descansar bastante',
            'Beber muitos líquidos',
            'Procurar médico se piorar'
        ],
        'confidence': 0.8,
        'emergency': False
    }
    
    mock_service.get_emergency_guidance.return_value = {
        'guidance': 'Orientações de emergência de teste',
        'steps': [
            'Manter a calma',
            'Verificar sinais vitais',
            'Chamar ajuda médica'
        ],
        'priority': 'high',
        'estimated_time': '5-10 minutos'
    }
    
    return mock_service

@pytest.fixture
def mock_ollama_response():
    """Mock de resposta do Ollama"""
    return {
        'model': 'gemma3n:latest',
        'created_at': '2024-01-01T00:00:00Z',
        'response': 'Resposta de teste do Ollama',
        'done': True,
        'context': [1, 2, 3, 4, 5],
        'total_duration': 1000000000,
        'load_duration': 100000000,
        'prompt_eval_count': 10,
        'prompt_eval_duration': 200000000,
        'eval_count': 20,
        'eval_duration': 700000000
    }

@pytest.fixture
def mock_requests():
    """Mock para requisições HTTP"""
    with patch('requests.post') as mock_post, \
         patch('requests.get') as mock_get:
        
        # Configurar resposta padrão
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.json.return_value = {'status': 'success'}
        mock_response.text = 'Success'
        
        mock_post.return_value = mock_response
        mock_get.return_value = mock_response
        
        yield {
            'post': mock_post,
            'get': mock_get,
            'response': mock_response
        }

@pytest.fixture
def temp_directory():
    """Diretório temporário para testes"""
    temp_dir = tempfile.mkdtemp()
    yield temp_dir
    shutil.rmtree(temp_dir)

@pytest.fixture
def sample_image_data():
    """Dados de imagem de exemplo para testes"""
    # Criar uma imagem PNG simples de 1x1 pixel em base64
    return {
        'data': 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
        'format': 'PNG',
        'size': (1, 1),
        'mode': 'RGB'
    }

@pytest.fixture
def sample_audio_data():
    """Dados de áudio de exemplo para testes"""
    return {
        'data': b'\x00\x01\x02\x03',  # Dados binários simulados
        'format': 'WAV',
        'duration': 1.0,
        'sample_rate': 44100,
        'channels': 1
    }

@pytest.fixture
def sample_medical_data():
    """Dados médicos de exemplo para testes"""
    return {
        'symptoms': ['febre', 'dor de cabeça', 'cansaço'],
        'duration': '2 dias',
        'severity': 'moderada',
        'age': 30,
        'gender': 'feminino',
        'location': 'Bissau, Guiné-Bissau',
        'emergency': False
    }

@pytest.fixture
def sample_agricultural_data():
    """Dados agrícolas de exemplo para testes"""
    return {
        'crop': 'arroz',
        'season': 'seca',
        'location': 'Bafatá, Guiné-Bissau',
        'soil_type': 'argiloso',
        'problem': 'pragas nas folhas',
        'area': '2 hectares',
        'planting_date': '2024-01-15'
    }

@pytest.fixture
def sample_educational_data():
    """Dados educacionais de exemplo para testes"""
    return {
        'subject': 'matemática',
        'level': 'ensino fundamental',
        'topic': 'frações',
        'language': 'português',
        'student_age': 12,
        'difficulty': 'intermediário'
    }

@pytest.fixture
def mock_file_operations():
    """Mock para operações de arquivo"""
    with patch('builtins.open', create=True) as mock_open, \
         patch('os.path.exists') as mock_exists, \
         patch('os.makedirs') as mock_makedirs:
        
        mock_exists.return_value = True
        mock_open.return_value.__enter__.return_value.read.return_value = 'test content'
        
        yield {
            'open': mock_open,
            'exists': mock_exists,
            'makedirs': mock_makedirs
        }

@pytest.fixture(autouse=True)
def setup_logging():
    """Configurar logging para testes"""
    import logging
    logging.getLogger().setLevel(logging.ERROR)
    yield
    logging.getLogger().setLevel(logging.INFO)

# Configurações de pytest
def pytest_configure(config):
    """Configuração do pytest"""
    # Adicionar marcadores personalizados
    config.addinivalue_line(
        "markers", "unit: marca testes unitários"
    )
    config.addinivalue_line(
        "markers", "integration: marca testes de integração"
    )
    config.addinivalue_line(
        "markers", "slow: marca testes lentos"
    )
    config.addinivalue_line(
        "markers", "api: marca testes de API"
    )
    config.addinivalue_line(
        "markers", "service: marca testes de serviços"
    )
    config.addinivalue_line(
        "markers", "config: marca testes de configuração"
    )