#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Rotas de Educação - Bu Fala Backend
Hackathon Gemma 3n

Especializado em educação para comunidades da Guiné-Bissau,
com foco em ensino adaptado e materiais acessíveis.
"""

import logging
from flask import Blueprint, request, jsonify, current_app
from datetime import datetime
from config.settings import SystemPrompts
from utils.error_handler import create_error_response, log_error

# Criar blueprint
education_bp = Blueprint('education', __name__)
logger = logging.getLogger(__name__)

@education_bp.route('/education', methods=['POST'])
def educational_content():
    """
    Gerar conteúdo educacional adaptado
    ---
    tags:
      - Educação
    summary: Conteúdo educacional personalizado
    description: |
      Endpoint para gerar conteúdo educacional adaptado às necessidades locais.
      Especializado em educação para comunidades da Guiné-Bissau com recursos limitados.
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
              description: Tópico ou pergunta educacional
              example: "Como ensinar matemática básica para crianças sem livros?"
            subject:
              type: string
              enum: ["matemática", "português", "ciências", "história", "geografia", "crioulo"]
              description: Matéria específica
              example: "matemática"
            level:
              type: string
              enum: ["infantil", "fundamental", "médio", "adulto"]
              description: Nível educacional
              example: "fundamental"
            age_group:
              type: string
              description: Faixa etária dos estudantes
              example: "6-10 anos"
            resources:
              type: array
              items:
                type: string
              description: Recursos disponíveis
              example: ["papel", "lápis", "objetos do cotidiano"]
            language:
              type: string
              enum: ["português", "crioulo", "ambos"]
              description: Idioma preferido
              example: "crioulo"
    responses:
      200:
        description: Conteúdo educacional gerado com sucesso
        schema:
          type: object
          properties:
            success:
              type: boolean
              example: true
            message:
              type: string
              example: "Conteúdo educacional gerado"
            data:
              type: object
              properties:
                content:
                  type: string
                  description: Conteúdo educacional gerado
                activities:
                  type: array
                  items:
                    type: string
                  description: Atividades práticas sugeridas
                materials_needed:
                  type: array
                  items:
                    type: string
                  description: Materiais necessários
                difficulty_level:
                  type: string
                  description: Nível de dificuldade
                estimated_time:
                  type: string
                  description: Tempo estimado da atividade
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
        
        # Obter parâmetros educacionais
        subject = data.get('subject', 'geral')
        education_level = data.get('education_level', 'basico')  # basico, medio, avancado
        age_group = data.get('age_group', 'adulto')  # crianca, adolescente, adulto
        language = data.get('language', 'portugues')  # portugues, crioulo
        
        # Preparar contexto educacional
        educational_context = _prepare_educational_context(
            prompt, subject, education_level, age_group, language
        )
        
        # Obter serviço Gemma
        gemma_service = getattr(current_app, 'gemma_service', None)
        
        if gemma_service:
            # Gerar resposta usando Gemma
            response = gemma_service.generate_response(
                educational_context,
                SystemPrompts.EDUCATION,
                temperature=0.7,  # Temperatura moderada para criatividade educacional
                max_new_tokens=500
            )
            
            # Adicionar informações educacionais específicas
            if response.get('success'):
                response['educational_info'] = {
                    'subject': subject,
                    'level': education_level,
                    'age_group': age_group,
                    'language': language,
                    'learning_tips': _get_learning_tips(education_level, age_group),
                    'additional_resources': _get_additional_resources(subject)
                }
        else:
            # Resposta de fallback
            response = _get_education_fallback_response(prompt, subject, education_level)
        
        return jsonify({
            'success': True,
            'data': response,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "conteúdo educacional")
        return jsonify(create_error_response(
            'education_error',
            'Erro ao gerar conteúdo educacional',
            500
        )), 500

@education_bp.route('/education/lesson-plan', methods=['POST'])
def create_lesson_plan():
    """Criar plano de aula adaptado"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        topic = data.get('topic')
        duration = data.get('duration', 60)  # minutos
        resources_available = data.get('resources_available', [])
        class_size = data.get('class_size', 20)
        
        if not topic:
            return jsonify(create_error_response(
                'missing_topic',
                'Campo "topic" é obrigatório',
                400
            )), 400
        
        # Gerar plano de aula
        lesson_plan = _create_lesson_plan(topic, duration, resources_available, class_size)
        
        return jsonify({
            'success': True,
            'data': {
                'topic': topic,
                'duration_minutes': duration,
                'lesson_plan': lesson_plan,
                'resources_needed': _get_minimal_resources(topic),
                'adaptation_notes': "Plano adaptado para recursos limitados e contexto local"
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "criação de plano de aula")
        return jsonify(create_error_response(
            'lesson_plan_error',
            'Erro ao criar plano de aula',
            500
        )), 500

@education_bp.route('/education/quiz', methods=['POST'])
def generate_quiz():
    """Gerar quiz educacional"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        topic = data.get('topic')
        difficulty = data.get('difficulty', 'medio')  # facil, medio, dificil
        num_questions = data.get('num_questions', 5)
        
        if not topic:
            return jsonify(create_error_response(
                'missing_topic',
                'Campo "topic" é obrigatório',
                400
            )), 400
        
        # Gerar quiz
        quiz = _generate_quiz(topic, difficulty, num_questions)
        
        return jsonify({
            'success': True,
            'data': {
                'topic': topic,
                'difficulty': difficulty,
                'quiz': quiz,
                'instructions': "Responda as perguntas e verifique suas respostas ao final"
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "geração de quiz")
        return jsonify(create_error_response(
            'quiz_error',
            'Erro ao gerar quiz',
            500
        )), 500

@education_bp.route('/education/translate-content', methods=['POST'])
def translate_educational_content():
    """Traduzir conteúdo educacional para crioulo"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        content = data.get('content')
        target_language = data.get('target_language', 'crioulo')
        
        if not content:
            return jsonify(create_error_response(
                'missing_content',
                'Campo "content" é obrigatório',
                400
            )), 400
        
        # Obter serviço Gemma
        gemma_service = getattr(current_app, 'gemma_service', None)
        
        if gemma_service:
            translation_prompt = f"Traduza o seguinte conteúdo educacional para {target_language}, mantendo o contexto pedagógico:\n\n{content}"
            
            response = gemma_service.generate_response(
                translation_prompt,
                SystemPrompts.TRANSLATION,
                temperature=0.3,
                max_new_tokens=400
            )
        else:
            response = {
                'response': f"Tradução para {target_language} não disponível no momento. Conteúdo original mantido.",
                'success': False,
                'fallback': True
            }
        
        return jsonify({
            'success': True,
            'data': {
                'original_content': content,
                'target_language': target_language,
                'translated_content': response.get('response', content),
                'translation_available': response.get('success', False)
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "tradução de conteúdo educacional")
        return jsonify(create_error_response(
            'translation_error',
            'Erro ao traduzir conteúdo',
            500
        )), 500

def _prepare_educational_context(prompt, subject, level, age_group, language):
    """Preparar contexto educacional"""
    context = f"Tópico educacional: {prompt}"
    context += f"\nMatéria: {subject}"
    context += f"\nNível: {level}"
    context += f"\nFaixa etária: {age_group}"
    context += f"\nIdioma preferido: {language}"
    context += "\n\nPor favor, forneça uma explicação educacional clara e adaptada para o contexto da Guiné-Bissau, considerando recursos limitados e a realidade local."
    
    return context

def _get_learning_tips(level, age_group):
    """Obter dicas de aprendizagem"""
    tips = {
        'basico': [
            "Use exemplos do dia a dia",
            "Repita conceitos importantes",
            "Faça perguntas simples para verificar compreensão"
        ],
        'medio': [
            "Conecte novos conceitos com conhecimentos anteriores",
            "Use exercícios práticos",
            "Encoraje discussões em grupo"
        ],
        'avancado': [
            "Promova pensamento crítico",
            "Use estudos de caso",
            "Encoraje pesquisa independente"
        ]
    }
    
    age_tips = {
        'crianca': ["Use jogos e atividades lúdicas", "Mantenha sessões curtas"],
        'adolescente': ["Use exemplos relevantes para a idade", "Promova participação ativa"],
        'adulto': ["Conecte com experiências de vida", "Foque em aplicações práticas"]
    }
    
    return tips.get(level, tips['basico']) + age_tips.get(age_group, [])

def _get_additional_resources(subject):
    """Obter recursos adicionais por matéria"""
    resources = {
        'matematica': ["Objetos do cotidiano para contagem", "Desenhos no chão ou areia"],
        'ciencias': ["Observação da natureza local", "Experimentos simples com materiais locais"],
        'historia': ["Histórias orais da comunidade", "Mapas desenhados à mão"],
        'geografia': ["Observação do ambiente local", "Caminhadas educativas"],
        'portugues': ["Leitura em voz alta", "Contação de histórias"],
        'geral': ["Materiais locais disponíveis", "Conhecimento da comunidade"]
    }
    
    return resources.get(subject, resources['geral'])

def _get_education_fallback_response(prompt, subject, level):
    """Resposta de fallback para educação"""
    return {
        'response': f"Para aprender sobre {prompt}, recomendo procurar professores qualificados na sua comunidade ou materiais educacionais locais. A educação é fundamental para o desenvolvimento pessoal e comunitário.",
        'success': True,
        'fallback': True,
        'educational_info': {
            'subject': subject,
            'level': level,
            'recommendation': "Busque recursos educacionais locais e apoio da comunidade"
        }
    }

def _create_lesson_plan(topic, duration, resources, class_size):
    """Criar plano de aula básico"""
    return {
        'introduction': {
            'duration_minutes': max(5, duration // 6),
            'activities': [
                "Apresentação do tópico",
                "Conexão com conhecimentos anteriores",
                "Objetivos da aula"
            ]
        },
        'development': {
            'duration_minutes': max(30, duration * 2 // 3),
            'activities': [
                f"Explicação do conceito: {topic}",
                "Exemplos práticos do contexto local",
                "Atividade participativa",
                "Discussão em grupos pequenos"
            ]
        },
        'conclusion': {
            'duration_minutes': max(10, duration // 6),
            'activities': [
                "Resumo dos pontos principais",
                "Perguntas e respostas",
                "Tarefa para casa (se apropriado)"
            ]
        },
        'adaptations': [
            f"Adaptado para {class_size} alunos",
            "Uso de recursos locais disponíveis",
            "Linguagem simples e clara"
        ]
    }

def _generate_quiz(topic, difficulty, num_questions):
    """Gerar quiz básico"""
    # Quiz básico de exemplo - em implementação real, seria gerado dinamicamente
    sample_questions = [
        {
            'question': f"O que você aprendeu sobre {topic}?",
            'type': 'open',
            'points': 2
        },
        {
            'question': f"Como {topic} se aplica no seu dia a dia?",
            'type': 'open',
            'points': 3
        },
        {
            'question': f"Qual a importância de {topic} para sua comunidade?",
            'type': 'open',
            'points': 3
        }
    ]
    
    return {
        'questions': sample_questions[:num_questions],
        'total_points': sum(q['points'] for q in sample_questions[:num_questions]),
        'instructions': "Responda com suas próprias palavras e use exemplos quando possível"
    }