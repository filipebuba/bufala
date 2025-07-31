#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Configuração do Swagger para Moransa Backend
"""

from flasgger import Swagger

# Template do Swagger
SWAGGER_TEMPLATE = {
    "swagger": "2.0",
    "info": {
        "title": "Moransa API - Sistema Multimodal com Gemma 3n",
        "description": """API revolucionária para assistência comunitária em Guiné-Bissau.
        
🌟 **Recursos Principais:**
- 🎭 Análise multimodal avançada (texto, imagem, áudio)
- 🗣️ Suporte nativo ao Crioulo da Guiné-Bissau
- 🚨 Sistema de emergências médicas e primeiros socorros
- 🎓 Conteúdo educacional adaptativo
- 🚜 Monitoramento agrícola inteligente
- 🤝 Validação colaborativa com gamificação
- 🧠 Seleção inteligente de modelos baseada no dispositivo
- ♿ Recursos de acessibilidade avançados
- 📱 Funcionamento offline-first
- 🏆 Sistema de ranking e badges comunitários

🤖 **Tecnologias:**
- Gemma 3n para processamento de linguagem natural
- Ollama para execução local de modelos
- Sistema de cache inteligente
- Análise multimodal com fusão de dados
- Tradução automática preservando contexto cultural
""",
        "version": "3.0.0",
        "contact": {
            "name": "Equipe Moransa",
            "email": "contato@bufala.app",
            "url": "https://bufala.app"
        },
        "license": {
            "name": "MIT",
            "url": "https://opensource.org/licenses/MIT"
        }
    },
    "host": "localhost:5000",
    "basePath": "/api",
    "schemes": ["http", "https"],
    "consumes": ["application/json", "multipart/form-data"],
    "produces": ["application/json"],
    "tags": [
        {
            "name": "Health",
            "description": "Endpoints de verificação de saúde do sistema"
        },
        {
            "name": "Medical",
            "description": "Assistência médica, emergências e primeiros socorros"
        },
        {
            "name": "Multimodal",
            "description": "Análise multimodal avançada com Gemma 3n"
        },
        {
            "name": "Education",
            "description": "Conteúdo educacional adaptativo e cultural"
        },
        {
            "name": "Agriculture",
            "description": "Monitoramento e análise agrícola inteligente"
        },
        {
            "name": "Translation",
            "description": "Tradução automática com preservação cultural"
        },
        {
            "name": "Accessibility",
            "description": "Recursos de acessibilidade avançados"
        },
        {
            "name": "Collaborative",
            "description": "Validação colaborativa e gamificação"
        },
        {
            "name": "Model Management",
            "description": "Gerenciamento e otimização de modelos de IA"
        },
        {
            "name": "Environmental",
            "description": "Monitoramento ambiental e sustentabilidade"
        }
    ]
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
                "description": "Status da resposta",
                "enum": ["error", "failed"]
            },
            "code": {
                "type": "integer",
                "description": "Código de erro HTTP"
            },
            "timestamp": {
                "type": "string",
                "format": "date-time",
                "description": "Timestamp do erro"
            }
        },
        "required": ["error", "status"]
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
                "description": "Status da resposta",
                "enum": ["success", "ok"]
            },
            "data": {
                "type": "object",
                "description": "Dados da resposta"
            },
            "timestamp": {
                "type": "string",
                "format": "date-time",
                "description": "Timestamp da resposta"
            }
        },
        "required": ["message", "status"]
    },
    "MultimodalContent": {
        "type": "object",
        "properties": {
            "text": {
                "type": "string",
                "description": "Conteúdo textual"
            },
            "image": {
                "type": "string",
                "format": "base64",
                "description": "Imagem em formato base64"
            },
            "audio": {
                "type": "string",
                "format": "base64",
                "description": "Áudio em formato base64"
            }
        }
    },
    "HealthStatus": {
        "type": "object",
        "properties": {
            "status": {
                "type": "string",
                "enum": ["healthy", "degraded", "down"],
                "description": "Status do serviço"
            },
            "uptime": {
                "type": "string",
                "description": "Tempo de atividade"
            },
            "version": {
                "type": "string",
                "description": "Versão do serviço"
            }
        }
    },
    "UserStats": {
        "type": "object",
        "properties": {
            "user_id": {
                "type": "string",
                "description": "ID do usuário"
            },
            "points": {
                "type": "integer",
                "description": "Pontos acumulados"
            },
            "level": {
                "type": "string",
                "description": "Nível do usuário"
            },
            "badges": {
                "type": "array",
                "items": {
                    "type": "string"
                },
                "description": "Badges conquistados"
            },
            "contributions": {
                "type": "integer",
                "description": "Número de contribuições"
            }
        }
    }
}

def setup_swagger(app):
    """
    Configura o Swagger para a aplicação Flask
    """
    return Swagger(app, config=SWAGGER_CONFIG, template=SWAGGER_TEMPLATE)