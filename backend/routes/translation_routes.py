#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Rotas de Tradução - Moransa Backend
Hackathon Gemma 3n

Especializado em tradução para crioulo da Guiné-Bissau
e outras línguas locais, com aprendizado adaptativo.
"""

import logging
from flask import Blueprint, request, jsonify, current_app
from datetime import datetime
from config.settings import SystemPrompts
from utils.error_handler import create_error_response, log_error

# Criar blueprint
translation_bp = Blueprint('translation', __name__)
logger = logging.getLogger(__name__)

@translation_bp.route('/translate', methods=['POST'])
def translate_text():
    """
    Traduzir texto para/de crioulo e outras línguas
    ---
    tags:
      - Tradução
    summary: Traduzir texto entre idiomas
    description: |
      Endpoint revolucionário para tradução de texto com foco especial no Crioulo da Guiné-Bissau.
      Características:
      - Tradução bidirecional (Português ↔ Crioulo ↔ Inglês ↔ Francês)
      - Contexto específico (médico, educacional, agrícola)
      - Preservação de significado cultural
      - Aprendizado adaptativo
    consumes:
      - application/json
    produces:
      - application/json
    parameters:
      - in: body
        name: translation_request
        description: Dados para tradução
        required: true
        schema:
          type: object
          required:
            - text
            - target_language
          properties:
            text:
              type: string
              description: Texto para traduzir
              example: "Como está você?"
            source_language:
              type: string
              enum: ["auto", "pt", "crioulo", "en", "fr"]
              default: "auto"
              description: Idioma de origem (auto para detecção automática)
              example: "pt"
            target_language:
              type: string
              enum: ["pt", "crioulo", "en", "fr"]
              description: Idioma de destino
              example: "crioulo"
            context:
              type: string
              enum: ["geral", "medico", "educacional", "agricola"]
              default: "geral"
              description: Contexto da tradução
              example: "medico"
            formality:
              type: string
              enum: ["formal", "informal"]
              default: "informal"
              description: Nível de formalidade
              example: "informal"
            preserve_meaning:
              type: boolean
              default: true
              description: Preservar significado cultural
              example: true
    responses:
      200:
        description: Tradução realizada com sucesso
        schema:
          type: object
          properties:
            success:
              type: boolean
              example: true
            message:
              type: string
              example: "Tradução realizada com sucesso"
            data:
              type: object
              properties:
                original_text:
                  type: string
                  example: "Como está você?"
                translated_text:
                  type: string
                  example: "Kuma ku sta?"
                source_language:
                  type: string
                  example: "pt"
                target_language:
                  type: string
                  example: "crioulo"
                context:
                  type: string
                  example: "geral"
                confidence:
                  type: number
                  format: float
                  example: 0.95
                pronunciation:
                  type: string
                  example: "Kuma ku sta?"
                cultural_notes:
                  type: array
                  items:
                    type: string
                  example: ["Expressão comum de cumprimento"]
            timestamp:
              type: string
              format: date-time
              example: "2024-01-20T10:30:00Z"
      400:
        description: Requisição inválida
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
        
        # Extrair texto para tradução
        text = data.get('text')
        if not text:
            return jsonify(create_error_response(
                'missing_text',
                'Campo "text" é obrigatório',
                400
            )), 400
        
        # Obter parâmetros de tradução
        source_language = data.get('source_language', 'auto')  # auto, pt, en, fr, crioulo
        target_language = data.get('target_language', 'crioulo')  # crioulo, pt, en, fr
        context = data.get('context', 'geral')  # medico, educacional, agricola, geral
        formality = data.get('formality', 'informal')  # formal, informal
        preserve_meaning = data.get('preserve_meaning', True)
        
        # Validar idiomas suportados
        supported_languages = ['pt', 'en', 'fr', 'crioulo', 'auto']
        if source_language not in supported_languages or target_language not in supported_languages:
            return jsonify(create_error_response(
                'unsupported_language',
                f'Idiomas suportados: {supported_languages}',
                400
            )), 400
        
        # Detectar idioma se necessário
        if source_language == 'auto':
            detected_language = _detect_language(text)
            source_language = detected_language
        
        # Preparar contexto de tradução
        translation_context = _prepare_translation_context(
            text, source_language, target_language, context, formality, preserve_meaning
        )
        
        # Obter serviço Gemma
        gemma_service = getattr(current_app, 'gemma_service', None)
        
        if gemma_service:
            # Gerar tradução usando Gemma
            response = gemma_service.generate_response(
                translation_context,
                SystemPrompts.TRANSLATION,
                temperature=0.3,  # Temperatura baixa para tradução precisa
                max_new_tokens=300
            )
            
            # Processar resposta de tradução
            if response.get('success'):
                translated_text = _extract_translation_from_response(response.get('response', ''))
                
                response['translation_info'] = {
                    'original_text': text,
                    'translated_text': translated_text,
                    'source_language': source_language,
                    'target_language': target_language,
                    'context': context,
                    'formality': formality,
                    'confidence': _calculate_translation_confidence(text, translated_text),
                    'cultural_notes': _get_cultural_notes(source_language, target_language),
                    'alternative_translations': _get_alternative_translations(text, target_language)
                }
        else:
            # Resposta de fallback
            response = _get_translation_fallback_response(text, source_language, target_language)
        
        return jsonify({
            'success': True,
            'data': response,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "tradução de texto")
        return jsonify(create_error_response(
            'translation_error',
            'Erro ao traduzir texto',
            500
        )), 500

@translation_bp.route('/translate/learn', methods=['POST'])
def learn_translation():
    """Aprender nova tradução ou correção"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        original_text = data.get('original_text')
        correct_translation = data.get('correct_translation')
        source_language = data.get('source_language')
        target_language = data.get('target_language')
        context = data.get('context', 'geral')
        contributor = data.get('contributor', 'anonimo')
        
        if not all([original_text, correct_translation, source_language, target_language]):
            return jsonify(create_error_response(
                'missing_fields',
                'Campos obrigatórios: original_text, correct_translation, source_language, target_language',
                400
            )), 400
        
        # Salvar aprendizado (simulado - em produção seria salvo em banco de dados)
        learning_entry = {
            'original_text': original_text,
            'correct_translation': correct_translation,
            'source_language': source_language,
            'target_language': target_language,
            'context': context,
            'contributor': contributor,
            'timestamp': datetime.now().isoformat(),
            'status': 'pending_validation'
        }
        
        # Simular salvamento
        logger.info(f"Nova entrada de aprendizado: {learning_entry}")
        
        return jsonify({
            'success': True,
            'data': {
                'message': "Tradução adicionada para aprendizado",
                'learning_entry': learning_entry,
                'validation_status': "Aguardando validação da comunidade",
                'contribution_points': 10  # Sistema de pontos para gamificação
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "aprendizado de tradução")
        return jsonify(create_error_response(
            'learning_error',
            'Erro ao processar aprendizado de tradução',
            500
        )), 500

@translation_bp.route('/translate/validate', methods=['POST'])
def validate_translation():
    """Validar tradução da comunidade"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        translation_id = data.get('translation_id')
        validation = data.get('validation')  # 'approve', 'reject', 'suggest_edit'
        validator = data.get('validator', 'anonimo')
        comments = data.get('comments', '')
        suggested_edit = data.get('suggested_edit', '')
        
        if not all([translation_id, validation]):
            return jsonify(create_error_response(
                'missing_fields',
                'Campos obrigatórios: translation_id, validation',
                400
            )), 400
        
        if validation not in ['approve', 'reject', 'suggest_edit']:
            return jsonify(create_error_response(
                'invalid_validation',
                'Validação deve ser: approve, reject ou suggest_edit',
                400
            )), 400
        
        # Processar validação (simulado)
        validation_entry = {
            'translation_id': translation_id,
            'validation': validation,
            'validator': validator,
            'comments': comments,
            'suggested_edit': suggested_edit,
            'timestamp': datetime.now().isoformat()
        }
        
        logger.info(f"Validação processada: {validation_entry}")
        
        return jsonify({
            'success': True,
            'data': {
                'message': f"Validação '{validation}' processada com sucesso",
                'validation_entry': validation_entry,
                'validator_points': 5,  # Pontos por validação
                'community_status': "Contribuição registrada"
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "validação de tradução")
        return jsonify(create_error_response(
            'validation_error',
            'Erro ao processar validação de tradução',
            500
        )), 500

@translation_bp.route('/translate/dictionary', methods=['GET'])
def get_dictionary():
    """Obter dicionário de termos comuns"""
    try:
        # Parâmetros de consulta
        source_lang = request.args.get('source_language', 'pt')
        target_lang = request.args.get('target_language', 'crioulo')
        category = request.args.get('category', 'all')  # medical, education, agriculture, common
        
        # Obter dicionário básico
        dictionary = _get_basic_dictionary(source_lang, target_lang, category)
        
        return jsonify({
            'success': True,
            'data': {
                'source_language': source_lang,
                'target_language': target_lang,
                'category': category,
                'dictionary': dictionary,
                'total_entries': len(dictionary),
                'last_updated': datetime.now().isoformat()
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "consulta de dicionário")
        return jsonify(create_error_response(
            'dictionary_error',
            'Erro ao consultar dicionário',
            500
        )), 500

@translation_bp.route('/translate/phrases', methods=['GET'])
def get_common_phrases():
    """Obter frases comuns traduzidas"""
    try:
        # Parâmetros de consulta
        target_lang = request.args.get('target_language', 'crioulo')
        context = request.args.get('context', 'daily')  # daily, medical, emergency, education
        
        # Obter frases comuns
        phrases = _get_common_phrases(target_lang, context)
        
        return jsonify({
            'success': True,
            'data': {
                'target_language': target_lang,
                'context': context,
                'phrases': phrases,
                'usage_tips': _get_phrase_usage_tips(context),
                'pronunciation_guide': "Guia de pronúncia disponível para crioulo"
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "consulta de frases")
        return jsonify(create_error_response(
            'phrases_error',
            'Erro ao consultar frases comuns',
            500
        )), 500

@translation_bp.route('/translate/pronunciation', methods=['POST'])
def get_pronunciation_guide():
    """Obter guia de pronúncia"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        text = data.get('text')
        language = data.get('language', 'crioulo')
        
        if not text:
            return jsonify(create_error_response(
                'missing_text',
                'Campo "text" é obrigatório',
                400
            )), 400
        
        # Obter guia de pronúncia
        pronunciation_guide = _get_pronunciation_guide(text, language)
        
        return jsonify({
            'success': True,
            'data': {
                'text': text,
                'language': language,
                'pronunciation_guide': pronunciation_guide,
                'phonetic_transcription': _get_phonetic_transcription(text, language),
                'audio_tips': "Ouça falantes nativos para melhor pronúncia"
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "guia de pronúncia")
        return jsonify(create_error_response(
            'pronunciation_error',
            'Erro ao obter guia de pronúncia',
            500
        )), 500

def _detect_language(text):
    """Detectar idioma do texto (simplificado)"""
    # Detecção básica baseada em palavras-chave
    text_lower = text.lower()
    
    # Palavras características do crioulo
    crioulo_words = ['bu', 'na', 'ku', 'kuma', 'suma', 'kin', 'kil']
    if any(word in text_lower for word in crioulo_words):
        return 'crioulo'
    
    # Palavras características do português
    portuguese_words = ['que', 'com', 'para', 'uma', 'não', 'mais', 'como']
    if any(word in text_lower for word in portuguese_words):
        return 'pt'
    
    # Palavras características do inglês
    english_words = ['the', 'and', 'for', 'with', 'that', 'this', 'have']
    if any(word in text_lower for word in english_words):
        return 'en'
    
    # Palavras características do francês
    french_words = ['que', 'avec', 'pour', 'une', 'dans', 'sur', 'comme']
    if any(word in text_lower for word in french_words):
        return 'fr'
    
    return 'pt'  # Default para português

def _prepare_translation_context(text, source_lang, target_lang, context, formality, preserve_meaning):
    """Preparar contexto de tradução"""
    context_text = f"Traduzir de {source_lang} para {target_lang}: {text}"
    context_text += f"\nContexto: {context}"
    context_text += f"\nFormalidade: {formality}"
    
    if preserve_meaning:
        context_text += "\nPreservar significado cultural e contextual."
    
    if target_lang == 'crioulo':
        context_text += "\nUsar crioulo da Guiné-Bissau, considerando variações regionais."
    
    context_text += "\nFornecer tradução natural e culturalmente apropriada."
    
    return context_text

def _extract_translation_from_response(response_text):
    """Extrair tradução da resposta do modelo"""
    # Lógica simples para extrair tradução
    # Em produção, seria mais sofisticada
    lines = response_text.split('\n')
    for line in lines:
        if line.strip() and not line.startswith('Tradução:'):
            return line.strip()
    return response_text.strip()

def _calculate_translation_confidence(original, translated):
    """Calcular confiança da tradução (simplificado)"""
    if not original or not translated:
        return 0.0
    
    # Lógica básica de confiança
    length_ratio = min(len(translated), len(original)) / max(len(translated), len(original))
    base_confidence = 0.7  # Confiança base
    
    return min(base_confidence + (length_ratio * 0.3), 1.0)

def _get_cultural_notes(source_lang, target_lang):
    """Obter notas culturais"""
    notes = {
        ('pt', 'crioulo'): "O crioulo da Guiné-Bissau tem influências do português, mandinga e outras línguas locais.",
        ('crioulo', 'pt'): "Algumas expressões crioulas não têm tradução direta em português.",
        ('en', 'crioulo'): "Conceitos ocidentais podem precisar de adaptação cultural.",
        ('fr', 'crioulo'): "Influência francesa limitada no crioulo da Guiné-Bissau."
    }
    
    return notes.get((source_lang, target_lang), "Considere diferenças culturais na tradução.")

def _get_alternative_translations(text, target_lang):
    """Obter traduções alternativas (simulado)"""
    # Em produção, seria baseado em banco de dados de traduções
    return [
        "Tradução alternativa 1",
        "Tradução alternativa 2"
    ]

def _get_translation_fallback_response(text, source_lang, target_lang):
    """Resposta de fallback para tradução"""
    return {
        'response': f"Tradução de {source_lang} para {target_lang} não disponível no momento. Consulte falantes nativos ou dicionários locais.",
        'success': True,
        'fallback': True,
        'translation_info': {
            'original_text': text,
            'source_language': source_lang,
            'target_language': target_lang,
            'suggestion': "Use recursos comunitários para tradução"
        }
    }

def _get_basic_dictionary(source_lang, target_lang, category):
    """Obter dicionário básico"""
    # Dicionário básico português-crioulo
    basic_dict = {
        'common': {
            'olá': 'oi',
            'obrigado': 'obrigadu',
            'por favor': 'pur favor',
            'desculpa': 'diskulpa',
            'sim': 'sin',
            'não': 'nau',
            'água': 'agu',
            'comida': 'kumida',
            'casa': 'kasa',
            'família': 'familia'
        },
        'medical': {
            'dor': 'dor',
            'médico': 'mediku',
            'remédio': 'remediu',
            'hospital': 'ospital',
            'doente': 'duenti'
        },
        'education': {
            'escola': 'skola',
            'professor': 'profesor',
            'livro': 'libru',
            'estudar': 'studar',
            'aprender': 'aprendi'
        },
        'agriculture': {
            'terra': 'tera',
            'plantar': 'planta',
            'colheita': 'kuleta',
            'arroz': 'aros',
            'milho': 'miliu'
        }
    }
    
    if category == 'all':
        result = {}
        for cat in basic_dict.values():
            result.update(cat)
        return result
    
    return basic_dict.get(category, basic_dict['common'])

def _get_common_phrases(target_lang, context):
    """Obter frases comuns"""
    phrases = {
        'daily': [
            {'pt': 'Como está?', 'crioulo': 'Kuma bu sta?'},
            {'pt': 'Tudo bem?', 'crioulo': 'Tudu drito?'},
            {'pt': 'Até logo', 'crioulo': 'Te logu'},
            {'pt': 'Com licença', 'crioulo': 'Kun lisensia'}
        ],
        'medical': [
            {'pt': 'Onde dói?', 'crioulo': 'Undi ki ta doi?'},
            {'pt': 'Preciso de ajuda', 'crioulo': 'N misti djuda'},
            {'pt': 'Chame o médico', 'crioulo': 'Chama mediku'}
        ],
        'emergency': [
            {'pt': 'Socorro!', 'crioulo': 'Djuda!'},
            {'pt': 'Emergência', 'crioulo': 'Emerjénsia'},
            {'pt': 'Chame ajuda', 'crioulo': 'Chama djuda'}
        ],
        'education': [
            {'pt': 'Não entendo', 'crioulo': 'N ka intindi'},
            {'pt': 'Pode repetir?', 'crioulo': 'Bu podi ripiti?'},
            {'pt': 'Obrigado professor', 'crioulo': 'Obrigadu profesor'}
        ]
    }
    
    return phrases.get(context, phrases['daily'])

def _get_phrase_usage_tips(context):
    """Obter dicas de uso de frases"""
    tips = {
        'daily': "Use essas frases em conversas cotidianas",
        'medical': "Frases úteis em situações de saúde",
        'emergency': "Use em situações de emergência",
        'education': "Frases para ambiente educacional"
    }
    
    return tips.get(context, "Use conforme o contexto apropriado")

def _get_pronunciation_guide(text, language):
    """Obter guia de pronúncia"""
    if language == 'crioulo':
        return {
            'general_rules': [
                "'u' no final soa como 'u' fechado",
                "'k' substitui 'qu' em muitas palavras",
                "Entonação similar ao português"
            ],
            'specific_sounds': {
                'bu': 'pronuncia-se \'bu\' (você)',
                'ku': 'pronuncia-se \'ku\' (com)',
                'kin': 'pronuncia-se \'kin\' (quem)'
            }
        }
    
    return {
        'general_rules': ["Siga regras de pronúncia padrão do idioma"],
        'specific_sounds': {}
    }

def _get_phonetic_transcription(text, language):
    """Obter transcrição fonética (simplificada)"""
    if language == 'crioulo':
        # Transcrição básica para algumas palavras comuns
        transcriptions = {
            'bu': '[bu]',
            'kuma': '[ˈkuma]',
            'oi': '[oj]',
            'obrigadu': '[obriˈgadu]'
        }
        
        words = text.lower().split()
        result = []
        for word in words:
            result.append(transcriptions.get(word, f'[{word}]'))
        
        return ' '.join(result)
    
    return f"[{text}]"  # Transcrição básica