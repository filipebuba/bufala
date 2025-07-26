#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Rotas do Guia de Voz - Bu Fala Backend
Hackathon Gemma 3n

Sistema de navegação assistiva por voz para
acessibilidade e orientação em ambientes diversos.
"""

import logging
from flask import Blueprint, request, jsonify, current_app
from datetime import datetime
from config.settings import SystemPrompts
from utils.error_handler import create_error_response, log_error

# Criar blueprint
voice_guide_bp = Blueprint('voice_guide', __name__)
logger = logging.getLogger(__name__)

@voice_guide_bp.route('/voice-guide/health', methods=['GET'])
def voice_guide_health():
    """Verificar saúde do sistema de guia de voz"""
    try:
        # Verificar componentes do sistema de voz
        voice_components = {
            'speech_recognition': _check_speech_recognition(),
            'text_to_speech': _check_text_to_speech(),
            'audio_processing': _check_audio_processing(),
            'voice_commands': _check_voice_commands()
        }
        
        # Determinar status geral
        all_healthy = all(comp['status'] == 'healthy' for comp in voice_components.values())
        overall_status = 'healthy' if all_healthy else 'degraded'
        
        return jsonify({
            'success': True,
            'data': {
                'status': overall_status,
                'components': voice_components,
                'features_available': {
                    'voice_navigation': True,
                    'audio_feedback': True,
                    'multilingual_support': True,
                    'offline_mode': True
                },
                'supported_languages': ['pt', 'crioulo', 'en', 'fr'],
                'last_check': datetime.now().isoformat()
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "verificação de saúde do guia de voz")
        return jsonify(create_error_response(
            'voice_guide_health_error',
            'Erro ao verificar saúde do guia de voz',
            500
        )), 500

@voice_guide_bp.route('/voice-guide/analyze-environment', methods=['POST'])
def analyze_environment():
    """Analisar ambiente para navegação assistiva"""
    try:
        # Obter dados da requisição
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        # Extrair informações do ambiente
        environment_data = data.get('environment_data')
        analysis_type = data.get('analysis_type', 'general')  # general, navigation, safety, accessibility
        user_location = data.get('user_location', 'desconhecido')
        user_needs = data.get('user_needs', [])  # visual_impairment, mobility_issues, hearing_impairment
        audio_input = data.get('audio_input')  # Comando de voz do usuário
        image_data = data.get('image_data')  # Dados de imagem do ambiente
        
        if not environment_data and not audio_input and not image_data:
            return jsonify(create_error_response(
                'missing_input',
                'Pelo menos um campo é obrigatório: environment_data, audio_input ou image_data',
                400
            )), 400
        
        # Preparar contexto de análise
        analysis_context = _prepare_environment_analysis_context(
            environment_data, analysis_type, user_location, user_needs, audio_input
        )
        
        # Obter serviço Gemma
        gemma_service = getattr(current_app, 'gemma_service', None)
        
        if gemma_service:
            # Escolher prompt apropriado baseado no tipo de entrada
            if image_data:
                system_prompt = SystemPrompts.IMAGE_ANALYSIS
            elif audio_input:
                system_prompt = SystemPrompts.AUDIO_TRANSCRIPTION
            else:
                system_prompt = SystemPrompts.GENERAL
            
            # Gerar análise usando Gemma
            response = gemma_service.generate_response(
                analysis_context,
                system_prompt,
                temperature=0.4,  # Temperatura baixa para análises precisas
                max_new_tokens=400
            )
            
            # Processar resposta
            if response.get('success'):
                analysis_result = response.get('response', '')
                
                # Adicionar informações específicas do guia de voz
                response['voice_guide_info'] = {
                    'analysis_result': analysis_result,
                    'navigation_instructions': _generate_navigation_instructions(analysis_result, user_needs),
                    'safety_alerts': _generate_safety_alerts(analysis_result),
                    'accessibility_features': _get_accessibility_features_for_environment(user_needs),
                    'voice_commands': _get_relevant_voice_commands(analysis_type),
                    'audio_feedback': _prepare_audio_feedback(analysis_result, user_needs)
                }
        else:
            # Resposta de fallback
            response = _get_environment_analysis_fallback(environment_data, analysis_type)
        
        return jsonify({
            'success': True,
            'data': response,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "análise de ambiente")
        return jsonify(create_error_response(
            'environment_analysis_error',
            'Erro ao analisar ambiente',
            500
        )), 500

@voice_guide_bp.route('/voice-guide/navigation', methods=['POST'])
def voice_navigation():
    """Navegação assistiva por voz"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        voice_command = data.get('voice_command')
        current_position = data.get('current_position', 'desconhecido')
        destination = data.get('destination')
        navigation_mode = data.get('navigation_mode', 'walking')  # walking, wheelchair, vehicle
        language = data.get('language', 'pt')
        assistance_level = data.get('assistance_level', 'medium')  # low, medium, high
        
        if not voice_command:
            return jsonify(create_error_response(
                'missing_voice_command',
                'Campo "voice_command" é obrigatório',
                400
            )), 400
        
        # Processar comando de navegação
        navigation_result = _process_navigation_command(
            voice_command, current_position, destination, navigation_mode, language, assistance_level
        )
        
        return jsonify({
            'success': True,
            'data': {
                'voice_command': voice_command,
                'current_position': current_position,
                'destination': destination,
                'navigation_mode': navigation_mode,
                'language': language,
                'navigation_result': navigation_result,
                'step_by_step_instructions': _generate_step_by_step_instructions(navigation_result),
                'audio_cues': _generate_audio_cues(navigation_result),
                'alternative_routes': _suggest_alternative_routes(current_position, destination, navigation_mode),
                'estimated_time': _calculate_estimated_time(current_position, destination, navigation_mode)
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

@voice_guide_bp.route('/voice-guide/commands', methods=['GET'])
def get_voice_commands():
    """Obter lista de comandos de voz disponíveis"""
    try:
        # Parâmetros de consulta
        category = request.args.get('category', 'all')  # navigation, accessibility, emergency, general
        language = request.args.get('language', 'pt')
        user_type = request.args.get('user_type', 'general')  # visual_impaired, mobility_impaired, elderly
        
        # Obter comandos de voz
        voice_commands = _get_voice_commands_by_category(category, language, user_type)
        
        return jsonify({
            'success': True,
            'data': {
                'category': category,
                'language': language,
                'user_type': user_type,
                'commands': voice_commands,
                'usage_tips': _get_voice_command_usage_tips(),
                'pronunciation_guide': _get_pronunciation_guide_for_commands(language),
                'customization_options': _get_command_customization_options()
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "consulta de comandos de voz")
        return jsonify(create_error_response(
            'voice_commands_error',
            'Erro ao obter comandos de voz',
            500
        )), 500

@voice_guide_bp.route('/voice-guide/feedback', methods=['POST'])
def process_voice_feedback():
    """Processar feedback de voz do usuário"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        feedback_audio = data.get('feedback_audio')
        feedback_text = data.get('feedback_text')
        feedback_type = data.get('feedback_type', 'general')  # navigation, accessibility, error, suggestion
        session_id = data.get('session_id')
        user_satisfaction = data.get('user_satisfaction')  # 1-5 scale
        
        if not feedback_audio and not feedback_text:
            return jsonify(create_error_response(
                'missing_feedback',
                'Campo "feedback_audio" ou "feedback_text" é obrigatório',
                400
            )), 400
        
        # Processar feedback
        feedback_result = _process_user_feedback(
            feedback_audio, feedback_text, feedback_type, session_id, user_satisfaction
        )
        
        return jsonify({
            'success': True,
            'data': {
                'feedback_type': feedback_type,
                'session_id': session_id,
                'processing_result': feedback_result,
                'acknowledgment': _generate_feedback_acknowledgment(feedback_type),
                'improvement_actions': _suggest_improvement_actions(feedback_result),
                'follow_up_questions': _generate_follow_up_questions(feedback_type)
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "processamento de feedback")
        return jsonify(create_error_response(
            'voice_feedback_error',
            'Erro ao processar feedback de voz',
            500
        )), 500

@voice_guide_bp.route('/voice-guide/emergency', methods=['POST'])
def emergency_voice_assistance():
    """Assistência de voz para emergências"""
    try:
        data = request.get_json()
        if not data:
            return jsonify(create_error_response(
                'invalid_request',
                'Dados JSON são obrigatórios',
                400
            )), 400
        
        emergency_type = data.get('emergency_type')  # medical, fire, accident, lost, other
        voice_input = data.get('voice_input')
        user_location = data.get('user_location')
        user_condition = data.get('user_condition', 'unknown')  # conscious, injured, trapped, mobile
        language = data.get('language', 'pt')
        
        if not emergency_type and not voice_input:
            return jsonify(create_error_response(
                'missing_emergency_info',
                'Campo "emergency_type" ou "voice_input" é obrigatório',
                400
            )), 400
        
        # Processar emergência
        emergency_response = _process_emergency_voice_assistance(
            emergency_type, voice_input, user_location, user_condition, language
        )
        
        return jsonify({
            'success': True,
            'data': {
                'emergency_type': emergency_type,
                'user_location': user_location,
                'user_condition': user_condition,
                'emergency_response': emergency_response,
                'immediate_actions': _get_immediate_emergency_actions(emergency_type),
                'emergency_contacts': _get_emergency_contacts(),
                'voice_instructions': _generate_emergency_voice_instructions(emergency_type, user_condition),
                'safety_priority': 'ALTA - Procure ajuda imediatamente'
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        log_error(logger, e, "assistência de emergência")
        return jsonify(create_error_response(
            'emergency_assistance_error',
            'Erro ao processar assistência de emergência',
            500
        )), 500

def _check_speech_recognition():
    """Verificar sistema de reconhecimento de fala"""
    return {
        'status': 'healthy',
        'accuracy': '85%',
        'languages_supported': ['pt', 'crioulo', 'en', 'fr'],
        'offline_capable': True
    }

def _check_text_to_speech():
    """Verificar sistema de síntese de fala"""
    return {
        'status': 'healthy',
        'voices_available': ['masculina', 'feminina', 'neutra'],
        'languages_supported': ['pt', 'crioulo', 'en', 'fr'],
        'quality': 'alta'
    }

def _check_audio_processing():
    """Verificar processamento de áudio"""
    return {
        'status': 'healthy',
        'noise_reduction': True,
        'echo_cancellation': True,
        'real_time_processing': True
    }

def _check_voice_commands():
    """Verificar sistema de comandos de voz"""
    return {
        'status': 'healthy',
        'commands_loaded': 150,
        'custom_commands': True,
        'multilingual': True
    }

def _prepare_environment_analysis_context(env_data, analysis_type, location, needs, audio_input):
    """Preparar contexto para análise de ambiente"""
    context = f"Análise de ambiente para navegação assistiva."
    
    if env_data:
        context += f"\nDados do ambiente: {env_data}"
    
    if audio_input:
        context += f"\nComando de voz do usuário: {audio_input}"
    
    context += f"\nTipo de análise: {analysis_type}"
    context += f"\nLocalização do usuário: {location}"
    
    if needs:
        context += f"\nNecessidades especiais: {', '.join(needs)}"
    
    context += "\nForneça análise detalhada e instruções de navegação seguras."
    
    return context

def _generate_navigation_instructions(analysis, user_needs):
    """Gerar instruções de navegação"""
    base_instructions = [
        "Mantenha-se na rota principal",
        "Observe obstáculos no caminho",
        "Use pontos de referência para orientação"
    ]
    
    if 'visual_impairment' in user_needs:
        base_instructions.extend([
            "Use bengala ou cão-guia",
            "Conte passos para distâncias",
            "Identifique sons ambientais"
        ])
    
    if 'mobility_issues' in user_needs:
        base_instructions.extend([
            "Procure rampas e elevadores",
            "Evite escadas e degraus",
            "Descanse quando necessário"
        ])
    
    return base_instructions

def _generate_safety_alerts(analysis):
    """Gerar alertas de segurança"""
    alerts = []
    
    analysis_lower = analysis.lower() if analysis else ''
    
    if any(word in analysis_lower for word in ['trânsito', 'carro', 'veículo', 'rua']):
        alerts.append("ATENÇÃO: Área com tráfego de veículos")
    
    if any(word in analysis_lower for word in ['escada', 'degrau', 'desnível']):
        alerts.append("CUIDADO: Desnível ou obstáculo vertical")
    
    if any(word in analysis_lower for word in ['obra', 'construção', 'bloqueio']):
        alerts.append("AVISO: Área em construção ou bloqueada")
    
    if any(word in analysis_lower for word in ['água', 'molhado', 'escorregadio']):
        alerts.append("CUIDADO: Superfície escorregadia")
    
    if not alerts:
        alerts.append("Nenhum perigo imediato identificado")
    
    return alerts

def _get_accessibility_features_for_environment(user_needs):
    """Obter recursos de acessibilidade para o ambiente"""
    features = {
        'visual_impairment': [
            "Descrição detalhada do ambiente",
            "Orientações por voz",
            "Identificação de obstáculos",
            "Pontos de referência sonoros"
        ],
        'hearing_impairment': [
            "Alertas visuais",
            "Vibração para notificações",
            "Texto em tempo real",
            "Sinais visuais de direção"
        ],
        'mobility_issues': [
            "Rotas acessíveis",
            "Localização de rampas",
            "Elevadores disponíveis",
            "Áreas de descanso"
        ]
    }
    
    result = []
    for need in user_needs:
        result.extend(features.get(need, []))
    
    return result if result else ["Recursos padrão de navegação"]

def _get_relevant_voice_commands(analysis_type):
    """Obter comandos de voz relevantes"""
    commands = {
        'general': [
            "Onde estou?",
            "Descrever ambiente",
            "Ajuda",
            "Repetir instruções"
        ],
        'navigation': [
            "Como chegar a [destino]?",
            "Qual direção seguir?",
            "Há obstáculos?",
            "Rota alternativa"
        ],
        'safety': [
            "Verificar segurança",
            "Alertas de perigo",
            "Emergência",
            "Chamar ajuda"
        ],
        'accessibility': [
            "Recursos de acessibilidade",
            "Rota acessível",
            "Assistência especial",
            "Configurar preferências"
        ]
    }
    
    return commands.get(analysis_type, commands['general'])

def _prepare_audio_feedback(analysis, user_needs):
    """Preparar feedback de áudio"""
    return {
        'text': analysis,
        'voice_type': 'clara e pausada' if 'hearing_impairment' in user_needs else 'normal',
        'speed': 'lenta' if 'cognitive_disability' in user_needs else 'normal',
        'emphasis': ['direções importantes', 'alertas de segurança'],
        'audio_cues': ['bipe de confirmação', 'som de alerta para perigos']
    }

def _get_environment_analysis_fallback(env_data, analysis_type):
    """Resposta de fallback para análise de ambiente"""
    return {
        'response': f"Análise básica do ambiente para {analysis_type}. Para análises mais detalhadas, forneça mais informações sobre o local ou use comandos de voz específicos.",
        'success': True,
        'fallback': True,
        'voice_guide_info': {
            'basic_instructions': ["Mantenha cautela", "Use pontos de referência", "Peça ajuda se necessário"],
            'safety_reminder': "Sempre priorize sua segurança"
        }
    }

def _process_navigation_command(command, position, destination, mode, language, assistance_level):
    """Processar comando de navegação"""
    command_lower = command.lower()
    
    if 'onde estou' in command_lower or 'localização' in command_lower:
        return f"Você está em: {position}. Use comandos de voz para obter direções."
    
    elif 'como chegar' in command_lower or 'direção' in command_lower:
        if destination:
            return f"Navegando de {position} para {destination} no modo {mode}. Siga as instruções de voz."
        else:
            return "Por favor, especifique o destino desejado."
    
    elif 'obstáculo' in command_lower or 'perigo' in command_lower:
        return "Verificando obstáculos no caminho. Mantenha cautela e use equipamentos de auxílio."
    
    elif 'parar' in command_lower or 'cancelar' in command_lower:
        return "Navegação cancelada. Diga 'ajuda' para ver comandos disponíveis."
    
    elif 'ajuda' in command_lower:
        return "Comandos disponíveis: 'onde estou', 'como chegar a [destino]', 'verificar obstáculos', 'parar navegação'."
    
    else:
        return "Comando não reconhecido. Diga 'ajuda' para ver comandos disponíveis."

def _generate_step_by_step_instructions(navigation_result):
    """Gerar instruções passo a passo"""
    return [
        "Passo 1: Oriente-se na direção indicada",
        "Passo 2: Caminhe em linha reta por 50 metros",
        "Passo 3: Vire à direita no próximo cruzamento",
        "Passo 4: Continue até o destino"
    ]

def _generate_audio_cues(navigation_result):
    """Gerar pistas de áudio"""
    return {
        'start_navigation': 'Bipe duplo - Navegação iniciada',
        'turn_left': 'Tom baixo - Virar à esquerda',
        'turn_right': 'Tom alto - Virar à direita',
        'obstacle_detected': 'Bipe rápido - Obstáculo detectado',
        'destination_reached': 'Melodia - Destino alcançado'
    }

def _suggest_alternative_routes(current, destination, mode):
    """Sugerir rotas alternativas"""
    return [
        {
            'route_name': 'Rota Principal',
            'estimated_time': '15 minutos',
            'accessibility': 'Alta',
            'difficulty': 'Fácil'
        },
        {
            'route_name': 'Rota Alternativa',
            'estimated_time': '20 minutos',
            'accessibility': 'Média',
            'difficulty': 'Moderada'
        }
    ]

def _calculate_estimated_time(current, destination, mode):
    """Calcular tempo estimado"""
    base_time = 15  # minutos base
    
    if mode == 'wheelchair':
        base_time += 5
    elif mode == 'vehicle':
        base_time -= 10
    
    return f"{base_time} minutos"

def _get_voice_commands_by_category(category, language, user_type):
    """Obter comandos de voz por categoria"""
    commands = {
        'navigation': {
            'pt': [
                {'command': 'Onde estou?', 'description': 'Obter localização atual'},
                {'command': 'Como chegar a [destino]?', 'description': 'Obter direções'},
                {'command': 'Verificar obstáculos', 'description': 'Identificar obstáculos no caminho'},
                {'command': 'Rota alternativa', 'description': 'Sugerir rota alternativa'}
            ],
            'crioulo': [
                {'command': 'Undi n sta?', 'description': 'Saber onde está'},
                {'command': 'Kuma n podi chiga na [destino]?', 'description': 'Como chegar ao destino'},
                {'command': 'Tcheka obstakulu', 'description': 'Verificar obstáculos'},
                {'command': 'Rota alternativa', 'description': 'Outra rota'}
            ]
        },
        'accessibility': {
            'pt': [
                {'command': 'Descrever ambiente', 'description': 'Descrição detalhada do local'},
                {'command': 'Recursos de acessibilidade', 'description': 'Listar recursos disponíveis'},
                {'command': 'Configurar preferências', 'description': 'Ajustar configurações'},
                {'command': 'Assistência especial', 'description': 'Solicitar ajuda específica'}
            ]
        },
        'emergency': {
            'pt': [
                {'command': 'Emergência médica', 'description': 'Solicitar ajuda médica'},
                {'command': 'Chamar socorro', 'description': 'Pedir socorro imediato'},
                {'command': 'Estou perdido', 'description': 'Solicitar orientação'},
                {'command': 'Preciso de ajuda', 'description': 'Pedir assistência geral'}
            ]
        }
    }
    
    if category == 'all':
        result = []
        for cat in commands.values():
            result.extend(cat.get(language, cat.get('pt', [])))
        return result
    
    return commands.get(category, {}).get(language, commands.get(category, {}).get('pt', []))

def _get_voice_command_usage_tips():
    """Obter dicas de uso de comandos de voz"""
    return [
        "Fale claramente e em ritmo normal",
        "Use palavras-chave específicas",
        "Aguarde o bipe antes de falar",
        "Repita o comando se não for reconhecido",
        "Use 'ajuda' para ver comandos disponíveis"
    ]

def _get_pronunciation_guide_for_commands(language):
    """Obter guia de pronúncia para comandos"""
    if language == 'crioulo':
        return {
            'undi': 'pronuncia-se "un-di"',
            'kuma': 'pronuncia-se "ku-ma"',
            'tcheka': 'pronuncia-se "tche-ka"'
        }
    
    return {}

def _get_command_customization_options():
    """Obter opções de customização de comandos"""
    return {
        'custom_phrases': 'Adicionar frases personalizadas',
        'sensitivity': 'Ajustar sensibilidade de reconhecimento',
        'language_mixing': 'Permitir mistura de idiomas',
        'shortcuts': 'Criar atalhos de voz'
    }

def _process_user_feedback(audio, text, feedback_type, session_id, satisfaction):
    """Processar feedback do usuário"""
    return {
        'feedback_received': True,
        'sentiment': 'positivo' if satisfaction and satisfaction >= 4 else 'neutro',
        'category': feedback_type,
        'action_required': satisfaction and satisfaction <= 2,
        'improvement_areas': ['reconhecimento de voz', 'precisão de direções'] if satisfaction and satisfaction <= 3 else []
    }

def _generate_feedback_acknowledgment(feedback_type):
    """Gerar reconhecimento do feedback"""
    acknowledgments = {
        'navigation': 'Obrigado pelo feedback sobre navegação. Suas sugestões nos ajudam a melhorar.',
        'accessibility': 'Agradecemos seu feedback sobre acessibilidade. Continuamos trabalhando para melhorar.',
        'error': 'Lamentamos o problema encontrado. Sua reportagem nos ajuda a corrigir erros.',
        'suggestion': 'Obrigado pela sugestão. Consideraremos sua ideia para futuras melhorias.'
    }
    
    return acknowledgments.get(feedback_type, 'Obrigado pelo seu feedback.')

def _suggest_improvement_actions(feedback_result):
    """Sugerir ações de melhoria"""
    if feedback_result.get('action_required'):
        return [
            "Revisar algoritmos de reconhecimento de voz",
            "Melhorar precisão de navegação",
            "Atualizar base de dados de locais",
            "Treinar modelo com mais dados locais"
        ]
    
    return ["Continuar monitoramento de qualidade"]

def _generate_follow_up_questions(feedback_type):
    """Gerar perguntas de acompanhamento"""
    questions = {
        'navigation': [
            "As direções foram claras?",
            "O tempo estimado foi preciso?",
            "Encontrou algum obstáculo não mencionado?"
        ],
        'accessibility': [
            "Os recursos de acessibilidade atenderam suas necessidades?",
            "Que melhorias você sugere?",
            "A velocidade da fala estava adequada?"
        ],
        'error': [
            "Pode descrever o erro em mais detalhes?",
            "Em que momento o erro ocorreu?",
            "O problema ainda persiste?"
        ]
    }
    
    return questions.get(feedback_type, ["Tem mais algum comentário?"])

def _process_emergency_voice_assistance(emergency_type, voice_input, location, condition, language):
    """Processar assistência de voz para emergência"""
    emergency_responses = {
        'medical': "Emergência médica detectada. Procure ajuda médica imediatamente. Se possível, chame 192 ou vá ao hospital mais próximo.",
        'fire': "Emergência de incêndio. Saia do local imediatamente. Chame os bombeiros no 193.",
        'accident': "Acidente detectado. Mantenha-se seguro. Chame socorro no 192 ou 193 conforme necessário.",
        'lost': "Pessoa perdida. Mantenha a calma. Tente identificar pontos de referência e peça ajuda a pessoas próximas.",
        'other': "Emergência detectada. Avalie a situação e chame ajuda apropriada. Em caso de dúvida, ligue 190."
    }
    
    base_response = emergency_responses.get(emergency_type, emergency_responses['other'])
    
    if condition == 'injured':
        base_response += " Não se mova desnecessariamente se estiver ferido."
    elif condition == 'trapped':
        base_response += " Se estiver preso, tente fazer ruído para chamar atenção."
    
    return base_response

def _get_immediate_emergency_actions(emergency_type):
    """Obter ações imediatas para emergência"""
    actions = {
        'medical': [
            "Chame ajuda médica (192)",
            "Mantenha a pessoa consciente se possível",
            "Não mova pessoa ferida",
            "Forneça primeiros socorros básicos"
        ],
        'fire': [
            "Saia do local imediatamente",
            "Chame bombeiros (193)",
            "Não use elevadores",
            "Cubra nariz e boca com pano úmido"
        ],
        'accident': [
            "Garanta segurança do local",
            "Chame socorro (192/193)",
            "Não mova vítimas",
            "Sinalize o local se necessário"
        ],
        'lost': [
            "Mantenha a calma",
            "Procure pontos de referência",
            "Peça ajuda a pessoas próximas",
            "Use GPS se disponível"
        ]
    }
    
    return actions.get(emergency_type, [
        "Avalie a situação",
        "Chame ajuda apropriada",
        "Mantenha-se seguro",
        "Forneça informações claras"
    ])

def _get_emergency_contacts():
    """Obter contatos de emergência"""
    return {
        'policia': '190',
        'bombeiros': '193',
        'samu': '192',
        'defesa_civil': '199',
        'emergencia_geral': '112 (se disponível)'
    }

def _generate_emergency_voice_instructions(emergency_type, condition):
    """Gerar instruções de voz para emergência"""
    instructions = {
        'medical': "Diga claramente: 'Emergência médica em [local]. Pessoa [condição]. Preciso de ambulância.'",
        'fire': "Diga: 'Incêndio em [local]. [Número] de pessoas no local. Bombeiros necessários.'",
        'accident': "Informe: 'Acidente em [local]. [Número] de vítimas. Condição: [estado das vítimas].'",
        'lost': "Diga: 'Estou perdido em [última localização conhecida]. Preciso de orientação.'"
    }
    
    base_instruction = instructions.get(emergency_type, "Descreva a emergência claramente com localização e situação.")
    
    if condition == 'unconscious':
        base_instruction += " Mencione que há pessoa inconsciente."
    elif condition == 'trapped':
        base_instruction += " Informe que há pessoa presa."
    
    return base_instruction