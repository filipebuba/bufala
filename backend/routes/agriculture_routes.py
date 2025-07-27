#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Rotas de Agricultura - Moransa Backend
Hackathon Gemma 3n

Especializado em agricultura tropical e sustentável,
com foco em cultivos da Guiné-Bissau e proteção de colheitas.
"""

import logging
from flask import Blueprint, request, jsonify, current_app
from datetime import datetime
from config.settings import SystemPrompts
from utils.error_handler import create_error_response, log_error

# Criar blueprint
agriculture_bp = Blueprint('agriculture', __name__)
logger = logging.getLogger(__name__)

@agriculture_bp.route('/agriculture', methods=['POST'])
def agricultural_advice():
    """
    Fornecer conselhos agrícolas especializados
    ---
    tags:
      - Agricultura
    summary: Assistência agrícola especializada
    description: |
      Endpoint para fornecer conselhos agrícolas adaptados às condições locais.
      Especializado em agricultura sustentável para a Guiné-Bissau.
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - prompt
          properties:
            prompt:
              type: string
              description: Pergunta ou problema agrícola
              example: "Como proteger minha plantação de arroz das pragas?"
            crop_type:
              type: string
              enum: ["arroz", "milho", "mandioca", "amendoim", "feijão", "caju", "manga", "outros"]
              description: Tipo de cultura
              example: "arroz"
            season:
              type: string
              enum: ["seca", "chuvas", "transição"]
              description: Estação do ano
              example: "chuvas"
            problem_type:
              type: string
              enum: ["pragas", "doenças", "solo", "irrigação", "plantio", "colheita", "armazenamento"]
              description: Tipo de problema
              example: "pragas"
            farm_size:
              type: string
              enum: ["pequena", "média", "grande"]
              description: Tamanho da propriedade
              example: "pequena"
            resources:
              type: array
              items:
                type: string
              description: Recursos disponíveis
              example: ["ferramentas básicas", "sementes locais", "água limitada"]
            location:
              type: string
              description: Região ou localização
              example: "Bissau"
    responses:
      200:
        description: Conselho agrícola gerado com sucesso
        schema:
          type: object
          properties:
            success:
              type: boolean
              example: true
            message:
              type: string
              example: "Conselho agrícola gerado"
            data:
              type: object
              properties:
                advice:
                  type: string
                  description: Conselho agrícola detalhado
                immediate_actions:
                  type: array
                  items:
                    type: string
                  description: Ações imediatas recomendadas
                long_term_solutions:
                  type: array
                  items:
                    type: string
                  description: Soluções de longo prazo
                materials_needed:
                  type: array
                  items:
                    type: string
                  description: Materiais necessários
                best_practices:
                  type: array
                  items:
                    type: string
                  description: Melhores práticas
                seasonal_tips:
                  type: array
                  items:
                    type: string
                  description: Dicas sazonais
      400:
        description: Dados inválidos
        schema:
          $ref: '#/definitions/ErrorResponse'
      500:
        description: Erro interno do servidor
        schema:
          $ref: '#/definitions/ErrorResponse'
    """
    try:
        # Obter dados da requisição
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        # Extrair prompt/pergunta
        prompt = data.get('prompt') or data.get('question') or data.get('query')
        if not prompt:
            return jsonify(create_error_response(
                'missing_prompt',
                'Campo "prompt", "question" ou "query" é obrigatório',
                400
            )), 400
        
        # Obter parâmetros agrícolas
        crop_type = data.get('crop_type', 'geral')
        season = data.get('season', 'atual')  # seca, chuva, atual
        soil_type = data.get('soil_type', 'desconhecido')
        region = data.get('region', 'guinea-bissau')
        problem_type = data.get('problem_type', 'geral')  # pragas, doencas, nutricao, irrigacao
        
        # Preparar contexto agrícola
        agricultural_context = _prepare_agricultural_context(
            prompt, crop_type, season, soil_type, region, problem_type
        )
        
        # Obter serviço Gemma
        gemma_service = getattr(current_app, 'gemma_service', None)
        
        if gemma_service:
            # Gerar resposta usando Gemma
            response = gemma_service.generate_response(
                agricultural_context,
                SystemPrompts.AGRICULTURE,
                temperature=0.6,  # Temperatura moderada para conselhos práticos
                max_new_tokens=500
            )
            
            # Adicionar informações agrícolas específicas
            if response.get('success'):
                response['agricultural_info'] = {
                    'crop_type': crop_type,
                    'season': season,
                    'region': region,
                    'problem_type': problem_type,
                    'seasonal_tips': _get_seasonal_tips(season),
                    'local_resources': _get_local_resources(crop_type),
                    'sustainability_notes': "Práticas sustentáveis recomendadas para preservação do solo e meio ambiente"
                }
        else:
            # Resposta de fallback
            response = _get_agriculture_fallback_response(prompt, crop_type, season)
        
        return jsonify({
            'success': True,
            'data': response,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "conselho agrícola")
        return jsonify(create_error_response(
            'agriculture_error',
            'Erro ao fornecer conselho agrícola',
            500
        )), 500

@agriculture_bp.route('/agriculture/crop-calendar', methods=['POST'])
def crop_calendar():
    """Fornecer calendário de cultivo"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        crop = data.get('crop')
        region = data.get('region', 'guinea-bissau')
        
        if not crop:
            return jsonify(create_error_response(
                'missing_crop',
                'Campo "crop" é obrigatório',
                400
            )), 400
        
        # Obter calendário de cultivo
        calendar = _get_crop_calendar(crop, region)
        
        return jsonify({
            'success': True,
            'data': {
                'crop': crop,
                'region': region,
                'calendar': calendar,
                'climate_notes': "Calendário baseado no clima tropical da Guiné-Bissau",
                'adaptation_tips': "Ajuste as datas conforme condições locais específicas"
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "calendário de cultivo")
        return jsonify(create_error_response(
            'calendar_error',
            'Erro ao obter calendário de cultivo',
            500
        )), 500

@agriculture_bp.route('/agriculture/pest-control', methods=['POST'])
def pest_control_advice():
    """Conselhos para controle de pragas"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        pest_description = data.get('pest_description')
        crop_affected = data.get('crop_affected')
        severity = data.get('severity', 'moderado')  # leve, moderado, severo
        
        if not pest_description:
            return jsonify(create_error_response(
                'missing_pest_description',
                'Campo "pest_description" é obrigatório',
                400
            )), 400
        
        # Obter conselhos de controle de pragas
        control_methods = _get_pest_control_methods(pest_description, crop_affected, severity)
        
        return jsonify({
            'success': True,
            'data': {
                'pest_description': pest_description,
                'crop_affected': crop_affected,
                'severity': severity,
                'control_methods': control_methods,
                'prevention_tips': _get_prevention_tips(),
                'organic_solutions': _get_organic_solutions(),
                'safety_notes': "Use sempre equipamentos de proteção ao aplicar qualquer tratamento"
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "controle de pragas")
        return jsonify(create_error_response(
            'pest_control_error',
            'Erro ao fornecer conselhos de controle de pragas',
            500
        )), 500

@agriculture_bp.route('/agriculture/soil-health', methods=['POST'])
def soil_health_assessment():
    """Avaliação e conselhos para saúde do solo"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        soil_description = data.get('soil_description')
        current_crops = data.get('current_crops', [])
        problems_observed = data.get('problems_observed', [])
        
        if not soil_description:
            return jsonify(create_error_response(
                'missing_soil_description',
                'Campo "soil_description" é obrigatório',
                400
            )), 400
        
        # Avaliar saúde do solo
        soil_assessment = _assess_soil_health(soil_description, current_crops, problems_observed)
        
        return jsonify({
            'success': True,
            'data': {
                'soil_description': soil_description,
                'assessment': soil_assessment,
                'improvement_recommendations': _get_soil_improvement_tips(),
                'organic_amendments': _get_organic_amendments(),
                'crop_rotation_suggestions': _get_crop_rotation_suggestions(current_crops)
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "avaliação do solo")
        return jsonify(create_error_response(
            'soil_health_error',
            'Erro ao avaliar saúde do solo',
            500
        )), 500

@agriculture_bp.route('/agriculture/weather-advice', methods=['POST'])
def weather_based_advice():
    """Conselhos baseados no clima atual"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        weather_condition = data.get('weather_condition')
        current_crops = data.get('current_crops', [])
        season = data.get('season', 'atual')
        
        if not weather_condition:
            return jsonify(create_error_response(
                'missing_weather_condition',
                'Campo "weather_condition" é obrigatório',
                400
            )), 400
        
        # Obter conselhos baseados no clima
        weather_advice = _get_weather_based_advice(weather_condition, current_crops, season)
        
        return jsonify({
            'success': True,
            'data': {
                'weather_condition': weather_condition,
                'season': season,
                'advice': weather_advice,
                'protective_measures': _get_protective_measures(weather_condition),
                'timing_recommendations': _get_timing_recommendations(weather_condition)
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "conselhos climáticos")
        return jsonify(create_error_response(
            'weather_advice_error',
            'Erro ao fornecer conselhos climáticos',
            500
        )), 500

def _prepare_agricultural_context(prompt, crop_type, season, soil_type, region, problem_type):
    """Preparar contexto agrícola"""
    context = f"Questão agrícola: {prompt}"
    context += f"\nTipo de cultura: {crop_type}"
    context += f"\nEstação: {season}"
    context += f"\nTipo de solo: {soil_type}"
    context += f"\nRegião: {region}"
    context += f"\nTipo de problema: {problem_type}"
    context += "\n\nPor favor, forneça conselhos agrícolas práticos e sustentáveis, considerando o clima tropical da Guiné-Bissau e recursos limitados."
    
    return context

def _get_seasonal_tips(season):
    """Obter dicas sazonais"""
    tips = {
        'seca': [
            "Conserve água com irrigação eficiente",
            "Use cobertura morta para reter umidade",
            "Plante culturas resistentes à seca"
        ],
        'chuva': [
            "Garanta boa drenagem",
            "Monitore doenças fúngicas",
            "Aproveite para plantio de culturas que precisam de água"
        ],
        'atual': [
            "Observe as condições climáticas locais",
            "Adapte práticas conforme a estação",
            "Mantenha flexibilidade no planejamento"
        ]
    }
    return tips.get(season, tips['atual'])

def _get_local_resources(crop_type):
    """Obter recursos locais disponíveis"""
    resources = {
        'arroz': ["Casca de arroz para cobertura", "Água de rios e poços"],
        'milho': ["Restos de milho para compostagem", "Rotação com leguminosas"],
        'mandioca': ["Folhas para alimentação animal", "Raízes para processamento"],
        'amendoim': ["Cascas para cobertura", "Fixação de nitrogênio no solo"],
        'geral': ["Materiais orgânicos locais", "Conhecimento tradicional da comunidade"]
    }
    return resources.get(crop_type, resources['geral'])

def _get_agriculture_fallback_response(prompt, crop_type, season):
    """Resposta de fallback para agricultura"""
    return {
        'response': f"Para questões sobre {crop_type} na estação {season}, recomendo consultar técnicos agrícolas locais ou cooperativas de agricultores. A agricultura sustentável é essencial para a segurança alimentar da comunidade.",
        'success': True,
        'fallback': True,
        'agricultural_info': {
            'crop_type': crop_type,
            'season': season,
            'recommendation': "Busque orientação de especialistas locais e pratique agricultura sustentável"
        }
    }

def _get_crop_calendar(crop, region):
    """Obter calendário básico de cultivo"""
    calendars = {
        'arroz': {
            'preparacao_solo': 'Abril-Maio',
            'plantio': 'Maio-Junho',
            'cuidados': 'Junho-Setembro',
            'colheita': 'Outubro-Novembro'
        },
        'milho': {
            'preparacao_solo': 'Março-Abril',
            'plantio': 'Abril-Maio',
            'cuidados': 'Maio-Agosto',
            'colheita': 'Agosto-Setembro'
        },
        'mandioca': {
            'preparacao_solo': 'Março-Abril',
            'plantio': 'Abril-Junho',
            'cuidados': 'Durante todo o ciclo',
            'colheita': '8-12 meses após plantio'
        }
    }
    
    return calendars.get(crop, {
        'preparacao_solo': 'Início da estação chuvosa',
        'plantio': 'Durante estação chuvosa',
        'cuidados': 'Durante todo o ciclo',
        'colheita': 'Conforme maturação da cultura'
    })

def _get_pest_control_methods(pest_description, crop, severity):
    """Obter métodos de controle de pragas"""
    return {
        'immediate_actions': [
            "Remover plantas infectadas",
            "Isolar área afetada",
            "Aplicar tratamento orgânico"
        ],
        'organic_methods': [
            "Extrato de nim",
            "Sabão neutro diluído",
            "Armadilhas naturais"
        ],
        'biological_control': [
            "Introduzir predadores naturais",
            "Plantar culturas repelentes",
            "Manter biodiversidade"
        ],
        'prevention': [
            "Rotação de culturas",
            "Limpeza regular da área",
            "Monitoramento constante"
        ]
    }

def _get_prevention_tips():
    """Obter dicas de prevenção"""
    return [
        "Mantenha a área limpa e livre de ervas daninhas",
        "Pratique rotação de culturas",
        "Use sementes de qualidade",
        "Monitore regularmente as plantas",
        "Mantenha boa drenagem"
    ]

def _get_organic_solutions():
    """Obter soluções orgânicas"""
    return [
        "Extrato de alho e cebola",
        "Óleo de nim",
        "Sabão de coco diluído",
        "Cinza de madeira",
        "Compostagem bem curtida"
    ]

def _assess_soil_health(description, crops, problems):
    """Avaliar saúde básica do solo"""
    return {
        'general_condition': 'Avaliação baseada na descrição fornecida',
        'main_concerns': problems if problems else ['Nenhum problema específico relatado'],
        'recommendations': [
            "Adicionar matéria orgânica",
            "Melhorar drenagem se necessário",
            "Testar pH do solo",
            "Praticar rotação de culturas"
        ]
    }

def _get_soil_improvement_tips():
    """Obter dicas de melhoria do solo"""
    return [
        "Adicionar compostagem regularmente",
        "Usar cobertura morta",
        "Plantar leguminosas para fixar nitrogênio",
        "Evitar compactação do solo",
        "Manter cobertura vegetal"
    ]

def _get_organic_amendments():
    """Obter amendos orgânicos"""
    return [
        "Esterco bem curtido",
        "Compostagem de restos vegetais",
        "Cinza de madeira (com moderação)",
        "Folhas decompostas",
        "Casca de arroz"
    ]

def _get_crop_rotation_suggestions(current_crops):
    """Obter sugestões de rotação"""
    return [
        "Alternar entre leguminosas e cereais",
        "Incluir plantas de cobertura",
        "Variar famílias de plantas",
        "Considerar culturas de ciclo curto",
        "Manter período de pousio quando possível"
    ]

def _get_weather_based_advice(weather, crops, season):
    """Obter conselhos baseados no clima"""
    advice = {
        'chuva_intensa': [
            "Garanta boa drenagem",
            "Proteja plantas jovens",
            "Monitore doenças fúngicas"
        ],
        'seca': [
            "Conserve água",
            "Use cobertura morta",
            "Irrigue nas horas mais frescas"
        ],
        'vento_forte': [
            "Proteja plantas altas",
            "Reforce estruturas de apoio",
            "Evite aplicações de defensivos"
        ]
    }
    
    return advice.get(weather, [
        "Monitore condições climáticas",
        "Adapte práticas conforme necessário",
        "Mantenha flexibilidade no manejo"
    ])

def _get_protective_measures(weather):
    """Obter medidas de proteção"""
    measures = {
        'chuva_intensa': ["Cobertura temporária", "Drenagem adequada"],
        'seca': ["Irrigação eficiente", "Sombreamento"],
        'vento_forte': ["Quebra-ventos", "Estruturas de apoio"]
    }
    
    return measures.get(weather, ["Monitoramento constante", "Adaptação conforme necessário"])

def _get_timing_recommendations(weather):
    """Obter recomendações de timing"""
    timing = {
        'chuva_intensa': "Evite trabalhos no campo durante chuvas fortes",
        'seca': "Trabalhe nas horas mais frescas do dia",
        'vento_forte': "Evite aplicações e trabalhos com plantas altas"
    }
    
    return timing.get(weather, "Adapte horários conforme condições climáticas")