#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Rotas Médicas - Bu Fala Backend
Hackathon Gemma 3n

Especializado em primeiros socorros e cuidados básicos de saúde
para comunidades rurais da Guiné-Bissau.
"""

import logging
from flask import Blueprint, request, jsonify, current_app
from datetime import datetime
from config.settings import SystemPrompts
from utils.error_handler import create_error_response, log_error

# Criar blueprint
medical_bp = Blueprint('medical', __name__)
logger = logging.getLogger(__name__)

@medical_bp.route('/medical', methods=['POST'])
def medical_consultation():
    """
    Consulta médica básica e primeiros socorros
    ---
    tags:
      - Medicina
    summary: Consulta médica e primeiros socorros
    description: |
      Endpoint para consultas médicas básicas e orientações de primeiros socorros.
      Especializado em cuidados de saúde para comunidades rurais da Guiné-Bissau.
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
              description: Pergunta ou descrição dos sintomas
              example: "Minha criança está com febre alta, o que devo fazer?"
            symptoms:
              type: array
              items:
                type: string
              description: Lista de sintomas observados
              example: ["febre", "dor de cabeça", "vômito"]
            urgency:
              type: string
              enum: ["low", "normal", "high", "emergency"]
              description: Nível de urgência da situação
              example: "high"
            patient_age:
              type: integer
              description: Idade do paciente
              example: 5
            patient_gender:
              type: string
              enum: ["masculino", "feminino", "outro"]
              description: Gênero do paciente
              example: "feminino"
    responses:
      200:
        description: Consulta realizada com sucesso
        schema:
          type: object
          properties:
            success:
              type: boolean
              example: true
            message:
              type: string
              example: "Consulta médica realizada"
            data:
              type: object
              properties:
                response:
                  type: string
                  description: Orientação médica gerada
                urgency_level:
                  type: string
                  description: Nível de urgência avaliado
                recommendations:
                  type: array
                  items:
                    type: string
                  description: Recomendações específicas
                seek_immediate_help:
                  type: boolean
                  description: Se deve procurar ajuda médica imediatamente
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
        
        # Obter parâmetros opcionais
        symptoms = data.get('symptoms', [])
        urgency = data.get('urgency', 'normal')  # low, normal, high, emergency
        patient_age = data.get('patient_age')
        patient_gender = data.get('patient_gender')
        
        # Preparar contexto médico
        medical_context = _prepare_medical_context(prompt, symptoms, urgency, patient_age, patient_gender)
        
        # Obter serviço Gemma
        gemma_service = getattr(current_app, 'gemma_service', None)
        
        if gemma_service:
            # Gerar resposta usando Gemma
            response = gemma_service.generate_response(
                medical_context,
                SystemPrompts.MEDICAL,
                temperature=0.3,  # Baixa temperatura para respostas mais precisas
                max_new_tokens=400
            )
            
            # Adicionar informações médicas específicas
            if response.get('success'):
                response['medical_info'] = {
                    'urgency_level': urgency,
                    'recommendation': _get_urgency_recommendation(urgency),
                    'disclaimer': "Esta orientação não substitui consulta médica profissional. Em emergências, procure imediatamente o centro de saúde mais próximo."
                }
        else:
            # Resposta de fallback
            response = _get_medical_fallback_response(prompt, urgency)
        
        return jsonify({
            'success': True,
            'data': response,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "consulta médica")
        return jsonify(create_error_response(
            'medical_error',
            'Erro ao processar consulta médica',
            500
        )), 500

@medical_bp.route('/medical/emergency', methods=['POST'])
def emergency_guidance():
    """Orientações para emergências médicas"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        emergency_type = data.get('emergency_type')
        description = data.get('description', '')
        
        if not emergency_type:
            return jsonify(create_error_response(
                'missing_emergency_type',
                'Campo "emergency_type" é obrigatório',
                400
            )), 400
        
        # Obter orientações de emergência
        emergency_guidance = _get_emergency_guidance(emergency_type, description)
        
        return jsonify({
            'success': True,
            'data': {
                'emergency_type': emergency_type,
                'guidance': emergency_guidance,
                'priority': 'ALTA',
                'disclaimer': "EMERGÊNCIA: Procure imediatamente ajuda médica profissional. Estas são orientações básicas apenas."
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "orientação de emergência")
        return jsonify(create_error_response(
            'emergency_error',
            'Erro ao processar orientação de emergência',
            500
        )), 500

@medical_bp.route('/medical/first-aid', methods=['POST'])
def first_aid_guide():
    """Guia de primeiros socorros"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        situation = data.get('situation')
        if not situation:
            return jsonify(create_error_response(
                'missing_situation',
                'Campo "situation" é obrigatório',
                400
            )), 400
        
        # Obter guia de primeiros socorros
        first_aid_steps = _get_first_aid_steps(situation)
        
        return jsonify({
            'success': True,
            'data': {
                'situation': situation,
                'steps': first_aid_steps,
                'important_notes': [
                    "Mantenha a calma",
                    "Avalie a segurança do local",
                    "Chame ajuda médica se necessário",
                    "Não mova a vítima se suspeitar de lesão na coluna"
                ],
                'disclaimer': "Estas são orientações básicas de primeiros socorros. Procure treinamento adequado."
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "guia de primeiros socorros")
        return jsonify(create_error_response(
            'first_aid_error',
            'Erro ao processar guia de primeiros socorros',
            500
        )), 500

def _prepare_medical_context(prompt, symptoms, urgency, age, gender):
    """Preparar contexto médico para a consulta"""
    context = f"Consulta médica: {prompt}"
    
    if symptoms:
        context += f"\nSintomas relatados: {', '.join(symptoms)}"
    
    if age:
        context += f"\nIdade do paciente: {age} anos"
    
    if gender:
        context += f"\nGênero: {gender}"
    
    context += f"\nNível de urgência: {urgency}"
    context += "\n\nPor favor, forneça orientações médicas básicas e de primeiros socorros apropriadas para esta situação, considerando o contexto de comunidades rurais da Guiné-Bissau."
    
    return context

def _get_urgency_recommendation(urgency):
    """Obter recomendação baseada no nível de urgência"""
    recommendations = {
        'low': 'Monitore os sintomas. Procure orientação médica se piorar.',
        'normal': 'Recomenda-se consulta médica para avaliação adequada.',
        'high': 'Procure atendimento médico o mais breve possível.',
        'emergency': 'EMERGÊNCIA: Procure imediatamente o centro de saúde mais próximo ou chame ajuda médica.'
    }
    return recommendations.get(urgency, recommendations['normal'])

def _get_medical_fallback_response(prompt, urgency):
    """Resposta de fallback para consultas médicas"""
    base_response = "Para questões médicas, é importante procurar um profissional de saúde qualificado."
    
    if urgency == 'emergency':
        base_response = "EMERGÊNCIA: Procure imediatamente o centro de saúde mais próximo ou chame ajuda médica."
    elif urgency == 'high':
        base_response = "Situação de alta prioridade. Procure atendimento médico o mais breve possível."
    
    return {
        'response': base_response,
        'success': True,
        'fallback': True,
        'medical_info': {
            'urgency_level': urgency,
            'recommendation': _get_urgency_recommendation(urgency),
            'disclaimer': "Esta orientação não substitui consulta médica profissional."
        }
    }

def _get_emergency_guidance(emergency_type, description):
    """Obter orientações específicas para emergências"""
    emergency_guides = {
        'breathing_difficulty': [
            "Mantenha a pessoa calma e em posição confortável",
            "Afrouxe roupas apertadas",
            "Garanta ventilação adequada",
            "Procure ajuda médica imediatamente"
        ],
        'chest_pain': [
            "Mantenha a pessoa em repouso",
            "Posição semi-sentada pode ajudar",
            "Não dê medicamentos sem orientação",
            "Chame ajuda médica urgentemente"
        ],
        'severe_bleeding': [
            "Aplique pressão direta no ferimento",
            "Eleve o membro se possível",
            "Use pano limpo ou gaze",
            "Procure ajuda médica imediatamente"
        ],
        'unconsciousness': [
            "Verifique se a pessoa respira",
            "Posicione em decúbito lateral de segurança",
            "Não dê líquidos",
            "Chame ajuda médica urgentemente"
        ],
        'burns': [
            "Resfrie com água corrente fria",
            "Não aplique gelo diretamente",
            "Não estoure bolhas",
            "Procure atendimento médico"
        ]
    }
    
    return emergency_guides.get(emergency_type, [
        "Mantenha a calma",
        "Avalie a situação",
        "Garanta a segurança",
        "Procure ajuda médica imediatamente"
    ])

def _get_first_aid_steps(situation):
    """Obter passos de primeiros socorros para situações específicas"""
    first_aid_guides = {
        'cut': [
            "Lave as mãos antes de ajudar",
            "Pare o sangramento com pressão direta",
            "Limpe o ferimento com água limpa",
            "Aplique curativo limpo",
            "Procure ajuda se o corte for profundo"
        ],
        'burn': [
            "Resfrie imediatamente com água corrente",
            "Continue por 10-20 minutos",
            "Remova joias antes do inchaço",
            "Cubra com curativo limpo e solto",
            "Procure ajuda médica se necessário"
        ],
        'sprain': [
            "Descanse a área lesionada",
            "Aplique gelo (protegido por pano)",
            "Comprima com bandagem elástica",
            "Eleve o membro se possível",
            "Procure avaliação médica"
        ],
        'choking': [
            "Encoraje a pessoa a tossir",
            "Se não conseguir, aplique golpes nas costas",
            "Use manobra de Heimlich se treinado",
            "Chame ajuda médica se necessário"
        ]
    }
    
    return first_aid_guides.get(situation, [
        "Avalie a situação",
        "Garanta a segurança",
        "Aplique cuidados básicos",
        "Procure orientação médica"
    ])