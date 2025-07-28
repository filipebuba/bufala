#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Moransa Backend - Novo
Backend modular e organizado para o aplicativo Moransa
Desenvolvido para o Hackathon Gemma 3n

Este backend foi criado seguindo as regras do hackathon:
- Uso do modelo Gemma-3n para IA multimodal
- Funcionamento offline e privado
- Foco em impacto social para comunidades da Guiné-Bissau
"""

import os
import sys
import logging
from flask import Flask, jsonify, request, render_template
from flask_cors import CORS
from datetime import datetime

# Adicionar o diretório atual ao path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Importar configurações
from config.settings import BackendConfig, SystemPrompts

# Importar configuração do Swagger
from swagger_config import setup_swagger, SWAGGER_TEMPLATE, COMMON_SCHEMAS

from services.gemma_service import GemmaService
from services.health_service import HealthService
from utils.logger import setup_logger
from utils.error_handler import setup_error_handlers

# Importar rotas
from routes.health_routes import health_bp
from routes.medical_routes import medical_bp
from routes.education_routes import education_bp
from routes.agriculture_routes import agriculture_bp
from routes.wellness_routes import wellness_bp
from routes.translation_routes import translation_bp
from routes.accessibility_routes import accessibility_bp
from routes.voice_guide_routes import voice_guide_bp
from routes.multimodal_routes import multimodal_bp
from routes.environmental_routes import environmental_bp
from routes.model_management_routes import model_management_bp
from routes.collaborative_routes import collaborative_bp

def create_app():
    """Factory function para criar a aplicação Flask"""
    app = Flask(__name__)
    
    # Configurar CORS
    CORS(app, resources={
        r"/*": {
            "origins": ["*"],
            "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
            "allow_headers": ["Content-Type", "Authorization"]
        }
    })
    
    # Configurar logging
    setup_logger()
    logger = logging.getLogger(__name__)
    
    # Configurar tratamento de erros
    setup_error_handlers(app)
    
    # Inicializar serviços
    try:
        logger.info("Inicializando serviços...")
        
        # Inicializar serviço Gemma
        gemma_service = GemmaService()
        app.gemma_service = gemma_service
        
        # Inicializar serviço de saúde
        health_service = HealthService(gemma_service)
        app.health_service = health_service
        
        logger.info("Serviços inicializados com sucesso")
        
    except Exception as e:
        logger.error(f"Erro ao inicializar serviços: {e}")
        # Continuar sem os serviços para permitir desenvolvimento
        app.gemma_service = None
        app.health_service = None
    
    # Configurar Swagger
    swagger = setup_swagger(app)
    
    # Registrar blueprints
    app.register_blueprint(health_bp, url_prefix='/api')
    app.register_blueprint(medical_bp, url_prefix='/api')
    app.register_blueprint(education_bp, url_prefix='/api')
    app.register_blueprint(agriculture_bp, url_prefix='/api')
    app.register_blueprint(wellness_bp, url_prefix='/api')
    app.register_blueprint(translation_bp, url_prefix='/api')
    app.register_blueprint(accessibility_bp, url_prefix='/api')
    app.register_blueprint(voice_guide_bp, url_prefix='/api')
    app.register_blueprint(multimodal_bp, url_prefix='/api')
    app.register_blueprint(environmental_bp, url_prefix='/api')
    app.register_blueprint(model_management_bp, url_prefix='/api')
    app.register_blueprint(collaborative_bp, url_prefix='/api')
    
    # Rota raiz
    @app.route('/')
    def index():
        return jsonify({
            'message': 'Moransa Backend - Novo',
            'version': '2.0.0',
            'status': 'running',
            'timestamp': datetime.now().isoformat(),
            'description': 'Backend modular para o aplicativo Moransa - Hackathon Gemma 3n',
            'documentation': {
                'swagger_ui': '/api/docs/',
                'swagger_json': '/api/swagger.json',
                'custom_ui': '/docs'
            },
            'endpoints': {
                'health': '/api/health',
                'medical': '/api/medical',
                'education': '/api/education',
                'agriculture': '/api/agriculture',
                'wellness': '/api/wellness',
                'translation': '/api/translate',
                'accessibility': '/api/accessibility',
                'voice_guide': '/api/voice-guide',
                'multimodal': '/api/multimodal',
                'environmental': '/api/environment',
                'model_management': '/api/models'
            }
        })
    
    # Rota de configuração do backend
    @app.route('/api/config/backend', methods=['GET'])
    def get_backend_config():
        """Retorna configurações do backend para o app Flutter"""
        try:
            # Verificar status do Gemma Service
            gemma_active = False
            if app.gemma_service:
                health_status = app.gemma_service.get_health_status()
                gemma_active = health_status.get('ollama_available', False) or health_status.get('model_loaded', False)
            
            gemma_status = 'active' if gemma_active else 'inactive'
            
            config = {
                'status': 'online',
                'version': '2.0.0',
                'ai_model': {
                    'name': 'Gemma-3n',
                    'status': gemma_status,
                    'capabilities': ['text', 'multimodal', 'offline']
                },
                'features': {
                    'medical_diagnosis': True,
                    'education_support': True,
                    'agriculture_advice': True,
                    'translation': True,
                    'voice_guide': True,
                    'offline_mode': True
                },
                'revolutionary_features': {
                    'creole_support': True,
                    'offline_ai': True,
                    'community_focused': True,
                    'multimodal_analysis': True,
                    'local_language_learning': True
                },
                'languages': {
                    'supported': ['pt', 'en', 'fr', 'creole'],
                    'primary': 'pt',
                    'learning': ['creole', 'fula', 'mandinka']
                },
                'connectivity': {
                    'offline_capable': True,
                    'sync_available': True,
                    'local_processing': True
                }
            }
            
            return jsonify(config)
            
        except Exception as e:
            logger.error(f"Erro ao obter configurações do backend: {e}")
            return jsonify({
                'error': 'Erro interno do servidor',
                'message': str(e)
            }), 500
    
    @app.route('/docs', methods=['GET'])
    def custom_swagger_ui():
        """Rota para interface Swagger personalizada"""
        return render_template('swagger_ui.html')
    
    @app.route('/swagger.yaml', methods=['GET'])
    def swagger_yaml():
        """Rota para servir o arquivo swagger.yaml"""
        import os
        from flask import send_file
        swagger_path = os.path.join(os.path.dirname(__file__), 'swagger.yaml')
        return send_file(swagger_path, mimetype='application/x-yaml')
    
    @app.route('/api/swagger.json', methods=['GET'])
    def swagger_json():
        """Rota para servir a especificação OpenAPI em formato JSON"""
        import os
        import yaml
        import json
        
        try:
            swagger_path = os.path.join(os.path.dirname(__file__), 'swagger.yaml')
            with open(swagger_path, 'r', encoding='utf-8') as file:
                yaml_content = yaml.safe_load(file)
            return jsonify(yaml_content)
        except Exception as e:
            logger.error(f"Erro ao carregar swagger.yaml: {e}")
            return jsonify({
                "error": "Não foi possível carregar a especificação da API",
                "message": str(e)
            }), 500
    
    # Middleware para logging de requests
    @app.before_request
    def log_request_info():
        logger.info(f'{request.method} {request.url} - {request.remote_addr}')
    
    return app

def main():
    """Função principal para executar o servidor"""
    app = create_app()
    
    logger = logging.getLogger(__name__)
    logger.info("="*50)
    logger.info("Moransa Backend - Novo")
    logger.info("Hackathon Gemma 3n")
    logger.info("="*50)
    logger.info(f"Servidor iniciando em http://{BackendConfig.HOST}:{BackendConfig.PORT}")
    
    try:
        app.run(
            host=BackendConfig.HOST,
            port=BackendConfig.PORT,
            debug=BackendConfig.DEBUG,
            threaded=True
        )
    except KeyboardInterrupt:
        logger.info("Servidor interrompido pelo usuário")
    except Exception as e:
        logger.error(f"Erro ao iniciar servidor: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()