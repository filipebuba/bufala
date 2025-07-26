#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Rotas de Saúde do Sistema - Bu Fala Backend
Hackathon Gemma 3n
"""

import logging
from flask import Blueprint, jsonify, current_app
from datetime import datetime
from utils.error_handler import create_error_response, log_error

# Criar blueprint
health_bp = Blueprint('health', __name__)
logger = logging.getLogger(__name__)

@health_bp.route('/health', methods=['GET'])
def health_check():
    """
    Verificação de saúde do sistema
    ---
    tags:
      - Saúde
    summary: Verificar status do sistema
    description: |
      Endpoint para verificar o status de saúde de todos os serviços do Bu Fala.
      Retorna informações detalhadas sobre:
      - Status dos serviços (backend, Gemma, health service)
      - Informações do sistema (CPU, memória, disco)
      - Timestamp da verificação
    responses:
      200:
        description: Sistema funcionando corretamente
        schema:
          type: object
          properties:
            success:
              type: boolean
              example: true
            message:
              type: string
              example: "Sistema funcionando"
            data:
              $ref: '#/definitions/HealthStatus'
      500:
        description: Erro interno do servidor
        schema:
          $ref: '#/definitions/ErrorResponse'
    """
    try:
        # Obter serviço de saúde
        health_service = getattr(current_app, 'health_service', None)
        
        if health_service:
            # Obter status completo
            health_status = health_service.get_system_health()
            
            return jsonify({
                'success': True,
                'message': 'Sistema funcionando',
                'data': health_status
            })
        else:
            # Fallback se serviço não estiver disponível
            return jsonify({
                'success': True,
                'message': 'Sistema funcionando (modo básico)',
                'data': {
                    'status': 'basic',
                    'timestamp': datetime.now().isoformat(),
                    'services': {
                        'backend': 'running',
                        'health_service': 'unavailable'
                    }
                }
            })
            
    except Exception as e:
        log_error(logger, e, "verificação de saúde")
        return jsonify(create_error_response(
            'health_check_error',
            'Erro ao verificar saúde do sistema',
            500
        )), 500

@health_bp.route('/health/quick', methods=['GET'])
def quick_health_check():
    """Verificação rápida de saúde"""
    try:
        health_service = getattr(current_app, 'health_service', None)
        
        if health_service:
            quick_status = health_service.get_quick_status()
            
            return jsonify({
                'success': True,
                'data': quick_status
            })
        else:
            return jsonify({
                'success': True,
                'data': {
                    'status': 'basic',
                    'timestamp': datetime.now().isoformat()
                }
            })
            
    except Exception as e:
        log_error(logger, e, "verificação rápida de saúde")
        return jsonify(create_error_response(
            'quick_health_error',
            'Erro na verificação rápida',
            500
        )), 500

@health_bp.route('/health/dependencies', methods=['GET'])
def check_dependencies():
    """Verificar dependências do sistema"""
    try:
        health_service = getattr(current_app, 'health_service', None)
        
        if health_service:
            deps_status = health_service.check_dependencies()
            
            return jsonify({
                'success': True,
                'data': deps_status
            })
        else:
            # Verificação básica de dependências
            basic_deps = {
                'flask': True,  # Se chegou aqui, Flask está funcionando
                'timestamp': datetime.now().isoformat()
            }
            
            return jsonify({
                'success': True,
                'data': basic_deps
            })
            
    except Exception as e:
        log_error(logger, e, "verificação de dependências")
        return jsonify(create_error_response(
            'dependencies_error',
            'Erro ao verificar dependências',
            500
        )), 500

@health_bp.route('/health/gemma', methods=['GET'])
def gemma_health():
    """Verificar saúde específica do serviço Gemma"""
    try:
        gemma_service = getattr(current_app, 'gemma_service', None)
        
        if gemma_service:
            gemma_status = gemma_service.get_health_status()
            
            return jsonify({
                'success': True,
                'data': gemma_status
            })
        else:
            return jsonify({
                'success': False,
                'message': 'Serviço Gemma não disponível',
                'data': {
                    'status': 'unavailable',
                    'timestamp': datetime.now().isoformat()
                }
            })
            
    except Exception as e:
        log_error(logger, e, "verificação de saúde do Gemma")
        return jsonify(create_error_response(
            'gemma_health_error',
            'Erro ao verificar saúde do Gemma',
            500
        )), 500