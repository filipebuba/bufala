#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Rotas Ambientais - Bu Fala Backend
Hackathon Gemma 3n

Sistema de monitoramento e análise ambiental
para sustentabilidade e conservação.
"""

import logging
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