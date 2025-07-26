#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Configuração do Swagger para Bu Fala Backend
"""

from flasgger import Swagger

# Template do Swagger
SWAGGER_TEMPLATE = {
    "swagger": "2.0",
    "info": {
        "title": "Bu Fala API",
        "description": "API para assistência comunitária em Guiné-Bissau",
        "version": "2.0.0",
        "contact": {
            "name": "Equipe Bu Fala",
            "email": "contato@bufala.app"
        }
    },
    "host": "localhost:5000",
    "basePath": "/",
    "schemes": ["http"],
    "consumes": ["application/json"],
    "produces": ["application/json"]
}

# Configuração do Swagger
SWAGGER_CONFIG = {
    "headers": [],
    "specs": [
        {
            "endpoint": 'apispec',
            "route": '/api/swagger.json',
            "rule_filter": lambda rule: True,
            "model_filter": lambda tag: True,
        }
    ],
    "static_url_path": "/flasgger_static",
    "swagger_ui": True,
    "specs_route": "/api/docs/"
}

# Schemas comuns
COMMON_SCHEMAS = {
    "ErrorResponse": {
        "type": "object",
        "properties": {
            "error": {
                "type": "string",
                "description": "Mensagem de erro"
            },
            "status": {
                "type": "string",
                "description": "Status da resposta"
            }
        }
    },
    "SuccessResponse": {
        "type": "object",
        "properties": {
            "message": {
                "type": "string",
                "description": "Mensagem de sucesso"
            },
            "status": {
                "type": "string",
                "description": "Status da resposta"
            },
            "data": {
                "type": "object",
                "description": "Dados da resposta"
            }
        }
    }
}

def setup_swagger(app):
    """
    Configura o Swagger para a aplicação Flask
    """
    return Swagger(app, config=SWAGGER_CONFIG, template=SWAGGER_TEMPLATE)