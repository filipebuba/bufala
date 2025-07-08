#!/usr/bin/env python3
"""
Script otimizado para iniciar o Bu Fala Backend
Versão com carregamento inteligente e fallbacks
"""

import sys
import os
import logging
from datetime import datetime

# Configurar logging básico
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Adicionar o diretório backend ao Python path
backend_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, backend_dir)

def check_system_resources():
    """Verificar recursos do sistema antes de carregar"""
    try:
        import psutil
        memory = psutil.virtual_memory()
        available_gb = memory.available / (1024**3)
        
        logger.info(f"💾 Memória disponível: {available_gb:.1f} GB")
        
        if available_gb < 4:
            logger.warning("⚠️ Pouca memória disponível. Recomendado usar modo simplificado.")
            return False
        return True
    except ImportError:
        logger.warning("⚠️ psutil não disponível. Continuando com carregamento padrão.")
        return True

def start_optimized_backend():
    """Iniciar backend com otimizações"""
    try:
        logger.info("🚀 Iniciando Bu Fala Backend Otimizado")
        logger.info(f"📅 Data/Hora: {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}")
        
        # Verificar recursos
        has_resources = check_system_resources()
        
        if not has_resources:
            logger.info("🔄 Iniciando em modo simplificado...")
            # Configurar para modo simplificado
            os.environ['BU_FALA_SIMPLE_MODE'] = 'true'
        
        # Importar e iniciar a aplicação
        from app import create_app
        
        app = create_app()
        
        # Configurações otimizadas
        host = "0.0.0.0"
        port = 5000
        debug = False  # Desabilitar debug para melhor performance
        
        logger.info(f"🌟 Servidor disponível em http://localhost:{port}")
        logger.info("📝 Endpoints principais:")
        logger.info("   • /health - Status do sistema")
        logger.info("   • /medical - Consultas médicas")
        logger.info("   • /multimodal/capabilities - Capacidades multimodais")
        logger.info("   • /multimodal/test/image - Teste de imagem")
        
        # Iniciar servidor
        app.run(
            host=host,
            port=port,
            debug=debug,
            threaded=True,
            use_reloader=False  # Desabilitar reloader para estabilidade
        )
        
    except KeyboardInterrupt:
        logger.info("🛑 Servidor interrompido pelo usuário")
    except Exception as e:
        logger.error(f"❌ Erro fatal no servidor: {e}")
        logger.info("🔄 Tentando iniciar em modo fallback...")
        start_fallback_server()
    finally:
        logger.info("👋 Bu Fala Backend finalizado")

def start_fallback_server():
    """Servidor de fallback simplificado"""
    try:
        from flask import Flask, jsonify
        from datetime import datetime
        
        app = Flask(__name__)
        
        @app.route('/health')
        def health():
            return jsonify({
                'status': 'healthy',
                'mode': 'fallback',
                'timestamp': datetime.now().isoformat(),
                'service': 'Bu Fala Backend Fallback',
                'version': '2.0.0-fallback',
                'message': 'Servidor funcionando em modo simplificado'
            })
        
        @app.route('/multimodal/capabilities')
        def capabilities():
            return jsonify({
                'success': False,
                'message': 'Funcionalidades multimodais não disponíveis no modo fallback',
                'available_features': ['health_check', 'basic_responses'],
                'mode': 'fallback'
            })
        
        logger.info("🔄 Servidor fallback iniciado na porta 5000")
        app.run(host="0.0.0.0", port=5000, debug=False)
        
    except Exception as e:
        logger.error(f"❌ Erro no servidor fallback: {e}")

if __name__ == "__main__":
    start_optimized_backend()
