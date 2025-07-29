#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Rotas de Bem-estar - Moransa Backend
Hackathon Gemma 3n

Especializado em bem-estar mental, físico e social,
com foco em saúde comunitária e prevenção.
"""

import logging
import re
from flask import Blueprint, request, jsonify, current_app
from datetime import datetime
from config.settings import SystemPrompts
from utils.error_handler import create_error_response, log_error

# Criar blueprint
wellness_bp = Blueprint('wellness', __name__)
logger = logging.getLogger(__name__)

@wellness_bp.route('/wellness', methods=['POST'])
def wellness_content():
    """
    Endpoint principal para conteúdo de bem-estar (respiração e meditação)
    ---
    tags:
      - Bem-estar
    summary: Conteúdo de bem-estar com Gemma-3
    description: |
      Endpoint principal para gerar conteúdo de bem-estar personalizado,
      incluindo exercícios de respiração e meditação usando Gemma-3.
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
              description: Solicitação de conteúdo de bem-estar
              example: "Preciso de um exercício de respiração para relaxar"
            type:
              type: string
              enum: ["breathing", "meditation", "relaxation", "mindfulness"]
              description: Tipo de conteúdo solicitado
              example: "breathing"
            duration:
              type: integer
              description: Duração desejada em minutos
              example: 5
            difficulty:
              type: string
              enum: ["beginner", "intermediate", "advanced"]
              description: Nível de dificuldade
              example: "beginner"
            language:
              type: string
              enum: ["português", "crioulo", "ambos"]
              description: Idioma preferido
              example: "português"
    responses:
      200:
        description: Conteúdo de bem-estar gerado com sucesso
        schema:
          type: object
          properties:
            success:
              type: boolean
              example: true
            data:
              type: object
              properties:
                content:
                  type: string
                  description: Conteúdo de bem-estar gerado
                instructions:
                  type: array
                  items:
                    type: string
                  description: Instruções passo a passo
                duration:
                  type: integer
                  description: Duração em minutos
                type:
                  type: string
                  description: Tipo de exercício
      400:
        description: Dados inválidos
      500:
        description: Erro interno do servidor
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
        
        # Extrair parâmetros
        prompt = data.get('prompt') or data.get('question') or data.get('query')
        if not prompt:
            return jsonify(create_error_response(
                'missing_prompt',
                'Campo "prompt", "question" ou "query" é obrigatório',
                400
            )), 400
        
        content_type = data.get('type', 'breathing')
        duration = data.get('duration', 5)
        difficulty = data.get('difficulty', 'beginner')
        language = data.get('language', 'português')
        
        # Preparar contexto para o Gemma-3
        wellness_context = _prepare_wellness_content_context(
            prompt, content_type, duration, difficulty, language
        )
        
        # Obter serviço Gemma
        gemma_service = getattr(current_app, 'gemma_service', None)
        
        if gemma_service:
            # Gerar conteúdo usando Gemma-3
            response = gemma_service.generate_response(
                wellness_context,
                SystemPrompts.WELLNESS,
                temperature=0.7,
                max_new_tokens=500
            )
            
            if response.get('success'):
                # Processar resposta do Gemma-3
                content_data = _process_wellness_content_response(
                    response.get('response', ''), content_type, duration
                )
            else:
                # Fallback se Gemma-3 falhar
                content_data = _get_wellness_content_fallback(
                    content_type, duration, difficulty, language
                )
        else:
            # Resposta de fallback sem Gemma-3
            content_data = _get_wellness_content_fallback(
                content_type, duration, difficulty, language
            )
        
        return jsonify({
            'success': True,
            'data': {
                'content': content_data['content'],
                'instructions': content_data['instructions'],
                'duration': duration,
                'type': content_type,
                'difficulty': difficulty,
                'language': language,
                'tips': content_data.get('tips', []),
                'benefits': content_data.get('benefits', [])
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "conteúdo de bem-estar")
        return jsonify(create_error_response(
            'wellness_content_error',
            'Erro ao gerar conteúdo de bem-estar',
            500
        )), 500

@wellness_bp.route('/wellness/mood-analysis', methods=['POST'])
def mood_analysis():
    """
    Análise de humor com IA
    ---
    tags:
      - Bem-estar
    summary: Análise profissional de humor usando Gemma-3
    description: |
      Endpoint para análise detalhada do humor do usuário usando IA.
      Fornece insights psicológicos, recomendações e técnicas de enfrentamento.
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - mood
            - intensity
          properties:
            mood:
              type: string
              enum: ["happy", "calm", "neutral", "sad", "anxious", "angry", "tired", "motivated"]
              description: Humor atual selecionado
              example: "anxious"
            intensity:
              type: integer
              minimum: 1
              maximum: 10
              description: Intensidade do humor (1-10)
              example: 7
            description:
              type: string
              description: Descrição adicional do estado emocional
              example: "Estou me sentindo ansioso por causa do trabalho"
            user_profile:
              type: object
              description: Perfil do usuário para personalização
              properties:
                name:
                  type: string
                goals:
                  type: array
                  items:
                    type: string
            language:
              type: string
              enum: ["português", "crioulo", "ambos"]
              description: Idioma preferido
              example: "português"
    responses:
      200:
        description: Análise de humor realizada com sucesso
        schema:
          type: object
          properties:
            success:
              type: boolean
              example: true
            data:
              type: object
              properties:
                insights:
                  type: string
                  description: Insights psicológicos sobre o estado emocional
                recommendations:
                  type: string
                  description: Recomendações específicas para melhorar o bem-estar
                coping_techniques:
                  type: string
                  description: Técnicas de enfrentamento práticas
                exercises:
                  type: string
                  description: Exercícios sugeridos (respiração, meditação, físicos)
                mood_score:
                  type: integer
                  description: Pontuação do humor (1-100)
                risk_level:
                  type: string
                  enum: ["low", "medium", "high"]
                  description: Nível de risco psicológico
            timestamp:
              type: string
              format: date-time
      400:
        description: Dados inválidos
      500:
        description: Erro interno do servidor
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
        
        # Extrair parâmetros obrigatórios
        mood = data.get('mood')
        intensity = data.get('intensity')
        
        if not mood or intensity is None:
            return jsonify(create_error_response(
                'missing_parameters',
                'Campos "mood" e "intensity" são obrigatórios',
                400
            )), 400
        
        # Validar intensidade
        try:
            intensity = int(intensity)
            if intensity < 1 or intensity > 10:
                raise ValueError("Intensidade deve estar entre 1 e 10")
        except (ValueError, TypeError):
            return jsonify(create_error_response(
                'invalid_intensity',
                'Intensidade deve ser um número entre 1 e 10',
                400
            )), 400
        
        # Extrair parâmetros opcionais
        description = data.get('description', '')
        user_profile = data.get('user_profile', {})
        language = data.get('language', 'português')
        
        # Mapear humor para português
        mood_labels = {
            'happy': 'Feliz',
            'calm': 'Calmo',
            'neutral': 'Neutro',
            'sad': 'Triste',
            'anxious': 'Ansioso',
            'angry': 'Irritado',
            'tired': 'Cansado',
            'motivated': 'Motivado'
        }
        
        mood_label = mood_labels.get(mood, mood)
        
        # Preparar contexto para análise
        profile_info = ''
        if user_profile:
            name = user_profile.get('name', 'Usuário')
            goals = user_profile.get('goals', [])
            if goals:
                profile_info = f"Nome: {name}, Metas: {', '.join(goals)}"
            else:
                profile_info = f"Nome: {name}"
        else:
            profile_info = 'Usuário geral'
        
        # Construir prompt para análise
        analysis_prompt = f"""
Você é um psicólogo especialista em saúde mental. Analise o humor do usuário e forneça insights profissionais.

Dados do usuário:
- Perfil: {profile_info}
- Humor atual: {mood_label} ({mood})
- Intensidade: {intensity}/10
- Descrição adicional: {description if description else 'Não fornecida'}

Por favor, forneça uma análise estruturada em {language} com:

1. INSIGHTS: Análise psicológica do estado emocional atual (2-3 parágrafos)
2. RECOMENDAÇÕES: Sugestões específicas para melhorar o bem-estar (lista de 4-5 itens)
3. TÉCNICAS DE ENFRENTAMENTO: Estratégias práticas para lidar com este humor (lista de 3-4 técnicas)
4. EXERCÍCIOS SUGERIDOS: Atividades específicas como respiração, meditação, exercícios físicos (lista de 3-4 exercícios)

Seja empático, profissional e focado em soluções práticas. Considere o contexto cultural da Guiné-Bissau.
"""
        
        # Obter serviço Gemma
        gemma_service = getattr(current_app, 'gemma_service', None)
        
        if gemma_service:
            # Gerar análise usando Gemma-3
            response = gemma_service.generate_response(
                analysis_prompt,
                SystemPrompts.WELLNESS,
                temperature=0.7,
                max_new_tokens=800
            )
            
            if response.get('success'):
                analysis_text = response.get('response', '')
                # Processar resposta estruturada
                analysis_data = _parse_mood_analysis_response(analysis_text)
            else:
                # Fallback se Gemma-3 falhar
                analysis_data = _get_mood_analysis_fallback(mood, intensity, description, language)
        else:
            # Resposta de fallback sem Gemma-3
            analysis_data = _get_mood_analysis_fallback(mood, intensity, description, language)
        
        # Calcular pontuação do humor e nível de risco
        mood_score = _calculate_mood_score(mood, intensity)
        risk_level = _assess_risk_level(mood, intensity, description)
        
        return jsonify({
            'success': True,
            'data': {
                'insights': analysis_data.get('insights', ''),
                'recommendations': analysis_data.get('recommendations', ''),
                'coping_techniques': analysis_data.get('coping_techniques', ''),
                'exercises': analysis_data.get('exercises', ''),
                'mood_score': mood_score,
                'risk_level': risk_level,
                'mood': mood,
                'intensity': intensity,
                'language': language
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "análise de humor")
        return jsonify(create_error_response(
            'mood_analysis_error',
            'Erro ao analisar humor',
            500
        )), 500

@wellness_bp.route('/wellness/coaching', methods=['POST'])
def wellness_coaching():
    """
    Fornecer coaching de bem-estar personalizado
    ---
    tags:
      - Bem-estar
    summary: Coaching de bem-estar e saúde mental
    description: |
      Endpoint para coaching de bem-estar personalizado e suporte à saúde mental.
      Adaptado às necessidades culturais e sociais da Guiné-Bissau.
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
              description: Questão ou situação de bem-estar
              example: "Estou me sentindo muito estressado com o trabalho"
            mood:
              type: string
              enum: ["muito_baixo", "baixo", "neutro", "bom", "muito_bom"]
              description: Estado de humor atual
              example: "baixo"
            stress_level:
              type: integer
              minimum: 1
              maximum: 10
              description: Nível de estresse (1-10)
              example: 7
            concerns:
              type: array
              items:
                type: string
              description: Principais preocupações
              example: ["trabalho", "família", "saúde"]
            support_type:
              type: string
              enum: ["emocional", "prático", "espiritual", "social"]
              description: Tipo de suporte desejado
              example: "emocional"
            cultural_context:
              type: string
              description: Contexto cultural específico
              example: "comunidade rural"
            language:
              type: string
              enum: ["português", "crioulo", "ambos"]
              description: Idioma preferido
              example: "crioulo"
    responses:
      200:
        description: Coaching de bem-estar fornecido com sucesso
        schema:
          type: object
          properties:
            success:
              type: boolean
              example: true
            message:
              type: string
              example: "Coaching de bem-estar fornecido"
            data:
              type: object
              properties:
                guidance:
                  type: string
                  description: Orientação de bem-estar personalizada
                coping_strategies:
                  type: array
                  items:
                    type: string
                  description: Estratégias de enfrentamento
                daily_practices:
                  type: array
                  items:
                    type: string
                  description: Práticas diárias recomendadas
                cultural_wisdom:
                  type: string
                  description: Sabedoria cultural aplicável
                emergency_resources:
                  type: array
                  items:
                    type: string
                  description: Recursos de emergência se necessário
                follow_up_suggestions:
                  type: array
                  items:
                    type: string
                  description: Sugestões de acompanhamento
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
        
        # Obter parâmetros de bem-estar
        wellness_area = data.get('wellness_area', 'geral')  # mental, fisico, social, nutricional
        urgency_level = data.get('urgency_level', 'normal')  # baixo, normal, alto, urgente
        age_group = data.get('age_group', 'adulto')  # crianca, adolescente, adulto, idoso
        context = data.get('context', 'comunidade')  # casa, trabalho, comunidade
        
        # Preparar contexto de bem-estar
        wellness_context = _prepare_wellness_context(
            prompt, wellness_area, urgency_level, age_group, context
        )
        
        # Obter serviço Gemma
        gemma_service = getattr(current_app, 'gemma_service', None)
        
        if gemma_service:
            # Gerar resposta usando Gemma
            response = gemma_service.generate_response(
                wellness_context,
                SystemPrompts.WELLNESS,
                temperature=0.7,  # Temperatura moderada para conselhos empáticos
                max_new_tokens=400
            )
            
            # Adicionar informações de bem-estar específicas
            if response.get('success'):
                response['wellness_info'] = {
                    'wellness_area': wellness_area,
                    'urgency_level': urgency_level,
                    'age_group': age_group,
                    'context': context,
                    'recommendations': _get_wellness_recommendations(wellness_area),
                    'resources': _get_community_resources(),
                    'follow_up': _get_follow_up_suggestions(urgency_level)
                }
        else:
            # Resposta de fallback
            response = _get_wellness_fallback_response(prompt, wellness_area, urgency_level)
        
        return jsonify({
            'success': True,
            'data': response,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "coaching de bem-estar")
        return jsonify(create_error_response(
            'wellness_error',
            'Erro ao fornecer coaching de bem-estar',
            500
        )), 500

@wellness_bp.route('/wellness/mental-health', methods=['POST'])
def mental_health_support():
    """Suporte para saúde mental"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        concern = data.get('concern')
        severity = data.get('severity', 'leve')  # leve, moderado, severo
        support_type = data.get('support_type', 'geral')  # ansiedade, depressao, estresse, geral
        
        if not concern:
            return jsonify(create_error_response(
                'missing_concern',
                'Campo "concern" é obrigatório',
                400
            )), 400
        
        # Verificar se é caso de emergência
        if severity == 'severo' or _is_mental_health_emergency(concern):
            emergency_response = _get_mental_health_emergency_response()
            return jsonify({
                'success': True,
                'data': {
                    'emergency': True,
                    'immediate_actions': emergency_response['actions'],
                    'emergency_contacts': emergency_response['contacts'],
                    'safety_message': "Procure ajuda profissional imediatamente. Você não está sozinho."
                },
                'timestamp': datetime.now().isoformat()
            })
        
        # Fornecer suporte para casos não emergenciais
        support_response = _get_mental_health_support(concern, severity, support_type)
        
        return jsonify({
            'success': True,
            'data': {
                'concern': concern,
                'severity': severity,
                'support_type': support_type,
                'guidance': support_response['guidance'],
                'coping_strategies': support_response['strategies'],
                'self_care_tips': support_response['self_care'],
                'when_to_seek_help': support_response['seek_help'],
                'local_resources': _get_mental_health_resources()
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "suporte de saúde mental")
        return jsonify(create_error_response(
            'mental_health_error',
            'Erro ao fornecer suporte de saúde mental',
            500
        )), 500

@wellness_bp.route('/wellness/nutrition', methods=['POST'])
def nutrition_guidance():
    """Orientações nutricionais"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        nutrition_query = data.get('nutrition_query')
        age_group = data.get('age_group', 'adulto')
        health_conditions = data.get('health_conditions', [])
        local_foods = data.get('local_foods', True)
        budget_conscious = data.get('budget_conscious', True)
        
        if not nutrition_query:
            return jsonify(create_error_response(
                'missing_nutrition_query',
                'Campo "nutrition_query" é obrigatório',
                400
            )), 400
        
        # Obter orientações nutricionais
        nutrition_advice = _get_nutrition_advice(
            nutrition_query, age_group, health_conditions, local_foods, budget_conscious
        )
        
        return jsonify({
            'success': True,
            'data': {
                'nutrition_query': nutrition_query,
                'age_group': age_group,
                'advice': nutrition_advice,
                'local_food_suggestions': _get_local_food_suggestions(),
                'meal_planning_tips': _get_meal_planning_tips(),
                'budget_friendly_options': _get_budget_nutrition_tips(),
                'nutritional_education': "Uma alimentação equilibrada é fundamental para a saúde"
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "orientações nutricionais")
        return jsonify(create_error_response(
            'nutrition_error',
            'Erro ao fornecer orientações nutricionais',
            500
        )), 500

@wellness_bp.route('/wellness/physical-activity', methods=['POST'])
def physical_activity_guidance():
    """Orientações para atividade física"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        activity_query = data.get('activity_query')
        fitness_level = data.get('fitness_level', 'iniciante')  # iniciante, intermediario, avancado
        age_group = data.get('age_group', 'adulto')
        available_time = data.get('available_time', '30min')  # 15min, 30min, 1h, mais
        equipment_available = data.get('equipment_available', False)
        
        if not activity_query:
            return jsonify(create_error_response(
                'missing_activity_query',
                'Campo "activity_query" é obrigatório',
                400
            )), 400
        
        # Obter orientações de atividade física
        activity_advice = _get_physical_activity_advice(
            activity_query, fitness_level, age_group, available_time, equipment_available
        )
        
        return jsonify({
            'success': True,
            'data': {
                'activity_query': activity_query,
                'fitness_level': fitness_level,
                'advice': activity_advice,
                'simple_exercises': _get_simple_exercises(equipment_available),
                'safety_tips': _get_exercise_safety_tips(),
                'motivation_tips': _get_motivation_tips(),
                'community_activities': _get_community_activity_suggestions()
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "orientações de atividade física")
        return jsonify(create_error_response(
            'physical_activity_error',
            'Erro ao fornecer orientações de atividade física',
            500
        )), 500

@wellness_bp.route('/wellness/stress-management', methods=['POST'])
def stress_management():
    """Técnicas de gerenciamento de estresse"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        stress_description = data.get('stress_description')
        stress_level = data.get('stress_level', 'moderado')  # baixo, moderado, alto
        stress_source = data.get('stress_source', 'geral')  # trabalho, familia, saude, financeiro
        time_available = data.get('time_available', '10min')
        
        if not stress_description:
            return jsonify(create_error_response(
                'missing_stress_description',
                'Campo "stress_description" é obrigatório',
                400
            )), 400
        
        # Obter técnicas de gerenciamento de estresse
        stress_management_techniques = _get_stress_management_techniques(
            stress_description, stress_level, stress_source, time_available
        )
        
        return jsonify({
            'success': True,
            'data': {
                'stress_description': stress_description,
                'stress_level': stress_level,
                'techniques': stress_management_techniques,
                'breathing_exercises': _get_breathing_exercises(),
                'relaxation_methods': _get_relaxation_methods(),
                'lifestyle_changes': _get_stress_prevention_tips(),
                'when_to_seek_help': "Se o estresse persistir ou piorar, procure ajuda profissional"
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "gerenciamento de estresse")
        return jsonify(create_error_response(
            'stress_management_error',
            'Erro ao fornecer técnicas de gerenciamento de estresse',
            500
        )), 500

def _prepare_wellness_context(prompt, wellness_area, urgency_level, age_group, context):
    """Preparar contexto de bem-estar"""
    context_text = f"Questão de bem-estar: {prompt}"
    context_text += f"\nÁrea de bem-estar: {wellness_area}"
    context_text += f"\nNível de urgência: {urgency_level}"
    context_text += f"\nFaixa etária: {age_group}"
    context_text += f"\nContexto: {context}"
    context_text += "\n\nPor favor, forneça orientações de bem-estar empáticas, práticas e culturalmente apropriadas para a comunidade da Guiné-Bissau."
    
    return context_text

def _get_wellness_recommendations(wellness_area):
    """Obter recomendações de bem-estar"""
    recommendations = {
        'mental': [
            "Pratique mindfulness e meditação",
            "Mantenha conexões sociais",
            "Estabeleça rotinas saudáveis",
            "Busque atividades prazerosas"
        ],
        'fisico': [
            "Mantenha atividade física regular",
            "Durma adequadamente",
            "Hidrate-se bem",
            "Faça check-ups regulares"
        ],
        'social': [
            "Participe de atividades comunitárias",
            "Cultive relacionamentos saudáveis",
            "Pratique comunicação assertiva",
            "Contribua para a comunidade"
        ],
        'nutricional': [
            "Consuma alimentos locais variados",
            "Mantenha horários regulares de refeição",
            "Beba água limpa suficiente",
            "Evite excessos de açúcar e sal"
        ]
    }
    return recommendations.get(wellness_area, recommendations['mental'])

def _get_community_resources():
    """Obter recursos comunitários"""
    return [
        "Centros de saúde locais",
        "Grupos de apoio comunitário",
        "Líderes religiosos e tradicionais",
        "Organizações não governamentais",
        "Programas de saúde pública"
    ]

def _get_follow_up_suggestions(urgency_level):
    """Obter sugestões de acompanhamento"""
    suggestions = {
        'baixo': "Monitore seu bem-estar regularmente",
        'normal': "Reavalie em uma semana se não houver melhora",
        'alto': "Busque acompanhamento profissional em poucos dias",
        'urgente': "Procure ajuda profissional imediatamente"
    }
    return suggestions.get(urgency_level, suggestions['normal'])

def _get_wellness_fallback_response(prompt, wellness_area, urgency_level):
    """Resposta de fallback para bem-estar"""
    return {
        'response': f"Para questões de {wellness_area} com urgência {urgency_level}, recomendo buscar apoio de profissionais de saúde locais ou líderes comunitários. O bem-estar é fundamental para uma vida saudável e produtiva.",
        'success': True,
        'fallback': True,
        'wellness_info': {
            'wellness_area': wellness_area,
            'urgency_level': urgency_level,
            'recommendation': "Busque apoio profissional e mantenha práticas de autocuidado"
        }
    }

def _is_mental_health_emergency(concern):
    """Verificar se é emergência de saúde mental"""
    emergency_keywords = [
        'suicidio', 'suicídio', 'matar', 'morrer', 'acabar com tudo',
        'não aguento mais', 'sem saída', 'desespero total'
    ]
    concern_lower = concern.lower()
    return any(keyword in concern_lower for keyword in emergency_keywords)

def _get_mental_health_emergency_response():
    """Obter resposta para emergência de saúde mental"""
    return {
        'actions': [
            "Procure ajuda profissional imediatamente",
            "Entre em contato com um centro de saúde",
            "Converse com alguém de confiança",
            "Não fique sozinho"
        ],
        'contacts': [
            "Centro de Saúde mais próximo",
            "Linha de apoio psicológico (se disponível)",
            "Líder religioso ou comunitário",
            "Familiar ou amigo de confiança"
        ]
    }

def _get_mental_health_support(concern, severity, support_type):
    """Obter suporte para saúde mental"""
    return {
        'guidance': f"Para {support_type} de nível {severity}, é importante reconhecer que buscar ajuda é um sinal de força, não fraqueza.",
        'strategies': [
            "Pratique respiração profunda",
            "Mantenha rotinas regulares",
            "Converse com pessoas de confiança",
            "Pratique atividades relaxantes"
        ],
        'self_care': [
            "Durma adequadamente",
            "Alimente-se bem",
            "Pratique atividade física leve",
            "Reserve tempo para si mesmo"
        ],
        'seek_help': "Procure ajuda profissional se os sintomas persistirem por mais de duas semanas ou interferirem significativamente na vida diária"
    }

def _get_mental_health_resources():
    """Obter recursos de saúde mental"""
    return [
        "Centros de saúde com psicólogos",
        "Grupos de apoio comunitário",
        "Programas de saúde mental",
        "Líderes espirituais",
        "Organizações de apoio social"
    ]

def _get_nutrition_advice(query, age_group, conditions, local_foods, budget_conscious):
    """Obter conselhos nutricionais"""
    base_advice = "Uma alimentação equilibrada inclui variedade de alimentos locais, com foco em frutas, vegetais, grãos e proteínas."
    
    if local_foods:
        base_advice += " Aproveite alimentos locais como arroz, mandioca, peixe, frutas tropicais e vegetais da região."
    
    if budget_conscious:
        base_advice += " Priorize alimentos sazonais e locais que são mais acessíveis e nutritivos."
    
    return base_advice

def _get_local_food_suggestions():
    """Obter sugestões de alimentos locais"""
    return [
        "Arroz integral",
        "Mandioca",
        "Peixe fresco",
        "Frutas tropicais (manga, papaia, banana)",
        "Vegetais verdes locais",
        "Amendoim",
        "Óleo de palma (com moderação)"
    ]

def _get_meal_planning_tips():
    """Obter dicas de planejamento de refeições"""
    return [
        "Planeje refeições com antecedência",
        "Inclua variedade de cores nos pratos",
        "Combine diferentes grupos alimentares",
        "Aproveite sobras de forma criativa",
        "Mantenha horários regulares de refeição"
    ]

def _get_budget_nutrition_tips():
    """Obter dicas de nutrição econômica"""
    return [
        "Compre alimentos sazonais",
        "Cultive horta caseira",
        "Aproveite todas as partes dos alimentos",
        "Cozinhe em casa sempre que possível",
        "Forme grupos de compra comunitária"
    ]

def _get_physical_activity_advice(query, fitness_level, age_group, time_available, equipment):
    """Obter conselhos de atividade física"""
    base_advice = f"Para nível {fitness_level} com {time_available} disponível, recomendo começar gradualmente e aumentar a intensidade progressivamente."
    
    if not equipment:
        base_advice += " Exercícios sem equipamento são eficazes: caminhada, alongamento, exercícios com peso corporal."
    
    return base_advice

def _get_simple_exercises(equipment_available):
    """Obter exercícios simples"""
    if equipment_available:
        return [
            "Caminhada ou corrida leve",
            "Flexões",
            "Agachamentos",
            "Alongamentos",
            "Exercícios com pesos improvisados"
        ]
    else:
        return [
            "Caminhada",
            "Flexões (adaptadas se necessário)",
            "Agachamentos",
            "Alongamentos",
            "Dança"
        ]

def _get_exercise_safety_tips():
    """Obter dicas de segurança para exercícios"""
    return [
        "Aqueça antes de exercitar-se",
        "Hidrate-se adequadamente",
        "Pare se sentir dor",
        "Progrida gradualmente",
        "Descanse adequadamente entre sessões"
    ]

def _get_motivation_tips():
    """Obter dicas de motivação"""
    return [
        "Estabeleça metas realistas",
        "Encontre atividades prazerosas",
        "Exercite-se com amigos",
        "Celebre pequenas conquistas",
        "Mantenha consistência, não perfeição"
    ]

def _get_community_activity_suggestions():
    """Obter sugestões de atividades comunitárias"""
    return [
        "Grupos de caminhada",
        "Dança tradicional",
        "Esportes comunitários",
        "Trabalho agrícola em grupo",
        "Atividades ao ar livre"
    ]

def _get_stress_management_techniques(description, level, source, time_available):
    """Obter técnicas de gerenciamento de estresse"""
    techniques = {
        '5min': [
            "Respiração profunda",
            "Relaxamento muscular rápido",
            "Mindfulness básico"
        ],
        '10min': [
            "Meditação guiada",
            "Exercícios de respiração",
            "Caminhada curta",
            "Alongamentos"
        ],
        '30min': [
            "Exercício físico",
            "Meditação completa",
            "Atividade criativa",
            "Conversa com amigo"
        ]
    }
    
    return techniques.get(time_available, techniques['10min'])

def _get_breathing_exercises():
    """Obter exercícios de respiração"""
    return [
        "Respiração 4-7-8: Inspire por 4, segure por 7, expire por 8",
        "Respiração abdominal: Respire profundamente pelo diafragma",
        "Respiração quadrada: Inspire, segure, expire, segure (4 tempos cada)"
    ]

def _get_relaxation_methods():
    """Obter métodos de relaxamento"""
    return [
        "Relaxamento muscular progressivo",
        "Visualização positiva",
        "Música relaxante",
        "Banho morno",
        "Massagem suave"
    ]

def _get_stress_prevention_tips():
    """Obter dicas de prevenção de estresse"""
    return [
        "Mantenha rotinas regulares",
        "Pratique atividade física regularmente",
        "Cultive relacionamentos saudáveis",
        "Estabeleça limites saudáveis",
        "Reserve tempo para relaxamento",
        "Pratique gratidão diariamente"
    ]

@wellness_bp.route('/wellness/guided-meditation', methods=['POST'])
def guided_meditation():
    """
    Sessão de meditação e respiração guiada com Gemma-3n
    ---
    tags:
      - Bem-estar
    summary: Sessão de meditação guiada com áudio do Gemma-3n
    description: |
      Endpoint para gerar sessões de meditação e respiração guiada usando
      as capacidades multimodais do Gemma-3n, incluindo geração de áudio.
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - session_type
          properties:
            session_type:
              type: string
              enum: ["breathing", "meditation", "relaxation"]
              description: Tipo de sessão
              example: "breathing"
            duration_minutes:
              type: integer
              description: Duração em minutos
              example: 5
            language:
              type: string
              enum: ["português", "crioulo"]
              description: Idioma preferido
              example: "português"
            personalized_prompt:
              type: string
              description: Prompt personalizado
              example: "Preciso relaxar após um dia difícil"
            use_gemma_audio:
              type: boolean
              description: Usar capacidade de áudio do Gemma-3n
              example: true
    responses:
      200:
        description: Sessão de meditação gerada com sucesso
        schema:
          type: object
          properties:
            success:
              type: boolean
            data:
              type: object
              properties:
                session_id:
                  type: string
                instructions:
                  type: object
                  properties:
                    introduction:
                      type: string
                    preparation:
                      type: string
                    conclusion:
                      type: string
                audio_content:
                  type: object
                  properties:
                    has_audio:
                      type: boolean
                    audio_instructions:
                      type: array
                      items:
                        type: string
                    fallback_text:
                      type: string
                pattern:
                  type: object
                  properties:
                    name:
                      type: string
                    inhale_seconds:
                      type: integer
                    hold_seconds:
                      type: integer
                    exhale_seconds:
                      type: integer
    """
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        # Extrair parâmetros
        session_type = data.get('session_type', 'breathing')
        duration_minutes = data.get('duration_minutes', 5)
        language = data.get('language', 'português')
        personalized_prompt = data.get('personalized_prompt', '')
        use_gemma_audio = data.get('use_gemma_audio', True)
        
        # Validar parâmetros
        if session_type not in ['breathing', 'meditation', 'relaxation']:
            return jsonify(create_error_response(
                'invalid_session_type',
                'Tipo de sessão deve ser: breathing, meditation ou relaxation',
                400
            )), 400
        
        if duration_minutes < 1 or duration_minutes > 60:
            return jsonify(create_error_response(
                'invalid_duration',
                'Duração deve estar entre 1 e 60 minutos',
                400
            )), 400
        
        # Obter serviço Gemma
        gemma_service = getattr(current_app, 'gemma_service', None)
        
        if gemma_service and use_gemma_audio:
            # Tentar usar capacidades multimodais do Gemma-3n
            session_data = _generate_guided_session_with_gemma_audio(
                gemma_service, session_type, duration_minutes, language, personalized_prompt
            )
        else:
            # Fallback para geração de texto + TTS
            session_data = _generate_guided_session_with_text(
                gemma_service, session_type, duration_minutes, language, personalized_prompt
            )
        
        return jsonify({
            'success': True,
            'data': session_data
        })
        
    except Exception as e:
        log_error(logger, e, 'guided_meditation')
        return jsonify(create_error_response(
            'internal_error',
            'Erro interno do servidor',
            500
        )), 500

@wellness_bp.route('/wellness/voice-analysis', methods=['POST'])
def voice_analysis():
    """
    Análise de voz para bem-estar mental
    ---
    tags:
      - Bem-estar
    summary: Análise de voz para saúde mental
    description: |
      Endpoint para análise de voz usando IA Gemma-3 para avaliar indicadores
      de bem-estar mental, estresse e estado emocional.
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - voice_data
          properties:
            voice_data:
              type: object
              description: Dados de análise de voz
              properties:
                stress_indicators:
                  type: number
                  description: Indicadores de estresse na voz
                energy_indicators:
                  type: number
                  description: Indicadores de energia na voz
                stability_indicators:
                  type: number
                  description: Indicadores de estabilidade emocional
                duration_factor:
                  type: number
                  description: Fator de duração da gravação
                quality_factor:
                  type: number
                  description: Fator de qualidade do áudio
                detected_mood:
                  type: string
                  description: Humor detectado
                pitch_variance:
                  type: number
                  description: Variação de tom
                speaking_rate:
                  type: number
                  description: Taxa de fala
            language:
              type: string
              description: Idioma preferido
              example: "pt-BR"
    responses:
      200:
        description: Análise de voz realizada com sucesso
        schema:
          type: object
          properties:
            success:
              type: boolean
              example: true
            analysis:
              type: object
              properties:
                stress_level:
                  type: number
                  description: Nível de estresse detectado (0-1)
                energy_level:
                  type: number
                  description: Nível de energia detectado (0-1)
                emotional_stability:
                  type: number
                  description: Estabilidade emocional (0-1)
                mood_state:
                  type: string
                  description: Estado de humor detectado
                confidence:
                  type: number
                  description: Confiança da análise (0-1)
            recommendations:
              type: array
              items:
                type: string
              description: Recomendações baseadas na análise
            wellness_tips:
              type: array
              items:
                type: string
              description: Dicas de bem-estar personalizadas
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
        
        # Extrair dados de voz
        voice_data = data.get('voice_data')
        if not voice_data:
            return jsonify(create_error_response(
                'missing_voice_data',
                'Campo "voice_data" é obrigatório',
                400
            )), 400
        
        # Obter parâmetros opcionais
        language = data.get('language', 'pt-BR')
        
        # Extrair métricas de voz
        stress_indicators = voice_data.get('stress_indicators', 0.5)
        energy_indicators = voice_data.get('energy_indicators', 0.5)
        stability_indicators = voice_data.get('stability_indicators', 0.5)
        detected_mood = voice_data.get('detected_mood', 'neutral')
        pitch_variance = voice_data.get('pitch_variance', 25.0)
        speaking_rate = voice_data.get('speaking_rate', 150.0)
        
        # Preparar prompt para análise de voz com Gemma-3
        voice_analysis_prompt = f"""
        Analise os seguintes dados de voz para avaliação de bem-estar mental:
        
        Indicadores de Estresse: {stress_indicators:.2f} (0-1)
        Indicadores de Energia: {energy_indicators:.2f} (0-1)
        Indicadores de Estabilidade: {stability_indicators:.2f} (0-1)
        Humor Detectado: {detected_mood}
        Variação de Tom: {pitch_variance:.1f} Hz
        Taxa de Fala: {speaking_rate:.1f} palavras/min
        
        Com base nestes dados, forneça:
        1. Análise do estado emocional e bem-estar
        2. Recomendações específicas para melhorar o bem-estar
        3. Técnicas de relaxamento apropriadas
        4. Sinais de alerta se necessário
        
        Responda em {language} de forma empática e culturalmente apropriada para a comunidade da Guiné-Bissau.
        """
        
        # Obter serviço Gemma
        gemma_service = getattr(current_app, 'gemma_service', None)
        
        if gemma_service:
            # Gerar análise usando Gemma-3
            response = gemma_service.generate_response(
                voice_analysis_prompt,
                SystemPrompts.WELLNESS,
                temperature=0.6,  # Temperatura moderada para análise consistente
                max_new_tokens=400
            )
            
            if response.get('success'):
                # Processar resposta do Gemma e extrair análise estruturada
                gemma_analysis = response.get('response', '')
                
                # Calcular métricas finais baseadas nos dados de entrada e análise do Gemma
                final_stress_level = min(max(stress_indicators, 0.0), 1.0)
                final_energy_level = min(max(energy_indicators, 0.0), 1.0)
                final_stability = min(max(stability_indicators, 0.0), 1.0)
                
                # Determinar estado de humor final
                mood_mapping = {
                    'stressed': 'estressado',
                    'tired': 'cansado',
                    'calm': 'calmo',
                    'energetic': 'energético',
                    'neutral': 'neutro'
                }
                final_mood = mood_mapping.get(detected_mood, 'neutro')
                
                # Gerar recomendações baseadas na análise
                recommendations = _generate_voice_recommendations(
                    final_stress_level, final_energy_level, final_stability, final_mood
                )
                
                return jsonify({
                    'success': True,
                    'analysis': {
                        'stress_level': final_stress_level,
                        'energy_level': final_energy_level,
                        'emotional_stability': final_stability,
                        'mood_state': final_mood,
                        'confidence': 0.85,
                        'gemma_analysis': gemma_analysis
                    },
                    'recommendations': recommendations,
                    'wellness_tips': _get_voice_wellness_tips(final_stress_level, final_energy_level),
                    'timestamp': datetime.now().isoformat()
                })
            else:
                # Fallback se Gemma falhar
                fallback_analysis = _get_voice_analysis_fallback(
                    stress_indicators, energy_indicators, stability_indicators, detected_mood
                )
                return jsonify(fallback_analysis)
        else:
            # Resposta de fallback quando Gemma não está disponível
            fallback_analysis = _get_voice_analysis_fallback(
                stress_indicators, energy_indicators, stability_indicators, detected_mood
            )
            return jsonify(fallback_analysis)
        
    except Exception as e:
        log_error(logger, e, "análise de voz")
        return jsonify(create_error_response(
            'voice_analysis_error',
            'Erro ao processar análise de voz',
            500
        )), 500

@wellness_bp.route('/chat', methods=['POST'])
def chat_generic():
    """
    Chat genérico com IA para bem-estar
    ---
    tags:
      - Bem-estar
    summary: Chat genérico com IA
    description: |
      Endpoint para chat genérico com a IA, focado em bem-estar e coaching.
      Suporta conversas contextuais e personalizadas.
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - message
          properties:
            message:
              type: string
              description: Mensagem do usuário
              example: "Como posso melhorar meu bem-estar?"
            context:
              type: string
              description: Contexto da conversa
              example: "wellness_coaching"
            language:
              type: string
              description: Idioma preferido
              example: "pt-BR"
            history:
              type: array
              items:
                type: object
                properties:
                  role:
                    type: string
                    enum: ["user", "assistant"]
                  content:
                    type: string
              description: Histórico da conversa
    responses:
      200:
        description: Resposta do chat gerada com sucesso
        schema:
          type: object
          properties:
            success:
              type: boolean
              example: true
            response:
              type: string
              description: Resposta da IA
            context:
              type: string
              description: Contexto utilizado
            timestamp:
              type: string
              description: Timestamp da resposta
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
        
        # Extrair mensagem
        message = data.get('message')
        if not message:
            return jsonify(create_error_response(
                'missing_message',
                'Campo "message" é obrigatório',
                400
            )), 400
        
        # Obter parâmetros opcionais
        context = data.get('context', 'wellness_coaching')
        language = data.get('language', 'pt-BR')
        history = data.get('history', [])
        
        # Preparar prompt baseado no contexto
        if context == 'wellness_coaching':
            system_prompt = SystemPrompts.WELLNESS
            prompt = f"Como coach de bem-estar para a comunidade da Guiné-Bissau, responda em {language}: {message}"
        elif context == 'wellness_tips':
            system_prompt = SystemPrompts.WELLNESS
            prompt = f"Como especialista em bem-estar, forneça dicas práticas em {language} para: {message}"
        else:
            system_prompt = SystemPrompts.WELLNESS
            prompt = f"Responda de forma útil e empática em {language}: {message}"
        
        # Obter serviço Gemma
        gemma_service = getattr(current_app, 'gemma_service', None)
        
        if gemma_service:
            # Gerar resposta usando Gemma
            response = gemma_service.generate_response(
                prompt,
                system_prompt,
                temperature=0.7,
                max_new_tokens=300
            )
            
            if response.get('success'):
                return jsonify({
                    'success': True,
                    'response': response.get('response', ''),
                    'answer': response.get('response', ''),  # Compatibilidade
                    'context': context,
                    'timestamp': datetime.now().isoformat()
                })
            else:
                # Fallback se Gemma falhar
                fallback_response = _get_chat_fallback_response(message, context, language)
                return jsonify({
                    'success': True,
                    'response': fallback_response,
                    'answer': fallback_response,
                    'context': context,
                    'timestamp': datetime.now().isoformat()
                })
        else:
            # Resposta de fallback quando Gemma não está disponível
            fallback_response = _get_chat_fallback_response(message, context, language)
            return jsonify({
                'success': True,
                'response': fallback_response,
                'answer': fallback_response,
                'context': context,
                'timestamp': datetime.now().isoformat()
            })
        
    except Exception as e:
        log_error(logger, e, "chat genérico")
        return jsonify(create_error_response(
            'chat_error',
            'Erro ao processar mensagem de chat',
            500
        )), 500

def _get_chat_fallback_response(message, context, language):
    """Obter resposta de fallback para chat"""
    if 'pt' in language.lower():
        if context == 'wellness_coaching':
            return "Obrigado por compartilhar isso comigo. Como seu coach de bem-estar, recomendo que você se concentre em pequenos passos diários para melhorar seu bem-estar. Que tal começarmos com uma prática de respiração ou uma caminhada curta?"
        elif context == 'wellness_tips':
            return "Aqui estão algumas dicas de bem-estar: 1) Pratique respiração profunda por 5 minutos diariamente, 2) Mantenha uma rotina de sono regular, 3) Conecte-se com pessoas queridas, 4) Pratique gratidão, 5) Faça atividade física leve regularmente."
        else:
            return "Entendo sua preocupação. É importante cuidar do seu bem-estar físico e mental. Recomendo conversar com pessoas de confiança e buscar atividades que tragam paz e alegria para sua vida."
    else:
        if context == 'wellness_coaching':
            return "Thank you for sharing that with me. As your wellness coach, I recommend focusing on small daily steps to improve your well-being. How about we start with a breathing practice or a short walk?"
        elif context == 'wellness_tips':
            return "Here are some wellness tips: 1) Practice deep breathing for 5 minutes daily, 2) Maintain a regular sleep routine, 3) Connect with loved ones, 4) Practice gratitude, 5) Do light physical activity regularly."
        else:
            return "I understand your concern. It's important to take care of your physical and mental well-being. I recommend talking to trusted people and seeking activities that bring peace and joy to your life."

def _generate_voice_recommendations(stress_level, energy_level, stability, mood):
    """Gerar recomendações baseadas na análise de voz"""
    recommendations = []
    
    # Recomendações baseadas no nível de estresse
    if stress_level > 0.7:
        recommendations.extend([
            "Pratique técnicas de respiração profunda por 10 minutos",
            "Considere uma caminhada ao ar livre para relaxar",
            "Tente ouvir música calma ou sons da natureza",
            "Converse com alguém de confiança sobre suas preocupações"
        ])
    elif stress_level > 0.4:
        recommendations.extend([
            "Faça pausas regulares durante suas atividades",
            "Pratique exercícios de alongamento suave",
            "Mantenha uma rotina de sono regular"
        ])
    
    # Recomendações baseadas no nível de energia
    if energy_level < 0.3:
        recommendations.extend([
            "Certifique-se de dormir adequadamente (7-8 horas)",
            "Considere uma alimentação nutritiva e regular",
            "Faça atividades físicas leves como caminhada",
            "Exponha-se à luz solar pela manhã"
        ])
    elif energy_level > 0.8:
        recommendations.extend([
            "Canalize sua energia em atividades produtivas",
            "Pratique exercícios físicos para equilibrar a energia",
            "Mantenha um horário estruturado para suas atividades"
        ])
    
    # Recomendações baseadas na estabilidade emocional
    if stability < 0.4:
        recommendations.extend([
            "Pratique técnicas de mindfulness e meditação",
            "Estabeleça rotinas diárias consistentes",
            "Busque apoio de familiares ou amigos próximos",
            "Considere conversar com um conselheiro ou líder comunitário"
        ])
    
    # Recomendações baseadas no humor
    if mood in ['estressado', 'cansado']:
        recommendations.extend([
            "Reserve tempo para atividades que lhe trazem alegria",
            "Pratique gratidão listando 3 coisas boas do seu dia",
            "Conecte-se com a natureza sempre que possível"
        ])
    
    return recommendations[:6]  # Limitar a 6 recomendações

def _get_voice_wellness_tips(stress_level, energy_level):
    """Obter dicas de bem-estar baseadas na análise de voz"""
    tips = [
        "Mantenha uma comunicação aberta com pessoas queridas",
        "Pratique atividades que conectem você com sua cultura local",
        "Reserve momentos diários para reflexão e paz interior"
    ]
    
    if stress_level > 0.6:
        tips.extend([
            "Experimente técnicas tradicionais de relaxamento da sua comunidade",
            "Participe de atividades comunitárias que tragam alegria",
            "Considere práticas espirituais ou religiosas que lhe confortem"
        ])
    
    if energy_level < 0.4:
        tips.extend([
            "Mantenha uma alimentação baseada em produtos locais frescos",
            "Estabeleça horários regulares para descanso e atividade",
            "Busque atividades ao ar livre durante o dia"
        ])
    
    return tips[:5]  # Limitar a 5 dicas

def _get_voice_analysis_fallback(stress_indicators, energy_indicators, stability_indicators, detected_mood):
    """Resposta de fallback para análise de voz quando Gemma não está disponível"""
    # Calcular métricas básicas
    final_stress = min(max(stress_indicators, 0.0), 1.0)
    final_energy = min(max(energy_indicators, 0.0), 1.0)
    final_stability = min(max(stability_indicators, 0.0), 1.0)
    
    # Mapear humor
    mood_mapping = {
        'stressed': 'estressado',
        'tired': 'cansado', 
        'calm': 'calmo',
        'energetic': 'energético',
        'neutral': 'neutro'
    }
    final_mood = mood_mapping.get(detected_mood, 'neutro')
    
    # Gerar recomendações básicas
    basic_recommendations = [
        "Pratique respiração profunda por alguns minutos",
        "Mantenha conexões sociais saudáveis",
        "Estabeleça uma rotina de sono regular",
        "Faça atividades físicas leves regularmente",
        "Reserve tempo para relaxamento diário"
    ]
    
    basic_tips = [
        "Cuide do seu bem-estar físico e mental",
        "Busque apoio da comunidade quando necessário",
        "Pratique atividades que lhe trazem paz",
        "Mantenha uma alimentação saudável"
    ]
    
    return {
        'success': True,
        'analysis': {
            'stress_level': final_stress,
            'energy_level': final_energy,
            'emotional_stability': final_stability,
            'mood_state': final_mood,
            'confidence': 0.75,
            'gemma_analysis': 'Análise básica realizada. Para uma avaliação mais detalhada, o serviço Gemma-3 precisa estar disponível.'
        },
        'recommendations': basic_recommendations,
        'wellness_tips': basic_tips,
        'fallback': True,
        'timestamp': datetime.now().isoformat()
    }

def _prepare_wellness_content_context(prompt, content_type, duration, difficulty, language):
    """Preparar contexto para geração de conteúdo de bem-estar com Gemma-3"""
    context_map = {
        'breathing': f"Como especialista em bem-estar, crie um exercício de respiração de {duration} minutos para nível {difficulty}. Solicitação: {prompt}",
        'meditation': f"Como guia de meditação, crie uma sessão de meditação de {duration} minutos para nível {difficulty}. Solicitação: {prompt}",
        'relaxation': f"Como terapeuta de relaxamento, crie um exercício de relaxamento de {duration} minutos para nível {difficulty}. Solicitação: {prompt}",
        'mindfulness': f"Como instrutor de mindfulness, crie uma prática de atenção plena de {duration} minutos para nível {difficulty}. Solicitação: {prompt}"
    }
    
    base_context = context_map.get(content_type, context_map['breathing'])
    
    if language == 'crioulo':
        base_context += " Responda em crioulo da Guiné-Bissau quando possível."
    elif language == 'ambos':
        base_context += " Forneça instruções em português e crioulo da Guiné-Bissau."
    else:
        base_context += " Responda em português claro e simples."
    
    base_context += " Inclua instruções passo a passo, benefícios e dicas práticas. Adapte para o contexto cultural da Guiné-Bissau."
    
    return base_context

def _process_wellness_content_response(gemma_response, content_type, duration):
    """Processar resposta do Gemma-3 para conteúdo de bem-estar"""
    # Extrair instruções da resposta
    lines = gemma_response.split('\n')
    instructions = []
    tips = []
    benefits = []
    
    current_section = 'content'
    content = ''
    
    for line in lines:
        line = line.strip()
        if not line:
            continue
            
        # Identificar seções
        if 'instruções' in line.lower() or 'passos' in line.lower():
            current_section = 'instructions'
            continue
        elif 'dicas' in line.lower() or 'tips' in line.lower():
            current_section = 'tips'
            continue
        elif 'benefícios' in line.lower() or 'benefits' in line.lower():
            current_section = 'benefits'
            continue
        
        # Adicionar conteúdo à seção apropriada
        if current_section == 'instructions' and (line.startswith(('-', '•', '1.', '2.', '3.')) or line[0].isdigit()):
            instructions.append(line.lstrip('-•0123456789. '))
        elif current_section == 'tips' and (line.startswith(('-', '•', '1.', '2.', '3.')) or line[0].isdigit()):
            tips.append(line.lstrip('-•0123456789. '))
        elif current_section == 'benefits' and (line.startswith(('-', '•', '1.', '2.', '3.')) or line[0].isdigit()):
            benefits.append(line.lstrip('-•0123456789. '))
        else:
            content += line + ' '
    
    # Se não conseguiu extrair instruções, criar algumas básicas
    if not instructions:
        instructions = _get_default_instructions(content_type, duration)
    
    return {
        'content': content.strip() or _get_default_content(content_type, duration),
        'instructions': instructions,
        'tips': tips or _get_default_tips(content_type),
        'benefits': benefits or _get_default_benefits(content_type)
    }

def _generate_guided_session_with_gemma_audio(gemma_service, session_type, duration_minutes, language, personalized_prompt):
    """
    Gerar sessão de meditação usando Gemma-3n para criar instruções de áudio estruturadas
    NOTA: Ollama ainda não suporta capacidades multimodais completas do Gemma-3n,
    então geramos instruções estruturadas para síntese de áudio
    """
    try:
        # Prompt especializado para geração de instruções de áudio estruturadas
        audio_prompt = f"""
        Você é um especialista em meditação e bem-estar usando o modelo Gemma-3n.
        
        Crie uma sessão detalhada de {session_type} de {duration_minutes} minutos em {language}.
        {f'Contexto personalizado: {personalized_prompt}' if personalized_prompt else ''}
        
        IMPORTANTE: Gere instruções estruturadas para síntese de áudio com:
        1. Texto narrativo completo para conversão em áudio
        2. Orientações passo-a-passo detalhadas
        3. Indicações de tom de voz e pausas
        4. Sinais sonoros descritos textualmente
        
        Estruture a resposta EXATAMENTE neste formato JSON:
        {{
            "session_id": "gemma3n_{session_type}_{duration_minutes}min",
            "instructions": {{
                "introduction": "Bem-vindos a esta sessão de {session_type}. Encontre uma posição confortável...",
                "preparation": "Vamos começar preparando nosso corpo e mente...",
                "main_content": "Agora vamos iniciar o exercício principal...",
                "conclusion": "Chegamos ao final desta sessão..."
            }},
            "audio_content": {{
                "has_structured_audio": true,
                "narration_text": "Texto completo para narração contínua",
                "breathing_cues": ["Inspire profundamente", "Segure o ar", "Expire lentamente"],
                "voice_instructions": "Voz calma, pausas de 2 segundos entre frases",
                "background_sounds": "Sons da natureza suaves"
            }},
            "pattern": {{
                "name": "Respiração {session_type}",
                "inhale_seconds": 4,
                "hold_seconds": 4,
                "exhale_seconds": 6,
                "cycles": {max(5, duration_minutes * 2)}
            }},
            "timing": {{
                "introduction_duration": 60,
                "main_duration": {(duration_minutes - 2) * 60},
                "conclusion_duration": 60
            }}
        }}
        
        Adapte para o contexto cultural da Guiné-Bissau e use linguagem acolhedora.
        """
        
        # Gerar com Gemma-3n
        response = gemma_service.generate_response(
            audio_prompt,
            SystemPrompts.WELLNESS,
            temperature=0.6,
            max_new_tokens=1200
        )
        
        if response.get('success'):
            # Processar resposta do Gemma-3n
            response_text = response.get('response', '')
            session_data = _parse_gemma_structured_audio_response(response_text, session_type, duration_minutes)
            
            # Marcar como gerado pelo Gemma-3n
            session_data['generated_by'] = 'gemma3n'
            session_data['audio_content']['has_audio'] = True  # Áudio será sintetizado
            session_data['audio_content']['use_tts'] = True
            
            logger.info("✅ Gemma-3n gerou instruções estruturadas para síntese de áudio")
            return session_data
        else:
            logger.warning("❌ Falha na geração com Gemma-3n, usando fallback")
            return _generate_guided_session_with_text(gemma_service, session_type, duration_minutes, language, personalized_prompt)
            
    except Exception as e:
        logger.error(f"Erro na geração com Gemma-3n: {e}")
        return _generate_guided_session_with_text(gemma_service, session_type, duration_minutes, language, personalized_prompt)

def _generate_guided_session_with_text(gemma_service, session_type, duration_minutes, language, personalized_prompt):
    """
    Gerar sessão de meditação com texto do Gemma-3n para usar com TTS
    """
    try:
        # Prompt para geração de texto estruturado
        text_prompt = f"""
        Você é um especialista em meditação e bem-estar.
        
        Crie uma sessão de {session_type} de {duration_minutes} minutos em {language}.
        {f'Contexto personalizado: {personalized_prompt}' if personalized_prompt else ''}
        
        Forneça instruções detalhadas que serão narradas por TTS:
        1. Introdução acolhedora (30-40 palavras)
        2. Preparação e posicionamento (20-30 palavras)
        3. Instruções passo-a-passo para a sessão
        4. Conclusão motivadora (30-40 palavras)
        
        Inclua também um padrão de respiração apropriado.
        
        Responda em JSON estruturado.
        """
        
        if gemma_service:
            response = gemma_service.generate_response(
                text_prompt,
                SystemPrompts.WELLNESS,
                temperature=0.7,
                max_new_tokens=600
            )
            
            if response.get('success'):
                response_text = response.get('response', '')
                session_data = _parse_gemma_text_response(response_text, session_type, duration_minutes)
            else:
                session_data = _get_fallback_session_data(session_type, duration_minutes, language)
        else:
            session_data = _get_fallback_session_data(session_type, duration_minutes, language)
        
        # Marcar que deve usar TTS
        session_data['audio_content'] = {
            'has_audio': False,
            'use_tts': True,
            'fallback_text': session_data['instructions']['introduction'] + ' ' + 
                           session_data['instructions']['preparation'] + ' ' +
                           session_data['instructions']['conclusion']
        }
        
        return session_data
        
    except Exception as e:
        logger.error(f"Erro na geração com texto: {e}")
        return _get_fallback_session_data(session_type, duration_minutes, language)

def _parse_gemma_structured_audio_response(response_text, session_type, duration_minutes):
    """
    Processar resposta do Gemma-3n com instruções estruturadas para áudio
    """
    try:
        import re
        import json
        
        # Tentar extrair JSON da resposta com múltiplas estratégias
        logger.info(f"🔍 Processando resposta do Gemma-3n (tamanho: {len(response_text)} chars)")
        
        # Estratégia 1: JSON completo
        json_match = re.search(r'\{.*\}', response_text, re.DOTALL)
        if json_match:
            json_text = json_match.group()
            try:
                data = json.loads(json_text)
            except json.JSONDecodeError as e:
                logger.error(f"Erro de JSON: {e}")
                # Estratégia 2: Tentar limpar o JSON
                json_text = re.sub(r',\s*\}', '}', json_text)  # Remove vírgulas antes de }
                json_text = re.sub(r',\s*\]', ']', json_text)  # Remove vírgulas antes de ]
                try:
                    data = json.loads(json_text)
                    logger.info("✅ JSON corrigido e parseado com sucesso")
                except json.JSONDecodeError as e2:
                     logger.error(f"Erro de JSON após correção: {e2}")
                     logger.info("📝 Criando estrutura a partir do texto bruto")
                     # Garantir que o texto do Gemma-3n seja usado para áudio
                     session_data = _create_enhanced_session_structure(response_text, session_type, duration_minutes)
                     session_data['generated_by'] = 'gemma3n'
                     session_data['audio_content']['generated_by_gemma3n'] = True
                     session_data['audio_content']['has_audio'] = True
                     # Usar o texto completo do Gemma-3n como narração
                     session_data['audio_content']['narration_text'] = response_text.strip()
                     logger.info(f"✅ Texto do Gemma-3n convertido para áudio (tamanho: {len(response_text)} chars)")
                     return session_data
            
            # Validar estrutura esperada
            if 'audio_content' in data and 'instructions' in data:
                # Garantir que tem os campos necessários
                if 'narration_text' not in data['audio_content']:
                    # Criar narração a partir das instruções
                    instructions = data.get('instructions', {})
                    narration_parts = []
                    
                    if 'introduction' in instructions:
                        narration_parts.append(instructions['introduction'])
                    if 'preparation' in instructions:
                        narration_parts.append(instructions['preparation'])
                    if 'main_content' in instructions:
                        narration_parts.append(instructions['main_content'])
                    if 'conclusion' in instructions:
                        narration_parts.append(instructions['conclusion'])
                    
                    data['audio_content']['narration_text'] = ' ... '.join(narration_parts)
                
                # Garantir campos de áudio
                data['audio_content']['has_structured_audio'] = True
                data['audio_content']['generated_by_gemma3n'] = True
                
                logger.info("✅ JSON estruturado extraído com sucesso do Gemma-3n")
                return data
            else:
                logger.warning("⚠️ JSON não tem estrutura esperada, criando estrutura básica")
                return _create_enhanced_session_structure(response_text, session_type, duration_minutes)
        else:
            # Se não conseguir extrair JSON, criar estrutura a partir do texto
            logger.info("📝 Criando estrutura a partir do texto do Gemma-3n")
            return _create_enhanced_session_structure(response_text, session_type, duration_minutes)
            
    except json.JSONDecodeError as e:
        logger.error(f"Erro de JSON: {e}")
        return _create_enhanced_session_structure(response_text, session_type, duration_minutes)
    except Exception as e:
        logger.error(f"Erro ao processar resposta estruturada: {e}")
        return _create_enhanced_session_structure(response_text, session_type, duration_minutes)

def _parse_gemma_audio_response(response_text, session_type, duration_minutes):
    """
    Processar resposta do Gemma-3n com capacidades de áudio (função legada)
    """
    # Redirecionar para a nova função
    return _parse_gemma_structured_audio_response(response_text, session_type, duration_minutes)

def _parse_gemma_text_response(response_text, session_type, duration_minutes):
    """
    Processar resposta de texto do Gemma-3n
    """
    try:
        import re
        import json
        
        # Tentar extrair JSON da resposta
        json_match = re.search(r'\{.*\}', response_text, re.DOTALL)
        if json_match:
            data = json.loads(json_match.group())
            return data
        else:
            # Criar estrutura a partir do texto
            return _create_basic_session_structure(response_text, session_type, duration_minutes, has_audio=False)
            
    except Exception as e:
        logger.error(f"Erro ao processar resposta de texto: {e}")
        return _create_basic_session_structure(response_text, session_type, duration_minutes, has_audio=False)

def _create_enhanced_session_structure(response_text, session_type, duration_minutes):
    """
    Criar estrutura melhorada de sessão usando o texto do Gemma-3n
    """
    import uuid
    import re
    
    # Extrair partes do texto do Gemma-3n
    text_parts = response_text.split('\n') if response_text else []
    clean_lines = [line.strip() for line in text_parts if line.strip()]
    
    # Tentar identificar seções no texto
    introduction = "Bem-vindo a esta sessão especial de bem-estar."
    preparation = "Vamos preparar nosso corpo e mente para esta experiência."
    main_content = f"Agora vamos praticar {session_type} por {duration_minutes} minutos."
    conclusion = "Parabéns por dedicar este tempo ao seu bem-estar."
    
    # Usar o texto do Gemma-3n se disponível
    if response_text and len(response_text) > 50:
        # Usar o texto completo como narração principal
        main_narration = response_text.strip()
        
        # Dividir o texto em partes para estrutura
        text_length = len(response_text)
        if text_length > 200:
            quarter = text_length // 4
            introduction = response_text[:quarter].strip()
            preparation = response_text[quarter:quarter*2].strip()
            main_content = response_text[quarter*2:quarter*3].strip()
            conclusion = response_text[quarter*3:].strip()
        else:
            main_content = response_text
    
    # Criar narração completa usando o texto do Gemma-3n
    if response_text and len(response_text) > 50:
        # Usar o texto completo do Gemma-3n como narração principal
        narration_text = main_narration
    else:
        # Fallback para estrutura por partes
        narration_text = f"{introduction} ... {preparation} ... {main_content} ... {conclusion}"
    
    return {
        'session_id': f"gemma3n_enhanced_{session_type}_{str(uuid.uuid4())[:8]}",
        'generated_by': 'gemma3n',
        'instructions': {
            'introduction': introduction,
            'preparation': preparation,
            'main_content': main_content,
            'conclusion': conclusion
        },
        'audio_content': {
            'has_audio': True,
            'use_tts': True,
            'has_structured_audio': True,
            'generated_by_gemma3n': True,
            'narration_text': narration_text,
            'breathing_cues': [
                "Inspire profundamente pelo nariz",
                "Segure o ar suavemente", 
                "Expire lentamente pela boca"
            ],
            'voice_instructions': "Voz calma e acolhedora, pausas naturais",
            'background_sounds': "Sons suaves da natureza"
        },
        'pattern': {
            'name': f"Respiração {session_type} - Gemma-3n",
            'inhale_seconds': 4,
            'hold_seconds': 4,
            'exhale_seconds': 6,
            'cycles': max(5, duration_minutes * 2)
        },
        'timing': {
            'introduction_duration': 60,
            'main_duration': (duration_minutes - 2) * 60,
            'conclusion_duration': 60
        }
    }

def _create_basic_session_structure(response_text, session_type, duration_minutes, has_audio=False):
    """
    Criar estrutura básica de sessão a partir do texto (função legada)
    """
    # Redirecionar para a função melhorada
    return _create_enhanced_session_structure(response_text, session_type, duration_minutes)

def _get_fallback_session_data(session_type, duration_minutes, language):
    """
    Dados de fallback quando Gemma-3n não está disponível
    """
    fallback_data = {
        'breathing': {
            'introduction': 'Bem-vindo à sua sessão de respiração guiada. Vamos encontrar calma e equilíbrio juntos.',
            'preparation': 'Sente-se confortavelmente, mantenha as costas retas e relaxe os ombros.',
            'conclusion': 'Parabéns! Você completou sua sessão de respiração. Observe como se sente agora.',
            'pattern': {'name': '4-7-8 Relaxamento', 'inhale_seconds': 4, 'hold_seconds': 7, 'exhale_seconds': 8}
        },
        'meditation': {
            'introduction': f'Bem-vindo à sua sessão de meditação de {duration_minutes} minutos. Vamos cultivar paz interior.',
            'preparation': 'Encontre uma posição confortável, feche os olhos suavemente e respire naturalmente.',
            'conclusion': 'Sua sessão de meditação está completa. Carregue essa paz consigo.',
            'pattern': {'name': 'Respiração Natural', 'inhale_seconds': 4, 'hold_seconds': 2, 'exhale_seconds': 6}
        },
        'relaxation': {
            'introduction': f'Hora de relaxar profundamente. Esta sessão de {duration_minutes} minutos é para você.',
            'preparation': 'Deite-se ou sente-se confortavelmente, solte toda a tensão do corpo.',
            'conclusion': 'Você está completamente relaxado. Mantenha essa sensação de paz.',
            'pattern': {'name': 'Respiração Calmante', 'inhale_seconds': 3, 'hold_seconds': 2, 'exhale_seconds': 6}
        }
    }
    
    data = fallback_data.get(session_type, fallback_data['breathing'])
    
    return {
        'session_id': f"{session_type}_fallback_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
        'instructions': {
            'introduction': data['introduction'],
            'preparation': data['preparation'],
            'conclusion': data['conclusion']
        },
        'audio_content': {
            'has_audio': False,
            'use_tts': True,
            'fallback_text': f"{data['introduction']} {data['preparation']} {data['conclusion']}"
        },
        'pattern': data['pattern']
    }

def _get_wellness_content_fallback(content_type, duration, difficulty, language):
    """Obter conteúdo de fallback quando Gemma-3 não está disponível"""
    content_templates = {
        'breathing': {
            'content': f"Exercício de respiração de {duration} minutos para relaxamento e redução do estresse. Esta prática ajuda a acalmar a mente e o corpo.",
            'instructions': [
                "Sente-se confortavelmente com as costas retas",
                "Feche os olhos suavemente",
                "Respire pelo nariz contando até 4",
                "Segure a respiração contando até 4",
                "Expire pela boca contando até 6",
                "Repita este ciclo durante todo o exercício",
                "Termine respirando naturalmente por alguns momentos"
            ],
            'tips': [
                "Pratique em um local silencioso",
                "Use roupas confortáveis",
                "Não force a respiração",
                "Se sentir tontura, respire normalmente"
            ],
            'benefits': [
                "Reduz o estresse e ansiedade",
                "Melhora a concentração",
                "Promove relaxamento",
                "Ajuda a regular as emoções"
            ]
        },
        'meditation': {
            'content': f"Sessão de meditação de {duration} minutos para cultivar paz interior e clareza mental.",
            'instructions': [
                "Encontre uma posição confortável",
                "Feche os olhos ou mantenha o olhar suave",
                "Concentre-se na sua respiração natural",
                "Quando a mente divagar, gentilmente retorne à respiração",
                "Observe pensamentos sem julgamento",
                "Mantenha uma atitude de aceitação",
                "Termine gradualmente voltando à consciência do ambiente"
            ],
            'tips': [
                "Comece com sessões curtas",
                "Seja paciente consigo mesmo",
                "Pratique regularmente",
                "Não há meditação 'errada'"
            ],
            'benefits': [
                "Aumenta a autoconsciência",
                "Reduz pensamentos negativos",
                "Melhora o foco",
                "Promove bem-estar emocional"
            ]
        }
    }
    
    return content_templates.get(content_type, content_templates['breathing'])

def _get_default_instructions(content_type, duration):
    """Obter instruções padrão por tipo de conteúdo"""
    defaults = {
        'breathing': [
            "Sente-se confortavelmente",
            "Respire profundamente pelo nariz",
            "Expire lentamente pela boca",
            "Repita por {} minutos".format(duration)
        ],
        'meditation': [
            "Encontre uma posição confortável",
            "Feche os olhos",
            "Concentre-se na respiração",
            "Medite por {} minutos".format(duration)
        ]
    }
    return defaults.get(content_type, defaults['breathing'])

def _get_default_content(content_type, duration):
    """Obter conteúdo padrão por tipo"""
    defaults = {
        'breathing': f"Exercício de respiração de {duration} minutos para relaxamento.",
        'meditation': f"Sessão de meditação de {duration} minutos para paz interior."
    }
    return defaults.get(content_type, defaults['breathing'])

def _get_default_tips(content_type):
    """Obter dicas padrão por tipo de conteúdo"""
    defaults = {
        'breathing': ["Pratique em local silencioso", "Não force a respiração"],
        'meditation': ["Seja paciente consigo mesmo", "Pratique regularmente"]
    }
    return defaults.get(content_type, defaults['breathing'])

def _get_default_benefits(content_type):
    """Obter benefícios padrão por tipo de conteúdo"""
    defaults = {
        'breathing': ["Reduz estresse", "Melhora concentração"],
        'meditation': ["Aumenta autoconsciência", "Promove bem-estar"]
    }
    return defaults.get(content_type, defaults['breathing'])

# ================= FUNÇÕES AUXILIARES PARA ANÁLISE DE HUMOR =================

def _parse_mood_analysis_response(response_text):
    """Parsear resposta estruturada da análise de humor do Gemma-3"""
    analysis = {}
    
    # Patterns para extrair seções
    patterns = {
        'insights': re.compile(r'(?:1\.|INSIGHTS:?)([\s\S]*?)(?=(?:2\.|RECOMENDAÇÕES|TÉCNICAS|EXERCÍCIOS|\Z))', re.IGNORECASE),
        'recommendations': re.compile(r'(?:2\.|RECOMENDAÇÕES:?)([\s\S]*?)(?=(?:3\.|TÉCNICAS|EXERCÍCIOS|\Z))', re.IGNORECASE),
        'coping_techniques': re.compile(r'(?:3\.|TÉCNICAS:?)([\s\S]*?)(?=(?:4\.|EXERCÍCIOS|\Z))', re.IGNORECASE),
        'exercises': re.compile(r'(?:4\.|EXERCÍCIOS:?)([\s\S]*?)\Z', re.IGNORECASE),
    }
    
    for key, pattern in patterns.items():
        match = pattern.search(response_text)
        if match:
            analysis[key] = match.group(1).strip()
    
    # Fallback se não conseguir parsear
    if not analysis:
        analysis['insights'] = response_text
    
    return analysis

def _get_mood_analysis_fallback(mood, intensity, description, language):
    """Obter análise de humor de fallback quando Gemma-3 não está disponível"""
    
    # Templates de análise baseados no humor
    mood_templates = {
        'happy': {
            'insights': 'Você está experimentando um estado emocional positivo, o que é excelente para seu bem-estar geral. A felicidade contribui para melhor saúde física e mental, fortalece relacionamentos e aumenta a resiliência.',
            'recommendations': '• Compartilhe sua alegria com pessoas queridas\n• Pratique gratidão diariamente\n• Mantenha atividades que lhe trazem prazer\n• Use este momento positivo para estabelecer metas',
            'coping_techniques': '• Técnica do diário de gratidão\n• Meditação da bondade amorosa\n• Exercícios de visualização positiva',
            'exercises': '• Caminhada ao ar livre\n• Dança ou movimento livre\n• Respiração energizante (4-4-4)\n• Meditação de alegria'
        },
        'sad': {
            'insights': 'A tristeza é uma emoção natural e importante que nos ajuda a processar perdas e mudanças. É importante permitir-se sentir essa emoção enquanto busca apoio e estratégias saudáveis de enfrentamento.',
            'recommendations': '• Busque apoio de familiares e amigos\n• Mantenha rotinas básicas de autocuidado\n• Pratique atividades que antes lhe davam prazer\n• Considere conversar com um conselheiro',
            'coping_techniques': '• Técnica de aceitação emocional\n• Journaling expressivo\n• Mindfulness para emoções difíceis',
            'exercises': '• Respiração calmante (4-7-8)\n• Meditação de autocompaixão\n• Caminhada leve na natureza\n• Alongamentos suaves'
        },
        'anxious': {
            'insights': 'A ansiedade pode ser uma resposta natural a situações desafiadoras, mas quando intensa pode interferir no bem-estar. É importante desenvolver estratégias para gerenciar esses sentimentos e reduzir sua intensidade.',
            'recommendations': '• Pratique técnicas de relaxamento regularmente\n• Identifique e questione pensamentos ansiosos\n• Mantenha uma rotina estruturada\n• Limite exposição a fatores estressantes',
            'coping_techniques': '• Técnica de grounding 5-4-3-2-1\n• Respiração diafragmática\n• Reestruturação cognitiva\n• Relaxamento muscular progressivo',
            'exercises': '• Respiração quadrada (4-4-4-4)\n• Meditação mindfulness\n• Yoga suave\n• Exercícios de relaxamento'
        },
        'angry': {
            'insights': 'A raiva pode ser uma emoção válida que sinaliza necessidades não atendidas ou injustiças percebidas. O importante é aprender a expressá-la de forma saudável e construtiva.',
            'recommendations': '• Identifique os gatilhos da raiva\n• Pratique técnicas de autorregulação\n• Comunique-se de forma assertiva\n• Busque soluções construtivas para conflitos',
            'coping_techniques': '• Técnica de pausa e respiração\n• Contagem regressiva\n• Exercício físico para liberar tensão\n• Comunicação não-violenta',
            'exercises': '• Respiração de resfriamento\n• Exercícios físicos intensos\n• Meditação de perdão\n• Caminhada rápida'
        }
    }
    
    # Obter template baseado no humor ou usar neutro como fallback
    template = mood_templates.get(mood, {
        'insights': 'Você está passando por um momento de reflexão emocional. É importante reconhecer e validar seus sentimentos enquanto busca estratégias saudáveis de bem-estar.',
        'recommendations': '• Pratique autocompaixão\n• Mantenha conexões sociais saudáveis\n• Estabeleça rotinas de autocuidado\n• Busque atividades prazerosas',
        'coping_techniques': '• Mindfulness\n• Respiração consciente\n• Journaling\n• Técnicas de relaxamento',
        'exercises': '• Respiração natural\n• Meditação básica\n• Caminhada tranquila\n• Alongamentos'
    })
    
    # Ajustar baseado na intensidade
    if intensity >= 8:
        template['insights'] += ' A alta intensidade deste sentimento sugere que pode ser benéfico buscar apoio adicional ou técnicas mais intensivas de manejo emocional.'
        template['recommendations'] += '\n• Considere buscar apoio profissional\n• Pratique técnicas intensivas de relaxamento'
    
    # Adaptar para idioma
    if language == 'crioulo':
        template['insights'] += ' (Na nha kultura, nos konxi ku emosion i natural i importante pa nos bem-estar.)'
    
    return template

def _calculate_mood_score(mood, intensity):
    """Calcular pontuação do humor (1-100)"""
    # Mapeamento base de humor para pontuação
    mood_base_scores = {
        'happy': 85,
        'motivated': 80,
        'calm': 75,
        'neutral': 60,
        'tired': 45,
        'sad': 35,
        'anxious': 30,
        'angry': 25
    }
    
    base_score = mood_base_scores.get(mood, 50)
    
    # Ajustar baseado na intensidade
    if mood in ['happy', 'motivated', 'calm']:
        # Para humores positivos, maior intensidade = maior pontuação
        score = base_score + (intensity - 5) * 3
    else:
        # Para humores negativos, maior intensidade = menor pontuação
        score = base_score - (intensity - 5) * 3
    
    # Garantir que a pontuação esteja entre 1 e 100
    return max(1, min(100, int(score)))

def _assess_risk_level(mood, intensity, description):
    """Avaliar nível de risco psicológico"""
    # Palavras-chave de alto risco
    high_risk_keywords = [
        'suicídio', 'morrer', 'acabar', 'desistir', 'sem esperança',
        'não aguento', 'sem saída', 'inútil', 'sozinho', 'abandonado'
    ]
    
    # Verificar palavras de alto risco na descrição
    if description and any(keyword in description.lower() for keyword in high_risk_keywords):
        return 'high'
    
    # Avaliar baseado no humor e intensidade
    if mood in ['sad', 'anxious', 'angry'] and intensity >= 8:
        return 'high'
    elif mood in ['sad', 'anxious', 'angry'] and intensity >= 6:
        return 'medium'
    elif mood == 'tired' and intensity >= 8:
        return 'medium'
    else:
        return 'low'