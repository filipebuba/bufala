#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Rotas de Bem-estar - Moransa Backend
Hackathon Gemma 3n

Especializado em bem-estar mental, físico e social,
com foco em saúde comunitária e prevenção.
"""

import logging
from flask import Blueprint, request, jsonify, current_app
from datetime import datetime
from config.settings import SystemPrompts
from utils.error_handler import create_error_response, log_error

# Criar blueprint
wellness_bp = Blueprint('wellness', __name__)
logger = logging.getLogger(__name__)

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