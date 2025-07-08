#!/usr/bin/env python3
"""
Bu Fala Backend - Ap    # Inicializar serviço Gemma rápido
    logger.info("🏃 Iniciando com serviço Gemma rápido para melhor performance")
    gemma_service = FastGemmaService()ação Principal
Versão modularizada com melhorias da documentação oficial Gemma-3n
"""

from flask import Flask
from flask_cors import CORS
import logging
import os
from datetime import datetime

from config.settings import BackendConfig
from services.ultra_fast_gemma_service import UltraFastGemmaService
from routes.health_routes import health_bp
from routes.medical_routes import medical_bp
from routes.education_routes import education_bp
from routes.agriculture_routes import agriculture_bp
from routes.accessibility_routes import accessibility_bp  # NOVO: Sistema de acessibilidade
from routes.wellness_routes import wellness_bp
from routes.translation_routes import translation_bp
from routes.environmental_routes import environmental_bp
from routes.multimodal_routes import multimodal_bp
from routes.collaborative_routes import collaborative_bp  # NOVO: Sistema colaborativo
from routes.international_routes import international_bp  # NOVO: Sistema internacional
from utils.logging_config import setup_logging

# Configurar logging
setup_logging()
logger = logging.getLogger(__name__)

def create_app():
    """Factory function para criar a aplicação Flask"""
    app = Flask(__name__)
    
    # Carregar configurações
    app.config.from_object(BackendConfig)
    
    # Configurações de timeout aumentadas
    app.config['SEND_FILE_MAX_AGE_DEFAULT'] = 0
    app.config['PERMANENT_SESSION_LIFETIME'] = 300  # 5 minutos
    
    # Configurar CORS
    CORS(app, resources={
        r"/*": {
            "origins": ["*"],
            "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
            "allow_headers": ["Content-Type", "Authorization", "Accept", "Origin", "X-Requested-With"],
            "supports_credentials": True
        }
    })
    
    # Inicializar serviço Gemma baseado na documentação oficial
    logger.info("📋 Iniciando com Docs Gemma Service baseado na documentação oficial")
    from services.docs_gemma_service import DocsGemmaService
    gemma_service = DocsGemmaService()
    app.gemma_service = gemma_service
    
    # Inicializar sistema de acessibilidade VoiceGuide AI
    logger.info("🌟 Iniciando VoiceGuide AI - Sistema de Acessibilidade")
    from services.accessibility_service import AccessibilityService
    accessibility_service = AccessibilityService(gemma_service)
    app.accessibility_service = accessibility_service
    
    # Registrar blueprints (rotas)
    app.register_blueprint(health_bp)
    app.register_blueprint(medical_bp)
    app.register_blueprint(education_bp)
    app.register_blueprint(agriculture_bp)
    app.register_blueprint(accessibility_bp)  # NOVO: Rotas de acessibilidade
    app.register_blueprint(wellness_bp)
    app.register_blueprint(translation_bp)
    app.register_blueprint(environmental_bp)
    app.register_blueprint(multimodal_bp)
    app.register_blueprint(collaborative_bp)  # NOVO: Rotas colaborativas
    app.register_blueprint(international_bp)  # NOVO: Rotas internacionais
    
    # Middleware para injetar serviços nas rotas
    @app.before_request
    def inject_services():
        from flask import g
        g.gemma_service = gemma_service
        g.accessibility_service = accessibility_service  # NOVO: Injetar serviço de acessibilidade
    
    logger.info("🚀 Bu Fala Backend iniciado com sucesso!")
    return app

def main():
    """Função principal para executar o servidor"""
    app = create_app()
    
    try:
        logger.info(f"🌟 Iniciando Bu Fala Backend em http://localhost:{BackendConfig.PORT}")
        logger.info(f"📅 Data/Hora: {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}")
        
        app.run(
            host=BackendConfig.HOST,
            port=BackendConfig.PORT,
            debug=BackendConfig.DEBUG,
            threaded=True
        )
        
    except KeyboardInterrupt:
        logger.info("🛑 Servidor interrompido pelo usuário")
    except Exception as e:
        logger.error(f"❌ Erro fatal no servidor: {e}")
    finally:
        logger.info("👋 Bu Fala Backend finalizado")

if __name__ == "__main__":
    main()
