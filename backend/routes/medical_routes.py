#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Rotas Médicas - Moransa Backend
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
        location = data.get('location', '')
        
        if not emergency_type:
            return jsonify(create_error_response(
                'missing_emergency_type',
                'Campo "emergency_type" é obrigatório',
                400
            )), 400
        
        # Preparar contexto de emergência para o Gemma
        emergency_context = _prepare_emergency_context(emergency_type, description, location)
        
        # Obter serviço Gemma
        gemma_service = getattr(current_app, 'gemma_service', None)
        
        if gemma_service:
            # Gerar resposta usando Gemma
            response = gemma_service.generate_response(
                emergency_context,
                SystemPrompts.MEDICAL,
                temperature=0.2,  # Baixa temperatura para emergências
                max_new_tokens=300
            )
            
            if response.get('success'):
                # Adicionar informações específicas de emergência
                emergency_data = {
                    'emergency_type': emergency_type,
                    'ai_guidance': response.get('response', ''),
                    'basic_steps': _get_emergency_guidance(emergency_type, description),
                    'priority': 'ALTA',
                    'warning': 'EMERGÊNCIA: Procure imediatamente ajuda médica profissional.',
                    'disclaimer': 'Esta orientação de IA não substitui atendimento médico profissional.',
                    'gemma_used': True
                }
            else:
                # Fallback se Gemma falhar
                emergency_data = _get_emergency_fallback_response(emergency_type, description)
        else:
            # Resposta de fallback se Gemma não estiver disponível
            emergency_data = _get_emergency_fallback_response(emergency_type, description)
        
        return jsonify({
            'success': True,
            'data': emergency_data,
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

def _prepare_emergency_context(emergency_type, description, location):
    """Preparar contexto específico para emergências médicas"""
    context = f"EMERGÊNCIA MÉDICA: {emergency_type}"
    
    if description:
        context += f"\nDescrição da situação: {description}"
    
    if location:
        context += f"\nLocalização: {location}"
    
    context += "\n\nPor favor, forneça orientações IMEDIATAS de primeiros socorros para esta emergência, considerando:"
    context += "\n- Comunidades rurais da Guiné-Bissau com acesso limitado a recursos médicos"
    context += "\n- Necessidade de ações rápidas e práticas"
    context += "\n- Uso de materiais básicos disponíveis localmente"
    context += "\n- Instruções claras e simples"
    context += "\n\nResposta em português, com passos numerados e claros."
    
    return context

def _get_emergency_fallback_response(emergency_type, description):
    """Resposta de fallback para emergências quando Gemma não está disponível"""
    basic_steps = _get_emergency_guidance(emergency_type, description)
    
    return {
        'emergency_type': emergency_type,
        'ai_guidance': 'Serviço de IA temporariamente indisponível. Seguindo orientações básicas de emergência.',
        'basic_steps': basic_steps,
        'priority': 'ALTA',
        'warning': 'EMERGÊNCIA: Procure imediatamente ajuda médica profissional.',
        'disclaimer': 'Estas são orientações básicas de emergência. Procure atendimento médico imediatamente.',
        'fallback': True
    }

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

# Novos endpoints específicos para emergências

@medical_bp.route('/medical/emergency/medical', methods=['POST'])
def medical_emergency():
    """Emergência médica - situações que requerem atendimento médico imediato"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        symptoms = data.get('symptoms', [])
        description = data.get('description', '')
        severity = data.get('severity', 'alta')
        
        # Preparar contexto específico para emergência médica
        context = f"EMERGÊNCIA MÉDICA GRAVE\n"
        context += f"Sintomas: {', '.join(symptoms) if symptoms else 'Não especificados'}\n"
        context += f"Descrição: {description}\n"
        context += f"Gravidade: {severity}\n\n"
        context += "Forneça orientações IMEDIATAS de primeiros socorros considerando:\n"
        context += "- Comunidade rural da Guiné-Bissau\n"
        context += "- Recursos médicos limitados\n"
        context += "- Necessidade de ação rápida\n"
        context += "- Instruções claras em português\n"
        
        # Obter serviço Gemma
        gemma_service = getattr(current_app, 'gemma_service', None)
        
        if gemma_service:
            response = gemma_service.generate_response(
                context,
                SystemPrompts.MEDICAL,
                temperature=0.1,  # Muito baixa para emergências
                max_new_tokens=400
            )
            
            if response.get('success'):
                emergency_data = {
                    'type': 'emergencia_medica',
                    'ai_guidance': response.get('response', ''),
                    'immediate_actions': [
                        "Mantenha a calma e avalie a situação",
                        "Verifique sinais vitais (respiração, pulso)",
                        "Posicione a pessoa adequadamente",
                        "Procure ajuda médica IMEDIATAMENTE"
                    ],
                    'warning': "EMERGÊNCIA MÉDICA: Tempo é crucial. Aja rapidamente.",
                    'gemma_used': True
                }
            else:
                emergency_data = _get_medical_emergency_fallback(symptoms, description)
        else:
            emergency_data = _get_medical_emergency_fallback(symptoms, description)
        
        return jsonify({
            'success': True,
            'data': emergency_data,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "emergência médica")
        return jsonify(create_error_response(
            'medical_emergency_error',
            'Erro ao processar emergência médica',
            500
        )), 500

@medical_bp.route('/medical/emergency/childbirth', methods=['POST'])
def emergency_childbirth():
    """Parto de emergência - assistência para partos em locais remotos"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        stage = data.get('stage', 'inicio')  # inicio, trabalho_parto, nascimento, pos_parto
        complications = data.get('complications', [])
        location = data.get('location', 'casa')
        
        # Preparar contexto específico para parto de emergência
        context = f"PARTO DE EMERGÊNCIA\n"
        context += f"Estágio: {stage}\n"
        context += f"Complicações: {', '.join(complications) if complications else 'Nenhuma relatada'}\n"
        context += f"Local: {location}\n\n"
        context += "Forneça orientações DETALHADAS para assistir um parto de emergência:\n"
        context += "- Em comunidade rural da Guiné-Bissau\n"
        context += "- Sem acesso imediato a hospital\n"
        context += "- Usando materiais básicos disponíveis\n"
        context += "- Instruções passo a passo em português\n"
        context += "- Foque na segurança da mãe e bebê\n"
        
        # Obter serviço Gemma
        gemma_service = getattr(current_app, 'gemma_service', None)
        
        if gemma_service:
            response = gemma_service.generate_response(
                context,
                SystemPrompts.MEDICAL,
                temperature=0.1,
                max_new_tokens=500
            )
            
            if response.get('success'):
                childbirth_data = {
                    'type': 'parto_emergencia',
                    'stage': stage,
                    'ai_guidance': response.get('response', ''),
                    'essential_steps': _get_childbirth_steps(stage),
                    'materials_needed': [
                        "Panos limpos ou toalhas",
                        "Água fervida (se possível)",
                        "Tesoura limpa (para cordão)",
                        "Barbante ou fio limpo",
                        "Cobertor para o bebê"
                    ],
                    'warning': "PARTO DE EMERGÊNCIA: Mantenha calma e higiene. Procure ajuda médica assim que possível.",
                    'gemma_used': True
                }
            else:
                childbirth_data = _get_childbirth_fallback(stage, complications)
        else:
            childbirth_data = _get_childbirth_fallback(stage, complications)
        
        return jsonify({
            'success': True,
            'data': childbirth_data,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "parto de emergência")
        return jsonify(create_error_response(
            'childbirth_emergency_error',
            'Erro ao processar parto de emergência',
            500
        )), 500

@medical_bp.route('/medical/emergency/accident', methods=['POST'])
def accident_emergency():
    """Acidente - primeiros socorros para acidentes"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        accident_type = data.get('accident_type', 'geral')
        injuries = data.get('injuries', [])
        consciousness = data.get('consciousness', 'consciente')
        location = data.get('location', '')
        
        # Preparar contexto específico para acidente
        context = f"ACIDENTE - PRIMEIROS SOCORROS\n"
        context += f"Tipo de acidente: {accident_type}\n"
        context += f"Lesões observadas: {', '.join(injuries) if injuries else 'A avaliar'}\n"
        context += f"Estado de consciência: {consciousness}\n"
        context += f"Local: {location}\n\n"
        context += "Forneça orientações IMEDIATAS de primeiros socorros para acidente:\n"
        context += "- Priorize segurança do local\n"
        context += "- Avaliação rápida da vítima\n"
        context += "- Cuidados com materiais básicos\n"
        context += "- Instruções claras em português\n"
        context += "- Quando chamar ajuda especializada\n"
        
        # Obter serviço Gemma
        gemma_service = getattr(current_app, 'gemma_service', None)
        
        if gemma_service:
            response = gemma_service.generate_response(
                context,
                SystemPrompts.MEDICAL,
                temperature=0.1,
                max_new_tokens=400
            )
            
            if response.get('success'):
                accident_data = {
                    'type': 'acidente',
                    'accident_type': accident_type,
                    'ai_guidance': response.get('response', ''),
                    'priority_actions': [
                        "1. SEGURANÇA: Avalie se o local é seguro",
                        "2. CONSCIÊNCIA: Verifique se a vítima responde",
                        "3. RESPIRAÇÃO: Confirme se está respirando",
                        "4. SANGRAMENTO: Controle hemorragias visíveis",
                        "5. AJUDA: Chame socorro médico"
                    ],
                    'warning': "ACIDENTE: Não mova a vítima se suspeitar de lesão na coluna.",
                    'gemma_used': True
                }
            else:
                accident_data = _get_accident_fallback(accident_type, injuries)
        else:
            accident_data = _get_accident_fallback(accident_type, injuries)
        
        return jsonify({
            'success': True,
            'data': accident_data,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "acidente")
        return jsonify(create_error_response(
            'accident_error',
            'Erro ao processar acidente',
            500
        )), 500

@medical_bp.route('/medical/emergency/poisoning', methods=['POST'])
def poisoning_emergency():
    """Intoxicação - casos de envenenamento ou intoxicação"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        poison_type = data.get('poison_type', 'desconhecido')
        symptoms = data.get('symptoms', [])
        time_since_exposure = data.get('time_since_exposure', 'desconhecido')
        amount = data.get('amount', 'desconhecido')
        
        # Preparar contexto específico para intoxicação
        context = f"INTOXICAÇÃO/ENVENENAMENTO\n"
        context += f"Tipo de substância: {poison_type}\n"
        context += f"Sintomas: {', '.join(symptoms) if symptoms else 'A observar'}\n"
        context += f"Tempo desde exposição: {time_since_exposure}\n"
        context += f"Quantidade: {amount}\n\n"
        context += "Forneça orientações URGENTES para intoxicação:\n"
        context += "- Ações imediatas de segurança\n"
        context += "- O que fazer e NÃO fazer\n"
        context += "- Quando induzir ou não o vômito\n"
        context += "- Cuidados básicos disponíveis\n"
        context += "- Instruções claras em português\n"
        
        # Obter serviço Gemma
        gemma_service = getattr(current_app, 'gemma_service', None)
        
        if gemma_service:
            response = gemma_service.generate_response(
                context,
                SystemPrompts.MEDICAL,
                temperature=0.1,
                max_new_tokens=400
            )
            
            if response.get('success'):
                poisoning_data = {
                    'type': 'intoxicacao',
                    'poison_type': poison_type,
                    'ai_guidance': response.get('response', ''),
                    'immediate_actions': [
                        "Remova a pessoa da fonte de exposição",
                        "Verifique sinais vitais",
                        "NÃO induza vômito sem orientação",
                        "Se consciente, dê água (se orientado)",
                        "Chame ajuda médica URGENTEMENTE"
                    ],
                    'do_not_do': [
                        "Não induza vômito se a pessoa engoliu produtos corrosivos",
                        "Não dê leite ou óleo",
                        "Não deixe a pessoa sozinha",
                        "Não espere os sintomas piorarem"
                    ],
                    'warning': "INTOXICAÇÃO: Tempo é crucial. Contate centro de intoxicações se disponível.",
                    'gemma_used': True
                }
            else:
                poisoning_data = _get_poisoning_fallback(poison_type, symptoms)
        else:
            poisoning_data = _get_poisoning_fallback(poison_type, symptoms)
        
        return jsonify({
            'success': True,
            'data': poisoning_data,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "intoxicação")
        return jsonify(create_error_response(
            'poisoning_error',
            'Erro ao processar intoxicação',
            500
        )), 500

# Funções auxiliares para os novos endpoints

def _get_medical_emergency_fallback(symptoms, description):
    """Resposta de fallback para emergência médica"""
    return {
        'type': 'emergencia_medica',
        'ai_guidance': 'Serviço de IA temporariamente indisponível. Seguindo protocolo básico de emergência médica.',
        'immediate_actions': [
            "Mantenha a calma e avalie a situação",
            "Verifique sinais vitais (respiração, pulso)",
            "Posicione a pessoa adequadamente",
            "Procure ajuda médica IMEDIATAMENTE"
        ],
        'warning': "EMERGÊNCIA MÉDICA: Tempo é crucial. Aja rapidamente.",
        'fallback': True
    }

def _get_childbirth_steps(stage):
    """Passos específicos para cada estágio do parto"""
    steps = {
        'inicio': [
            "Mantenha a calma e tranquilize a mãe",
            "Prepare um local limpo e confortável",
            "Lave bem as mãos",
            "Reúna materiais limpos (toalhas, água)",
            "Monitore as contrações"
        ],
        'trabalho_parto': [
            "Ajude a mãe a encontrar posição confortável",
            "Encoraje respiração profunda e calma",
            "Não force o processo",
            "Prepare-se para o nascimento",
            "Mantenha higiene rigorosa"
        ],
        'nascimento': [
            "Apoie a cabeça do bebê gentilmente",
            "Deixe o bebê sair naturalmente",
            "Limpe boca e nariz do bebê",
            "Estimule a respiração se necessário",
            "Mantenha o bebê aquecido"
        ],
        'pos_parto': [
            "Aguarde a placenta sair naturalmente",
            "Corte o cordão apenas se necessário",
            "Monitore sangramento da mãe",
            "Mantenha mãe e bebê aquecidos",
            "Procure ajuda médica assim que possível"
        ]
    }
    return steps.get(stage, steps['inicio'])

def _get_childbirth_fallback(stage, complications):
    """Resposta de fallback para parto de emergência"""
    return {
        'type': 'parto_emergencia',
        'stage': stage,
        'ai_guidance': 'Serviço de IA temporariamente indisponível. Seguindo protocolo básico de parto de emergência.',
        'essential_steps': _get_childbirth_steps(stage),
        'materials_needed': [
            "Panos limpos ou toalhas",
            "Água fervida (se possível)",
            "Tesoura limpa (para cordão)",
            "Barbante ou fio limpo",
            "Cobertor para o bebê"
        ],
        'warning': "PARTO DE EMERGÊNCIA: Mantenha calma e higiene. Procure ajuda médica assim que possível.",
        'fallback': True
    }

def _get_accident_fallback(accident_type, injuries):
    """Resposta de fallback para acidentes"""
    return {
        'type': 'acidente',
        'accident_type': accident_type,
        'ai_guidance': 'Serviço de IA temporariamente indisponível. Seguindo protocolo básico de primeiros socorros.',
        'priority_actions': [
            "1. SEGURANÇA: Avalie se o local é seguro",
            "2. CONSCIÊNCIA: Verifique se a vítima responde",
            "3. RESPIRAÇÃO: Confirme se está respirando",
            "4. SANGRAMENTO: Controle hemorragias visíveis",
            "5. AJUDA: Chame socorro médico"
        ],
        'warning': "ACIDENTE: Não mova a vítima se suspeitar de lesão na coluna.",
        'fallback': True
    }

def _get_poisoning_fallback(poison_type, symptoms):
    """Resposta de fallback para intoxicação"""
    return {
        'type': 'intoxicacao',
        'poison_type': poison_type,
        'ai_guidance': 'Serviço de IA temporariamente indisponível. Seguindo protocolo básico de intoxicação.',
        'immediate_actions': [
            "Remova a pessoa da fonte de exposição",
            "Verifique sinais vitais",
            "NÃO induza vômito sem orientação",
            "Se consciente, dê água (se orientado)",
            "Chame ajuda médica URGENTEMENTE"
        ],
        'do_not_do': [
            "Não induza vômito se a pessoa engoliu produtos corrosivos",
            "Não dê leite ou óleo",
            "Não deixe a pessoa sozinha",
            "Não espere os sintomas piorarem"
        ],
        'warning': "INTOXICAÇÃO: Tempo é crucial. Contate centro de intoxicações se disponível.",
        'fallback': True
    }