#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Rotas de Acessibilidade - Moransa Backend
Hackathon Gemma 3n

Especializado em acessibilidade para pessoas com deficiência,
com foco em navegação assistiva e descrição de ambiente.
"""

import logging
from flask import Blueprint, request, jsonify, current_app
from datetime import datetime
from config.settings import SystemPrompts
from utils.error_handler import create_error_response, log_error

# Criar blueprint
accessibility_bp = Blueprint('accessibility', __name__)
logger = logging.getLogger(__name__)

@accessibility_bp.route('/accessibility/visual/describe', methods=['POST'])
def describe_environment():
    """Descrever ambiente para deficientes visuais"""
    try:
        # Obter dados da requisição
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        # Verificar se há imagem ou descrição do ambiente
        image_data = data.get('image_data')
        environment_description = data.get('environment_description')
        detail_level = data.get('detail_level', 'medium')  # low, medium, high
        focus_area = data.get('focus_area', 'general')  # obstacles, navigation, objects, people
        audio_output = data.get('audio_output', True)
        
        if not image_data and not environment_description:
            return jsonify(create_error_response(
                'missing_input',
                'Campo "image_data" ou "environment_description" é obrigatório',
                400
            )), 400
        
        # Preparar contexto para descrição
        description_context = _prepare_visual_description_context(
            image_data, environment_description, detail_level, focus_area
        )
        
        # Obter serviço Gemma
        gemma_service = getattr(current_app, 'gemma_service', None)
        
        if gemma_service and image_data:
            # Usar análise de imagem multimodal
            response = gemma_service.generate_response(
                description_context,
                SystemPrompts.IMAGE_ANALYSIS,
                temperature=0.4,  # Temperatura baixa para descrições precisas
                max_new_tokens=400
            )
        elif gemma_service:
            # Usar descrição textual
            response = gemma_service.generate_response(
                description_context,
                SystemPrompts.GENERAL,
                temperature=0.4,
                max_new_tokens=400
            )
        else:
            # Resposta de fallback
            response = _get_visual_description_fallback(environment_description, focus_area)
        
        # Processar resposta
        if response.get('success'):
            description = response.get('response', '')
            
            # Adicionar informações de acessibilidade
            accessibility_info = {
                'description': description,
                'detail_level': detail_level,
                'focus_area': focus_area,
                'navigation_tips': _get_navigation_tips(focus_area),
                'safety_alerts': _get_safety_alerts(description),
                'audio_ready': audio_output,
                'interaction_suggestions': _get_interaction_suggestions(focus_area)
            }
            
            response['accessibility_info'] = accessibility_info
        
        return jsonify({
            'success': True,
            'data': response,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "descrição visual")
        return jsonify(create_error_response(
            'visual_description_error',
            'Erro ao descrever ambiente visual',
            500
        )), 500

@accessibility_bp.route('/accessibility/navigation/voice', methods=['POST'])
def voice_navigation():
    """Navegação por comando de voz"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        voice_command = data.get('voice_command')
        current_location = data.get('current_location', 'desconhecido')
        destination = data.get('destination')
        navigation_mode = data.get('navigation_mode', 'walking')  # walking, vehicle, public_transport
        accessibility_needs = data.get('accessibility_needs', [])  # wheelchair, visual_impairment, hearing_impairment
        
        if not voice_command:
            return jsonify(create_error_response(
                'missing_voice_command',
                'Campo "voice_command" é obrigatório',
                400
            )), 400
        
        # Processar comando de voz
        navigation_response = _process_voice_navigation_command(
            voice_command, current_location, destination, navigation_mode, accessibility_needs
        )
        
        return jsonify({
            'success': True,
            'data': {
                'voice_command': voice_command,
                'current_location': current_location,
                'destination': destination,
                'navigation_mode': navigation_mode,
                'response': navigation_response,
                'accessibility_features': _get_accessibility_features(accessibility_needs),
                'voice_feedback': _get_voice_feedback(navigation_response),
                'alternative_routes': _get_alternative_accessible_routes(current_location, destination)
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "navegação por voz")
        return jsonify(create_error_response(
            'voice_navigation_error',
            'Erro ao processar navegação por voz',
            500
        )), 500

@accessibility_bp.route('/accessibility/audio/transcribe', methods=['POST'])
def transcribe_audio():
    """Transcrever áudio para texto"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        audio_data = data.get('audio_data')
        language = data.get('language', 'pt')  # pt, crioulo, en, fr
        context = data.get('context', 'general')  # medical, education, emergency
        speaker_identification = data.get('speaker_identification', False)
        
        if not audio_data:
            return jsonify(create_error_response(
                'missing_audio_data',
                'Campo "audio_data" é obrigatório',
                400
            )), 400
        
        # Simular transcrição de áudio (em produção usaria serviço de STT)
        transcription_result = _simulate_audio_transcription(
            audio_data, language, context, speaker_identification
        )
        
        return jsonify({
            'success': True,
            'data': {
                'transcription': transcription_result['text'],
                'language': language,
                'context': context,
                'confidence': transcription_result['confidence'],
                'speaker_info': transcription_result.get('speakers', []),
                'timestamps': transcription_result.get('timestamps', []),
                'accessibility_features': {
                    'text_formatting': 'Texto formatado para leitores de tela',
                    'punctuation_enhanced': True,
                    'speaker_labels': speaker_identification
                }
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "transcrição de áudio")
        return jsonify(create_error_response(
            'audio_transcription_error',
            'Erro ao transcrever áudio',
            500
        )), 500

@accessibility_bp.route('/accessibility/text-to-speech', methods=['POST'])
def text_to_speech():
    """Converter texto para fala"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        text = data.get('text')
        language = data.get('language', 'pt')
        voice_type = data.get('voice_type', 'neutral')  # neutral, male, female
        speed = data.get('speed', 'normal')  # slow, normal, fast
        emphasis = data.get('emphasis', [])  # palavras para enfatizar
        
        if not text:
            return jsonify(create_error_response(
                'missing_text',
                'Campo "text" é obrigatório',
                400
            )), 400
        
        # Simular conversão texto-para-fala
        tts_result = _simulate_text_to_speech(
            text, language, voice_type, speed, emphasis
        )
        
        return jsonify({
            'success': True,
            'data': {
                'text': text,
                'language': language,
                'voice_type': voice_type,
                'speed': speed,
                'audio_url': tts_result['audio_url'],
                'duration': tts_result['duration'],
                'accessibility_features': {
                    'pronunciation_guide': tts_result.get('pronunciation_notes', []),
                    'pause_markers': tts_result.get('pause_points', []),
                    'emphasis_applied': emphasis
                }
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "conversão texto-para-fala")
        return jsonify(create_error_response(
            'tts_error',
            'Erro ao converter texto para fala',
            500
        )), 500

@accessibility_bp.route('/accessibility/cognitive/simplify', methods=['POST'])
def simplify_content():
    """Simplificar conteúdo para acessibilidade cognitiva"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        content = data.get('content')
        simplification_level = data.get('simplification_level', 'medium')  # low, medium, high
        target_audience = data.get('target_audience', 'general')  # children, elderly, cognitive_disability
        preserve_meaning = data.get('preserve_meaning', True)
        add_visual_aids = data.get('add_visual_aids', False)
        
        if not content:
            return jsonify(create_error_response(
                'missing_content',
                'Campo "content" é obrigatório',
                400
            )), 400
        
        # Simplificar conteúdo
        simplified_result = _simplify_content_for_accessibility(
            content, simplification_level, target_audience, preserve_meaning
        )
        
        return jsonify({
            'success': True,
            'data': {
                'original_content': content,
                'simplified_content': simplified_result['simplified_text'],
                'simplification_level': simplification_level,
                'target_audience': target_audience,
                'readability_score': simplified_result['readability_score'],
                'key_points': simplified_result['key_points'],
                'visual_aids_suggestions': simplified_result.get('visual_aids', []) if add_visual_aids else [],
                'accessibility_features': {
                    'clear_structure': True,
                    'simple_vocabulary': True,
                    'short_sentences': True,
                    'logical_flow': True
                }
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "simplificação de conteúdo")
        return jsonify(create_error_response(
            'content_simplification_error',
            'Erro ao simplificar conteúdo',
            500
        )), 500

@accessibility_bp.route('/accessibility/motor/interface', methods=['POST'])
def motor_accessible_interface():
    """Interface acessível para deficiências motoras"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        interaction_type = data.get('interaction_type')  # eye_tracking, voice, switch, head_movement
        command = data.get('command')
        interface_element = data.get('interface_element')
        assistance_level = data.get('assistance_level', 'medium')  # low, medium, high
        
        if not all([interaction_type, command]):
            return jsonify(create_error_response(
                'missing_fields',
                'Campos obrigatórios: interaction_type, command',
                400
            )), 400
        
        # Processar interação motora
        interaction_result = _process_motor_interaction(
            interaction_type, command, interface_element, assistance_level
        )
        
        return jsonify({
            'success': True,
            'data': {
                'interaction_type': interaction_type,
                'command': command,
                'interface_element': interface_element,
                'result': interaction_result,
                'alternative_methods': _get_alternative_interaction_methods(interaction_type),
                'customization_options': _get_motor_customization_options(),
                'accessibility_features': {
                    'large_targets': True,
                    'dwell_time_adjustable': True,
                    'gesture_alternatives': True,
                    'voice_backup': True
                }
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "interface motora")
        return jsonify(create_error_response(
            'motor_interface_error',
            'Erro ao processar interface motora',
            500
        )), 500

def _prepare_visual_description_context(image_data, description, detail_level, focus_area):
    """Preparar contexto para descrição visual"""
    context = "Descreva o ambiente de forma clara e útil para uma pessoa com deficiência visual."
    
    if image_data:
        context += "\nAnalise a imagem fornecida."
    
    if description:
        context += f"\nDescrição do ambiente: {description}"
    
    context += f"\nNível de detalhe: {detail_level}"
    context += f"\nFoco em: {focus_area}"
    
    if focus_area == 'obstacles':
        context += "\nPrioritize obstáculos e perigos potenciais."
    elif focus_area == 'navigation':
        context += "\nFoque em informações de navegação e orientação."
    elif focus_area == 'objects':
        context += "\nDescreva objetos importantes no ambiente."
    elif focus_area == 'people':
        context += "\nDescreva pessoas presentes e suas atividades."
    
    return context

def _get_navigation_tips(focus_area):
    """Obter dicas de navegação"""
    tips = {
        'obstacles': [
            "Mantenha-se atento a obstáculos no chão",
            "Use bengala ou cão-guia para detecção",
            "Peça ajuda se necessário"
        ],
        'navigation': [
            "Use pontos de referência sonoros",
            "Conte passos para distâncias",
            "Mantenha orientação com pontos cardeais"
        ],
        'objects': [
            "Explore com as mãos cuidadosamente",
            "Use referências táteis",
            "Memorize posições de objetos importantes"
        ],
        'people': [
            "Identifique-se ao se aproximar",
            "Peça orientações específicas",
            "Use comunicação verbal clara"
        ]
    }
    
    return tips.get(focus_area, tips['navigation'])

def _get_safety_alerts(description):
    """Obter alertas de segurança"""
    # Análise básica para identificar possíveis perigos
    alerts = []
    
    description_lower = description.lower() if description else ''
    
    if any(word in description_lower for word in ['escada', 'degrau', 'buraco']):
        alerts.append("Atenção: Possível desnível ou obstáculo vertical")
    
    if any(word in description_lower for word in ['água', 'molhado', 'escorregadio']):
        alerts.append("Cuidado: Superfície pode estar escorregadia")
    
    if any(word in description_lower for word in ['trânsito', 'carro', 'veículo']):
        alerts.append("Alerta: Área com tráfego de veículos")
    
    if not alerts:
        alerts.append("Nenhum perigo óbvio identificado, mas mantenha cautela")
    
    return alerts

def _get_interaction_suggestions(focus_area):
    """Obter sugestões de interação"""
    suggestions = {
        'obstacles': "Use comando de voz 'descrever obstáculos' para mais detalhes",
        'navigation': "Diga 'onde estou' para orientação atual",
        'objects': "Use 'identificar objeto' apontando na direção",
        'people': "Pergunte 'quem está aqui' para identificar pessoas"
    }
    
    return suggestions.get(focus_area, "Use comandos de voz para mais informações")

def _get_visual_description_fallback(description, focus_area):
    """Resposta de fallback para descrição visual"""
    return {
        'response': f"Descrição básica do ambiente com foco em {focus_area}. Para descrições mais detalhadas, use a câmera ou forneça mais informações sobre o local.",
        'success': True,
        'fallback': True
    }

def _process_voice_navigation_command(command, location, destination, mode, needs):
    """Processar comando de navegação por voz"""
    command_lower = command.lower()
    
    if 'onde estou' in command_lower:
        return f"Você está em: {location}. Use pontos de referência sonoros para orientação."
    
    elif 'como chegar' in command_lower or 'direção' in command_lower:
        if destination:
            return f"Para chegar a {destination} a partir de {location}, siga as orientações de voz. Modo: {mode}."
        else:
            return "Por favor, especifique o destino desejado."
    
    elif 'obstáculo' in command_lower:
        return "Analisando obstáculos no caminho. Use bengala ou cão-guia para navegação segura."
    
    elif 'ajuda' in command_lower:
        return "Comandos disponíveis: 'onde estou', 'como chegar a [destino]', 'obstáculos no caminho', 'repetir direções'."
    
    else:
        return "Comando não reconhecido. Diga 'ajuda' para ver comandos disponíveis."

def _get_accessibility_features(needs):
    """Obter recursos de acessibilidade"""
    features = {
        'wheelchair': [
            "Rotas acessíveis para cadeira de rodas",
            "Evitar escadas e degraus",
            "Priorizar rampas e elevadores"
        ],
        'visual_impairment': [
            "Orientações por voz detalhadas",
            "Descrição de obstáculos",
            "Pontos de referência sonoros"
        ],
        'hearing_impairment': [
            "Orientações visuais",
            "Vibração para alertas",
            "Texto em tempo real"
        ]
    }
    
    result = []
    for need in needs:
        result.extend(features.get(need, []))
    
    return result if result else ["Navegação padrão disponível"]

def _get_voice_feedback(response):
    """Obter feedback de voz"""
    return {
        'text': response,
        'audio_cues': ["Bipe de confirmação", "Tom de orientação"],
        'speech_rate': 'normal',
        'emphasis_points': ["direções importantes", "alertas de segurança"]
    }

def _get_alternative_accessible_routes(current, destination):
    """Obter rotas alternativas acessíveis"""
    return [
        {
            'route_name': 'Rota Principal Acessível',
            'accessibility_features': ['Rampas', 'Piso tátil', 'Semáforos sonoros'],
            'estimated_time': '15 minutos',
            'difficulty': 'Fácil'
        },
        {
            'route_name': 'Rota Alternativa',
            'accessibility_features': ['Elevadores', 'Corrimãos'],
            'estimated_time': '20 minutos',
            'difficulty': 'Moderado'
        }
    ]

def _simulate_audio_transcription(audio_data, language, context, speaker_id):
    """Simular transcrição de áudio"""
    # Em produção, usaria serviço real de STT
    return {
        'text': 'Texto transcrito do áudio fornecido.',
        'confidence': 0.85,
        'speakers': ['Falante 1'] if speaker_id else [],
        'timestamps': [{'start': 0, 'end': 5, 'text': 'Texto transcrito do áudio fornecido.'}]
    }

def _simulate_text_to_speech(text, language, voice_type, speed, emphasis):
    """Simular conversão texto-para-fala"""
    # Em produção, usaria serviço real de TTS
    return {
        'audio_url': '/audio/generated_speech.mp3',
        'duration': len(text) * 0.1,  # Estimativa simples
        'pronunciation_notes': ['Pronúncia clara aplicada'],
        'pause_points': [i for i, char in enumerate(text) if char in '.!?']
    }

def _simplify_content_for_accessibility(content, level, audience, preserve_meaning):
    """Simplificar conteúdo para acessibilidade"""
    # Simplificação básica
    simplified = content
    
    if level == 'high':
        # Simplificação máxima
        sentences = content.split('.')
        simplified_sentences = []
        
        for sentence in sentences:
            if sentence.strip():
                # Simplificar frases longas
                words = sentence.split()
                if len(words) > 10:
                    # Dividir em frases menores
                    mid = len(words) // 2
                    simplified_sentences.append(' '.join(words[:mid]) + '.')
                    simplified_sentences.append(' '.join(words[mid:]) + '.')
                else:
                    simplified_sentences.append(sentence.strip() + '.')
        
        simplified = ' '.join(simplified_sentences)
    
    return {
        'simplified_text': simplified,
        'readability_score': 'Fácil' if level == 'high' else 'Moderado',
        'key_points': _extract_key_points(content),
        'visual_aids': ['Ícones explicativos', 'Diagramas simples', 'Cores de destaque']
    }

def _extract_key_points(content):
    """Extrair pontos-chave do conteúdo"""
    # Extração básica de pontos importantes
    sentences = content.split('.')
    key_points = []
    
    for sentence in sentences[:3]:  # Primeiras 3 frases como pontos-chave
        if sentence.strip() and len(sentence.strip()) > 20:
            key_points.append(sentence.strip())
    
    return key_points

def _process_motor_interaction(interaction_type, command, element, assistance_level):
    """Processar interação motora"""
    interactions = {
        'eye_tracking': f"Comando '{command}' executado via rastreamento ocular",
        'voice': f"Comando de voz '{command}' processado",
        'switch': f"Comando '{command}' ativado via switch",
        'head_movement': f"Movimento de cabeça '{command}' detectado"
    }
    
    base_response = interactions.get(interaction_type, f"Comando '{command}' processado")
    
    if element:
        base_response += f" no elemento {element}"
    
    return base_response

def _get_alternative_interaction_methods(current_type):
    """Obter métodos alternativos de interação"""
    alternatives = {
        'eye_tracking': ['Comando de voz', 'Switch', 'Movimento de cabeça'],
        'voice': ['Rastreamento ocular', 'Switch', 'Toque adaptado'],
        'switch': ['Comando de voz', 'Rastreamento ocular', 'Sopro'],
        'head_movement': ['Comando de voz', 'Switch', 'Rastreamento ocular']
    }
    
    return alternatives.get(current_type, ['Comando de voz', 'Toque adaptado'])

def _get_motor_customization_options():
    """Obter opções de customização motora"""
    return {
        'dwell_time': 'Tempo de permanência ajustável (0.5-3.0s)',
        'target_size': 'Tamanho de alvos personalizável',
        'gesture_sensitivity': 'Sensibilidade de gestos configurável',
        'voice_commands': 'Comandos de voz personalizáveis',
        'switch_timing': 'Temporização de switch ajustável'
    }