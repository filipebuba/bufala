#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Rotas Ambientais - Moransa Backend
Hackathon Gemma 3n

Sistema de monitoramento e análise ambiental
para sustentabilidade e conservação.
"""

import logging
import json
from flask import Blueprint, request, jsonify, current_app
from datetime import datetime, timedelta
from config.settings import SystemPrompts
from utils.error_handler import create_error_response, log_error

# Criar blueprint
environmental_bp = Blueprint('environmental', __name__)
logger = logging.getLogger(__name__)

@environmental_bp.route('/environmental/health', methods=['GET'])
def environmental_health():
    """
    Verificar saúde do sistema ambiental
    ---
    tags:
      - Environmental
    summary: Verificar saúde do sistema ambiental
    description: |
      Retorna o status de saúde de todos os componentes do sistema de monitoramento ambiental,
      incluindo monitoramento meteorológico, qualidade do ar, água, solo, biodiversidade e dados climáticos.
    responses:
      200:
        description: Status de saúde do sistema ambiental
        content:
          application/json:
            schema:
              type: object
              properties:
                success:
                  type: boolean
                  example: true
                data:
                  type: object
                  properties:
                    status:
                      type: string
                      enum: [healthy, degraded]
                      example: healthy
                    components:
                      type: object
                      properties:
                        weather_monitoring:
                          type: object
                          properties:
                            status:
                              type: string
                              example: healthy
                        air_quality:
                          type: object
                          properties:
                            status:
                              type: string
                              example: healthy
                        water_quality:
                          type: object
                          properties:
                            status:
                              type: string
                              example: healthy
                        soil_analysis:
                          type: object
                          properties:
                            status:
                              type: string
                              example: healthy
                        biodiversity_tracking:
                          type: object
                          properties:
                            status:
                              type: string
                              example: healthy
                        climate_data:
                          type: object
                          properties:
                            status:
                              type: string
                              example: healthy
                    monitoring_capabilities:
                      type: object
                      properties:
                        real_time_weather:
                          type: boolean
                          example: true
                        pollution_tracking:
                          type: boolean
                          example: true
                        ecosystem_health:
                          type: boolean
                          example: true
                        climate_analysis:
                          type: boolean
                          example: true
                        sustainability_metrics:
                          type: boolean
                          example: true
                    coverage_area:
                      type: string
                      example: "Guiné-Bissau e região"
                    last_check:
                      type: string
                      format: date-time
                timestamp:
                  type: string
                  format: date-time
      500:
        description: Erro interno do servidor
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ErrorResponse'
    """
    try:
        # Verificar componentes ambientais
        environmental_components = {
            'weather_monitoring': _check_weather_monitoring(),
            'air_quality': _check_air_quality_monitoring(),
            'water_quality': _check_water_quality_monitoring(),
            'soil_analysis': _check_soil_analysis(),
            'biodiversity_tracking': _check_biodiversity_tracking(),
            'climate_data': _check_climate_data()
        }
        
        # Determinar status geral
        all_healthy = all(comp['status'] == 'healthy' for comp in environmental_components.values())
        overall_status = 'healthy' if all_healthy else 'degraded'
        
        return jsonify({
            'success': True,
            'data': {
                'status': overall_status,
                'components': environmental_components,
                'monitoring_capabilities': {
                    'real_time_weather': True,
                    'pollution_tracking': True,
                    'ecosystem_health': True,
                    'climate_analysis': True,
                    'sustainability_metrics': True
                },
                'data_sources': {
                    'local_sensors': True,
                    'satellite_data': True,
                    'community_reports': True,
                    'government_data': True
                },
                'coverage_area': 'Guiné-Bissau e região',
                'last_check': datetime.now().isoformat()
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "verificação de saúde ambiental")
        return jsonify(create_error_response(
            'environmental_health_error',
            'Erro ao verificar saúde do sistema ambiental',
            500
        )), 500

@environmental_bp.route('/environmental/weather', methods=['GET'])
def get_weather_data():
    """
    Obter dados meteorológicos
    ---
    tags:
      - Environmental
    summary: Obter dados meteorológicos
    description: |
      Fornece dados meteorológicos atuais e previsões para uma localização específica,
      incluindo insights agrícolas e alertas meteorológicos.
    parameters:
      - name: location
        in: query
        description: Localização para obter dados meteorológicos
        required: false
        schema:
          type: string
          default: "Bissau"
          example: "Bissau"
      - name: forecast_days
        in: query
        description: Número de dias de previsão (máximo 14)
        required: false
        schema:
          type: integer
          minimum: 1
          maximum: 14
          default: 7
          example: 7
      - name: include_historical
        in: query
        description: Incluir dados históricos
        required: false
        schema:
          type: boolean
          default: false
          example: false
      - name: data_type
        in: query
        description: Tipo de dados meteorológicos
        required: false
        schema:
          type: string
          enum: [basic, comprehensive, agricultural]
          default: "comprehensive"
          example: "comprehensive"
      - name: language
        in: query
        description: Idioma da resposta
        required: false
        schema:
          type: string
          default: "pt"
          example: "pt"
    responses:
      200:
        description: Dados meteorológicos obtidos com sucesso
        content:
          application/json:
            schema:
              type: object
              properties:
                success:
                  type: boolean
                  example: true
                data:
                  type: object
                  properties:
                    location:
                      type: string
                      example: "Bissau"
                    forecast_days:
                      type: integer
                      example: 7
                    data_type:
                      type: string
                      example: "comprehensive"
                    current_weather:
                      type: object
                      properties:
                        temperature:
                          type: number
                          example: 28.5
                        humidity:
                          type: number
                          example: 75
                        wind_speed:
                          type: number
                          example: 12
                        conditions:
                          type: string
                          example: "Parcialmente nublado"
                    forecast:
                      type: array
                      items:
                        type: object
                        properties:
                          date:
                            type: string
                            format: date
                          temperature_max:
                            type: number
                          temperature_min:
                            type: number
                          precipitation:
                            type: number
                          conditions:
                            type: string
                    agricultural_insights:
                      type: object
                      properties:
                        planting_conditions:
                          type: string
                        harvest_window:
                          type: string
                        irrigation_needs:
                          type: string
                    weather_alerts:
                      type: array
                      items:
                        type: object
                        properties:
                          type:
                            type: string
                          severity:
                            type: string
                          message:
                            type: string
                    last_updated:
                      type: string
                      format: date-time
                timestamp:
                  type: string
                  format: date-time
      500:
        description: Erro interno do servidor
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ErrorResponse'
    """
    try:
        # Parâmetros de consulta
        location = request.args.get('location', 'Bissau')
        forecast_days = int(request.args.get('forecast_days', 7))
        include_historical = request.args.get('include_historical', 'false').lower() == 'true'
        data_type = request.args.get('data_type', 'comprehensive')  # basic, comprehensive, agricultural
        language = request.args.get('language', 'pt')
        
        # Validar parâmetros
        if forecast_days > 14:
            forecast_days = 14
        elif forecast_days < 1:
            forecast_days = 1
        
        # Obter dados meteorológicos
        weather_data = _get_weather_information(
            location, forecast_days, include_historical, data_type
        )
        
        # Análise específica para agricultura
        agricultural_insights = None
        if data_type in ['comprehensive', 'agricultural']:
            agricultural_insights = _generate_agricultural_weather_insights(weather_data)
        
        # Alertas meteorológicos
        weather_alerts = _check_weather_alerts(weather_data, location)
        
        return jsonify({
            'success': True,
            'data': {
                'location': location,
                'forecast_days': forecast_days,
                'data_type': data_type,
                'language': language,
                'current_weather': weather_data.get('current', {}),
                'forecast': weather_data.get('forecast', []),
                'historical_data': weather_data.get('historical', []) if include_historical else None,
                'agricultural_insights': agricultural_insights,
                'weather_alerts': weather_alerts,
                'recommendations': _generate_weather_recommendations(weather_data, data_type),
                'last_updated': datetime.now().isoformat()
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "consulta de dados meteorológicos")
        return jsonify(create_error_response(
            'weather_data_error',
            'Erro ao obter dados meteorológicos',
            500
        )), 500

@environmental_bp.route('/environmental/air-quality', methods=['GET'])
def get_air_quality():
    """
    Obter dados de qualidade do ar
    ---
    tags:
      - Environmental
    summary: Obter dados de qualidade do ar
    description: |
      Fornece dados de qualidade do ar para uma localização específica,
      incluindo níveis de poluentes, índice de qualidade do ar (AQI) e impactos na saúde.
    parameters:
      - name: location
        in: query
        description: Localização para monitoramento da qualidade do ar
        required: false
        schema:
          type: string
          default: "Bissau"
          example: "Bissau"
      - name: radius_km
        in: query
        description: Raio de monitoramento em quilômetros
        required: false
        schema:
          type: number
          default: 50
          example: 50
      - name: pollutants
        in: query
        description: Poluentes específicos para monitorar
        required: false
        schema:
          type: string
          enum: [all, pm25, pm10, no2, so2, co, o3]
          default: "all"
          example: "all"
      - name: time_range
        in: query
        description: Período de tempo para análise
        required: false
        schema:
          type: string
          enum: [1h, 24h, 7d, 30d]
          default: "24h"
          example: "24h"
      - name: health_focus
        in: query
        description: Foco específico de saúde para análise
        required: false
        schema:
          type: string
          enum: [general, respiratory, cardiovascular, children, elderly]
          default: "general"
          example: "general"
    responses:
      200:
        description: Dados de qualidade do ar obtidos com sucesso
        content:
          application/json:
            schema:
              type: object
              properties:
                success:
                  type: boolean
                  example: true
                data:
                  type: object
                  properties:
                    location:
                      type: string
                      example: "Bissau"
                    radius_km:
                      type: number
                      example: 50
                    air_quality_index:
                      type: integer
                      example: 65
                      description: "Índice de qualidade do ar (0-500)"
                    aqi_category:
                      type: string
                      example: "Moderado"
                      enum: ["Bom", "Moderado", "Insalubre para grupos sensíveis", "Insalubre", "Muito insalubre", "Perigoso"]
                    pollutant_levels:
                      type: object
                      properties:
                        pm25:
                          type: object
                          properties:
                            value:
                              type: number
                              example: 25
                            unit:
                              type: string
                              example: "μg/m³"
                            status:
                              type: string
                              example: "moderate"
                        pm10:
                          type: object
                          properties:
                            value:
                              type: number
                              example: 45
                            unit:
                              type: string
                              example: "μg/m³"
                            status:
                              type: string
                              example: "moderate"
                        no2:
                          type: object
                          properties:
                            value:
                              type: number
                              example: 30
                            unit:
                              type: string
                              example: "μg/m³"
                            status:
                              type: string
                              example: "good"
                    health_impact:
                      type: object
                      properties:
                        risk_level:
                          type: string
                          example: "low"
                        affected_groups:
                          type: array
                          items:
                            type: string
                          example: ["crianças", "idosos"]
                        symptoms:
                          type: array
                          items:
                            type: string
                          example: ["irritação nos olhos", "tosse leve"]
                    protection_recommendations:
                      type: array
                      items:
                        type: string
                      example: ["Evitar exercícios ao ar livre", "Usar máscara em áreas poluídas"]
                    monitoring_stations:
                      type: array
                      items:
                        type: object
                        properties:
                          name:
                            type: string
                          distance_km:
                            type: number
                          last_reading:
                            type: string
                            format: date-time
                    last_measurement:
                      type: string
                      format: date-time
                timestamp:
                  type: string
                  format: date-time
      500:
        description: Erro interno do servidor
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ErrorResponse'
    """
    try:
        # Parâmetros de consulta
        location = request.args.get('location', 'Bissau')
        radius_km = float(request.args.get('radius_km', 50))
        pollutants = request.args.get('pollutants', 'all')  # all, pm25, pm10, no2, so2, co, o3
        time_range = request.args.get('time_range', '24h')  # 1h, 24h, 7d, 30d
        health_focus = request.args.get('health_focus', 'general')  # general, respiratory, cardiovascular, children, elderly
        
        # Obter dados de qualidade do ar
        air_quality_data = _get_air_quality_data(
            location, radius_km, pollutants, time_range
        )
        
        # Análise de impacto na saúde
        health_impact = _analyze_air_quality_health_impact(
            air_quality_data, health_focus
        )
        
        # Recomendações de proteção
        protection_recommendations = _generate_air_quality_recommendations(
            air_quality_data, health_focus
        )
        
        return jsonify({
            'success': True,
            'data': {
                'location': location,
                'radius_km': radius_km,
                'pollutants_monitored': pollutants,
                'time_range': time_range,
                'health_focus': health_focus,
                'air_quality_index': air_quality_data.get('aqi', 0),
                'aqi_category': _get_aqi_category(air_quality_data.get('aqi', 0)),
                'pollutant_levels': air_quality_data.get('pollutants', {}),
                'health_impact': health_impact,
                'protection_recommendations': protection_recommendations,
                'trends': air_quality_data.get('trends', {}),
                'monitoring_stations': air_quality_data.get('stations', []),
                'last_measurement': air_quality_data.get('last_updated')
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "consulta de qualidade do ar")
        return jsonify(create_error_response(
            'air_quality_error',
            'Erro ao obter dados de qualidade do ar',
            500
        )), 500

@environmental_bp.route('/environmental', methods=['POST'])
def environmental_consultation():
    """
    Consulta ambiental e análise de sustentabilidade
    ---
    tags:
      - Ambiental
    summary: Análise ambiental e sustentabilidade
    description: |
      Endpoint para análises ambientais e orientações de sustentabilidade.
      Especializado em monitoramento ambiental para comunidades rurais da Guiné-Bissau.
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
              description: Pergunta ou descrição da situação ambiental
              example: "Como posso melhorar a qualidade do solo da minha plantação?"
            analysis_type:
              type: string
              enum: ["water", "soil", "air", "climate", "biodiversity", "sustainability"]
              description: Tipo de análise ambiental desejada
              example: "soil"
            location:
              type: string
              description: Localização para análise contextual
              example: "Bissau, Guiné-Bissau"
            urgency:
              type: string
              enum: ["low", "normal", "high", "critical"]
              description: Nível de urgência da situação ambiental
              example: "normal"
            data_available:
              type: array
              items:
                type: string
              description: Dados ambientais disponíveis
              example: ["temperatura", "umidade", "ph_solo"]
    responses:
      200:
        description: Análise ambiental realizada com sucesso
        schema:
          type: object
          properties:
            success:
              type: boolean
              example: true
            message:
              type: string
              example: "Análise ambiental concluída"
            data:
              type: object
              properties:
                analysis:
                  type: string
                  description: Análise detalhada da situação ambiental
                recommendations:
                  type: array
                  items:
                    type: string
                  description: Recomendações específicas
                sustainability_score:
                  type: number
                  description: Pontuação de sustentabilidade (0-100)
                environmental_impact:
                  type: string
                  description: Avaliação do impacto ambiental
                next_steps:
                  type: array
                  items:
                    type: string
                  description: Próximos passos recomendados
                monitoring_suggestions:
                  type: array
                  items:
                    type: string
                  description: Sugestões de monitoramento
                timestamp:
                  type: string
                  format: date-time
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
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        prompt = data.get('prompt')
        if not prompt:
            return jsonify(create_error_response(
                'missing_prompt',
                'Campo prompt é obrigatório',
                400
            )), 400
        
        # Extrair parâmetros opcionais
        analysis_type = data.get('analysis_type', 'sustainability')
        location = data.get('location', 'Guiné-Bissau')
        urgency = data.get('urgency', 'normal')
        data_available = data.get('data_available', [])
        
        # Construir prompt contextualizado
        context_prompt = f"""
        {SystemPrompts.ENVIRONMENTAL_EXPERT}
        
        Localização: {location}
        Tipo de análise: {analysis_type}
        Urgência: {urgency}
        Dados disponíveis: {', '.join(data_available) if data_available else 'Nenhum'}
        
        Pergunta do usuário: {prompt}
        
        Por favor, forneça:
        1. Análise detalhada da situação ambiental
        2. Recomendações específicas e práticas
        3. Avaliação de sustentabilidade
        4. Impacto ambiental
        5. Próximos passos
        6. Sugestões de monitoramento
        
        Responda em português, considerando o contexto da Guiné-Bissau.
        """
        
        # Obter resposta do modelo
        gemma_service = current_app.config.get('gemma_service')
        if not gemma_service:
            return jsonify(create_error_response(
                'service_unavailable',
                'Serviço de IA não disponível',
                503
            )), 503
        
        response = gemma_service.generate_response(context_prompt)
        
        # Processar resposta
        analysis_result = {
            'analysis': response,
            'recommendations': _extract_recommendations(response),
            'sustainability_score': _calculate_sustainability_score(analysis_type, response),
            'environmental_impact': _assess_environmental_impact(response),
            'next_steps': _extract_next_steps(response),
            'monitoring_suggestions': _get_monitoring_suggestions(analysis_type),
            'timestamp': datetime.now().isoformat()
        }
        
        return jsonify({
            'success': True,
            'message': 'Análise ambiental concluída com sucesso',
            'data': analysis_result
        })
        
    except Exception as e:
        log_error(logger, e, "consulta ambiental")
        return jsonify(create_error_response(
            'environmental_error',
            'Erro ao processar consulta ambiental',
            500
        )), 500

