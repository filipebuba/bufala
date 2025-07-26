#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Tratamento de Erros para Bu Fala Backend
Hackathon Gemma 3n
"""

import logging
from flask import Flask, jsonify, request
from datetime import datetime
from typing import Dict, Any

def setup_error_handlers(app: Flask):
    """Configurar handlers de erro para a aplicação Flask"""
    
    logger = logging.getLogger(__name__)
    
    @app.errorhandler(404)
    def not_found(error):
        """Handler para erro 404"""
        logger.warning(f"404 - Rota não encontrada: {request.url}")
        return jsonify({
            'error': 'Rota não encontrada',
            'message': 'O endpoint solicitado não existe',
            'status_code': 404,
            'timestamp': datetime.now().isoformat(),
            'path': request.path
        }), 404
    
    @app.errorhandler(405)
    def method_not_allowed(error):
        """Handler para erro 405"""
        logger.warning(f"405 - Método não permitido: {request.method} {request.url}")
        return jsonify({
            'error': 'Método não permitido',
            'message': f'O método {request.method} não é permitido para este endpoint',
            'status_code': 405,
            'timestamp': datetime.now().isoformat(),
            'path': request.path,
            'method': request.method
        }), 405
    
    @app.errorhandler(400)
    def bad_request(error):
        """Handler para erro 400"""
        logger.warning(f"400 - Requisição inválida: {request.url}")
        return jsonify({
            'error': 'Requisição inválida',
            'message': 'Os dados enviados são inválidos ou estão malformados',
            'status_code': 400,
            'timestamp': datetime.now().isoformat(),
            'path': request.path
        }), 400
    
    @app.errorhandler(500)
    def internal_error(error):
        """Handler para erro 500"""
        logger.error(f"500 - Erro interno: {str(error)}")
        return jsonify({
            'error': 'Erro interno do servidor',
            'message': 'Ocorreu um erro interno. Tente novamente mais tarde.',
            'status_code': 500,
            'timestamp': datetime.now().isoformat(),
            'path': request.path
        }), 500
    
    @app.errorhandler(Exception)
    def handle_exception(error):
        """Handler genérico para exceções não tratadas"""
        logger.error(f"Exceção não tratada: {str(error)}", exc_info=True)
        
        # Se for um erro HTTP conhecido, manter o código
        if hasattr(error, 'code'):
            return jsonify({
                'error': 'Erro do servidor',
                'message': str(error),
                'status_code': error.code,
                'timestamp': datetime.now().isoformat(),
                'path': request.path
            }), error.code
        
        # Para outros erros, retornar 500
        return jsonify({
            'error': 'Erro interno do servidor',
            'message': 'Ocorreu um erro inesperado. Tente novamente mais tarde.',
            'status_code': 500,
            'timestamp': datetime.now().isoformat(),
            'path': request.path
        }), 500

def create_error_response(
    error_type: str,
    message: str,
    status_code: int = 500,
    details: Dict[str, Any] = None
) -> Dict[str, Any]:
    """Criar resposta de erro padronizada"""
    
    response = {
        'success': False,
        'error': error_type,
        'message': message,
        'status_code': status_code,
        'timestamp': datetime.now().isoformat()
    }
    
    if details:
        response['details'] = details
    
    return response

def log_error(logger: logging.Logger, error: Exception, context: str = ""):
    """Registrar erro no log com contexto"""
    error_msg = f"Erro{' em ' + context if context else ''}: {str(error)}"
    logger.error(error_msg, exc_info=True)