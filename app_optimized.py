#!/usr/bin/env python3
"""
Bu Fala Backend Otimizado - Versão com Múltiplos Serviços
Permite escolher entre diferentes implementações Gemma 3n baseadas na documentação oficial
"""

from flask import Flask
from flask_cors import CORS
import logging
import os
import sys
from datetime import datetime

from config.settings import BackendConfig
from routes.health_routes import health_bp
from routes.medical_routes import medical_bp
from routes.education_routes import education_bp
from routes.agriculture_routes import agriculture_bp
from routes.wellness_routes import wellness_bp
from routes.translation_routes import translation_bp
from routes.environmental_routes import environmental_bp
from routes.multimodal_routes import multimodal_bp
from utils.logging_config import setup_logging

# Importar todos os serviços disponíveis
try:
    from services.ultra_fast_gemma_service import UltraFastGemmaService
    from services.pipeline_gemma_service import PipelineGemmaService
    from services.official_gemma_service import OfficialGemmaService
    from services.hybrid_gemma_service import HybridGemmaService
except ImportError as e:
    print(f"❌ Erro ao importar serviços: {e}")
    sys.exit(1)

# Configurar logging
setup_logging()
logger = logging.getLogger(__name__)

def get_service_by_name(service_name):
    """Retorna o serviço correspondente ao nome"""
    services = {
        "ultra": UltraFastGemmaService,
        "pipeline": PipelineGemmaService,
        "official": OfficialGemmaService,
        "hybrid": HybridGemmaService
    }
    
    return services.get(service_name.lower())

def create_app(service_type="hybrid"):
    """Factory function para criar a aplicação Flask com serviço específico"""
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
    
    # Inicializar serviço Gemma baseado no tipo escolhido
    service_class = get_service_by_name(service_type)
    
    if not service_class:
        logger.error(f"❌ Serviço '{service_type}' não encontrado!")
        logger.info("📋 Serviços disponíveis: ultra, pipeline, official, hybrid")
        sys.exit(1)
    
    logger.info(f"🚀 Iniciando com {service_class.__name__}")
    gemma_service = service_class()
    app.gemma_service = gemma_service
    
    # Registrar blueprints (rotas)
    app.register_blueprint(health_bp)
    app.register_blueprint(medical_bp)
    app.register_blueprint(education_bp)
    app.register_blueprint(agriculture_bp)
    app.register_blueprint(wellness_bp)
    app.register_blueprint(translation_bp)
    app.register_blueprint(environmental_bp)
    app.register_blueprint(multimodal_bp)
    
    # Middleware para injetar serviço Gemma nas rotas
    @app.before_request
    def inject_services():
        from flask import g
        g.gemma_service = gemma_service
    
    # Rota adicional para informações do serviço
    @app.route('/api/service-info')
    def service_info():
        return {
            "service": service_class.__name__,
            "status": gemma_service.get_status(),
            "initialized": gemma_service.is_initialized
        }
    
    logger.info(f"✅ Bu Fala Backend iniciado com {service_class.__name__}!")
    return app

def show_help():
    """Mostra ajuda sobre os serviços disponíveis"""
    print("""
🚀 Bu Fala Backend Otimizado

USO:
    python app_optimized.py [SERVIÇO]

SERVIÇOS DISPONÍVEIS:
    ultra     - Ultra Fast Service (atual, simplificado)
    pipeline  - Pipeline API Service (documentação oficial)
    official  - Official Direct Service (Gemma3nForConditionalGeneration)
    hybrid    - Hybrid Service (combinação otimizada)

EXEMPLOS:
    python app_optimized.py hybrid     # Usar serviço híbrido (recomendado)
    python app_optimized.py pipeline   # Usar pipeline API
    python app_optimized.py official   # Usar implementação oficial direta
    python app_optimized.py ultra      # Usar serviço atual

PADRÃO: hybrid (se nenhum argumento for fornecido)
    """)

def main():
    """Função principal para executar o servidor"""
    
    # Processar argumentos da linha de comando
    if len(sys.argv) > 1:
        if sys.argv[1] in ['-h', '--help', 'help']:
            show_help()
            return
        service_type = sys.argv[1]
    else:
        service_type = "hybrid"  # Padrão
    
    # Validar serviço
    if service_type not in ["ultra", "pipeline", "official", "hybrid"]:
        print(f"❌ Serviço '{service_type}' inválido!")
        show_help()
        return
    
    # Criar app com serviço específico
    app = create_app(service_type)
    
    try:
        logger.info(f"🌟 Bu Fala Backend executando em http://localhost:{BackendConfig.PORT}")
        logger.info(f"🎯 Serviço ativo: {service_type.upper()}")
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