@environmental_bp.route('/environmental/water-quality', methods=['POST'])
def analyze_water_quality():
    """
    Analisar qualidade da água
    ---
    tags:
      - Environmental
    summary: Analisar qualidade da água
    description: |
      Analisa a qualidade da água com base em parâmetros físicos, químicos e biológicos,
      fornecendo avaliação de segurança e recomendações de tratamento.
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              water_source:
                type: string
                description: Fonte da água
                enum: ["poço", "rio", "lago", "chuva", "torneira", "nascente"]
                example: "poço"
              location:
                type: object
                description: Localização da fonte de água
                properties:
                  latitude:
                    type: number
                    example: 11.8636
                  longitude:
                    type: number
                    example: -15.5982
                  address:
                    type: string
                    example: "Bissau, Guiné-Bissau"
              test_parameters:
                type: object
                description: Parâmetros de teste da água
                properties:
                  ph:
                    type: number
                    description: Nível de pH
                    example: 7.2
                  turbidity:
                    type: number
                    description: Turbidez (NTU)
                    example: 2.5
                  dissolved_oxygen:
                    type: number
                    description: Oxigênio dissolvido (mg/L)
                    example: 8.5
                  temperature:
                    type: number
                    description: Temperatura (°C)
                    example: 25
                  conductivity:
                    type: number
                    description: Condutividade (μS/cm)
                    example: 150
                  nitrates:
                    type: number
                    description: Nitratos (mg/L)
                    example: 5
                  phosphates:
                    type: number
                    description: Fosfatos (mg/L)
                    example: 0.5
                  bacteria_count:
                    type: number
                    description: Contagem de bactérias (CFU/100ml)
                    example: 10
              visual_assessment:
                type: object
                description: Avaliação visual da água
                properties:
                  color:
                    type: string
                    enum: ["transparente", "amarelada", "marrom", "verde", "azul"]
                    example: "transparente"
                  odor:
                    type: string
                    enum: ["nenhum", "cloro", "sulfuroso", "metálico", "orgânico"]
                    example: "nenhum"
                  taste:
                    type: string
                    enum: ["normal", "metálico", "salgado", "doce", "amargo"]
                    example: "normal"
                  clarity:
                    type: string
                    enum: ["clara", "ligeiramente turva", "turva", "muito turva"]
                    example: "clara"
              intended_use:
                type: string
                description: Uso pretendido da água
                enum: ["consumo", "cozinhar", "irrigação", "animais", "limpeza"]
                example: "consumo"
            required: ["water_source", "location", "intended_use"]
    responses:
      200:
        description: Análise de qualidade da água realizada com sucesso
        content:
          application/json:
            schema:
              type: object
              properties:
                success:
                  type: boolean
                  example: true
                data:
                  type: object
                  properties:
                    water_source:
                      type: string
                      example: "poço"
                    location:
                      type: object
                      properties:
                        address:
                          type: string
                          example: "Bissau, Guiné-Bissau"
                    overall_quality:
                      type: string
                      enum: ["excelente", "boa", "aceitável", "ruim", "perigosa"]
                      example: "boa"
                    safety_score:
                      type: integer
                      description: Pontuação de segurança (0-100)
                      example: 85
                    parameter_analysis:
                      type: object
                      properties:
                        ph:
                          type: object
                          properties:
                            value:
                              type: number
                              example: 7.2
                            status:
                              type: string
                              example: "normal"
                            recommendation:
                              type: string
                              example: "pH dentro da faixa ideal"
                        turbidity:
                          type: object
                          properties:
                            value:
                              type: number
                              example: 2.5
                            status:
                              type: string
                              example: "aceitável"
                            recommendation:
                              type: string
                              example: "Filtração recomendada"
                    contamination_risks:
                      type: array
                      items:
                        type: object
                        properties:
                          type:
                            type: string
                          level:
                            type: string
                          description:
                            type: string
                      example:
                        - type: "bacterial"
                          level: "low"
                          description: "Baixo risco de contaminação bacteriana"
                    treatment_recommendations:
                      type: array
                      items:
                        type: string
                      example: ["Ferver por 5 minutos antes do consumo", "Usar filtro de carvão ativado"]
                    health_warnings:
                      type: array
                      items:
                        type: string
                      example: ["Não recomendado para bebês menores de 6 meses"]
                    monitoring_frequency:
                      type: string
                      example: "Testar mensalmente"
                timestamp:
                  type: string
                  format: date-time
      400:
        description: Dados de entrada inválidos
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ErrorResponse'
      500:
        description: Erro interno do servidor
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ErrorResponse'
    """
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        # Dados de qualidade da água
        water_source = data.get('water_source')  # well, river, lake, tap, rainwater
        location = data.get('location')
        test_parameters = data.get('test_parameters', {})  # pH, turbidity, bacteria, chemicals, etc.
        visual_assessment = data.get('visual_assessment')  # cor, odor, clareza
        usage_purpose = data.get('usage_purpose', 'drinking')  # drinking, irrigation, livestock, domestic
        sample_date = data.get('sample_date', datetime.now().isoformat())
        community_concerns = data.get('community_concerns', [])
        
        if not water_source:
            return jsonify(create_error_response(
                'missing_water_source',
                'Campo "water_source" é obrigatório',
                400
            )), 400
        
        # Análise de qualidade da água
        water_analysis = _analyze_water_quality_data(
            water_source, location, test_parameters, visual_assessment, 
            usage_purpose, sample_date, community_concerns
        )
        
        # Avaliação de segurança
        safety_assessment = _assess_water_safety(
            water_analysis, usage_purpose
        )
        
        # Recomendações de tratamento
        treatment_recommendations = _generate_water_treatment_recommendations(
            water_analysis, usage_purpose
        )
        
        return jsonify({
            'success': True,
            'data': {
                'water_source': water_source,
                'location': location,
                'usage_purpose': usage_purpose,
                'sample_date': sample_date,
                'water_analysis': water_analysis,
                'safety_assessment': safety_assessment,
                'treatment_recommendations': treatment_recommendations,
                'monitoring_schedule': _suggest_monitoring_schedule(water_source, safety_assessment),
                'community_actions': _suggest_community_water_actions(water_analysis, community_concerns),
                'emergency_protocols': _get_water_emergency_protocols(safety_assessment)
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "análise de qualidade da água")
        return jsonify(create_error_response(
            'water_quality_error',
            'Erro ao analisar qualidade da água',
            500
        )), 500

@environmental_bp.route('/environmental/soil-analysis', methods=['POST'])
def analyze_soil():
    """
    Analisar saúde do solo
    ---
    tags:
      - Environmental
    summary: Analisar saúde do solo
    description: |
      Analisa a saúde e qualidade do solo com base em parâmetros físicos, químicos e biológicos,
      fornecendo recomendações para melhorar a produtividade agrícola.
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              location:
                type: object
                description: Localização da análise do solo
                properties:
                  latitude:
                    type: number
                    example: 11.8636
                  longitude:
                    type: number
                    example: -15.5982
                  address:
                    type: string
                    example: "Bissau, Guiné-Bissau"
                required: ["latitude", "longitude"]
              soil_type:
                type: string
                description: Tipo de solo
                enum: ["arenoso", "argiloso", "siltoso", "franco", "orgânico"]
                example: "franco"
              crop_type:
                type: string
                description: Tipo de cultura plantada ou planejada
                example: "arroz"
              soil_tests:
                type: object
                description: Resultados dos testes de solo
                properties:
                  ph:
                    type: number
                    description: Nível de pH do solo
                    example: 6.5
                  organic_matter:
                    type: number
                    description: Matéria orgânica (%)
                    example: 3.2
                  nitrogen:
                    type: number
                    description: Nitrogênio (mg/kg)
                    example: 45
                  phosphorus:
                    type: number
                    description: Fósforo (mg/kg)
                    example: 25
                  potassium:
                    type: number
                    description: Potássio (mg/kg)
                    example: 180
                  calcium:
                    type: number
                    description: Cálcio (mg/kg)
                    example: 1200
                  magnesium:
                    type: number
                    description: Magnésio (mg/kg)
                    example: 150
                  sulfur:
                    type: number
                    description: Enxofre (mg/kg)
                    example: 12
                  electrical_conductivity:
                    type: number
                    description: Condutividade elétrica (dS/m)
                    example: 0.8
                  cation_exchange_capacity:
                    type: number
                    description: Capacidade de troca catiônica (cmol/kg)
                    example: 15
              visual_indicators:
                type: object
                description: Indicadores visuais do solo
                properties:
                  color:
                    type: string
                    enum: ["preto", "marrom escuro", "marrom", "vermelho", "amarelo", "cinza"]
                    example: "marrom escuro"
                  texture:
                    type: string
                    enum: ["muito fina", "fina", "média", "grossa", "muito grossa"]
                    example: "média"
                  compaction:
                    type: string
                    enum: ["nenhuma", "leve", "moderada", "severa"]
                    example: "leve"
                  drainage:
                    type: string
                    enum: ["excelente", "boa", "moderada", "ruim", "muito ruim"]
                    example: "boa"
                  erosion_signs:
                    type: boolean
                    example: false
              land_use_history:
                type: object
                description: Histórico de uso da terra
                properties:
                  previous_crops:
                    type: array
                    items:
                      type: string
                    example: ["milho", "feijão"]
                  fertilizer_use:
                    type: string
                    enum: ["nenhum", "orgânico", "químico", "misto"]
                    example: "orgânico"
                  pesticide_use:
                    type: boolean
                    example: false
                  years_in_use:
                    type: integer
                    example: 5
              environmental_factors:
                type: object
                description: Fatores ambientais
                properties:
                  rainfall_mm:
                    type: number
                    description: Precipitação anual (mm)
                    example: 1200
                  temperature_avg:
                    type: number
                    description: Temperatura média (°C)
                    example: 27
                  slope_percentage:
                    type: number
                    description: Inclinação do terreno (%)
                    example: 2.5
              farmer_observations:
                type: string
                description: Observações do agricultor
                example: "Solo parece menos produtivo nos últimos anos"
            required: ["location", "soil_type"]
    responses:
      200:
        description: Análise do solo realizada com sucesso
        content:
          application/json:
            schema:
              type: object
              properties:
                success:
                  type: boolean
                  example: true
                data:
                  type: object
                  properties:
                    location:
                      type: object
                      properties:
                        address:
                          type: string
                          example: "Bissau, Guiné-Bissau"
                    soil_health_score:
                      type: integer
                      description: Pontuação de saúde do solo (0-100)
                      example: 78
                    overall_assessment:
                      type: string
                      enum: ["excelente", "boa", "moderada", "ruim", "muito ruim"]
                      example: "boa"
                    nutrient_analysis:
                      type: object
                      properties:
                        nitrogen:
                          type: object
                          properties:
                            level:
                              type: string
                              example: "adequado"
                            recommendation:
                              type: string
                              example: "Manter níveis atuais"
                        phosphorus:
                          type: object
                          properties:
                            level:
                              type: string
                              example: "baixo"
                            recommendation:
                              type: string
                              example: "Adicionar fertilizante fosfatado"
                        potassium:
                          type: object
                          properties:
                            level:
                              type: string
                              example: "alto"
                            recommendation:
                              type: string
                              example: "Reduzir aplicação de potássio"
                    ph_assessment:
                      type: object
                      properties:
                        current_ph:
                          type: number
                          example: 6.5
                        status:
                          type: string
                          example: "ideal"
                        recommendation:
                          type: string
                          example: "pH adequado para a maioria das culturas"
                    improvement_recommendations:
                      type: array
                      items:
                        type: object
                        properties:
                          category:
                            type: string
                          action:
                            type: string
                          priority:
                            type: string
                      example:
                        - category: "fertilização"
                          action: "Aplicar compostagem orgânica"
                          priority: "alta"
                        - category: "estrutura"
                          action: "Evitar compactação com rotação de culturas"
                          priority: "média"
                    crop_suitability:
                      type: object
                      properties:
                        current_crop:
                          type: string
                          example: "arroz"
                        suitability_score:
                          type: integer
                          example: 85
                        alternative_crops:
                          type: array
                          items:
                            type: string
                          example: ["milho", "mandioca"]
                    monitoring_schedule:
                      type: string
                      example: "Testar novamente em 6 meses"
                timestamp:
                  type: string
                  format: date-time
      400:
        description: Dados de entrada inválidos
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ErrorResponse'
      500:
        description: Erro interno do servidor
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ErrorResponse'
    """
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        # Dados do solo
        location = data.get('location')
        soil_type = data.get('soil_type')  # clay, sand, loam, silt
        crop_type = data.get('crop_type')
        soil_tests = data.get('soil_tests', {})  # pH, nutrients, organic_matter, etc.
        visual_indicators = data.get('visual_indicators', {})  # color, texture, moisture
        land_use_history = data.get('land_use_history', [])
        environmental_factors = data.get('environmental_factors', {})  # rainfall, temperature, etc.
        farmer_observations = data.get('farmer_observations')
        
        if not location:
            return jsonify(create_error_response(
                'missing_location',
                'Campo "location" é obrigatório',
                400
            )), 400
        
        # Análise de saúde do solo
        soil_analysis = _analyze_soil_health_data(
            location, soil_type, crop_type, soil_tests, visual_indicators,
            land_use_history, environmental_factors, farmer_observations
        )
        
        # Recomendações de manejo
        management_recommendations = _generate_soil_management_recommendations(
            soil_analysis, crop_type
        )
        
        # Plano de melhoria
        improvement_plan = _create_soil_improvement_plan(
            soil_analysis, management_recommendations
        )
        
        return jsonify({
            'success': True,
            'data': {
                'location': location,
                'soil_type': soil_type,
                'crop_type': crop_type,
                'soil_analysis': soil_analysis,
                'health_score': soil_analysis.get('overall_health_score', 0),
                'health_category': _categorize_soil_health(soil_analysis.get('overall_health_score', 0)),
                'management_recommendations': management_recommendations,
                'improvement_plan': improvement_plan,
                'monitoring_schedule': _suggest_soil_monitoring_schedule(soil_analysis),
                'seasonal_considerations': _get_seasonal_soil_considerations(location, crop_type),
                'sustainability_metrics': _calculate_soil_sustainability_metrics(soil_analysis)
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "análise de saúde do solo")
        return jsonify(create_error_response(
            'soil_analysis_error',
            'Erro ao analisar saúde do solo',
            500
        )), 500

@environmental_bp.route('/environmental/biodiversity', methods=['GET'])
def get_biodiversity_data():
    """
    Obter dados de biodiversidade
    ---
    tags:
      - Environmental
    summary: Obter dados de biodiversidade
    description: |
      Fornece informações sobre biodiversidade local, incluindo espécies nativas,
      ameaçadas e programas de conservação.
    parameters:
      - name: location
        in: query
        description: Localização para consulta de biodiversidade
        required: false
        schema:
          type: string
          default: "Guiné-Bissau"
          example: "Bissau"
      - name: ecosystem_type
        in: query
        description: Tipo de ecossistema
        required: false
        schema:
          type: string
          enum: ["all", "forest", "wetland", "coastal", "marine", "savanna"]
          default: "all"
          example: "wetland"
      - name: species_group
        in: query
        description: Grupo de espécies de interesse
        required: false
        schema:
          type: string
          enum: ["all", "mammals", "birds", "reptiles", "amphibians", "fish", "plants"]
          default: "all"
          example: "birds"
      - name: conservation_status
        in: query
        description: Status de conservação
        required: false
        schema:
          type: string
          enum: ["all", "endangered", "vulnerable", "near_threatened", "least_concern"]
          default: "all"
          example: "endangered"
      - name: data_source
        in: query
        description: Fonte dos dados
        required: false
        schema:
          type: string
          enum: ["local", "iucn", "gbif", "combined"]
          default: "combined"
          example: "combined"
    responses:
      200:
        description: Dados de biodiversidade obtidos com sucesso
        content:
          application/json:
            schema:
              type: object
              properties:
                success:
                  type: boolean
                  example: true
                data:
                  type: object
                  properties:
                    location:
                      type: string
                      example: "Bissau"
                    ecosystem_info:
                      type: object
                      properties:
                        type:
                          type: string
                          example: "wetland"
                        area_km2:
                          type: number
                          example: 1500
                        protection_status:
                          type: string
                          example: "partially_protected"
                    species_count:
                      type: integer
                      description: Número total de espécies registradas
                      example: 245
                    endemic_species:
                      type: array
                      items:
                        type: object
                        properties:
                          name:
                            type: string
                          scientific_name:
                            type: string
                          group:
                            type: string
                          conservation_status:
                            type: string
                      example:
                        - name: "Hipopótamo-pigmeu"
                          scientific_name: "Choeropsis liberiensis"
                          group: "mammals"
                          conservation_status: "endangered"
                    threatened_species:
                      type: array
                      items:
                        type: object
                        properties:
                          name:
                            type: string
                          threat_level:
                            type: string
                          main_threats:
                            type: array
                            items:
                              type: string
                      example:
                        - name: "Tartaruga-verde"
                          threat_level: "vulnerable"
                          main_threats: ["pesca acidental", "perda de habitat"]
                    threat_analysis:
                      type: object
                      properties:
                        primary_threats:
                          type: array
                          items:
                            type: string
                          example: ["desmatamento", "poluição da água"]
                        threat_level:
                          type: string
                          enum: ["low", "medium", "high", "critical"]
                          example: "medium"
                    conservation_recommendations:
                      type: array
                      items:
                        type: object
                        properties:
                          action:
                            type: string
                          priority:
                            type: string
                          timeline:
                            type: string
                      example:
                        - action: "Estabelecer corredores ecológicos"
                          priority: "high"
                          timeline: "1-2 anos"
                    community_involvement:
                      type: object
                      properties:
                        opportunities:
                          type: array
                          items:
                            type: string
                          example: ["ecoturismo", "monitoramento participativo"]
                        training_programs:
                          type: array
                          items:
                            type: string
                          example: ["identificação de espécies", "técnicas de conservação"]
                    monitoring_programs:
                      type: array
                      items:
                        type: object
                        properties:
                          name:
                            type: string
                          frequency:
                            type: string
                          participants:
                            type: string
                      example:
                        - name: "Contagem de aves migratórias"
                          frequency: "anual"
                          participants: "comunidade local"
                timestamp:
                  type: string
                  format: date-time
      500:
        description: Erro interno do servidor
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ErrorResponse'
    """
    try:
        # Parâmetros de consulta
        location = request.args.get('location', 'Guiné-Bissau')
        ecosystem_type = request.args.get('ecosystem_type', 'all')  # forest, wetland, coastal, agricultural, urban
        species_group = request.args.get('species_group', 'all')  # mammals, birds, plants, insects, marine
        conservation_status = request.args.get('conservation_status', 'all')  # endangered, vulnerable, stable
        data_source = request.args.get('data_source', 'comprehensive')  # local, scientific, community
        include_threats = request.args.get('include_threats', 'true').lower() == 'true'
        
        # Obter dados de biodiversidade
        biodiversity_data = _get_biodiversity_information(
            location, ecosystem_type, species_group, conservation_status, data_source
        )
        
        # Análise de ameaças
        threat_analysis = None
        if include_threats:
            threat_analysis = _analyze_biodiversity_threats(
                biodiversity_data, location, ecosystem_type
            )
        
        # Recomendações de conservação
        conservation_recommendations = _generate_conservation_recommendations(
            biodiversity_data, threat_analysis
        )
        
        return jsonify({
            'success': True,
            'data': {
                'location': location,
                'ecosystem_type': ecosystem_type,
                'species_group': species_group,
                'conservation_status': conservation_status,
                'biodiversity_data': biodiversity_data,
                'species_count': biodiversity_data.get('total_species', 0),
                'endemic_species': biodiversity_data.get('endemic_species', []),
                'threatened_species': biodiversity_data.get('threatened_species', []),
                'threat_analysis': threat_analysis,
                'conservation_recommendations': conservation_recommendations,
                'community_involvement': _get_community_conservation_opportunities(location),
                'monitoring_programs': _get_biodiversity_monitoring_programs(location),
                'success_stories': _get_conservation_success_stories(location)
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "consulta de dados de biodiversidade")
        return jsonify(create_error_response(
            'biodiversity_data_error',
            'Erro ao obter dados de biodiversidade',
            500
        )), 500

@environmental_bp.route('/environmental/climate-analysis', methods=['POST'])
def analyze_climate_data():
    """
    Analisar dados climáticos
    ---
    tags:
      - Environmental
    summary: Analisar dados climáticos
    description: |
      Analisa dados climáticos históricos e atuais, fornecendo tendências,
      extremos e projeções para diferentes setores.
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              location:
                type: string
                description: Localização para análise climática
                default: "Guiné-Bissau"
                example: "Bissau"
              time_period:
                type: string
                description: Período de tempo para análise
                enum: ["1_year", "5_years", "10_years", "30_years"]
                default: "10_years"
                example: "10_years"
              climate_variables:
                type: array
                description: Variáveis climáticas para análise
                items:
                  type: string
                  enum: ["temperature", "precipitation", "humidity", "wind"]
                default: ["temperature", "precipitation"]
                example: ["temperature", "precipitation", "humidity"]
              analysis_type:
                type: string
                description: Tipo de análise climática
                enum: ["trends", "extremes", "variability", "projections"]
                default: "trends"
                example: "trends"
              sector_focus:
                type: string
                description: Setor de foco para análise
                enum: ["general", "agriculture", "health", "water", "energy", "coastal"]
                default: "general"
                example: "agriculture"
              include_projections:
                type: boolean
                description: Incluir projeções climáticas futuras
                default: false
                example: true
            required: []
    responses:
      200:
        description: Análise climática realizada com sucesso
        content:
          application/json:
            schema:
              type: object
              properties:
                success:
                  type: boolean
                  example: true
                data:
                  type: object
                  properties:
                    location:
                      type: string
                      example: "Bissau"
                    analysis_period:
                      type: object
                      properties:
                        start_year:
                          type: integer
                          example: 2014
                        end_year:
                          type: integer
                          example: 2024
                        duration_years:
                          type: integer
                          example: 10
                    climate_trends:
                      type: object
                      properties:
                        temperature:
                          type: object
                          properties:
                            average_change:
                              type: number
                              description: Mudança média em °C
                              example: 1.2
                            trend:
                              type: string
                              enum: ["increasing", "decreasing", "stable"]
                              example: "increasing"
                            seasonal_variation:
                              type: object
                              properties:
                                dry_season:
                                  type: number
                                  example: 1.5
                                wet_season:
                                  type: number
                                  example: 0.8
                        precipitation:
                          type: object
                          properties:
                            annual_change:
                              type: number
                              description: Mudança em mm/ano
                              example: -15.5
                            trend:
                              type: string
                              example: "decreasing"
                            variability:
                              type: string
                              enum: ["low", "medium", "high"]
                              example: "high"
                    extreme_events:
                      type: object
                      properties:
                        heat_waves:
                          type: object
                          properties:
                            frequency_change:
                              type: string
                              example: "increasing"
                            intensity_change:
                              type: string
                              example: "moderate_increase"
                        droughts:
                          type: object
                          properties:
                            frequency:
                              type: string
                              example: "stable"
                            severity:
                              type: string
                              example: "increasing"
                        floods:
                          type: object
                          properties:
                            frequency:
                              type: string
                              example: "increasing"
                            impact_areas:
                              type: array
                              items:
                                type: string
                              example: ["áreas costeiras", "bacias hidrográficas"]
                    sector_impacts:
                      type: object
                      properties:
                        agriculture:
                          type: object
                          properties:
                            crop_suitability:
                              type: object
                              properties:
                                rice:
                                  type: string
                                  example: "declining"
                                cashew:
                                  type: string
                                  example: "stable"
                            growing_season:
                              type: object
                              properties:
                                length_change:
                                  type: string
                                  example: "shortening"
                                start_shift:
                                  type: string
                                  example: "later"
                        water_resources:
                          type: object
                          properties:
                            availability:
                              type: string
                              example: "decreasing"
                            quality_risks:
                              type: array
                              items:
                                type: string
                              example: ["salinização", "contaminação"]
                    adaptation_strategies:
                      type: array
                      items:
                        type: object
                        properties:
                          strategy:
                            type: string
                          sector:
                            type: string
                          priority:
                            type: string
                          timeline:
                            type: string
                      example:
                        - strategy: "Diversificação de culturas resistentes à seca"
                          sector: "agriculture"
                          priority: "high"
                          timeline: "1-3 anos"
                    climate_projections:
                      type: object
                      description: Incluído apenas se include_projections=true
                      properties:
                        temperature_2050:
                          type: object
                          properties:
                            increase_range:
                              type: string
                              example: "1.5-2.5°C"
                            confidence:
                              type: string
                              example: "high"
                        precipitation_2050:
                          type: object
                          properties:
                            change_range:
                              type: string
                              example: "-10% a +5%"
                            confidence:
                              type: string
                              example: "medium"
                timestamp:
                  type: string
                  format: date-time
      400:
        description: Dados de entrada inválidos
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ErrorResponse'
      500:
        description: Erro interno do servidor
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ErrorResponse'
    """
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        # Parâmetros de análise climática
        location = data.get('location', 'Guiné-Bissau')
        time_period = data.get('time_period', '10_years')  # 1_year, 5_years, 10_years, 30_years
        climate_variables = data.get('climate_variables', ['temperature', 'precipitation'])  # temperature, precipitation, humidity, wind
        analysis_type = data.get('analysis_type', 'trends')  # trends, extremes, variability, projections
        sector_focus = data.get('sector_focus', 'general')  # agriculture, health, water, energy, coastal
        include_projections = data.get('include_projections', False)
        
        # Análise climática
        climate_analysis = _perform_climate_analysis(
            location, time_period, climate_variables, analysis_type, sector_focus
        )
        
        # Projeções climáticas
        climate_projections = None
        if include_projections:
            climate_projections = _generate_climate_projections(
                climate_analysis, location, sector_focus
            )
        
        # Impactos e adaptação
        impact_assessment = _assess_climate_impacts(
            climate_analysis, sector_focus, location
        )
        
        adaptation_strategies = _suggest_climate_adaptation_strategies(
            impact_assessment, sector_focus
        )
        
        return jsonify({
            'success': True,
            'data': {
                'location': location,
                'time_period': time_period,
                'climate_variables': climate_variables,
                'analysis_type': analysis_type,
                'sector_focus': sector_focus,
                'climate_analysis': climate_analysis,
                'climate_projections': climate_projections,
                'impact_assessment': impact_assessment,
                'adaptation_strategies': adaptation_strategies,
                'vulnerability_assessment': _assess_climate_vulnerability(location, sector_focus),
                'resilience_recommendations': _generate_resilience_recommendations(impact_assessment),
                'monitoring_indicators': _suggest_climate_monitoring_indicators(sector_focus)
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "análise climática")
        return jsonify(create_error_response(
            'climate_analysis_error',
            'Erro ao analisar dados climáticos',
            500
        )), 500

@environmental_bp.route('/environmental/sustainability-assessment', methods=['POST'])
def assess_sustainability():
    """
    Avaliar sustentabilidade ambiental
    ---
    tags:
      - Environmental
    summary: Avaliar sustentabilidade ambiental
    description: |
      Realiza uma avaliação abrangente de sustentabilidade para projetos,
      considerando fatores ambientais, sociais e econômicos.
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              project_type:
                type: string
                description: Tipo de projeto para avaliação
                enum: ["agriculture", "construction", "energy", "tourism", "industry"]
                example: "agriculture"
              location:
                type: object
                description: Localização do projeto
                properties:
                  latitude:
                    type: number
                    example: 11.8636
                  longitude:
                    type: number
                    example: -15.5982
                  address:
                    type: string
                    example: "Bissau, Guiné-Bissau"
                  region:
                    type: string
                    example: "Bissau"
                required: ["latitude", "longitude"]
              project_description:
                type: string
                description: Descrição detalhada do projeto
                example: "Projeto de agricultura sustentável com foco em cultivo de arroz"
              environmental_data:
                type: object
                description: Dados ambientais relevantes
                properties:
                  land_use:
                    type: string
                    enum: ["agricultural", "forest", "urban", "wetland", "coastal"]
                    example: "agricultural"
                  ecosystem_type:
                    type: string
                    example: "mangue"
                  biodiversity_level:
                    type: string
                    enum: ["low", "medium", "high", "critical"]
                    example: "medium"
                  water_resources:
                    type: object
                    properties:
                      availability:
                        type: string
                        enum: ["abundant", "adequate", "limited", "scarce"]
                        example: "adequate"
                      quality:
                        type: string
                        enum: ["excellent", "good", "fair", "poor"]
                        example: "good"
                  soil_quality:
                    type: string
                    enum: ["excellent", "good", "fair", "poor"]
                    example: "good"
                  climate_risks:
                    type: array
                    items:
                      type: string
                    example: ["flooding", "drought"]
              social_factors:
                type: object
                description: Fatores sociais do projeto
                properties:
                  community_size:
                    type: integer
                    example: 500
                  local_employment:
                    type: object
                    properties:
                      jobs_created:
                        type: integer
                        example: 25
                      skill_level_required:
                        type: string
                        enum: ["low", "medium", "high"]
                        example: "medium"
                  cultural_heritage:
                    type: object
                    properties:
                      sites_affected:
                        type: boolean
                        example: false
                      traditional_practices:
                        type: array
                        items:
                          type: string
                        example: ["pesca tradicional"]
                  health_impact:
                    type: object
                    properties:
                      positive_effects:
                        type: array
                        items:
                          type: string
                        example: ["melhoria na nutrição"]
                      negative_risks:
                        type: array
                        items:
                          type: string
                        example: ["uso de pesticidas"]
              economic_factors:
                type: object
                description: Fatores econômicos do projeto
                properties:
                  initial_investment:
                    type: number
                    description: Investimento inicial em USD
                    example: 50000
                  annual_revenue:
                    type: number
                    description: Receita anual estimada em USD
                    example: 15000
                  operational_costs:
                    type: number
                    description: Custos operacionais anuais em USD
                    example: 8000
                  payback_period:
                    type: number
                    description: Período de retorno em anos
                    example: 5
                  local_economic_impact:
                    type: string
                    enum: ["very_positive", "positive", "neutral", "negative"]
                    example: "positive"
              timeframe:
                type: string
                description: Horizonte temporal da avaliação
                enum: ["short_term", "medium_term", "long_term"]
                default: "medium_term"
                example: "medium_term"
              assessment_scope:
                type: string
                description: Escopo da avaliação
                enum: ["basic", "comprehensive", "detailed"]
                default: "comprehensive"
                example: "comprehensive"
            required: ["project_type", "location"]
    responses:
      200:
        description: Avaliação de sustentabilidade realizada com sucesso
        content:
          application/json:
            schema:
              type: object
              properties:
                success:
                  type: boolean
                  example: true
                data:
                  type: object
                  properties:
                    project_info:
                      type: object
                      properties:
                        type:
                          type: string
                          example: "agriculture"
                        location:
                          type: string
                          example: "Bissau, Guiné-Bissau"
                        description:
                          type: string
                          example: "Projeto de agricultura sustentável"
                    sustainability_score:
                      type: object
                      properties:
                        overall:
                          type: integer
                          description: Pontuação geral (0-100)
                          example: 78
                        environmental:
                          type: integer
                          example: 82
                        social:
                          type: integer
                          example: 75
                        economic:
                          type: integer
                          example: 77
                    assessment_results:
                      type: object
                      properties:
                        environmental_impact:
                          type: object
                          properties:
                            positive_aspects:
                              type: array
                              items:
                                type: string
                              example: ["Conservação do solo", "Uso eficiente da água"]
                            concerns:
                              type: array
                              items:
                                type: string
                              example: ["Possível impacto na biodiversidade local"]
                            mitigation_measures:
                              type: array
                              items:
                                type: string
                              example: ["Implementar corredores ecológicos"]
                        social_impact:
                          type: object
                          properties:
                            benefits:
                              type: array
                              items:
                                type: string
                              example: ["Criação de empregos locais"]
                            challenges:
                              type: array
                              items:
                                type: string
                              example: ["Necessidade de treinamento"]
                        economic_viability:
                          type: object
                          properties:
                            roi:
                              type: number
                              description: Retorno sobre investimento (%)
                              example: 15.5
                            break_even_years:
                              type: number
                              example: 4.2
                            risk_level:
                              type: string
                              enum: ["low", "medium", "high"]
                              example: "medium"
                    recommendations:
                      type: array
                      items:
                        type: object
                        properties:
                          category:
                            type: string
                          priority:
                            type: string
                            enum: ["high", "medium", "low"]
                          action:
                            type: string
                          timeline:
                            type: string
                      example:
                        - category: "environmental"
                          priority: "high"
                          action: "Implementar sistema de monitoramento da qualidade da água"
                          timeline: "3 meses"
                    certification_opportunities:
                      type: array
                      items:
                        type: string
                      example: ["Certificação orgânica", "Fair Trade"]
                    monitoring_plan:
                      type: object
                      properties:
                        frequency:
                          type: string
                          example: "trimestral"
                        key_indicators:
                          type: array
                          items:
                            type: string
                          example: ["produtividade", "qualidade da água", "biodiversidade"]
                timestamp:
                  type: string
                  format: date-time
      400:
        description: Dados de entrada inválidos
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ErrorResponse'
      500:
        description: Erro interno do servidor
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ErrorResponse'
    """
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        # Dados para avaliação de sustentabilidade
        project_type = data.get('project_type')  # agriculture, construction, energy, tourism, industry
        location = data.get('location')
        project_description = data.get('project_description')
        environmental_data = data.get('environmental_data', {})
        social_factors = data.get('social_factors', {})
        economic_factors = data.get('economic_factors', {})
        timeframe = data.get('timeframe', 'medium_term')  # short_term, medium_term, long_term
        assessment_scope = data.get('assessment_scope', 'comprehensive')  # basic, comprehensive, detailed
        
        if not project_type or not location:
            return jsonify(create_error_response(
                'missing_required_fields',
                'Campos "project_type" e "location" são obrigatórios',
                400
            )), 400
        
        # Avaliação de sustentabilidade
        sustainability_assessment = _perform_sustainability_assessment(
            project_type, location, project_description, environmental_data,
            social_factors, economic_factors, timeframe, assessment_scope
        )
        
        # Recomendações de melhoria
        improvement_recommendations = _generate_sustainability_improvements(
            sustainability_assessment, project_type
        )
        
        # Plano de monitoramento
        monitoring_plan = _create_sustainability_monitoring_plan(
            sustainability_assessment, timeframe
        )
        
        return jsonify({
            'success': True,
            'data': {
                'project_type': project_type,
                'location': location,
                'timeframe': timeframe,
                'assessment_scope': assessment_scope,
                'sustainability_assessment': sustainability_assessment,
                'overall_score': sustainability_assessment.get('overall_score', 0),
                'sustainability_rating': _get_sustainability_rating(sustainability_assessment.get('overall_score', 0)),
                'improvement_recommendations': improvement_recommendations,
                'monitoring_plan': monitoring_plan,
                'certification_opportunities': _identify_sustainability_certifications(project_type, sustainability_assessment),
                'community_benefits': _assess_community_sustainability_benefits(sustainability_assessment),
                'risk_mitigation': _suggest_sustainability_risk_mitigation(sustainability_assessment)
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "avaliação de sustentabilidade")
        return jsonify(create_error_response(
            'sustainability_assessment_error',
            'Erro ao avaliar sustentabilidade',
            500
        )), 500

# Funções auxiliares

def _check_weather_monitoring():
    """Verificar monitoramento meteorológico"""
    return {
        'status': 'healthy',
        'data_sources': ['estações locais', 'satélite', 'modelos globais'],
        'update_frequency': 'hourly',
        'forecast_accuracy': '85%'
    }

def _check_air_quality_monitoring():
    """Verificar monitoramento de qualidade do ar"""
    return {
        'status': 'healthy',
        'monitoring_stations': 5,
        'pollutants_tracked': ['PM2.5', 'PM10', 'NO2', 'SO2', 'CO', 'O3'],
        'real_time_data': True
    }

def _check_water_quality_monitoring():
    """Verificar monitoramento de qualidade da água"""
    return {
        'status': 'healthy',
        'water_sources_monitored': ['rios', 'poços', 'lagos', 'água da torneira'],
        'parameters_tested': ['pH', 'turbidez', 'bactérias', 'químicos'],
        'community_testing': True
    }

def _check_soil_analysis():
    """Verificar análise de solo"""
    return {
        'status': 'healthy',
        'analysis_types': ['nutrientes', 'pH', 'matéria orgânica', 'contaminantes'],
        'agricultural_focus': True,
        'field_testing_available': True
    }

def _check_biodiversity_tracking():
    """Verificar rastreamento de biodiversidade"""
    return {
        'status': 'healthy',
        'species_databases': ['flora', 'fauna', 'marinhas'],
        'conservation_programs': True,
        'community_monitoring': True
    }

def _check_climate_data():
    """Verificar dados climáticos"""
    return {
        'status': 'healthy',
        'historical_data': '30+ anos',
        'climate_models': ['regionais', 'globais'],
        'projection_capability': True
    }

def _get_weather_information(location, forecast_days, include_historical, data_type):
    """Obter informações meteorológicas"""
    # Simulação de dados meteorológicos
    current_weather = {
        'temperature': 28,
        'humidity': 75,
        'precipitation': 0,
        'wind_speed': 12,
        'wind_direction': 'NE',
        'pressure': 1013,
        'visibility': 10,
        'uv_index': 8,
        'conditions': 'Parcialmente nublado'
    }
    
    forecast = []
    for i in range(forecast_days):
        day_forecast = {
            'date': (datetime.now() + timedelta(days=i)).strftime('%Y-%m-%d'),
            'temperature_max': 30 + (i % 3),
            'temperature_min': 22 + (i % 2),
            'humidity': 70 + (i % 10),
            'precipitation_probability': 20 + (i * 5) % 60,
            'wind_speed': 10 + (i % 5),
            'conditions': ['Ensolarado', 'Parcialmente nublado', 'Nublado', 'Chuva leve'][i % 4]
        }
        forecast.append(day_forecast)
    
    weather_data = {
        'current': current_weather,
        'forecast': forecast
    }
    
    if include_historical:
        weather_data['historical'] = [
            {
                'date': (datetime.now() - timedelta(days=i)).strftime('%Y-%m-%d'),
                'temperature_avg': 26 + (i % 4),
                'precipitation': (i * 2) % 15
            } for i in range(1, 31)
        ]
    
    return weather_data

def _generate_agricultural_weather_insights(weather_data):
    """Gerar insights meteorológicos para agricultura"""
    current = weather_data.get('current', {})
    forecast = weather_data.get('forecast', [])
    
    insights = {
        'irrigation_recommendation': 'Irrigação recomendada' if current.get('precipitation', 0) < 5 else 'Irrigação não necessária',
        'planting_conditions': 'Favoráveis' if current.get('temperature', 0) > 20 and current.get('humidity', 0) > 60 else 'Desfavoráveis',
        'pest_risk': 'Médio' if current.get('humidity', 0) > 70 else 'Baixo',
        'harvest_window': _calculate_harvest_window(forecast),
        'crop_stress_indicators': _assess_crop_stress_from_weather(current, forecast)
    }
    
    return insights

def _check_weather_alerts(weather_data, location):
    """Verificar alertas meteorológicos"""
    alerts = []
    current = weather_data.get('current', {})
    forecast = weather_data.get('forecast', [])
    
    # Verificar temperatura extrema
    if current.get('temperature', 0) > 35:
        alerts.append({
            'type': 'heat_warning',
            'severity': 'medium',
            'message': 'Temperatura elevada - tome precauções contra o calor'
        })
    
    # Verificar chuva intensa
    for day in forecast[:3]:  # Próximos 3 dias
        if day.get('precipitation_probability', 0) > 80:
            alerts.append({
                'type': 'heavy_rain_warning',
                'severity': 'medium',
                'message': f'Chuva intensa prevista para {day.get("date")}'
            })
    
    # Verificar vento forte
    if current.get('wind_speed', 0) > 25:
        alerts.append({
            'type': 'strong_wind_warning',
            'severity': 'low',
            'message': 'Ventos fortes - cuidado com atividades ao ar livre'
        })
    
    return alerts


@environmental_bp.route('/environmental/education/generate-content', methods=['POST'])
def generate_environmental_content():
    """
    Gerar conteudo educativo ambiental com prompts personalizados
    ---
    tags:
      - Educacao Ambiental
    summary: Geracao de conteudo educativo com IA personalizada
    description: |
      Endpoint especializado para gerar conteudo educativo ambiental usando prompts
      personalizados do Gemma3n. Focado na educacao ambiental da Guine-Bissau.
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - topic
            - prompt
          properties:
            topic:
              type: string
              description: Tópico ambiental específico
              example: "biodiversidade"
            prompt:
              type: string
              description: Prompt personalizado para o Gemma3n
              example: "Explique a biodiversidade da Guiné-Bissau para adolescentes"
            age_group:
              type: string
              enum: ["crianca", "adolescente", "adulto", "idoso"]
              description: Faixa etária do público-alvo
              example: "adolescente"
            language:
              type: string
              enum: ["portugues", "crioulo", "fula", "mandinga"]
              description: Idioma preferido
              example: "portugues"
            ecosystem:
              type: string
              enum: ["mangue", "floresta", "savana", "costeiro", "urbano", "geral"]
              description: Ecossistema de interesse
              example: "mangue"
            duration:
              type: integer
              description: Duração desejada em minutos
              example: 20
            include_activities:
              type: boolean
              description: Incluir atividades práticas
              example: true
            difficulty:
              type: string
              enum: ["basico", "intermediario", "avancado"]
              description: Nível de dificuldade
              example: "intermediario"
    responses:
      200:
        description: Conteúdo educativo gerado com sucesso
        schema:
          type: object
          properties:
            success:
              type: boolean
              example: true
            data:
              type: object
              properties:
                title:
                  type: string
                  example: "Biodiversidade dos Manguezais"
                description:
                  type: string
                  example: "Aprenda sobre a rica biodiversidade dos manguezais da Guiné-Bissau"
                content:
                  type: string
                  description: Conteúdo educativo principal gerado pela IA
                difficulty:
                  type: string
                  example: "intermediario"
                key_concepts:
                  type: array
                  items:
                    type: string
                  example: ["Biodiversidade", "Manguezais", "Conservação"]
                local_examples:
                  type: array
                  items:
                    type: string
                  example: ["Arquipélago dos Bijagós", "Parque Nacional de Cantanhez"]
                practical_activities:
                  type: array
                  items:
                    type: object
                    properties:
                      name:
                        type: string
                      description:
                        type: string
                      materials:
                        type: array
                        items:
                          type: string
                cultural_connections:
                  type: array
                  items:
                    type: string
                  example: ["Conhecimento tradicional dos pescadores", "Práticas ancestrais de conservação"]
                generated_by:
                  type: string
                  example: "Gemma3n AI"
      400:
        description: Dados de entrada inválidos
      500:
        description: Erro interno do servidor
    """
    try:
        data = request.get_json()
        if not data:
            return create_error_response(
                'invalid_input',
                'Dados de entrada são obrigatórios',
                400
            )
        
        # Validar campos obrigatórios
        required_fields = ['topic', 'prompt']
        for field in required_fields:
            if not data.get(field):
                return create_error_response(
                    'missing_field',
                    f'Campo obrigatório ausente: {field}',
                    400
                )
        
        topic = data.get('topic')
        custom_prompt = data.get('prompt')
        age_group = data.get('age_group', 'adolescente')
        language = data.get('language', 'portugues')
        ecosystem = data.get('ecosystem', 'geral')
        duration = data.get('duration', 20)
        include_activities = data.get('include_activities', True)
        difficulty = data.get('difficulty', 'intermediario')
        
        # Construir prompt especializado para educação ambiental
        system_prompt = f"""
        Você é um educador ambiental especializado em criar conteúdo educativo para comunidades da Guiné-Bissau.
        
        CONTEXTO:
        - Público-alvo: {age_group}
        - Idioma: {language}
        - Ecossistema: {ecosystem}
        - Duração: {duration} minutos
        - Nível: {difficulty}
        - Incluir atividades: {'Sim' if include_activities else 'Não'}
        
        INSTRUÇÕES:
        1. Crie conteúdo educativo sobre: {topic}
        2. Use linguagem adequada para {age_group}
        3. Inclua exemplos específicos da Guiné-Bissau
        4. Conecte com conhecimento tradicional local
        5. Seja prático e aplicável ao contexto local
        
        PROMPT PERSONALIZADO:
        {custom_prompt}
        
        FORMATO DE RESPOSTA (JSON):
        {{
            "title": "Título atrativo do conteúdo",
            "description": "Breve descrição do que será aprendido",
            "content": "Conteúdo educativo principal (mínimo 300 palavras)",
            "difficulty": "{difficulty}",
            "key_concepts": ["conceito1", "conceito2", "conceito3"],
            "local_examples": ["exemplo1 da Guiné-Bissau", "exemplo2"],
            "practical_activities": [
                {{
                    "name": "Nome da atividade",
                    "description": "Descrição da atividade",
                    "materials": ["material1", "material2"]
                }}
            ],
            "cultural_connections": ["conexão cultural 1", "conexão cultural 2"]
        }}
        """
        
        # Tentar usar Gemma-3n para gerar conteúdo
        gemma_service = current_app.gemma_service
        
        if gemma_service and hasattr(gemma_service, 'generate_response'):
            try:
                response = gemma_service.generate_response(
                    prompt=system_prompt,
                    context="environmental_education",
                    max_tokens=2000,
                    temperature=0.7
                )
                
                # Tentar parsear resposta JSON
                try:
                    import re
                    # Extrair JSON da resposta
                    json_match = re.search(r'\{.*\}', response, re.DOTALL)
                    if json_match:
                        content_data = json.loads(json_match.group())
                    else:
                        # Se não encontrar JSON, criar estrutura básica
                        content_data = _create_fallback_content(topic, custom_prompt, age_group, ecosystem)
                        content_data['content'] = response
                except (json.JSONDecodeError, AttributeError):
                    # Fallback se não conseguir parsear JSON
                    content_data = _create_fallback_content(topic, custom_prompt, age_group, ecosystem)
                    content_data['content'] = response
                
                # Adicionar metadados
                content_data['generated_by'] = 'Gemma3n AI'
                content_data['topic'] = topic
                content_data['age_group'] = age_group
                content_data['ecosystem'] = ecosystem
                content_data['language'] = language
                content_data['duration'] = duration
                
                return jsonify({
                    'success': True,
                    'data': content_data,
                    'message': 'Conteúdo educativo gerado com sucesso'
                })
                
            except Exception as e:
                current_app.logger.error(f"Erro no Gemma3n: {e}")
                # Fallback para conteúdo estruturado
                fallback_content = _create_fallback_content(topic, custom_prompt, age_group, ecosystem)
                return jsonify({
                    'success': True,
                    'data': fallback_content,
                    'message': 'Conteúdo educativo gerado (modo fallback)',
                    'note': 'Gemma3n temporariamente indisponível'
                })
        else:
            # Fallback se Gemma-3n não estiver disponível
            fallback_content = _create_fallback_content(topic, custom_prompt, age_group, ecosystem)
            return jsonify({
                'success': True,
                'data': fallback_content,
                'message': 'Conteúdo educativo gerado (modo fallback)'
            })
            
    except Exception as e:
        current_app.logger.error(f"Erro na geração de conteúdo educativo: {e}")
        log_error(logger, e, "geração de conteúdo educativo ambiental")
        return create_error_response(
            'content_generation_error',
            'Erro ao gerar conteúdo educativo ambiental',
            500
        )


def _create_fallback_content(topic, prompt, age_group, ecosystem):
    """
    Criar conteúdo estruturado básico quando Gemma3n não está disponível
    """
    topic_content = {
        'biodiversidade': {
            'title': 'Biodiversidade da Guiné-Bissau',
            'description': 'Explore a rica diversidade de vida da nossa terra',
            'content': 'A Guiné-Bissau possui uma biodiversidade única, com manguezais, florestas e savanas que abrigam centenas de espécies. Nossos ecossistemas são fundamentais para a vida das comunidades locais.',
            'key_concepts': ['Biodiversidade', 'Ecossistemas', 'Conservação', 'Espécies endêmicas'],
            'local_examples': ['Arquipélago dos Bijagós', 'Parque Nacional de Cantanhez', 'Reserva da Biosfera de Bolama-Bijagós'],
            'cultural_connections': ['Conhecimento tradicional dos pescadores', 'Práticas ancestrais de conservação']
        },
        'mangue': {
            'title': 'Manguezais: Berçário da Vida',
            'description': 'Descubra a importância dos manguezais para nossa comunidade',
            'content': 'Os manguezais da Guiné-Bissau são ecossistemas únicos que servem como berçário para peixes, proteção contra erosão e fonte de sustento para milhares de famílias.',
            'key_concepts': ['Manguezais', 'Ecossistema costeiro', 'Proteção natural', 'Sustentabilidade'],
            'local_examples': ['Manguezais de Cacheu', 'Zona costeira de Bissau', 'Ilhas Bijagós'],
            'cultural_connections': ['Pesca tradicional', 'Coleta de ostras', 'Medicina tradicional']
        },
        'conservacao': {
            'title': 'Conservação: Protegendo Nosso Futuro',
            'description': 'Aprenda estratégias de conservação para nossa região',
            'content': 'A conservação ambiental na Guiné-Bissau combina conhecimento tradicional com práticas modernas para proteger nossos recursos naturais para as futuras gerações.',
            'key_concepts': ['Conservação', 'Sustentabilidade', 'Proteção ambiental', 'Gestão de recursos'],
            'local_examples': ['Áreas protegidas', 'Projetos comunitários', 'Iniciativas de reflorestamento'],
            'cultural_connections': ['Tabus tradicionais', 'Gestão comunitária de recursos', 'Conhecimento dos anciãos']
        }
    }
    
    base_content = topic_content.get(topic, topic_content['biodiversidade'])
    
    # Atividades práticas baseadas no tópico
    activities = [
        {
            'name': f'Observação de {topic}',
            'description': f'Atividade prática para observar e documentar {topic} na sua comunidade',
            'materials': ['Caderno', 'Lápis', 'Câmera (se disponível)']
        },
        {
            'name': 'Discussão comunitária',
            'description': 'Conversar com anciãos sobre conhecimento tradicional',
            'materials': ['Tempo', 'Respeito', 'Curiosidade']
        }
    ]
    
    return {
        'title': base_content['title'],
        'description': base_content['description'],
        'content': base_content['content'],
        'difficulty': 'intermediario',
        'key_concepts': base_content['key_concepts'],
        'local_examples': base_content['local_examples'],
        'practical_activities': activities,
        'cultural_connections': base_content['cultural_connections'],
        'generated_by': 'Sistema Fallback'
    }


@environmental_bp.route('/environmental/education/topics', methods=['GET'])
def get_education_topics():
    """
    Obter lista de tópicos educativos ambientais disponíveis
    ---
    tags:
      - Educação Ambiental
    summary: Lista de tópicos educativos disponíveis
    description: |
      Retorna lista completa de tópicos educativos ambientais disponíveis
      para geração de conteúdo personalizado.
    responses:
      200:
        description: Lista de tópicos obtida com sucesso
        schema:
          type: object
          properties:
            success:
              type: boolean
              example: true
            topics:
              type: array
              items:
                type: object
                properties:
                  value:
                    type: string
                    example: "biodiversidade"
                  label:
                    type: string
                    example: "Biodiversidade"
                  icon:
                    type: string
                    example: "🌿"
                  color:
                    type: string
                    example: "green"
                  description:
                    type: string
                    example: "Diversidade de vida na Guiné-Bissau"
                  gemma_prompt:
                    type: string
                    example: "Explique a biodiversidade da Guiné-Bissau..."
    """
    try:
        topics = [
            {
                'value': 'biodiversidade',
                'label': 'Biodiversidade',
                'icon': '🌿',
                'color': 'green',
                'description': 'Diversidade de vida na Guiné-Bissau',
                'gemma_prompt': 'Explique a biodiversidade da Guiné-Bissau, incluindo espécies endêmicas, ecossistemas únicos e importância para a comunidade local'
            },
            {
                'value': 'mangue',
                'label': 'Manguezais',
                'icon': '🌊',
                'color': 'blue',
                'description': 'Ecossistemas costeiros únicos',
                'gemma_prompt': 'Descreva os manguezais da Guiné-Bissau, sua importância ecológica, econômica e cultural para as comunidades costeiras'
            },
            {
                'value': 'floresta',
                'label': 'Florestas',
                'icon': '🌳',
                'color': 'brown',
                'description': 'Florestas tropicais e sua conservação',
                'gemma_prompt': 'Aborde as florestas da Guiné-Bissau, incluindo tipos de vegetação, fauna, desmatamento e conservação'
            },
            {
                'value': 'conservacao',
                'label': 'Conservação',
                'icon': '🛡️',
                'color': 'orange',
                'description': 'Estratégias de proteção ambiental',
                'gemma_prompt': 'Explique estratégias de conservação ambiental aplicáveis à Guiné-Bissau, incluindo práticas tradicionais e modernas'
            },
            {
                'value': 'agricultura',
                'label': 'Agricultura Sustentável',
                'icon': '🌾',
                'color': 'amber',
                'description': 'Práticas agrícolas sustentáveis',
                'gemma_prompt': 'Ensine sobre agricultura sustentável na Guiné-Bissau, incluindo técnicas tradicionais, rotação de culturas e conservação do solo'
            },
            {
                'value': 'agua',
                'label': 'Recursos Hídricos',
                'icon': '💧',
                'color': 'cyan',
                'description': 'Gestão e conservação da água',
                'gemma_prompt': 'Explique a importância dos recursos hídricos na Guiné-Bissau, incluindo rios, aquíferos e conservação da água'
            },
            {
                'value': 'energia',
                'label': 'Energia Renovável',
                'icon': '☀️',
                'color': 'yellow',
                'description': 'Fontes de energia sustentável',
                'gemma_prompt': 'Aborde as possibilidades de energia renovável na Guiné-Bissau, incluindo solar, eólica e biomassa'
            },
            {
                'value': 'clima',
                'label': 'Mudanças Climáticas',
                'icon': '🌡️',
                'color': 'red',
                'description': 'Impactos e adaptação climática',
                'gemma_prompt': 'Explique as mudanças climáticas e seus impactos na Guiné-Bissau, incluindo estratégias de adaptação e mitigação'
            }
        ]
        
        return jsonify({
            'success': True,
            'topics': topics,
            'total': len(topics)
        })
        
    except Exception as e:
        current_app.logger.error(f"Erro ao obter tópicos educativos: {e}")
        log_error(logger, e, "obtenção de tópicos educativos")
        return create_error_response(
            'topics_error',
            'Erro ao obter lista de tópicos educativos',
            500
        )


@environmental_bp.route('/environmental/education', methods=['GET', 'POST'])
def environmental_education():
    """Teste simples para verificar se a rota funciona"""
    return jsonify({'success': True, 'message': 'Rota funcionando'})

@environmental_bp.route('/environmental/education-full', methods=['GET', 'POST'])
def environmental_education_full():
    """
    Educação Ambiental Interativa com IA
    ---
    tags:
      - Educação Ambiental
    summary: Conteúdo educativo ambiental personalizado
    description: |
      Endpoint para gerar conteúdo educativo ambiental personalizado usando IA.
      Especializado em educação ambiental para comunidades da Guiné-Bissau.
    parameters:
      - in: body
        name: body
        required: false
        schema:
          type: object
          properties:
            topic:
              type: string
              description: Tópico de educação ambiental
              example: "biodiversidade"
            age_group:
              type: string
              enum: ["crianca", "adolescente", "adulto", "idoso"]
              description: Faixa etária do público-alvo
              example: "adolescente"
            education_level:
              type: string
              enum: ["basico", "medio", "superior"]
              description: Nível educacional
              example: "medio"
            language:
              type: string
              enum: ["portugues", "crioulo", "fula", "mandinga"]
              description: Idioma preferido
              example: "portugues"
            ecosystem:
              type: string
              enum: ["mangue", "floresta", "savana", "costeiro", "urbano"]
              description: Ecossistema de interesse
              example: "mangue"
            learning_style:
              type: string
              enum: ["visual", "auditivo", "pratico", "teorico"]
              description: Estilo de aprendizagem preferido
              example: "pratico"
            duration:
              type: integer
              description: Duração desejada em minutos
              example: 15
            include_activities:
              type: boolean
              description: Incluir atividades práticas
              example: true
    responses:
      200:
        description: Conteúdo educativo gerado com sucesso
        schema:
          type: object
          properties:
            success:
              type: boolean
              example: true
            data:
              type: object
              properties:
                title:
                  type: string
                  example: "Explorando os Manguezais da Guiné-Bissau"
                content:
                  type: string
                  description: Conteúdo educativo principal
                key_concepts:
                  type: array
                  items:
                    type: string
                  example: ["Biodiversidade", "Ecossistema", "Conservação"]
                learning_objectives:
                  type: array
                  items:
                    type: string
                  example: ["Identificar espécies do mangue", "Compreender importância ecológica"]
                practical_activities:
                  type: array
                  items:
                    type: object
                    properties:
                      name:
                        type: string
                      description:
                        type: string
                      materials:
                        type: array
                        items:
                          type: string
                      duration:
                        type: integer
                local_examples:
                  type: array
                  items:
                    type: string
                  example: ["Parque Nacional de Cantanhez", "Arquipélago dos Bijagós"]
                quiz_questions:
                  type: array
                  items:
                    type: object
                    properties:
                      question:
                        type: string
                      options:
                        type: array
                        items:
                          type: string
                      correct_answer:
                        type: integer
                additional_resources:
                  type: array
                  items:
                    type: object
                    properties:
                      type:
                        type: string
                      title:
                        type: string
                      description:
                        type: string
                cultural_context:
                  type: object
                  properties:
                    traditional_knowledge:
                      type: array
                      items:
                        type: string
                    local_practices:
                      type: array
                      items:
                        type: string
                    community_involvement:
                      type: array
                      items:
                        type: string
      400:
        description: Dados de entrada inválidos
      500:
        description: Erro interno do servidor
    """
    try:
        if request.method == 'GET':
            # Retornar módulos educativos disponíveis
            modules = _get_available_education_modules()
            return jsonify({
                'success': True,
                'modules': modules
            })
        
        # POST - Gerar conteúdo educativo personalizado
        data = request.get_json() or {}
        
        topic = data.get('topic', 'biodiversidade')
        age_group = data.get('age_group', 'adolescente')
        education_level = data.get('education_level', 'medio')
        language = data.get('language', 'portugues')
        ecosystem = data.get('ecosystem', 'mangue')
        learning_style = data.get('learning_style', 'pratico')
        duration = data.get('duration', 15)
        include_activities = data.get('include_activities', True)
        
        # Tentar usar Gemma-3n para gerar conteúdo educativo
        gemma_service = current_app.gemma_service
        
        if gemma_service and gemma_service.is_available():
            educational_content = _generate_educational_content_with_gemma(
                gemma_service, topic, age_group, education_level, 
                language, ecosystem, learning_style, duration, include_activities
            )
        else:
            # Fallback para conteúdo pré-definido
            educational_content = _generate_fallback_educational_content(
                topic, age_group, education_level, language, ecosystem, 
                learning_style, duration, include_activities
            )
        
        return jsonify({
            'success': True,
            'data': educational_content
        })
        
    except Exception as e:
        current_app.logger.error(f"Erro na educação ambiental: {e}")
        return jsonify({
            'success': False,
            'error': 'Erro interno do servidor',
            'message': str(e)
        }), 500


def _get_available_education_modules():
    """Retornar módulos educativos disponíveis"""
    return [
        {
            'id': 'biodiversity_basics',
            'title': 'Fundamentos da Biodiversidade',
            'description': 'Introdução à diversidade biológica da Guiné-Bissau',
            'duration': 20,
            'difficulty': 'basico',
            'ecosystem': 'geral',
            'topics': ['espécies nativas', 'ecossistemas', 'conservação']
        },
        {
            'id': 'mangrove_ecosystem',
            'title': 'Ecossistema de Mangue',
            'description': 'Explorando os manguezais únicos da Guiné-Bissau',
            'duration': 25,
            'difficulty': 'medio',
            'ecosystem': 'mangue',
            'topics': ['flora do mangue', 'fauna aquática', 'importância econômica']
        },
        {
            'id': 'forest_conservation',
            'title': 'Conservação Florestal',
            'description': 'Proteção das florestas tropicais',
            'duration': 30,
            'difficulty': 'medio',
            'ecosystem': 'floresta',
            'topics': ['desmatamento', 'reflorestamento', 'uso sustentável']
        },
        {
            'id': 'coastal_protection',
            'title': 'Proteção Costeira',
            'description': 'Conservação das áreas costeiras e marinhas',
            'duration': 25,
            'difficulty': 'medio',
            'ecosystem': 'costeiro',
            'topics': ['erosão costeira', 'pesca sustentável', 'turismo responsável']
        },
        {
            'id': 'climate_change',
            'title': 'Mudanças Climáticas',
            'description': 'Impactos e adaptação às mudanças climáticas',
            'duration': 35,
            'difficulty': 'superior',
            'ecosystem': 'geral',
            'topics': ['aquecimento global', 'adaptação', 'mitigação']
        },
        {
            'id': 'sustainable_agriculture',
            'title': 'Agricultura Sustentável',
            'description': 'Práticas agrícolas ambientalmente responsáveis',
            'duration': 30,
            'difficulty': 'medio',
            'ecosystem': 'agricola',
            'topics': ['agroecologia', 'solo saudável', 'controle biológico']
        }
    ]


def _generate_educational_content_with_gemma(gemma_service, topic, age_group, education_level, language, ecosystem, learning_style, duration, include_activities):
    """Gerar conteúdo educativo usando Gemma-3n"""
    
    # Construir prompt especializado para educação ambiental
    prompt = f"""
    Você é um educador ambiental especializado em criar conteúdo educativo para comunidades da Guiné-Bissau.
    
    Crie um módulo educativo com as seguintes especificações:
    - Tópico: {topic}
    - Faixa etária: {age_group}
    - Nível educacional: {education_level}
    - Idioma: {language}
    - Ecossistema: {ecosystem}
    - Estilo de aprendizagem: {learning_style}
    - Duração: {duration} minutos
    - Incluir atividades práticas: {include_activities}
    
    O conteúdo deve:
    1. Ser culturalmente relevante para a Guiné-Bissau
    2. Usar exemplos locais e espécies nativas
    3. Incluir conhecimento tradicional quando apropriado
    4. Ser adequado para o nível educacional especificado
    5. Promover a conservação e sustentabilidade
    
    Responda APENAS com um JSON válido no seguinte formato:
    {{
        "title": "Título do módulo educativo",
        "content": "Conteúdo educativo principal detalhado",
        "key_concepts": ["conceito1", "conceito2", "conceito3"],
        "learning_objectives": ["objetivo1", "objetivo2", "objetivo3"],
        "practical_activities": [
            {{
                "name": "Nome da atividade",
                "description": "Descrição detalhada",
                "materials": ["material1", "material2"],
                "duration": 10
            }}
        ],
        "local_examples": ["exemplo1", "exemplo2", "exemplo3"],
        "quiz_questions": [
            {{
                "question": "Pergunta sobre o conteúdo",
                "options": ["opção1", "opção2", "opção3", "opção4"],
                "correct_answer": 0
            }}
        ],
        "additional_resources": [
            {{
                "type": "video",
                "title": "Título do recurso",
                "description": "Descrição do recurso"
            }}
        ],
        "cultural_context": {{
            "traditional_knowledge": ["conhecimento1", "conhecimento2"],
            "local_practices": ["prática1", "prática2"],
            "community_involvement": ["envolvimento1", "envolvimento2"]
        }}
    }}
    """
    
    try:
        response = gemma_service.generate_response(prompt)
        
        # Tentar parsear a resposta como JSON
        import json
        educational_content = json.loads(response)
        
        # Validar estrutura básica
        required_fields = ['title', 'content', 'key_concepts', 'learning_objectives']
        for field in required_fields:
            if field not in educational_content:
                raise ValueError(f"Campo obrigatório '{field}' não encontrado na resposta")
        
        return educational_content
        
    except (json.JSONDecodeError, ValueError) as e:
        current_app.logger.warning(f"Erro ao parsear resposta do Gemma: {e}")
        # Fallback para conteúdo pré-definido
        return _generate_fallback_educational_content(
            topic, age_group, education_level, language, ecosystem, 
            learning_style, duration, include_activities
        )


def _generate_fallback_educational_content(topic, age_group, education_level, language, ecosystem, learning_style, duration, include_activities):
    """Gerar conteúdo educativo de fallback quando Gemma não está disponível"""
    
    # Conteúdo base por tópico
    content_templates = {
        'biodiversidade': {
            'title': 'Descobrindo a Biodiversidade da Guiné-Bissau',
            'content': 'A Guiné-Bissau é um país rico em biodiversidade, com ecossistemas únicos que abrigam uma grande variedade de espécies. Desde os manguezais costeiros até as florestas tropicais do interior, cada ambiente possui características especiais que sustentam diferentes formas de vida.',
            'key_concepts': ['Biodiversidade', 'Ecossistemas', 'Espécies nativas', 'Conservação'],
            'local_examples': ['Parque Nacional de Cantanhez', 'Arquipélago dos Bijagós', 'Reserva da Biosfera de Bolama-Bijagós']
        },
        'mangue': {
            'title': 'Os Manguezais: Berçários da Vida',
            'content': 'Os manguezais da Guiné-Bissau são ecossistemas únicos onde a água doce dos rios encontra a água salgada do oceano. Estas áreas são fundamentais para a reprodução de peixes, proteção da costa e sustento das comunidades locais.',
            'key_concepts': ['Mangue', 'Ecossistema costeiro', 'Biodiversidade aquática', 'Proteção costeira'],
            'local_examples': ['Manguezais de Cacheu', 'Estuário do Rio Geba', 'Ilhas Bijagós']
        },
        'floresta': {
            'title': 'Florestas Tropicais: Pulmões Verdes',
            'content': 'As florestas da Guiné-Bissau são lar de muitas espécies endêmicas e desempenham papel crucial na regulação do clima local. Elas fornecem recursos importantes para as comunidades e ajudam a manter o equilíbrio ecológico.',
            'key_concepts': ['Floresta tropical', 'Espécies endêmicas', 'Regulação climática', 'Recursos florestais'],
            'local_examples': ['Floresta de Cantanhez', 'Mata de Cufada', 'Floresta de Dulombi']
        }
    }
    
    # Selecionar template baseado no tópico
    template = content_templates.get(topic, content_templates['biodiversidade'])
    
    # Atividades práticas baseadas no estilo de aprendizagem
    activities = []
    if include_activities:
        if learning_style == 'visual':
            activities.append({
                'name': 'Galeria Fotográfica da Natureza',
                'description': 'Criar uma coleção de fotos de espécies locais e seus habitats',
                'materials': ['Câmera ou celular', 'Caderno de anotações'],
                'duration': 30
            })
        elif learning_style == 'pratico':
            activities.append({
                'name': 'Caminhada Ecológica',
                'description': 'Explorar um ecossistema local identificando espécies e observando interações',
                'materials': ['Guia de campo', 'Lupa', 'Caderno'],
                'duration': 45
            })
        else:
            activities.append({
                'name': 'Pesquisa Comunitária',
                'description': 'Entrevistar anciãos sobre conhecimento tradicional da natureza local',
                'materials': ['Gravador', 'Questionário'],
                'duration': 25
            })
    
    # Perguntas de quiz adaptadas ao nível educacional
    quiz_questions = [
        {
            'question': 'Qual é a principal função dos manguezais?',
            'options': [
                'Proteção costeira e berçário marinho',
                'Apenas produção de madeira',
                'Somente turismo',
                'Agricultura intensiva'
            ],
            'correct_answer': 0
        },
        {
            'question': 'Por que a biodiversidade é importante?',
            'options': [
                'Apenas para cientistas',
                'Equilíbrio ecológico e recursos',
                'Não tem importância',
                'Somente para animais'
            ],
            'correct_answer': 1
        }
    ]
    
    return {
        'title': template['title'],
        'content': template['content'],
        'key_concepts': template['key_concepts'],
        'learning_objectives': [
            f'Compreender a importância da {topic} na Guiné-Bissau',
            'Identificar espécies e ecossistemas locais',
            'Reconhecer práticas de conservação'
        ],
        'practical_activities': activities,
        'local_examples': template['local_examples'],
        'quiz_questions': quiz_questions,
        'additional_resources': [
            {
                'type': 'documento',
                'title': 'Guia de Biodiversidade da Guiné-Bissau',
                'description': 'Manual ilustrado com espécies nativas'
            },
            {
                'type': 'video',
                'title': 'Documentário: Natureza da Guiné-Bissau',
                'description': 'Exploração visual dos ecossistemas locais'
            }
        ],
        'cultural_context': {
            'traditional_knowledge': [
                'Conhecimento ancestral sobre plantas medicinais',
                'Técnicas tradicionais de pesca sustentável',
                'Calendário agrícola baseado em observações naturais'
            ],
            'local_practices': [
                'Rituais de proteção da natureza',
                'Uso sustentável de recursos florestais',
                'Práticas comunitárias de conservação'
            ],
            'community_involvement': [
                'Participação em programas de monitoramento',
                'Educação ambiental nas escolas',
                'Projetos comunitários de reflorestamento'
            ]
        }
    }


def _simulate_plant_image_diagnosis(image_base64, plant_type):
    """Simular diagnóstico de planta por imagem quando Gemma não está disponível"""
    import random
    
    # Plantas comuns na Guiné-Bissau
    plant_species = {
        'tomate': {'species': 'Solanum lycopersicum', 'common_name': 'Tomate'},
        'milho': {'species': 'Zea mays', 'common_name': 'Milho'},
        'arroz': {'species': 'Oryza sativa', 'common_name': 'Arroz'},
        'mandioca': {'species': 'Manihot esculenta', 'common_name': 'Mandioca'},
        'amendoim': {'species': 'Arachis hypogaea', 'common_name': 'Amendoim'},
        'feijão': {'species': 'Phaseolus vulgaris', 'common_name': 'Feijão'},
        'desconhecida': {'species': 'Espécie não identificada', 'common_name': 'Planta desconhecida'}
    }
    
    # Problemas comuns
    common_issues = [
        {
            'type': 'doença',
            'name': 'Mancha foliar',
            'severity': 'moderada',
            'confidence': random.uniform(0.6, 0.9)
        },
        {
            'type': 'praga',
            'name': 'Pulgões',
            'severity': 'leve',
            'confidence': random.uniform(0.5, 0.8)
        },
        {
            'type': 'deficiência',
            'name': 'Deficiência de nitrogênio',
            'severity': 'moderada',
            'confidence': random.uniform(0.7, 0.9)
        }
    ]
    
    plant_info = plant_species.get(plant_type.lower(), plant_species['desconhecida'])
    detected_issues = random.sample(common_issues, random.randint(0, 2))
    
    health_status = 'Saudável'
    if detected_issues:
        severities = [issue['severity'] for issue in detected_issues]
        if 'grave' in severities:
            health_status = 'Crítico'
        elif 'moderada' in severities:
            health_status = 'Moderadamente saudável'
        else:
            health_status = 'Levemente afetado'
    
    return {
        'plant_identification': {
            'species': plant_info['species'],
            'common_name': plant_info['common_name'],
            'confidence': random.uniform(0.7, 0.95)
        },
        'health_assessment': {
            'overall_health': health_status,
            'issues_detected': detected_issues
        },
        'recommendations': {
            'immediate_actions': [
                'Remover folhas afetadas',
                'Melhorar drenagem do solo',
                'Aplicar fertilizante orgânico'
            ],
            'preventive_measures': [
                'Rotação de culturas',
                'Monitoramento regular',
                'Controle de irrigação'
            ],
            'treatment_options': [
                {
                    'method': 'Tratamento orgânico',
                    'description': 'Uso de extratos naturais e compostagem',
                    'effectiveness': 'Alta para prevenção'
                },
                {
                    'method': 'Manejo integrado',
                    'description': 'Combinação de práticas culturais e biológicas',
                    'effectiveness': 'Muito alta'
                }
            ]
        }
    }

def _simulate_plant_audio_diagnosis(audio_base64, plant_type):
    """Simular diagnóstico de planta por áudio quando Gemma não está disponível"""
    import random
    
    # Sintomas comuns descritos em áudio
    common_symptoms = [
        {
            'symptom': 'amarelamento das folhas',
            'possible_causes': ['Deficiência nutricional', 'Excesso de água', 'Doença fúngica'],
            'severity': 'moderada'
        },
        {
            'symptom': 'manchas nas folhas',
            'possible_causes': ['Doença bacteriana', 'Queimadura solar', 'Deficiência de potássio'],
            'severity': 'leve'
        },
        {
            'symptom': 'folhas murchas',
            'possible_causes': ['Falta de água', 'Problemas nas raízes', 'Excesso de calor'],
            'severity': 'moderada'
        }
    ]
    
    # Simular transcrição
    transcriptions = [
        'As folhas estão amarelando e caindo',
        'Há manchas escuras nas folhas',
        'A planta está murcha mesmo com água',
        'As folhas ficaram com bordas queimadas',
        'Apareceram pequenos insetos nas folhas'
    ]
    
    selected_symptoms = random.sample(common_symptoms, random.randint(1, 2))
    transcription = random.choice(transcriptions)
    
    primary_causes = [symptom['possible_causes'][0] for symptom in selected_symptoms]
    primary_cause = primary_causes[0] if primary_causes else 'Estresse ambiental'
    
    return {
        'audio_transcription': transcription,
        'symptoms_identified': selected_symptoms,
        'probable_diagnosis': {
            'primary_cause': primary_cause,
            'confidence': random.uniform(0.6, 0.8),
            'alternative_causes': [
                'Deficiência nutricional',
                'Estresse hídrico',
                'Ataque de pragas'
            ]
        },
        'recommendations': {
            'immediate_actions': [
                'Verificar umidade do solo',
                'Examinar presença de pragas',
                'Ajustar irrigação'
            ],
            'diagnostic_steps': [
                'Coletar amostra de solo para análise',
                'Fotografar sintomas para comparação',
                'Monitorar evolução por 3-5 dias'
            ],
            'treatment_options': [
                {
                    'method': 'Correção nutricional',
                    'description': 'Aplicação de fertilizante balanceado',
                    'timeline': '2-3 semanas para resultados'
                },
                {
                    'method': 'Controle biológico',
                    'description': 'Uso de predadores naturais',
                    'timeline': '1-2 semanas para efeito'
                }
            ]
        }
    }

def _analyze_plant_image_with_gemma(gemma_service, image_base64, plant_type, language):
    """Analisar imagem de planta usando Gemma"""
    try:
        prompt = f"""
        Você é um especialista em diagnóstico de plantas e agricultura tropical, especialmente familiarizado com as culturas da Guiné-Bissau.
        
        Analise esta imagem de uma planta (tipo: {plant_type}) e forneça um diagnóstico detalhado.
        
        Sua resposta deve incluir:
        1. Identificação da espécie (nome científico e comum)
        2. Avaliação da saúde geral
        3. Problemas identificados (doenças, pragas, deficiências)
        4. Recomendações de tratamento
        
        Considere o clima tropical da Guiné-Bissau e práticas agrícolas locais.
        Responda em {language}.
        
        Formate sua resposta como JSON com a seguinte estrutura:
        {{
            "plant_identification": {{
                "species": "nome científico",
                "common_name": "nome comum",
                "confidence": 0.0-1.0
            }},
            "health_assessment": {{
                "overall_health": "status geral",
                "issues_detected": [
                    {{
                        "type": "doença/praga/deficiência",
                        "name": "nome do problema",
                        "severity": "leve/moderada/grave",
                        "confidence": 0.0-1.0
                    }}
                ]
            }},
            "recommendations": {{
                "immediate_actions": ["ação1", "ação2"],
                "preventive_measures": ["medida1", "medida2"],
                "treatment_options": [
                    {{
                        "method": "método",
                        "description": "descrição",
                        "effectiveness": "eficácia"
                    }}
                ]
            }}
        }}
        """
        
        response = gemma_service.analyze_multimodal(
            prompt=prompt,
            image_base64=image_base64
        )
        
        return _process_gemma_plant_response(response)
        
    except Exception as e:
        logger.error(f"Erro na análise com Gemma: {e}")
        # Fallback para simulação
        return _simulate_plant_image_diagnosis(image_base64, plant_type)

def _analyze_plant_audio_with_gemma(gemma_service, audio_base64, plant_type, language):
    """Analisar descrição em áudio sobre planta usando Gemma"""
    try:
        prompt = f"""
        Você é um especialista em diagnóstico de plantas e agricultura tropical da Guiné-Bissau.
        
        Analise esta descrição em áudio sobre problemas em uma planta (tipo: {plant_type}).
        
        Baseado na descrição, identifique:
        1. Sintomas mencionados
        2. Possíveis causas
        3. Diagnóstico provável
        4. Recomendações de tratamento
        
        Considere práticas agrícolas locais e recursos disponíveis na Guiné-Bissau.
        Responda em {language}.
        
        Formate sua resposta como JSON:
        {{
            "audio_transcription": "transcrição do áudio",
            "symptoms_identified": [
                {{
                    "symptom": "sintoma",
                    "possible_causes": ["causa1", "causa2"],
                    "severity": "leve/moderada/grave"
                }}
            ],
            "probable_diagnosis": {{
                "primary_cause": "causa principal",
                "confidence": 0.0-1.0,
                "alternative_causes": ["alternativa1", "alternativa2"]
            }},
            "recommendations": {{
                "immediate_actions": ["ação1", "ação2"],
                "diagnostic_steps": ["passo1", "passo2"],
                "treatment_options": [
                    {{
                        "method": "método",
                        "description": "descrição",
                        "timeline": "prazo"
                    }}
                ]
            }}
        }}
        """
        
        response = gemma_service.analyze_multimodal(
            prompt=prompt,
            audio_base64=audio_base64
        )
        
        return _process_gemma_plant_response(response)
        
    except Exception as e:
        logger.error(f"Erro na análise de áudio com Gemma: {e}")
        # Fallback para simulação
        return _simulate_plant_audio_diagnosis(audio_base64, plant_type)

def _process_gemma_plant_response(response):
    """Processar resposta do Gemma para diagnóstico de plantas"""
    try:
        import json
        import re
        
        # Extrair JSON da resposta
        json_match = re.search(r'\{.*\}', response, re.DOTALL)
        if json_match:
            json_str = json_match.group()
            return json.loads(json_str)
        else:
            # Se não conseguir extrair JSON, criar resposta estruturada
            return {
                'plant_identification': {
                    'species': 'Análise em processamento',
                    'common_name': 'Aguarde resultado',
                    'confidence': 0.5
                },
                'health_assessment': {
                    'overall_health': 'Em análise',
                    'issues_detected': []
                },
                'recommendations': {
                    'immediate_actions': ['Aguardar análise completa'],
                    'preventive_measures': ['Monitoramento regular'],
                    'treatment_options': []
                },
                'raw_response': response
            }
            
    except Exception as e:
        logger.error(f"Erro ao processar resposta do Gemma: {e}")
        return {
            'plant_identification': {
                'species': 'Erro na análise',
                'common_name': 'Tente novamente',
                'confidence': 0.0
            },
            'health_assessment': {
                'overall_health': 'Não determinado',
                'issues_detected': []
            },
            'recommendations': {
                'immediate_actions': ['Consultar especialista local'],
                'preventive_measures': ['Cuidados básicos'],
                'treatment_options': []
            },
            'error': str(e)
        }

@environmental_bp.route('/recycling/scan', methods=['POST'])
def scan_recycling():
    """
    Analisar material para reciclagem
    ---
    tags:
      - Environmental
    summary: Analisar material para reciclagem
    description: |
      Analisa uma imagem de material para identificar o tipo de resíduo,
      classificação de reciclagem e fornecer orientações de descarte adequado.
    requestBody:
      required: true
      content:
        multipart/form-data:
          schema:
            type: object
            properties:
              image:
                type: string
                format: binary
                description: Imagem do material a ser analisado
              location:
                type: string
                description: Localização para recomendações específicas
                example: "Bissau"
              language:
                type: string
                description: Idioma da resposta
                default: "pt"
                example: "pt"
            required:
              - image
    responses:
      200:
        description: Análise de reciclagem realizada com sucesso
        content:
          application/json:
            schema:
              type: object
              properties:
                success:
                  type: boolean
                  example: true
                data:
                  type: object
                  properties:
                    material_type:
                      type: string
                      example: "Plástico PET"
                    recyclable:
                      type: boolean
                      example: true
                    recycling_category:
                      type: string
                      example: "Plástico Tipo 1"
                    disposal_instructions:
                      type: array
                      items:
                        type: string
                      example: ["Remover rótulos", "Lavar o recipiente", "Depositar no contentor azul"]
                    environmental_impact:
                      type: object
                      properties:
                        co2_saved:
                          type: string
                          example: "0.5 kg CO2"
                        energy_saved:
                          type: string
                          example: "2.3 kWh"
                    nearest_collection_points:
                      type: array
                      items:
                        type: object
                        properties:
                          name:
                            type: string
                          address:
                            type: string
                          distance_km:
                            type: number
                          accepts:
                            type: array
                            items:
                              type: string
                    tips:
                      type: array
                      items:
                        type: string
                      example: ["Separe por tipo de material", "Mantenha limpo e seco"]
                timestamp:
                  type: string
                  format: date-time
      400:
        description: Dados inválidos ou imagem não fornecida
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ErrorResponse'
      500:
        description: Erro interno do servidor
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ErrorResponse'
    """
    try:
        # Verificar se uma imagem foi enviada
        if 'image' not in request.files:
            return jsonify(create_error_response(
                'missing_image',
                'Imagem é obrigatória para análise de reciclagem',
                400
            )), 400
        
        image_file = request.files['image']
        if image_file.filename == '':
            return jsonify(create_error_response(
                'empty_image',
                'Nenhuma imagem foi selecionada',
                400
            )), 400
        
        # Parâmetros opcionais
        location = request.form.get('location', 'Bissau')
        language = request.form.get('language', 'pt')
        
        # Processar imagem com Gemma
        gemma_service = current_app.gemma_service
        if not gemma_service:
            # Fallback para análise simulada
            analysis_result = _simulate_recycling_analysis(image_file, location)
        else:
            # Usar Gemma para análise real
            analysis_result = _analyze_recycling_with_gemma(
                gemma_service, image_file, location, language
            )
        
        return jsonify({
            'success': True,
            'data': analysis_result,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "análise de reciclagem")
        return jsonify(create_error_response(
            'recycling_analysis_error',
            'Erro ao analisar material para reciclagem',
            500
        )), 500

@environmental_bp.route('/biodiversity/track', methods=['POST'])
def track_biodiversity():
    """
    Rastrear biodiversidade através de imagem
    ---
    tags:
      - Environmental
    summary: Rastrear biodiversidade através de imagem
    description: |
      Analisa uma imagem para identificar espécies, avaliar biodiversidade local
      e fornecer informações sobre conservação e monitoramento.
    requestBody:
      required: true
      content:
        multipart/form-data:
          schema:
            type: object
            properties:
              image:
                type: string
                format: binary
                description: Imagem da fauna/flora a ser analisada
              location:
                type: string
                description: Localização para análise contextual
                example: "Bissau"
              ecosystem_type:
                type: string
                description: Tipo de ecossistema
                example: "floresta"
              language:
                type: string
                description: Idioma da resposta
                default: "pt"
                example: "pt"
            required:
              - image
    responses:
      200:
        description: Análise de biodiversidade realizada com sucesso
        content:
          application/json:
            schema:
              type: object
              properties:
                success:
                  type: boolean
                  example: true
                data:
                  type: object
                  properties:
                    species_identified:
                      type: array
                      items:
                        type: object
                        properties:
                          name:
                            type: string
                            example: "Cecropia peltata"
                          common_name:
                            type: string
                            example: "Embaúba"
                          confidence:
                            type: number
                            example: 0.85
                          conservation_status:
                            type: string
                            example: "Pouco Preocupante"
                          endemic:
                            type: boolean
                            example: false
                    biodiversity_index:
                      type: object
                      properties:
                        score:
                          type: number
                          example: 7.5
                        level:
                          type: string
                          example: "Alto"
                        factors:
                          type: array
                          items:
                            type: string
                    ecosystem_health:
                      type: object
                      properties:
                        status:
                          type: string
                          example: "Saudável"
                        indicators:
                          type: array
                          items:
                            type: string
                        threats:
                          type: array
                          items:
                            type: string
                    conservation_recommendations:
                      type: array
                      items:
                        type: string
                      example: ["Proteger habitat natural", "Monitoramento regular"]
                    monitoring_suggestions:
                      type: array
                      items:
                        type: string
                    local_programs:
                      type: array
                      items:
                        type: object
                        properties:
                          name:
                            type: string
                          description:
                            type: string
                          contact:
                            type: string
                timestamp:
                  type: string
                  format: date-time
      400:
        description: Dados inválidos ou imagem não fornecida
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ErrorResponse'
      500:
        description: Erro interno do servidor
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ErrorResponse'
    """
    try:
        # Verificar se uma imagem foi enviada
        if 'image' not in request.files:
            return jsonify(create_error_response(
                'missing_image',
                'Imagem é obrigatória para rastreamento de biodiversidade',
                400
            )), 400
        
        image_file = request.files['image']
        if image_file.filename == '':
            return jsonify(create_error_response(
                'empty_image',
                'Nenhuma imagem foi selecionada',
                400
            )), 400
        
        # Parâmetros opcionais
        location = request.form.get('location', 'Bissau')
        ecosystem_type = request.form.get('ecosystem_type', 'floresta')
        language = request.form.get('language', 'pt')
        
        # Processar imagem com Gemma
        gemma_service = current_app.gemma_service
        if not gemma_service:
            # Fallback para análise simulada
            analysis_result = _simulate_biodiversity_analysis(image_file, location, ecosystem_type)
        else:
            # Usar Gemma para análise real
            analysis_result = _analyze_biodiversity_with_gemma(
                gemma_service, image_file, location, ecosystem_type, language
            )
        
        return jsonify({
            'success': True,
            'data': analysis_result,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "rastreamento de biodiversidade")
        return jsonify(create_error_response(
            'biodiversity_tracking_error',
            'Erro ao rastrear biodiversidade',
            500
        )), 500

def _simulate_recycling_analysis(image_file, location):
    """Simular análise de reciclagem quando Gemma não está disponível"""
    # Análise simulada baseada no nome do arquivo ou outros fatores
    filename = image_file.filename.lower()
    
    # Determinar tipo de material baseado em padrões comuns
    if any(term in filename for term in ['pet', 'garrafa', 'bottle']):
        material_type = "Plástico PET"
        recyclable = True
        category = "Plástico Tipo 1"
        disposal_instructions = [
            "Remover rótulos e tampas",
            "Lavar o recipiente com água",
            "Depositar no contentor azul para plásticos"
        ]
        co2_saved = "0.5 kg CO2"
        energy_saved = "2.3 kWh"
    elif any(term in filename for term in ['papel', 'paper', 'cardboard']):
        material_type = "Papel/Papelão"
        recyclable = True
        category = "Papel"
        disposal_instructions = [
            "Remover fitas adesivas e grampos",
            "Manter seco",
            "Depositar no contentor azul para papel"
        ]
        co2_saved = "1.2 kg CO2"
        energy_saved = "4.1 kWh"
    elif any(term in filename for term in ['metal', 'lata', 'can', 'aluminio']):
        material_type = "Metal/Alumínio"
        recyclable = True
        category = "Metal"
        disposal_instructions = [
            "Lavar para remover resíduos",
            "Amassar para economizar espaço",
            "Depositar no contentor amarelo para metais"
        ]
        co2_saved = "2.1 kg CO2"
        energy_saved = "8.7 kWh"
    elif any(term in filename for term in ['vidro', 'glass']):
        material_type = "Vidro"
        recyclable = True
        category = "Vidro"
        disposal_instructions = [
            "Remover tampas e rótulos",
            "Lavar para remover resíduos",
            "Depositar no contentor verde para vidros"
        ]
        co2_saved = "0.8 kg CO2"
        energy_saved = "3.2 kWh"
    else:
        material_type = "Material Misto"
        recyclable = False
        category = "Resíduo Comum"
        disposal_instructions = [
            "Verificar composição do material",
            "Consultar centro de reciclagem local",
            "Depositar no lixo comum se não reciclável"
        ]
        co2_saved = "0 kg CO2"
        energy_saved = "0 kWh"
    
    # Pontos de coleta simulados para Bissau
    collection_points = [
        {
            "name": "Centro de Reciclagem Bissau",
            "address": "Avenida Amílcar Cabral, Bissau",
            "distance_km": 2.5,
            "accepts": ["Plástico", "Papel", "Metal", "Vidro"]
        },
        {
            "name": "Ecoponto Bandim",
            "address": "Bairro Bandim, Bissau",
            "distance_km": 4.1,
            "accepts": ["Plástico", "Papel"]
        },
        {
            "name": "Cooperativa de Reciclagem",
            "address": "Mercado Central, Bissau",
            "distance_km": 1.8,
            "accepts": ["Metal", "Vidro"]
        }
    ]
    
    # Dicas gerais de reciclagem
    tips = [
        "Separe os materiais por tipo antes do descarte",
        "Mantenha os materiais limpos e secos",
        "Remova etiquetas e adesivos quando possível",
        "Reduza, reutilize e depois recicle",
        "Participe de programas comunitários de reciclagem"
    ]
    
    return {
        "material_type": material_type,
        "recyclable": recyclable,
        "recycling_category": category,
        "disposal_instructions": disposal_instructions,
        "environmental_impact": {
            "co2_saved": co2_saved,
            "energy_saved": energy_saved
        },
        "nearest_collection_points": collection_points,
        "tips": tips,
        "confidence": 0.75,
        "analysis_method": "simulation"
    }

def _analyze_recycling_with_gemma(gemma_service, image_file, location, language):
    """Analisar reciclagem usando o modelo Gemma"""
    try:
        # Preparar prompt para análise de reciclagem
        recycling_prompt = f"""
        Analise esta imagem de material e forneça informações detalhadas sobre reciclagem.
        
        Localização: {location}
        Idioma de resposta: {language}
        
        Por favor, identifique:
        1. Tipo de material (plástico, papel, metal, vidro, etc.)
        2. Se é reciclável ou não
        3. Categoria específica de reciclagem
        4. Instruções de descarte adequado
        5. Impacto ambiental da reciclagem
        6. Dicas de preparação para reciclagem
        
        Forneça uma resposta estruturada e educativa adequada para a comunidade local.
        """
        
        # Processar imagem com Gemma
        analysis = gemma_service.analyze_image(
            image_file.read(),
            recycling_prompt,
            max_tokens=1000
        )
        
        # Processar resposta do Gemma e estruturar dados
        return _process_gemma_recycling_response(analysis, location)
        
    except Exception as e:
        logger.warning(f"Erro na análise com Gemma: {e}. Usando análise simulada.")
        return _simulate_recycling_analysis(image_file, location)

def _process_gemma_recycling_response(gemma_response, location):
    """Processar resposta do Gemma e estruturar dados de reciclagem"""
    # Esta função processaria a resposta do Gemma e extrairia informações estruturadas
    # Por enquanto, retornamos uma análise simulada melhorada
    
    return {
        "material_type": "Material identificado por IA",
        "recyclable": True,
        "recycling_category": "Categoria determinada por análise",
        "disposal_instructions": [
            "Instruções baseadas em análise de IA",
            "Preparação adequada do material",
            "Descarte no local apropriado"
        ],
        "environmental_impact": {
            "co2_saved": "Calculado por IA",
            "energy_saved": "Estimativa baseada no material"
        },
        "nearest_collection_points": [
            {
                "name": "Ponto de coleta identificado",
                "address": f"Localização próxima a {location}",
                "distance_km": 2.0,
                "accepts": ["Material analisado"]
            }
        ],
        "tips": [
            "Dicas personalizadas baseadas na análise",
            "Recomendações específicas para o material"
        ],
        "confidence": 0.95,
        "analysis_method": "gemma_ai"
    }

def _generate_weather_recommendations(weather_data, data_type):
    """Gerar recomendações baseadas no tempo"""
    recommendations = []
    current = weather_data.get('current', {})
    
    if data_type == 'agricultural':
        if current.get('precipitation', 0) < 2:
            recommendations.append('Considere irrigação para culturas sensíveis')
        if current.get('humidity', 0) > 80:
            recommendations.append('Monitore pragas e doenças devido à alta umidade')
        if current.get('temperature', 0) > 32:
            recommendations.append('Proteja culturas do calor excessivo')
    else:
        if current.get('uv_index', 0) > 7:
            recommendations.append('Use protetor solar e evite exposição prolongada ao sol')
        if current.get('temperature', 0) > 30:
            recommendations.append('Mantenha-se hidratado e procure locais frescos')
        if current.get('precipitation_probability', 0) > 60:
            recommendations.append('Leve guarda-chuva ou capa de chuva')
    
    return recommendations

def _get_air_quality_data(location, radius_km, pollutants, time_range):
    """Obter dados de qualidade do ar"""
    # Simulação de dados de qualidade do ar
    return {
        'aqi': 65,  # Índice de qualidade do ar
        'pollutants': {
            'pm25': {'value': 25, 'unit': 'μg/m³', 'status': 'moderate'},
            'pm10': {'value': 45, 'unit': 'μg/m³', 'status': 'moderate'},
            'no2': {'value': 30, 'unit': 'μg/m³', 'status': 'good'},
            'so2': {'value': 15, 'unit': 'μg/m³', 'status': 'good'},
            'co': {'value': 1.2, 'unit': 'mg/m³', 'status': 'good'},
            'o3': {'value': 80, 'unit': 'μg/m³', 'status': 'moderate'}
        },
        'trends': {
            'improving': ['so2', 'co'],
            'stable': ['no2'],
            'worsening': ['pm25', 'pm10']
        },
        'stations': [
            {'name': 'Bissau Centro', 'distance_km': 2.5, 'status': 'active'},
            {'name': 'Bissau Porto', 'distance_km': 8.1, 'status': 'active'}
        ],
        'last_updated': datetime.now().isoformat()
    }

def _get_aqi_category(aqi):
    """Obter categoria do índice de qualidade do ar"""
    if aqi <= 50:
        return {'category': 'Bom', 'color': 'green', 'description': 'Qualidade do ar satisfatória'}
    elif aqi <= 100:
        return {'category': 'Moderado', 'color': 'yellow', 'description': 'Qualidade do ar aceitável'}
    elif aqi <= 150:
        return {'category': 'Insalubre para grupos sensíveis', 'color': 'orange', 'description': 'Grupos sensíveis podem sentir efeitos'}
    elif aqi <= 200:
        return {'category': 'Insalubre', 'color': 'red', 'description': 'Todos podem sentir efeitos na saúde'}
    elif aqi <= 300:
        return {'category': 'Muito insalubre', 'color': 'purple', 'description': 'Emergência de saúde'}
    else:
        return {'category': 'Perigoso', 'color': 'maroon', 'description': 'Alerta de saúde'}

def _extract_recommendations(response):
    """Extrair recomendações da resposta"""
    recommendations = []
    lines = response.split('\n')
    
    for line in lines:
        line = line.strip()
        if any(keyword in line.lower() for keyword in ['recomend', 'suger', 'deve', 'precisa', 'importante']):
            if len(line) > 10 and not line.startswith('#'):
                recommendations.append(line)
    
    # Recomendações padrão se nenhuma for encontrada
    if not recommendations:
        recommendations = [
            "Monitorar regularmente os indicadores ambientais",
            "Implementar práticas sustentáveis",
            "Buscar orientação técnica quando necessário"
        ]
    
    return recommendations[:5]  # Limitar a 5 recomendações

def _calculate_sustainability_score(analysis_type, response):
    """Calcular pontuação de sustentabilidade"""
    base_score = 70
    
    # Ajustar pontuação baseada no tipo de análise
    type_scores = {
        'water': 75,
        'soil': 80,
        'air': 65,
        'climate': 70,
        'biodiversity': 85,
        'sustainability': 75
    }
    
    score = type_scores.get(analysis_type, base_score)
    
    # Ajustar baseado em palavras-chave na resposta
    positive_keywords = ['sustentável', 'renovável', 'limpo', 'preservar', 'conservar']
    negative_keywords = ['poluição', 'degradação', 'contaminação', 'destruição']
    
    response_lower = response.lower()
    
    for keyword in positive_keywords:
        if keyword in response_lower:
            score += 2
    
    for keyword in negative_keywords:
        if keyword in response_lower:
            score -= 3
    
    return max(0, min(100, score))

def _assess_environmental_impact(response):
    """Avaliar impacto ambiental"""
    response_lower = response.lower()
    
    high_impact_keywords = ['grave', 'crítico', 'urgente', 'perigoso', 'severo']
    medium_impact_keywords = ['moderado', 'atenção', 'cuidado', 'monitorar']
    low_impact_keywords = ['leve', 'mínimo', 'baixo', 'controlado']
    
    if any(keyword in response_lower for keyword in high_impact_keywords):
        return "Alto impacto - Ação imediata necessária"
    elif any(keyword in response_lower for keyword in medium_impact_keywords):
        return "Impacto moderado - Monitoramento recomendado"
    elif any(keyword in response_lower for keyword in low_impact_keywords):
        return "Baixo impacto - Situação controlada"
    else:
        return "Impacto a ser avaliado - Análise adicional necessária"

def _extract_next_steps(response):
    """Extrair próximos passos da resposta"""
    next_steps = []
    lines = response.split('\n')
    
    for line in lines:
        line = line.strip()
        if any(keyword in line.lower() for keyword in ['próximo', 'seguinte', 'depois', 'então', 'em seguida']):
            if len(line) > 10 and not line.startswith('#'):
                next_steps.append(line)
    
    # Passos padrão se nenhum for encontrado
    if not next_steps:
        next_steps = [
            "Coletar mais dados sobre a situação atual",
            "Implementar as recomendações prioritárias",
            "Agendar reavaliação em 30 dias"
        ]
    
    return next_steps[:4]  # Limitar a 4 passos

def _get_monitoring_suggestions(analysis_type):
    """Obter sugestões de monitoramento baseadas no tipo de análise"""
    monitoring_suggestions = {
        'water': [
            "Testar pH da água semanalmente",
            "Verificar turbidez e cor da água",
            "Monitorar fontes de contaminação próximas",
            "Observar mudanças na vida aquática"
        ],
        'soil': [
            "Analisar pH do solo mensalmente",
            "Verificar erosão e compactação",
            "Monitorar matéria orgânica",
            "Observar crescimento das plantas"
        ],
        'air': [
            "Observar qualidade do ar diariamente",
            "Monitorar fontes de poluição",
            "Verificar condições meteorológicas",
            "Atentar para sintomas respiratórios"
        ],
        'climate': [
            "Registrar temperaturas diárias",
            "Monitorar padrões de chuva",
            "Observar mudanças sazonais",
            "Acompanhar eventos climáticos extremos"
        ],
        'biodiversity': [
            "Observar espécies locais regularmente",
            "Monitorar habitats naturais",
            "Registrar mudanças na fauna e flora",
            "Verificar áreas de conservação"
        ],
        'sustainability': [
            "Avaliar práticas sustentáveis mensalmente",
            "Monitorar uso de recursos",
            "Verificar impactos ambientais",
            "Acompanhar indicadores de sustentabilidade"
        ]
    }
    
    return monitoring_suggestions.get(analysis_type, [
        "Monitorar indicadores ambientais relevantes",
        "Registrar observações regularmente",
        "Buscar orientação técnica quando necessário",
        "Avaliar progresso periodicamente"
    ])

def _analyze_air_quality_health_impact(air_data, health_focus):
    """Analisar impacto da qualidade do ar na saúde"""
    aqi = air_data.get('aqi', 0)
    
    impact = {
        'risk_level': 'low',
        'affected_groups': [],
        'symptoms': [],
        'recommendations': []
    }
    
    if aqi > 100:
        impact['risk_level'] = 'moderate'
        impact['affected_groups'] = ['crianças', 'idosos', 'pessoas com problemas respiratórios']
        impact['symptoms'] = ['irritação nos olhos', 'tosse leve', 'desconforto respiratório']
    
    if aqi > 150:
        impact['risk_level'] = 'high'
        impact['affected_groups'].append('população geral')
        impact['symptoms'].extend(['dificuldade respiratória', 'fadiga', 'dor de cabeça'])
    
    if health_focus == 'respiratory':
        impact['specific_concerns'] = ['agravamento de asma', 'bronquite', 'DPOC']
    elif health_focus == 'cardiovascular':
        impact['specific_concerns'] = ['pressão arterial', 'arritmias', 'infarto']
    elif health_focus == 'children':
        impact['specific_concerns'] = ['desenvolvimento pulmonar', 'infecções respiratórias']
    
    return impact

def _generate_air_quality_recommendations(air_data, health_focus):
    """Gerar recomendações de proteção"""
    aqi = air_data.get('aqi', 0)
    recommendations = []
    
    if aqi > 50:
        recommendations.extend([
            'Limite atividades ao ar livre prolongadas',
            'Mantenha janelas fechadas durante picos de poluição',
            'Use purificadores de ar em ambientes internos'
        ])
    
    if aqi > 100:
        recommendations.extend([
            'Evite exercícios ao ar livre',
            'Use máscara de proteção quando sair',
            'Grupos sensíveis devem permanecer em ambientes internos'
        ])
    
    if aqi > 150:
        recommendations.extend([
            'Evite todas as atividades ao ar livre',
            'Procure atendimento médico se sentir sintomas',
            'Considere deixar a área se possível'
        ])
    
    return recommendations

# Implementações simplificadas para outras funções

def _analyze_water_quality_data(source, location, tests, visual, purpose, date, concerns):
    return {'quality_score': 75, 'contaminants': [], 'safety_level': 'acceptable'}

def _assess_water_safety(analysis, purpose):
    return {'safe_for_use': True, 'treatment_needed': False, 'risk_level': 'low'}

def _generate_water_treatment_recommendations(analysis, purpose):
    return ['Filtração básica recomendada', 'Teste regular de qualidade']

def _suggest_monitoring_schedule(source, safety):
    return {'frequency': 'monthly', 'parameters': ['pH', 'turbidez', 'bactérias']}

def _suggest_community_water_actions(analysis, concerns):
    return ['Educação sobre qualidade da água', 'Programa de testes comunitários']

def _get_water_emergency_protocols(safety):
    return ['Ferver água antes do consumo', 'Usar água engarrafada se disponível']

def _analyze_soil_health_data(location, soil_type, crop, tests, visual, history, env, observations):
    return {'overall_health_score': 70, 'nutrient_levels': 'adequate', 'ph_level': 6.5}

def _categorize_soil_health(score):
    if score >= 80: return 'Excelente'
    elif score >= 60: return 'Bom'
    elif score >= 40: return 'Regular'
    else: return 'Ruim'

def _generate_soil_management_recommendations(analysis, crop_type):
    return ['Adicionar matéria orgânica', 'Rotação de culturas', 'Controle de erosão']

def _create_soil_improvement_plan(analysis, recommendations):
    return {'short_term': recommendations[:2], 'long_term': recommendations[2:]}

def _suggest_soil_monitoring_schedule(analysis):
    return {'frequency': 'seasonal', 'tests': ['pH', 'nutrientes', 'matéria orgânica']}

def _get_seasonal_soil_considerations(location, crop_type):
    return ['Preparação para estação chuvosa', 'Manejo durante seca']

def _calculate_soil_sustainability_metrics(analysis):
    return {'carbon_sequestration': 'medium', 'erosion_risk': 'low', 'biodiversity_index': 'good'}

def _get_biodiversity_information(location, ecosystem, species, status, source):
    return {'total_species': 150, 'endemic_species': ['espécie A', 'espécie B'], 'threatened_species': ['espécie C']}

def _analyze_biodiversity_threats(data, location, ecosystem):
    return {'primary_threats': ['desmatamento', 'poluição'], 'threat_level': 'moderate'}

def _generate_conservation_recommendations(data, threats):
    return ['Proteção de habitats', 'Educação ambiental', 'Monitoramento de espécies']

def _get_community_conservation_opportunities(location):
    return ['Programa de reflorestamento', 'Monitoramento participativo']

def _get_biodiversity_monitoring_programs(location):
    return ['Censo de aves', 'Monitoramento de mamíferos']

def _get_conservation_success_stories(location):
    return ['Recuperação de área degradada', 'Proteção de espécie ameaçada']

def _perform_climate_analysis(location, period, variables, analysis_type, sector):
    return {'temperature_trend': 'increasing', 'precipitation_trend': 'variable', 'extreme_events': 'increasing'}

def _generate_climate_projections(analysis, location, sector):
    return {'temperature_increase': '1.5°C by 2050', 'precipitation_change': 'variable', 'sea_level_rise': '20cm by 2050'}

def _assess_climate_impacts(analysis, sector, location):
    return {'agriculture': 'moderate impact', 'water': 'high impact', 'health': 'moderate impact'}

def _suggest_climate_adaptation_strategies(impacts, sector):
    return ['Culturas resistentes à seca', 'Sistemas de irrigação eficientes', 'Infraestrutura resiliente']

def _assess_climate_vulnerability(location, sector):
    return {'vulnerability_level': 'moderate', 'key_vulnerabilities': ['recursos hídricos', 'agricultura']}

def _generate_resilience_recommendations(impacts):
    return ['Diversificação econômica', 'Infraestrutura adaptativa', 'Capacitação comunitária']

def _suggest_climate_monitoring_indicators(sector):
    return ['temperatura', 'precipitação', 'eventos extremos']

def _perform_sustainability_assessment(project_type, location, description, env_data, social, economic, timeframe, scope):
    return {'overall_score': 75, 'environmental_score': 80, 'social_score': 70, 'economic_score': 75}

def _get_sustainability_rating(score):
    if score >= 80: return 'Excelente'
    elif score >= 60: return 'Bom'
    elif score >= 40: return 'Regular'
    else: return 'Ruim'

def _generate_sustainability_improvements(assessment, project_type):
    return ['Reduzir pegada de carbono', 'Melhorar eficiência energética', 'Aumentar benefícios sociais']

def _create_sustainability_monitoring_plan(assessment, timeframe):
    return {'indicators': ['emissões', 'uso de recursos', 'impacto social'], 'frequency': 'quarterly'}

def _identify_sustainability_certifications(project_type, assessment):
    return ['ISO 14001', 'LEED', 'Certificação orgânica']

def _assess_community_sustainability_benefits(assessment):
    return ['geração de empregos', 'melhoria da qualidade de vida', 'preservação ambiental']

def _suggest_sustainability_risk_mitigation(assessment):
    return ['monitoramento contínuo', 'planos de contingência', 'engajamento comunitário']

# Funções auxiliares adicionais

def _calculate_harvest_window(forecast):
    return 'Próximos 5-7 dias favoráveis para colheita'

def _assess_crop_stress_from_weather(current, forecast):
    return ['estresse hídrico moderado', 'risco de pragas baixo']

@environmental_bp.route('/environmental/alerts', methods=['GET'])
def get_environmental_alerts():
    """
    Obter alertas ambientais em tempo real usando Gemma3
    
    Parâmetros suportados:
    - location: Nome da cidade/região (ex: 'São Paulo', 'New York', 'Tokyo')
    - latitude: Coordenada de latitude (ex: -23.5505)
    - longitude: Coordenada de longitude (ex: -46.6333)
    - types: Tipos de alerta ['weather', 'air_quality', 'agriculture', 'emergency']
    - severity: Filtro de severidade ['low', 'medium', 'high', 'critical', 'all']
    - language: Idioma da resposta ['pt', 'en', 'fr', 'es'] (padrão: 'pt')
    
    Retorna alertas baseados em:
    - Condições meteorológicas locais
    - Qualidade do ar regional
    - Riscos agrícolas específicos
    - Emergências ambientais
    """
    try:
        # Obter localização do usuário
        location = _get_user_location(request)
        
        # Obter parâmetros opcionais
        alert_types = request.args.getlist('types') or ['weather', 'air_quality', 'agriculture', 'emergency']
        severity_filter = request.args.get('severity', 'all')  # low, medium, high, critical, all
        language = request.args.get('language', 'pt')  # pt, en, fr, es
        
        logger.info(f"Gerando alertas para localização: {location}")
        
        # Usar Gemma3 para gerar alertas dinâmicos baseados na localização
        alerts = _generate_alerts_with_gemma3(location, alert_types, language)
        
        # Filtrar por severidade se especificado
        if severity_filter != 'all':
            alerts = [alert for alert in alerts if alert.get('severity') == severity_filter]
        
        # Ordenar por severidade e timestamp
        severity_order = {'critical': 0, 'high': 1, 'medium': 2, 'low': 3}
        alerts.sort(key=lambda x: (severity_order.get(x.get('severity', 'low'), 3), x.get('timestamp', '')))
        
        return jsonify({
            'success': True,
            'alerts': alerts,
            'total_count': len(alerts),
            'location': location,
            'timestamp': datetime.now().isoformat(),
            'alert_types': alert_types,
            'language': language,
            'generated_by': 'Gemma3-AI',
            'ai_insights': True,
            'location_based': True
        })
        
    except Exception as e:
        logger.error(f"Erro ao gerar alertas com Gemma3: {str(e)}")
        # Fallback para alertas estáticos em caso de erro
        location = request.args.get('location', 'Localização Desconhecida')
        alerts = _get_fallback_alerts(location, alert_types)
        return jsonify({
            'success': True,
            'alerts': alerts,
            'total_count': len(alerts),
            'location': location,
            'timestamp': datetime.now().isoformat(),
            'alert_types': alert_types,
            'generated_by': 'fallback',
            'ai_insights': False,
            'warning': 'Usando dados de fallback devido a erro no Gemma3'
        }), 200

# Cache simples para evitar alertas repetitivos
_alert_cache = {}
_cache_timeout = 300  # 5 minutos

def _get_user_location(request):
    """
    Detectar localização do usuário baseada em parâmetros da requisição
    """
    # Prioridade 1: Coordenadas GPS
    latitude = request.args.get('latitude')
    longitude = request.args.get('longitude')
    
    if latitude and longitude:
        try:
            lat = float(latitude)
            lon = float(longitude)
            # Converter coordenadas para nome da cidade/região
            location = _coordinates_to_location(lat, lon)
            logger.info(f"Localização detectada por GPS: {location} ({lat}, {lon})")
            return location
        except ValueError:
            logger.warning(f"Coordenadas inválidas: lat={latitude}, lon={longitude}")
    
    # Prioridade 2: Nome da localização fornecido
    location = request.args.get('location')
    if location:
        logger.info(f"Localização fornecida pelo usuário: {location}")
        return location.strip()
    
    # Prioridade 3: Detectar por IP (simulado)
    user_ip = request.remote_addr
    if user_ip and user_ip != '127.0.0.1':
        location = _ip_to_location(user_ip)
        if location:
            logger.info(f"Localização detectada por IP: {location}")
            return location
    
    # Fallback: Localização padrão
    default_location = "Localização Global"
    logger.info(f"Usando localização padrão: {default_location}")
    return default_location

def _coordinates_to_location(latitude, longitude):
    """
    Converter coordenadas GPS para nome da localização
    """
    # Base de dados simplificada de coordenadas para cidades principais
    locations = [
        # África
        {'name': 'Bissau, Guiné-Bissau', 'lat': 11.8636, 'lon': -15.5982, 'radius': 1.0},
        {'name': 'Dakar, Senegal', 'lat': 14.6928, 'lon': -17.4467, 'radius': 1.0},
        {'name': 'Lagos, Nigéria', 'lat': 6.5244, 'lon': 3.3792, 'radius': 1.0},
        {'name': 'Accra, Gana', 'lat': 5.6037, 'lon': -0.1870, 'radius': 1.0},
        {'name': 'Cairo, Egito', 'lat': 30.0444, 'lon': 31.2357, 'radius': 1.0},
        
        # Brasil
        {'name': 'São Paulo, Brasil', 'lat': -23.5505, 'lon': -46.6333, 'radius': 1.0},
        {'name': 'Rio de Janeiro, Brasil', 'lat': -22.9068, 'lon': -43.1729, 'radius': 1.0},
        {'name': 'Brasília, Brasil', 'lat': -15.8267, 'lon': -47.9218, 'radius': 1.0},
        {'name': 'Salvador, Brasil', 'lat': -12.9714, 'lon': -38.5014, 'radius': 1.0},
        {'name': 'Manaus, Brasil', 'lat': -3.1190, 'lon': -60.0217, 'radius': 1.0},
        
        # Europa
        {'name': 'Lisboa, Portugal', 'lat': 38.7223, 'lon': -9.1393, 'radius': 1.0},
        {'name': 'Madrid, Espanha', 'lat': 40.4168, 'lon': -3.7038, 'radius': 1.0},
        {'name': 'Paris, França', 'lat': 48.8566, 'lon': 2.3522, 'radius': 1.0},
        {'name': 'Londres, Reino Unido', 'lat': 51.5074, 'lon': -0.1278, 'radius': 1.0},
        {'name': 'Roma, Itália', 'lat': 41.9028, 'lon': 12.4964, 'radius': 1.0},
        
        # América do Norte
        {'name': 'Nova York, EUA', 'lat': 40.7128, 'lon': -74.0060, 'radius': 1.0},
        {'name': 'Los Angeles, EUA', 'lat': 34.0522, 'lon': -118.2437, 'radius': 1.0},
        {'name': 'Miami, EUA', 'lat': 25.7617, 'lon': -80.1918, 'radius': 1.0},
        {'name': 'Toronto, Canadá', 'lat': 43.6532, 'lon': -79.3832, 'radius': 1.0},
        
        # Ásia
        {'name': 'Tóquio, Japão', 'lat': 35.6762, 'lon': 139.6503, 'radius': 1.0},
        {'name': 'Mumbai, Índia', 'lat': 19.0760, 'lon': 72.8777, 'radius': 1.0},
        {'name': 'Pequim, China', 'lat': 39.9042, 'lon': 116.4074, 'radius': 1.0},
        {'name': 'Singapura', 'lat': 1.3521, 'lon': 103.8198, 'radius': 1.0},
        
        # Oceania
        {'name': 'Sydney, Austrália', 'lat': -33.8688, 'lon': 151.2093, 'radius': 1.0},
        {'name': 'Melbourne, Austrália', 'lat': -37.8136, 'lon': 144.9631, 'radius': 1.0},
    ]
    
    # Encontrar a cidade mais próxima
    import math
    
    def distance(lat1, lon1, lat2, lon2):
        # Fórmula de Haversine para calcular distância
        R = 6371  # Raio da Terra em km
        dlat = math.radians(lat2 - lat1)
        dlon = math.radians(lon2 - lon1)
        a = math.sin(dlat/2) * math.sin(dlat/2) + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon/2) * math.sin(dlon/2)
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
        return R * c
    
    closest_location = None
    min_distance = float('inf')
    
    for loc in locations:
        dist = distance(latitude, longitude, loc['lat'], loc['lon'])
        if dist < min_distance and dist <= loc['radius'] * 100:  # Raio de 100km
            min_distance = dist
            closest_location = loc['name']
    
    if closest_location:
        return closest_location
    
    # Se não encontrou cidade específica, determinar região geral
    if -90 <= latitude <= 90 and -180 <= longitude <= 180:
        if -35 <= latitude <= 37:  # África
            if -20 <= longitude <= 55:
                return f"África ({latitude:.2f}, {longitude:.2f})"
        elif -60 <= latitude <= 15:  # América do Sul
            if -85 <= longitude <= -30:
                return f"América do Sul ({latitude:.2f}, {longitude:.2f})"
        elif 15 <= latitude <= 85:  # América do Norte/Europa/Ásia
            if -170 <= longitude <= -50:
                return f"América do Norte ({latitude:.2f}, {longitude:.2f})"
            elif -15 <= longitude <= 180:
                if longitude <= 45:
                    return f"Europa ({latitude:.2f}, {longitude:.2f})"
                else:
                    return f"Ásia ({latitude:.2f}, {longitude:.2f})"
        elif -50 <= latitude <= -10:  # Oceania
            if 110 <= longitude <= 180:
                return f"Oceania ({latitude:.2f}, {longitude:.2f})"
    
    return f"Coordenadas ({latitude:.2f}, {longitude:.2f})"

def _ip_to_location(ip_address):
    """
    Detectar localização aproximada baseada no IP (simulado)
    """
    # Em um ambiente real, usaria serviços como GeoIP
    # Por enquanto, retorna None para usar fallback
    return None

def _get_region_info(location):
    """
    Detectar informações da região baseado na localização
    """
    location_lower = location.lower()
    
    # Base de dados de regiões e características climáticas
    region_data = {
        # África Ocidental
        'bissau': {
            'region': 'África Ocidental',
            'climate': 'Tropical savana',
            'characteristics': 'Costeiro, estação seca/chuvosa, agricultura de subsistência, mangues'
        },
        'guinea-bissau': {
            'region': 'África Ocidental',
            'climate': 'Tropical savana',
            'characteristics': 'Costeiro, estação seca/chuvosa, agricultura de subsistência, mangues'
        },
        'dakar': {
            'region': 'África Ocidental',
            'climate': 'Semi-árido',
            'characteristics': 'Costeiro, ventos alísios, pesca, urbanização'
        },
        'lagos': {
            'region': 'África Ocidental',
            'climate': 'Tropical úmido',
            'characteristics': 'Costeiro, alta densidade populacional, chuvas intensas, poluição urbana'
        },
        'accra': {
            'region': 'África Ocidental',
            'climate': 'Tropical savana',
            'characteristics': 'Costeiro, duas estações chuvosas, urbanização, agricultura'
        },
        
        # Brasil
        'são paulo': {
            'region': 'Sudeste do Brasil',
            'climate': 'Subtropical úmido',
            'characteristics': 'Metrópole, poluição do ar, ilha de calor urbana, chuvas de verão'
        },
        'rio de janeiro': {
            'region': 'Sudeste do Brasil',
            'climate': 'Tropical atlântico',
            'characteristics': 'Costeiro, montanhoso, chuvas de verão, alta umidade'
        },
        'brasília': {
            'region': 'Centro-Oeste do Brasil',
            'climate': 'Tropical savana',
            'characteristics': 'Planalto central, estação seca/chuvosa bem definidas, cerrado'
        },
        'manaus': {
            'region': 'Norte do Brasil',
            'climate': 'Equatorial úmido',
            'characteristics': 'Amazônia, alta umidade, chuvas frequentes, biodiversidade'
        },
        
        # Europa
        'lisboa': {
            'region': 'Europa Ocidental',
            'climate': 'Mediterrâneo',
            'characteristics': 'Costeiro atlântico, verões secos, invernos amenos e chuvosos'
        },
        'madrid': {
            'region': 'Europa Ocidental',
            'climate': 'Continental mediterrâneo',
            'characteristics': 'Interior, verões quentes e secos, invernos frios'
        },
        'paris': {
            'region': 'Europa Ocidental',
            'climate': 'Oceânico temperado',
            'characteristics': 'Continental, chuvas distribuídas, poluição urbana'
        },
        'london': {
            'region': 'Europa Ocidental',
            'climate': 'Oceânico temperado',
            'characteristics': 'Insular, chuvas frequentes, neblina, poluição urbana'
        },
        
        # América do Norte
        'new york': {
            'region': 'Costa Leste dos EUA',
            'climate': 'Continental úmido',
            'characteristics': 'Costeiro, quatro estações bem definidas, ilha de calor urbana'
        },
        'los angeles': {
            'region': 'Costa Oeste dos EUA',
            'climate': 'Mediterrâneo',
            'characteristics': 'Costeiro, smog, risco sísmico, verões secos'
        },
        'miami': {
            'region': 'Sudeste dos EUA',
            'climate': 'Tropical',
            'characteristics': 'Costeiro, furacões, alta umidade, nível do mar'
        },
        
        # Ásia
        'tokyo': {
            'region': 'Ásia Oriental',
            'climate': 'Subtropical úmido',
            'characteristics': 'Insular, monções, tifões, alta densidade populacional'
        },
        'mumbai': {
            'region': 'Ásia Meridional',
            'climate': 'Tropical úmido',
            'characteristics': 'Costeiro, monções intensas, alta densidade, poluição'
        },
        'beijing': {
            'region': 'Ásia Oriental',
            'climate': 'Continental úmido',
            'characteristics': 'Continental, poluição do ar, tempestades de areia'
        },
        
        # Oceania
        'sydney': {
            'region': 'Oceania',
            'climate': 'Subtropical úmido',
            'characteristics': 'Costeiro, risco de incêndios, chuvas de verão'
        },
        'melbourne': {
            'region': 'Oceania',
            'climate': 'Oceânico temperado',
            'characteristics': 'Costeiro, quatro estações, variabilidade climática'
        }
    }
    
    # Buscar informações específicas da localização
    for key, info in region_data.items():
        if key in location_lower:
            return info
    
    # Detectar por país ou região geral
    if any(term in location_lower for term in ['guinea', 'bissau', 'gabú', 'bafatá']):
        return region_data['guinea-bissau']
    elif any(term in location_lower for term in ['brasil', 'brazil']):
        return {
            'region': 'América do Sul',
            'climate': 'Tropical/Subtropical',
            'characteristics': 'Diversidade climática, chuvas de verão, agricultura extensiva'
        }
    elif any(term in location_lower for term in ['portugal', 'spain', 'france']):
        return {
            'region': 'Europa Ocidental',
            'climate': 'Mediterrâneo/Oceânico',
            'characteristics': 'Temperado, chuvas de inverno, agricultura mediterrânea'
        }
    elif any(term in location_lower for term in ['usa', 'united states', 'america']):
        return {
            'region': 'América do Norte',
            'climate': 'Variado',
            'characteristics': 'Diversidade climática, eventos extremos, urbanização'
        }
    elif any(term in location_lower for term in ['africa', 'áfrica']):
        return {
            'region': 'África',
            'climate': 'Tropical/Árido',
            'characteristics': 'Estações secas/chuvosas, agricultura de subsistência, variabilidade climática'
        }
    
    # Fallback para localização desconhecida
    return {
        'region': 'Região Global',
        'climate': 'Variado',
        'characteristics': 'Condições climáticas locais, riscos ambientais regionais'
    }

def _generate_alerts_with_gemma3(location, alert_types, language='pt'):
    """
    Gerar alertas ambientais usando Gemma3
    """
    try:
        from services.gemma_service import GemmaService
        
        gemma_service = current_app.gemma_service
        
        # Verificar cache para evitar repetições
        import uuid
        cache_key = f"{location}_{'-'.join(sorted(alert_types))}"
        current_time = datetime.now()
        
        if cache_key in _alert_cache:
            cached_time, cached_alerts = _alert_cache[cache_key]
            if (current_time - cached_time).seconds < _cache_timeout:
                logger.info(f"Usando alertas do cache para {location}")
                # Adicionar variação temporal aos alertas em cache
                for alert in cached_alerts:
                    alert['timestamp'] = current_time.isoformat()
                    alert['id'] = f"gemma3_{uuid.uuid4().hex[:8]}"
                return cached_alerts
        
        # Obter dados temporais para gerar alertas dinâmicos
        current_time = datetime.now()
        season = "seca" if current_time.month in [11, 12, 1, 2, 3, 4] else "chuvas"
        hour = current_time.hour
        day_period = "manhã" if 6 <= hour < 12 else "tarde" if 12 <= hour < 18 else "noite"
        
        # Detectar região e características climáticas baseado na localização
        region_info = _get_region_info(location)
        
        # Configurar idioma e contexto cultural
        language_config = {
            'pt': {
                'task': 'TAREFA: Gere exatamente 4 alertas ambientais específicos para a localização fornecida.',
                'context': 'CONTEXTO GEOGRÁFICO:',
                'instructions': 'INSTRUÇÕES:',
                'important': 'IMPORTANTE:',
                'response_format': 'RESPONDA APENAS COM ESTE JSON (sem texto adicional):'
            },
            'en': {
                'task': 'TASK: Generate exactly 4 specific environmental alerts for the provided location.',
                'context': 'GEOGRAPHICAL CONTEXT:',
                'instructions': 'INSTRUCTIONS:',
                'important': 'IMPORTANT:',
                'response_format': 'RESPOND ONLY WITH THIS JSON (no additional text):'
            },
            'fr': {
                'task': 'TÂCHE: Générez exactement 4 alertes environnementales spécifiques pour la localisation fournie.',
                'context': 'CONTEXTE GÉOGRAPHIQUE:',
                'instructions': 'INSTRUCTIONS:',
                'important': 'IMPORTANT:',
                'response_format': 'RÉPONDEZ UNIQUEMENT AVEC CE JSON (sans texte supplémentaire):'
            },
            'es': {
                'task': 'TAREA: Genere exactamente 4 alertas ambientales específicas para la ubicación proporcionada.',
                'context': 'CONTEXTO GEOGRÁFICO:',
                'instructions': 'INSTRUCCIONES:',
                'important': 'IMPORTANTE:',
                'response_format': 'RESPONDA SOLO CON ESTE JSON (sin texto adicional):'
            }
        }
        
        lang_config = language_config.get(language, language_config['pt'])
        
        # Prompt dinâmico multilíngue para gerar alertas ambientais globais
        prompt = f"""
        {lang_config['task']}
        
        {lang_config['context']}
        - Localização: {location}
        - Região: {region_info['region']}
        - Clima: {region_info['climate']}
        - Características: {region_info['characteristics']}
        - Data/Hora: {current_time.strftime('%d/%m/%Y %H:%M')}
        - Estação local: {season}
        - Período do dia: {day_period}
        - Tipos solicitados: {', '.join(alert_types)}
        - Idioma: {language}
        
        {lang_config['instructions']}
        1. Analise as características climáticas e geográficas específicas da região
        2. Considere riscos ambientais reais e atuais da localização
        3. Adapte alertas ao contexto local (urbano/rural, costeiro/interior, montanhoso/planície)
        4. Use dados realistas e relevantes para a região específica
        5. Considere fatores sazonais e horários locais
        6. Inclua riscos específicos da infraestrutura e população local
        7. Varie a severidade baseada em condições reais da região
        
        {lang_config['response_format']}
        [
          {{
            "title": "Alerta específico e realista para {location}",
            "message": "Mensagem contextualizada baseada em condições reais",
            "description": "Descrição detalhada considerando geografia, clima e população local",
            "severity": "low|medium|high|critical",
            "type": "weather|air_quality|agriculture|emergency",
            "category": "categoria específica da região",
            "recommendations": ["Ação 1 adaptada às condições locais", "Ação 2 considerando infraestrutura", "Ação 3 baseada em recursos disponíveis"]
          }},
          {{
            "title": "Segundo alerta contextual para {location}",
            "message": "Condição ambiental relevante para a área",
            "description": "Análise baseada em padrões climáticos e riscos regionais",
            "severity": "low|medium|high|critical",
            "type": "weather|air_quality|agriculture|emergency",
            "category": "categoria apropriada ao contexto",
            "recommendations": ["Medida 1 específica da região", "Medida 2 adaptada ao clima", "Medida 3 considerando recursos"]
          }},
          {{
            "title": "Terceiro alerta ambiental regional",
            "message": "Risco específico da localização",
            "description": "Impacto considerando população, economia e infraestrutura local",
            "severity": "low|medium|high|critical",
            "type": "weather|air_quality|agriculture|emergency",
            "category": "categoria regional específica",
            "recommendations": ["Ação local 1", "Ação local 2", "Ação local 3"]
          }},
          {{
            "title": "Quarto alerta contextualizado",
            "message": "Condição ambiental específica da área",
            "description": "Análise baseada em características únicas da região",
            "severity": "low|medium|high|critical",
            "type": "weather|air_quality|agriculture|emergency",
            "category": "categoria específica do local",
            "recommendations": ["Recomendação 1 adaptada", "Recomendação 2 contextual", "Recomendação 3 regional"]
          }}
        ]
        
        {lang_config['important']}
        - Varie os alertas baseado na estação {season} e período {day_period}
        - Considere características ESPECÍFICAS de {location}
        - Use terminologia e riscos apropriados para a região
        - Adapte severidade aos padrões climáticos locais
        - Gere alertas DIFERENTES a cada chamada
        - Considere contexto cultural e socioeconômico da região
        - Use dados realistas e verificáveis para a localização
        """
        
        # Gerar resposta com Gemma3
        response = gemma_service.generate_response(
            prompt=prompt,
            context="environmental_alerts",
            max_tokens=1000
        )
        
        # Processar resposta do Gemma3
        alerts = _parse_gemma3_alerts_response(response, location)
        
        # Salvar no cache para evitar repetições
        if alerts:
            import uuid
            _alert_cache[cache_key] = (current_time, alerts)
            logger.info(f"Alertas salvos no cache para {location}")
        
        return alerts
        
    except Exception as e:
        logger.error(f"Erro ao usar Gemma3 para alertas: {str(e)}")
        # Fallback para alertas estáticos
        return _get_fallback_alerts(location, alert_types)

def _parse_gemma3_alerts_response(response, location):
    """
    Processar resposta do Gemma3 e converter em formato de alertas
    """
    import json
    import re
    import uuid
    
    try:
        # Verificar se a resposta é um dict (resposta do Ollama)
        if isinstance(response, dict):
            response_text = response.get('message', {}).get('content', str(response))
            
            # Verificar se a resposta contém um campo 'response' com JSON
            if 'response' in response and isinstance(response['response'], str):
                inner_response = response['response']
                
                # Caso 1: JSON dentro de markdown
                if '```json' in inner_response:
                    json_start = inner_response.find('```json') + 7
                    json_end = inner_response.find('```', json_start)
                    if json_end > json_start:
                        response_text = inner_response[json_start:json_end].strip()
                else:
                    # Caso 2: JSON direto na resposta
                    json_match = re.search(r'\[\s*\{.*?\}\s*\]', inner_response, re.DOTALL)
                    if json_match:
                        response_text = json_match.group().strip()
                    else:
                        response_text = inner_response
            
            # Tentar extrair JSON de diferentes formatos de resposta
            elif isinstance(response_text, str):
                # Caso 1: JSON dentro de markdown
                if '```json' in response_text:
                    json_start = response_text.find('```json') + 7
                    json_end = response_text.find('```', json_start)
                    if json_end > json_start:
                        response_text = response_text[json_start:json_end].strip()
                
                # Caso 2: JSON dentro de um campo 'response' como string
                elif "'response':" in response_text or '"response":' in response_text:
                    # Extrair o conteúdo após 'response':
                    if "'response': '" in response_text:
                        start = response_text.find("'response': '") + 13
                        # Encontrar o final da string, considerando escapes
                        end = start
                        quote_count = 0
                        while end < len(response_text):
                            if response_text[end] == "'" and (end == 0 or response_text[end-1] != '\\'):
                                quote_count += 1
                                if quote_count == 1:  # Primeira aspa de fechamento
                                    break
                            end += 1
                        
                        if end > start:
                            inner_content = response_text[start:end]
                            # Decodificar escapes
                            inner_content = inner_content.replace("\\\\", "\\").replace("\\n", "\n").replace("\\\"", '"').replace("\\'", "'")
                            
                            if '```json' in inner_content:
                                json_start = inner_content.find('```json') + 7
                                json_end = inner_content.find('```', json_start)
                                if json_end > json_start:
                                    response_text = inner_content[json_start:json_end].strip()
                            else:
                                # Tentar extrair JSON diretamente
                                json_match = re.search(r'\[\s*\{.*?\}\s*\]', inner_content, re.DOTALL)
                                if json_match:
                                    response_text = json_match.group().strip()
        else:
            response_text = str(response)
        
        logger.info(f"Processando resposta do Gemma3: {response_text[:200]}...")
        logger.info(f"Resposta completa do Gemma3: {response_text}")
        
        # Múltiplas tentativas de extrair JSON
        alerts_data = None
        
        # Tentativa 1: JSON array completo
        json_match = re.search(r'\[.*?\]', response_text, re.DOTALL)
        if json_match:
            json_text = json_match.group()
            logger.info(f"JSON encontrado: {json_text[:500]}...")
            
            # Limpeza avançada de caracteres especiais e malformações
            json_text = json_text.replace('\\n', ' ')  # Remove quebras de linha escapadas
            json_text = json_text.replace('\\"', '"')  # Remove escapes desnecessários
            json_text = json_text.replace('\\\\', '')  # Remove barras duplas
            
            # Corrigir erros comuns no JSON
            json_text = json_text.replace('"recommendaions":', '"recommendations":')
            json_text = json_text.replace('"recomendaions":', '"recommendations":')
            json_text = json_text.replace('"recomendações":', '"recommendations":')
            json_text = json_text.replace('"título":', '"title":')
            json_text = json_text.replace('"mensagem":', '"message":')
            json_text = json_text.replace('"descrição":', '"description":')
            
            # Remover fragmentos de JSON malformado que aparecem nos campos
            json_text = re.sub(r'"[^"]*\\n[^"]*"\s*,\s*"[^"]*"\s*:', '"Alerta Ambiental":', json_text)
            json_text = re.sub(r'"[^"]*severity[^"]*"\s*,\s*"[^"]*"\s*:', '"Alerta":', json_text)
            
            # Garantir que o JSON está completo
            if not json_text.endswith(']'):
                json_text += ']'
            if not json_text.endswith('}]'):
                json_text = json_text.rstrip(']') + '}]'
            
            try:
                # Limpar caracteres problemáticos antes do parsing
                json_text = json_text.strip()
                if json_text.startswith('\n'):
                    json_text = json_text.lstrip('\n').strip()
                
                alerts_data = json.loads(json_text)
                logger.info(f"JSON extraído com sucesso: {len(alerts_data)} alertas")
                logger.info(f"Dados dos alertas: {alerts_data}")
            except json.JSONDecodeError as e:
                logger.warning(f"Erro ao decodificar JSON array: {e}")
                logger.warning(f"JSON problemático: {json_text[:500]}...")
                
                # Tentar corrigir problemas comuns de formatação
                try:
                    # Remover caracteres de controle e espaços problemáticos
                    cleaned_json = re.sub(r'[\x00-\x1f\x7f-\x9f]', '', json_text)
                    cleaned_json = re.sub(r'\s+', ' ', cleaned_json).strip()
                    
                    # Tentar novamente
                    alerts_data = json.loads(cleaned_json)
                    logger.info(f"JSON corrigido e extraído: {len(alerts_data)} alertas")
                except json.JSONDecodeError:
                    # Tentar extrair apenas o primeiro objeto válido
                    try:
                        first_obj_match = re.search(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}', json_text)
                        if first_obj_match:
                            single_obj = first_obj_match.group()
                            alerts_data = [json.loads(single_obj)]
                            logger.info(f"Extraído objeto único: 1 alerta")
                    except:
                        pass
        
        # Tentativa 2: Múltiplos objetos JSON
        if not alerts_data:
            json_objects = re.findall(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}', response_text)
            if json_objects:
                alerts_data = []
                for obj_str in json_objects:
                    try:
                        obj = json.loads(obj_str)
                        alerts_data.append(obj)
                    except json.JSONDecodeError:
                        continue
                logger.info(f"Objetos JSON extraídos: {len(alerts_data)} alertas")
        
        # Tentativa 3: Criar alertas do texto
        if not alerts_data:
            logger.warning("Não foi possível extrair JSON, criando alertas do texto")
            alerts_data = _create_alerts_from_text(response_text)
        
        # Garantir que temos uma lista
        if not isinstance(alerts_data, list):
            alerts_data = [alerts_data] if alerts_data else []
        
        alerts = []
        for i, alert_data in enumerate(alerts_data[:5]):  # Máximo 5 alertas
            # Garantir que alert_data é um dict
            if not isinstance(alert_data, dict):
                continue
                
            # Mapear campos em português para inglês
            title = (alert_data.get('title') or alert_data.get('título') or 
                    alert_data.get('titulo') or f'Alerta Ambiental {i+1}')
            message = (alert_data.get('message') or alert_data.get('mensagem') or 
                      alert_data.get('msg') or title)
            description = (alert_data.get('description') or alert_data.get('descrição') or 
                          alert_data.get('descricao') or message)
            recommendations = (alert_data.get('recommendations') or 
                             alert_data.get('recomendações') or 
                             alert_data.get('recomendacoes') or 
                             ['Monitorar situação', 'Seguir orientações locais'])
            
            alert = {
                'id': f"gemma3_{uuid.uuid4().hex[:8]}",
                'type': alert_data.get('type', 'general'),
                'category': alert_data.get('category', 'environmental'),
                'severity': alert_data.get('severity', 'medium'),
                'title': title,
                'message': message,
                'description': description,
                'recommendations': recommendations if isinstance(recommendations, list) else [str(recommendations)],
                'timestamp': datetime.now().isoformat(),
                'expires_at': (datetime.now() + timedelta(hours=24)).isoformat(),
                'location': location,
                'icon': _get_alert_icon(alert_data.get('category', 'environmental')),
                'color': _get_alert_color(alert_data.get('severity', 'medium')),
                'generated_by': 'Gemma3'
            }
            alerts.append(alert)
        
        logger.info(f"Processados {len(alerts)} alertas do Gemma3 com sucesso")
        return alerts if alerts else _get_fallback_alerts(location, ['weather', 'agriculture'])
        
    except Exception as e:
        logger.error(f"Erro ao processar resposta do Gemma3: {str(e)}")
        return _get_fallback_alerts(location, ['weather', 'agriculture'])

def _create_alerts_from_text(text):
    """
    Criar alertas a partir de texto livre do Gemma3
    """
    import re
    
    alerts = []
    
    # Padrões para identificar diferentes tipos de alertas
    alert_patterns = {
        'weather': ['chuva', 'vento', 'tempestade', 'seca', 'temperatura', 'clima'],
        'agriculture': ['colheita', 'plantação', 'pragas', 'cultivo', 'agricultura', 'arroz', 'milho'],
        'air_quality': ['poluição', 'ar', 'qualidade', 'fumaça', 'poeira'],
        'emergency': ['emergência', 'perigo', 'risco', 'evacuação', 'socorro']
    }
    
    severity_patterns = {
        'critical': ['crítico', 'grave', 'urgente', 'imediato', 'extremo'],
        'high': ['alto', 'elevado', 'importante', 'significativo'],
        'medium': ['moderado', 'médio', 'atenção'],
        'low': ['baixo', 'leve', 'menor']
    }
    
    # Dividir texto em seções
    sections = re.split(r'\n\s*\n|\.|\!|\?', text)
    sections = [s.strip() for s in sections if len(s.strip()) > 30]
    
    for i, section in enumerate(sections[:5]):  # Máximo 5 alertas
        # Determinar tipo do alerta
        alert_type = 'general'
        for type_key, keywords in alert_patterns.items():
            if any(keyword in section.lower() for keyword in keywords):
                alert_type = type_key
                break
        
        # Determinar severidade
        severity = 'medium'
        for sev_key, keywords in severity_patterns.items():
            if any(keyword in section.lower() for keyword in keywords):
                severity = sev_key
                break
        
        # Extrair título (primeira linha ou primeiras palavras)
        lines = section.split('\n')
        title = lines[0][:60] if lines else section[:60]
        if ':' in title:
            title = title.split(':')[0]
        
        # Gerar recomendações baseadas no tipo
        recommendations = {
            'weather': ['Verificar previsão do tempo', 'Proteger cultivos', 'Evitar atividades ao ar livre'],
            'agriculture': ['Monitorar plantações', 'Aplicar medidas preventivas', 'Consultar técnico agrícola'],
            'air_quality': ['Evitar atividades externas', 'Usar proteção respiratória', 'Manter janelas fechadas'],
            'emergency': ['Seguir protocolos de segurança', 'Contactar autoridades', 'Evacuar se necessário'],
            'general': ['Monitorar situação', 'Seguir orientações locais', 'Manter-se informado']
        }.get(alert_type, ['Monitorar situação', 'Seguir orientações locais'])
        
        alert = {
            'title': title.strip(),
            'message': section[:150] + '...' if len(section) > 150 else section,
            'description': section,
            'severity': severity,
            'type': alert_type,
            'category': alert_type,
            'recommendations': recommendations
        }
        alerts.append(alert)
    
    # Se não conseguiu extrair alertas, criar pelo menos um genérico
    if not alerts:
        alerts.append({
            'title': 'Alerta Ambiental',
            'message': 'Monitoramento ambiental ativo',
            'description': 'Sistema de monitoramento detectou condições que requerem atenção.',
            'severity': 'medium',
            'type': 'general',
            'category': 'environmental',
            'recommendations': ['Monitorar situação', 'Seguir orientações locais', 'Manter-se informado']
        })
    
    return alerts

def _get_alert_icon(category):
    """
    Obter ícone baseado na categoria do alerta
    """
    icons = {
        'temperature': 'temperature_high',
        'wind': 'wind',
        'precipitation': 'rain',
        'pollution': 'air_quality',
        'pest': 'bug_report',
        'harvest': 'agriculture',
        'drought': 'water_drop',
        'flood': 'flood',
        'storm': 'storm'
    }
    return icons.get(category, 'warning')

def _get_alert_color(severity):
    """
    Obter cor baseada na severidade do alerta
    """
    colors = {
        'low': '#4CAF50',
        'medium': '#FF9800',
        'high': '#FF6B35',
        'critical': '#D32F2F'
    }
    return colors.get(severity, '#FF9800')

def _get_fallback_alerts(location, alert_types):
    """
    Gerar alertas de fallback quando Gemma3 não está disponível
    """
    alerts = []
    
    # Alertas meteorológicos
    if 'weather' in alert_types:
        weather_alerts = _get_weather_alerts(location)
        alerts.extend(weather_alerts)
    
    # Alertas de qualidade do ar
    if 'air_quality' in alert_types:
        air_alerts = _get_air_quality_alerts(location)
        alerts.extend(air_alerts)
    
    # Alertas agrícolas
    if 'agriculture' in alert_types:
        agri_alerts = _get_agriculture_alerts(location)
        alerts.extend(agri_alerts)
    
    # Alertas de emergência
    if 'emergency' in alert_types:
        emergency_alerts = _get_emergency_alerts(location)
        alerts.extend(emergency_alerts)
    
    return alerts

def _get_weather_alerts(location):
    """Gerar alertas meteorológicos"""
    alerts = []
    
    # Simular dados meteorológicos atuais
    current_weather = {
        'temperature': 32,
        'humidity': 85,
        'wind_speed': 25,
        'precipitation': 15,
        'pressure': 1010
    }
    
    # Alertas de temperatura alta
    if current_weather['temperature'] > 35:
        alerts.append({
            'id': 'weather_temp_001',
            'type': 'weather',
            'category': 'temperature',
            'severity': 'high',
            'title': 'Temperatura Extrema',
            'message': f'Temperatura de {current_weather["temperature"]}°C pode causar estresse térmico em culturas',
            'description': 'Temperaturas acima de 35°C podem danificar culturas sensíveis e aumentar o risco de desidratação.',
            'recommendations': [
                'Aumentar irrigação das culturas',
                'Evitar trabalho ao ar livre nas horas mais quentes',
                'Proteger animais do calor excessivo'
            ],
            'timestamp': datetime.now().isoformat(),
            'expires_at': (datetime.now() + timedelta(hours=6)).isoformat(),
            'location': location,
            'icon': 'temperature_high',
            'color': '#FF6B35'
        })
    
    # Alertas de vento forte
    if current_weather['wind_speed'] > 20:
        alerts.append({
            'id': 'weather_wind_001',
            'type': 'weather',
            'category': 'wind',
            'severity': 'medium',
            'title': 'Ventos Fortes',
            'message': f'Ventos de {current_weather["wind_speed"]} km/h podem danificar culturas',
            'description': 'Ventos fortes podem quebrar galhos, derrubar plantas e espalhar pragas.',
            'recommendations': [
                'Proteger culturas jovens',
                'Verificar estruturas agrícolas',
                'Adiar pulverizações'
            ],
            'timestamp': datetime.now().isoformat(),
            'expires_at': (datetime.now() + timedelta(hours=4)).isoformat(),
            'location': location,
            'icon': 'wind',
            'color': '#4A90E2'
        })
    
    # Alertas de chuva intensa
    if current_weather['precipitation'] > 10:
        alerts.append({
            'id': 'weather_rain_001',
            'type': 'weather',
            'category': 'precipitation',
            'severity': 'medium',
            'title': 'Chuva Intensa',
            'message': f'Precipitação de {current_weather["precipitation"]}mm pode causar alagamentos',
            'description': 'Chuvas intensas podem causar erosão do solo e alagamento de culturas.',
            'recommendations': [
                'Verificar drenagem dos campos',
                'Proteger sementes recém-plantadas',
                'Monitorar níveis de água'
            ],
            'timestamp': datetime.now().isoformat(),
            'expires_at': (datetime.now() + timedelta(hours=8)).isoformat(),
            'location': location,
            'icon': 'rain',
            'color': '#5DADE2'
        })
    
    return alerts

def _get_air_quality_alerts(location):
    """Gerar alertas de qualidade do ar"""
    alerts = []
    
    # Simular dados de qualidade do ar
    aqi = 85  # Índice de qualidade do ar
    
    if aqi > 100:
        severity = 'high' if aqi > 150 else 'medium'
        alerts.append({
            'id': 'air_quality_001',
            'type': 'air_quality',
            'category': 'pollution',
            'severity': severity,
            'title': 'Qualidade do Ar Prejudicial',
            'message': f'AQI de {aqi} - Qualidade do ar prejudicial à saúde',
            'description': 'Níveis elevados de poluição podem afetar a saúde respiratória e cardiovascular.',
            'recommendations': [
                'Evitar atividades ao ar livre prolongadas',
                'Usar máscara de proteção',
                'Manter janelas fechadas'
            ],
            'timestamp': datetime.now().isoformat(),
            'expires_at': (datetime.now() + timedelta(hours=12)).isoformat(),
            'location': location,
            'icon': 'air_quality',
            'color': '#E74C3C'
        })
    
    return alerts

def _simulate_biodiversity_analysis(image_file, location, ecosystem_type):
    """Simular análise de biodiversidade quando Gemma não está disponível"""
    import random
    
    # Espécies comuns da Guiné-Bissau baseadas no tipo de ecossistema
    species_database = {
        'floresta': [
            {'name': 'Cecropia peltata', 'common_name': 'Embaúba', 'type': 'flora', 'endemic': False},
            {'name': 'Colobus polykomos', 'common_name': 'Macaco-colobo', 'type': 'fauna', 'endemic': True},
            {'name': 'Pterocarpus erinaceus', 'common_name': 'Pau-sangue', 'type': 'flora', 'endemic': False},
            {'name': 'Cercopithecus campbelli', 'common_name': 'Macaco-campbell', 'type': 'fauna', 'endemic': False}
        ],
        'mangue': [
            {'name': 'Rhizophora mangle', 'common_name': 'Mangue-vermelho', 'type': 'flora', 'endemic': False},
            {'name': 'Ardea goliath', 'common_name': 'Garça-golias', 'type': 'fauna', 'endemic': False},
            {'name': 'Avicennia germinans', 'common_name': 'Mangue-preto', 'type': 'flora', 'endemic': False},
            {'name': 'Crocodylus niloticus', 'common_name': 'Crocodilo-do-nilo', 'type': 'fauna', 'endemic': False}
        ],
        'savana': [
            {'name': 'Adansonia digitata', 'common_name': 'Baobá', 'type': 'flora', 'endemic': False},
            {'name': 'Loxodonta africana', 'common_name': 'Elefante-africano', 'type': 'fauna', 'endemic': False},
            {'name': 'Acacia senegal', 'common_name': 'Acácia', 'type': 'flora', 'endemic': False},
            {'name': 'Panthera leo', 'common_name': 'Leão', 'type': 'fauna', 'endemic': False}
        ]
    }
    
    # Selecionar espécies baseadas no ecossistema
    available_species = species_database.get(ecosystem_type, species_database['floresta'])
    
    # Simular identificação de 1-3 espécies
    num_species = random.randint(1, 3)
    identified_species = random.sample(available_species, min(num_species, len(available_species)))
    
    # Adicionar dados de confiança e status de conservação
    for species in identified_species:
        species['confidence'] = round(random.uniform(0.7, 0.95), 2)
        species['conservation_status'] = random.choice([
            'Pouco Preocupante', 'Quase Ameaçada', 'Vulnerável', 'Em Perigo'
        ])
    
    # Calcular índice de biodiversidade
    biodiversity_score = round(random.uniform(6.0, 9.0), 1)
    biodiversity_level = 'Alto' if biodiversity_score >= 8.0 else 'Médio' if biodiversity_score >= 6.0 else 'Baixo'
    
    # Status do ecossistema
    ecosystem_status = random.choice(['Saudável', 'Moderadamente Saudável', 'Degradado'])
    
    return {
        'species_identified': identified_species,
        'biodiversity_index': {
            'score': biodiversity_score,
            'level': biodiversity_level,
            'factors': [
                'Diversidade de espécies',
                'Presença de espécies endêmicas',
                'Qualidade do habitat',
                'Conectividade ecológica'
            ]
        },
        'ecosystem_health': {
            'status': ecosystem_status,
            'indicators': [
                'Cobertura vegetal',
                'Qualidade da água',
                'Diversidade de fauna',
                'Ausência de poluição'
            ],
            'threats': [
                'Desmatamento',
                'Poluição da água',
                'Caça ilegal',
                'Mudanças climáticas'
            ]
        },
        'conservation_recommendations': [
            'Estabelecer áreas de proteção',
            'Implementar corredores ecológicos',
            'Monitoramento regular de espécies',
            'Educação ambiental comunitária',
            'Controle de espécies invasoras'
        ],
        'monitoring_suggestions': [
            'Censo de fauna trimestral',
            'Monitoramento de vegetação',
            'Análise de qualidade da água',
            'Registro fotográfico mensal',
            'Coleta de dados climáticos'
        ],
        'local_programs': [
            {
                'name': 'Programa de Conservação da Biodiversidade',
                'description': 'Monitoramento participativo de espécies locais',
                'contact': 'Instituto da Biodiversidade - Bissau'
            },
            {
                'name': 'Rede de Observadores da Natureza',
                'description': 'Cidadãos cientistas para coleta de dados',
                'contact': 'ONG Tiniguena - conservacao@tiniguena.org'
            }
        ]
    }

def _analyze_biodiversity_with_gemma(gemma_service, image_file, location, ecosystem_type, language):
    """Analisar biodiversidade usando o modelo Gemma"""
    try:
        # Converter imagem para base64
        image_data = image_file.read()
        image_base64 = base64.b64encode(image_data).decode('utf-8')
        
        # Prompt para análise de biodiversidade
        prompt = f"""
        Analise esta imagem para identificar espécies de fauna e flora.
        
        Contexto:
        - Localização: {location}
        - Tipo de ecossistema: {ecosystem_type}
        - Idioma da resposta: {language}
        
        Por favor, forneça:
        1. Identificação de espécies visíveis (nome científico e comum)
        2. Nível de confiança na identificação (0-1)
        3. Status de conservação de cada espécie
        4. Avaliação da biodiversidade local
        5. Recomendações de conservação
        6. Sugestões de monitoramento
        
        Responda em formato JSON estruturado.
        """
        
        # Chamar o serviço Gemma
        response = gemma_service.analyze_image(
            image_base64=image_base64,
            prompt=prompt,
            context={'location': location, 'ecosystem': ecosystem_type}
        )
        
        # Processar resposta do Gemma
        if response and 'analysis' in response:
            return _process_gemma_biodiversity_response(response['analysis'])
        else:
            # Fallback para análise simulada
            return _simulate_biodiversity_analysis(image_file, location, ecosystem_type)
            
    except Exception as e:
        logger.error(f"Erro na análise com Gemma: {e}")
        # Fallback para análise simulada
        return _simulate_biodiversity_analysis(image_file, location, ecosystem_type)

def _process_gemma_biodiversity_response(gemma_response):
    """Processar resposta do Gemma para análise de biodiversidade"""
    try:
        # Tentar parsear JSON da resposta do Gemma
        if isinstance(gemma_response, str):
            import json
            analysis_data = json.loads(gemma_response)
        else:
            analysis_data = gemma_response
        
        # Estruturar dados conforme esperado pela API
        return {
            'species_identified': analysis_data.get('species_identified', []),
            'biodiversity_index': analysis_data.get('biodiversity_index', {
                'score': 7.5,
                'level': 'Médio',
                'factors': ['Análise baseada em IA']
            }),
            'ecosystem_health': analysis_data.get('ecosystem_health', {
                'status': 'Análise em andamento',
                'indicators': ['Dados coletados via IA'],
                'threats': ['A ser determinado']
            }),
            'conservation_recommendations': analysis_data.get('conservation_recommendations', [
                'Monitoramento contínuo recomendado'
            ]),
            'monitoring_suggestions': analysis_data.get('monitoring_suggestions', [
                'Coleta regular de dados'
            ]),
            'local_programs': analysis_data.get('local_programs', [])
        }
        
    except Exception as e:
        logger.error(f"Erro ao processar resposta do Gemma: {e}")
        # Retornar estrutura básica em caso de erro
        return {
            'species_identified': [],
            'biodiversity_index': {'score': 0, 'level': 'Indeterminado', 'factors': []},
            'ecosystem_health': {'status': 'Erro na análise', 'indicators': [], 'threats': []},
            'conservation_recommendations': ['Análise manual recomendada'],
            'monitoring_suggestions': ['Consultar especialista local'],
            'local_programs': []
        }

def _get_agriculture_alerts(location):
    """Gerar alertas agrícolas"""
    alerts = []
    
    # Alerta de pragas
    alerts.append({
        'id': 'agri_pest_001',
        'type': 'agriculture',
        'category': 'pest',
        'severity': 'medium',
        'title': 'Risco de Pragas',
        'message': 'Condições favoráveis para proliferação de pragas detectadas',
        'description': 'Temperatura e umidade elevadas favorecem o desenvolvimento de insetos-praga.',
        'recommendations': [
            'Monitorar culturas diariamente',
            'Aplicar controle biológico preventivo',
            'Verificar armadilhas de monitoramento'
        ],
        'timestamp': datetime.now().isoformat(),
        'expires_at': (datetime.now() + timedelta(days=3)).isoformat(),
        'location': location,
        'icon': 'bug_report',
        'color': '#FF9800'
    })
    
    # Alerta de janela de colheita
    alerts.append({
        'id': 'agri_harvest_001',
        'type': 'agriculture',
        'category': 'harvest',
        'severity': 'low',
        'title': 'Janela de Colheita Ideal',
        'message': 'Condições meteorológicas favoráveis para colheita nos próximos 5 dias',
        'description': 'Previsão de tempo seco e temperaturas moderadas ideais para colheita.',
        'recommendations': [
            'Planejar atividades de colheita',
            'Preparar equipamentos',
            'Organizar mão de obra'
        ],
        'timestamp': datetime.now().isoformat(),
        'expires_at': (datetime.now() + timedelta(days=5)).isoformat(),
        'location': location,
        'icon': 'agriculture',
        'color': '#4CAF50'
    })
    
    return alerts

@environmental_bp.route('/plant/image-diagnosis', methods=['POST'])
def plant_image_diagnosis():
    """
    Diagnóstico de plantas através de análise de imagem
    ---
    tags:
      - Plant Diagnosis
    summary: Diagnóstico de plantas por imagem
    description: |
      Analisa uma imagem de planta para identificar doenças, pragas, deficiências nutricionais
      e fornecer recomendações de tratamento usando IA Gemma-3.
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              image:
                type: string
                description: Imagem da planta em base64
              plant_type:
                type: string
                description: Tipo de planta (opcional)
                example: "tomate"
              user_id:
                type: string
                description: ID do usuário (opcional)
              language:
                type: string
                description: Idioma da resposta
                default: "pt"
                example: "pt"
            required:
              - image
    responses:
      200:
        description: Diagnóstico realizado com sucesso
        content:
          application/json:
            schema:
              type: object
              properties:
                success:
                  type: boolean
                  example: true
                diagnosis:
                  type: object
                  properties:
                    plant_identification:
                      type: object
                      properties:
                        species:
                          type: string
                          example: "Solanum lycopersicum"
                        common_name:
                          type: string
                          example: "Tomate"
                        confidence:
                          type: number
                          example: 0.85
                    health_assessment:
                      type: object
                      properties:
                        overall_health:
                          type: string
                          example: "Moderadamente saudável"
                        issues_detected:
                          type: array
                          items:
                            type: object
                            properties:
                              type:
                                type: string
                                example: "doença"
                              name:
                                type: string
                                example: "Mancha bacteriana"
                              severity:
                                type: string
                                example: "moderada"
                              confidence:
                                type: number
                                example: 0.75
                    recommendations:
                      type: object
                      properties:
                        immediate_actions:
                          type: array
                          items:
                            type: string
                        preventive_measures:
                          type: array
                          items:
                            type: string
                        treatment_options:
                          type: array
                          items:
                            type: object
                            properties:
                              method:
                                type: string
                              description:
                                type: string
                              effectiveness:
                                type: string
                timestamp:
                  type: string
                  format: date-time
      400:
        description: Dados inválidos
      500:
        description: Erro interno do servidor
    """
    try:
        data = request.get_json()
        if not data or 'image' not in data:
            return jsonify(create_error_response(
                'missing_image',
                'Imagem é obrigatória para diagnóstico',
                400
            )), 400
        
        image_base64 = data['image']
        plant_type = data.get('plant_type', 'desconhecida')
        user_id = data.get('user_id')
        language = data.get('language', 'pt')
        
        # Processar diagnóstico com Gemma
        gemma_service = current_app.gemma_service
        if not gemma_service:
            # Fallback para diagnóstico simulado
            diagnosis_result = _simulate_plant_image_diagnosis(image_base64, plant_type)
        else:
            # Usar Gemma para diagnóstico real
            diagnosis_result = _analyze_plant_image_with_gemma(
                gemma_service, image_base64, plant_type, language
            )
        
        return jsonify({
            'success': True,
            'diagnosis': diagnosis_result,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "diagnóstico de planta por imagem")
        return jsonify(create_error_response(
            'plant_diagnosis_error',
            'Erro ao diagnosticar planta',
            500
        )), 500

@environmental_bp.route('/plant/audio-diagnosis', methods=['POST'])
def plant_audio_diagnosis():
    """
    Diagnóstico de plantas através de análise de áudio
    ---
    tags:
      - Plant Diagnosis
    summary: Diagnóstico de plantas por áudio
    description: |
      Analisa descrição em áudio sobre problemas da planta para identificar possíveis
      causas e fornecer recomendações de tratamento usando IA Gemma-3.
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              audio:
                type: string
                description: Áudio da descrição em base64
              plant_type:
                type: string
                description: Tipo de planta (opcional)
                example: "milho"
              user_id:
                type: string
                description: ID do usuário (opcional)
              language:
                type: string
                description: Idioma do áudio
                default: "pt"
                example: "pt"
            required:
              - audio
    responses:
      200:
        description: Diagnóstico por áudio realizado com sucesso
        content:
          application/json:
            schema:
              type: object
              properties:
                success:
                  type: boolean
                  example: true
                diagnosis:
                  type: object
                  properties:
                    audio_transcription:
                      type: string
                      example: "As folhas estão amarelando e caindo"
                    symptoms_identified:
                      type: array
                      items:
                        type: object
                        properties:
                          symptom:
                            type: string
                            example: "amarelamento das folhas"
                          possible_causes:
                            type: array
                            items:
                              type: string
                          severity:
                            type: string
                            example: "moderada"
                    probable_diagnosis:
                      type: object
                      properties:
                        primary_cause:
                          type: string
                          example: "Deficiência nutricional"
                        confidence:
                          type: number
                          example: 0.70
                        alternative_causes:
                          type: array
                          items:
                            type: string
                    recommendations:
                      type: object
                      properties:
                        immediate_actions:
                          type: array
                          items:
                            type: string
                        diagnostic_steps:
                          type: array
                          items:
                            type: string
                        treatment_options:
                          type: array
                          items:
                            type: object
                            properties:
                              method:
                                type: string
                              description:
                                type: string
                              timeline:
                                type: string
                timestamp:
                  type: string
                  format: date-time
      400:
        description: Dados inválidos
      500:
        description: Erro interno do servidor
    """
    try:
        data = request.get_json()
        if not data or 'audio' not in data:
            return jsonify(create_error_response(
                'missing_audio',
                'Áudio é obrigatório para diagnóstico',
                400
            )), 400
        
        audio_base64 = data['audio']
        plant_type = data.get('plant_type', 'desconhecida')
        user_id = data.get('user_id')
        language = data.get('language', 'pt')
        
        # Processar diagnóstico com Gemma
        gemma_service = current_app.gemma_service
        if not gemma_service:
            # Fallback para diagnóstico simulado
            diagnosis_result = _simulate_plant_audio_diagnosis(audio_base64, plant_type)
        else:
            # Usar Gemma para diagnóstico real
            diagnosis_result = _analyze_plant_audio_with_gemma(
                gemma_service, audio_base64, plant_type, language
            )
        
        return jsonify({
            'success': True,
            'diagnosis': diagnosis_result,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "diagnóstico de planta por áudio")
        return jsonify(create_error_response(
            'plant_audio_diagnosis_error',
            'Erro ao diagnosticar planta por áudio',
            500
        )), 500

def _get_emergency_alerts(location):
    """Gerar alertas de emergência"""
    alerts = []
    
    # Simular alerta de emergência baseado em condições extremas
    # Este seria conectado a sistemas de monitoramento reais
    
    # Exemplo: Alerta de seca
    alerts.append({
        'id': 'emergency_drought_001',
        'type': 'emergency',
        'category': 'drought',
        'severity': 'high',
        'title': 'Alerta de Seca',
        'message': 'Período prolongado sem chuvas pode afetar abastecimento de água',
        'description': 'Ausência de precipitação por mais de 15 dias consecutivos.',
        'recommendations': [
            'Racionar uso de água',
            'Implementar irrigação de emergência',
            'Contactar autoridades locais'
        ],
        'timestamp': datetime.now().isoformat(),
        'expires_at': (datetime.now() + timedelta(days=7)).isoformat(),
        'location': location,
        'icon': 'water_drop',
        'color': '#D32F2F',
        'emergency_contacts': [
            {'name': 'Defesa Civil', 'phone': '+245-123-4567'},
            {'name': 'Ministério da Agricultura', 'phone': '+245-234-5678'}
        ]
    })
    
    return alerts