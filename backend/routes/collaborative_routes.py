#!/usr/bin/env python3
"""
Rotas para o Sistema Colaborativo "Ensine o Bu Fala"
"""

from flask import Blueprint, request, jsonify, g
from datetime import datetime, timedelta
import logging
import uuid
from typing import Dict, List, Any

logger = logging.getLogger(__name__)

collaborative_bp = Blueprint('collaborative', __name__, url_prefix='/api/collaborative')

# Base de dados simulada (em produção seria um banco real)
teachers_db = {}
phrases_db = {}
validations_db = {}
rankings_db = {}
provocations_db = {}
duels_db = {}

# Endpoint para submissão de tradução colaborativa vinculada a uma frase existente
@collaborative_bp.route('/translation/submit', methods=['POST'])
def submit_translation():
    data = request.get_json(force=True) or {}
    required_fields = ['phrase_id', 'translated_text', 'target_language', 'user_id']
    for field in required_fields:
        if not data.get(field):
            return jsonify({'success': False, 'error': f'{field} é obrigatório'}), 400

    phrase_id = data['phrase_id']
    if phrase_id not in phrases_db:
        return jsonify({'success': False, 'error': 'Frase não encontrada'}), 404

    # Cria uma nova tradução colaborativa vinculada à frase
    translation_id = str(uuid.uuid4())
    translation = {
        'id': translation_id,
        'phrase_id': phrase_id,
        'translated_text': data['translated_text'],
        'target_language': data['target_language'],
        'user_id': data['user_id'],
        'created_at': datetime.now().isoformat(),
        'validated': False
    }
    # Armazena a tradução em uma lista dentro da frase
    phrase = phrases_db[phrase_id]
    if 'collaborative_translations' not in phrase:
        phrase['collaborative_translations'] = []
    phrase['collaborative_translations'].append(translation)

    # Pontua o usuário colaborador
    if data['user_id'] in teachers_db:
        teacher = teachers_db[data['user_id']]
        teacher['points'] += 7  # Pontos por colaboração
        teacher['last_active'] = datetime.now().isoformat()
        _check_and_award_badges(teacher)

    return jsonify({'success': True, 'data': translation, 'message': 'Tradução colaborativa submetida com sucesso!'})

@collaborative_bp.route('/health', methods=['GET'])
def health_check():
    """Health check específico do sistema colaborativo"""
    return jsonify({
        'status': 'healthy',
        'service': 'collaborative_learning',
        'timestamp': datetime.now().isoformat(),
        'stats': {
            'total_teachers': len(teachers_db),
            'total_phrases': len(phrases_db),
            'total_validations': len(validations_db)
        }
    })

@collaborative_bp.route('/teacher/profile', methods=['GET'])
def get_teacher_profile():
    """Obter perfil do professor"""
    teacher_id = request.args.get('teacher_id')
    if not teacher_id:
        return jsonify({'error': 'teacher_id é obrigatório'}), 400
    
    # Se não existe, criar novo perfil
    if teacher_id not in teachers_db:
        teachers_db[teacher_id] = {
            'id': teacher_id,
            'name': f'Professor {teacher_id[:8]}',
            'total_teachings': 0,
            'expertise_level': 'beginner',
            'languages_taught': [],
            'points': 0,
            'badges': [],
            'ranking_position': 0,
            'created_at': datetime.now().isoformat(),
            'last_active': datetime.now().isoformat()
        }
    
    profile = teachers_db[teacher_id]
    profile['last_active'] = datetime.now().isoformat()
    
    return jsonify({
        'success': True,
        'data': profile
    })

@collaborative_bp.route('/teacher/profile', methods=['PUT'])
def update_teacher_profile():
    """Atualizar perfil do professor"""
    data = request.get_json(force=True) or {}
    teacher_id = data.get('teacher_id')
    
    if not teacher_id:
        return jsonify({'error': 'teacher_id é obrigatório'}), 400
    
    if teacher_id in teachers_db:
        # Atualizar campos permitidos
        allowed_fields = ['name', 'languages_taught']
        for field in allowed_fields:
            if field in data:
                teachers_db[teacher_id][field] = data[field]
        
        teachers_db[teacher_id]['last_active'] = datetime.now().isoformat()
        
        return jsonify({
            'success': True,
            'data': teachers_db[teacher_id]
        })
    
    return jsonify({'error': 'Professor não encontrado'}), 404

@collaborative_bp.route('/phrase/teach', methods=['POST'])
def teach_phrase():
    """Ensinar nova frase"""
    data = request.get_json(force=True) or {}
    
    required_fields = ['teacher_id', 'portuguese_text', 'translated_text', 'target_language', 'category']
    for field in required_fields:
        if not data.get(field):
            return jsonify({'error': f'{field} é obrigatório'}), 400
    
    phrase_id = str(uuid.uuid4())
    phrase = {
        'id': phrase_id,
        'teacher_id': data['teacher_id'],
        'portuguese_text': data['portuguese_text'],
        'translated_text': data['translated_text'],
        'target_language': data['target_language'],
        'category': data['category'],
        'audio_url': data.get('audio_url'),
        'pronunciation_guide': data.get('pronunciation_guide'),
        'cultural_context': data.get('cultural_context'),
        'difficulty_level': data.get('difficulty_level', 'beginner'),
        'validation_status': 'pending',
        'validation_count': 0,
        'created_at': datetime.now().isoformat(),
        'updated_at': datetime.now().isoformat()
    }
    
    phrases_db[phrase_id] = phrase
    
    # Atualizar estatísticas do professor
    if data['teacher_id'] in teachers_db:
        teacher = teachers_db[data['teacher_id']]
        teacher['total_teachings'] += 1
        teacher['points'] += 10  # 10 pontos por ensinar
        
        # Adicionar linguagem se não existe
        if data['target_language'] not in teacher['languages_taught']:
            teacher['languages_taught'].append(data['target_language'])
        
        # Verificar badges
        _check_and_award_badges(teacher)
        
        teacher['last_active'] = datetime.now().isoformat()
    
    # Gerar provocação ética usando o serviço
    try:
        provocation = _generate_ethical_provocation(phrase, data['teacher_id'])
        phrase['provocation'] = provocation
    except Exception as e:
        logger.warning(f"Erro ao gerar provocação: {e}")
        phrase['provocation'] = "Que legal! Você poderia me ensinar mais uma palavra?"
    
    return jsonify({
        'success': True,
        'data': phrase,
        'message': 'Frase ensinada com sucesso!'
    })

@collaborative_bp.route('/phrase/validate', methods=['POST'])
def validate_phrase():
    """Validar frase de outro professor"""
    data = request.get_json(force=True) or {}
    
    required_fields = ['validator_id', 'phrase_id', 'validation_type']
    for field in required_fields:
        if not data.get(field):
            return jsonify({'error': f'{field} é obrigatório'}), 400
    
    phrase_id = data['phrase_id']
    if phrase_id not in phrases_db:
        return jsonify({'error': 'Frase não encontrada'}), 404
    
    validation_id = str(uuid.uuid4())
    validation = {
        'id': validation_id,
        'validator_id': data['validator_id'],
        'phrase_id': phrase_id,
        'validation_type': data['validation_type'],  # 'correct', 'incorrect', 'alternative'
        'feedback': data.get('feedback'),
        'alternative_translation': data.get('alternative_translation'),
        'created_at': datetime.now().isoformat()
    }
    
    validations_db[validation_id] = validation
    
    # Atualizar frase
    phrase = phrases_db[phrase_id]
    phrase['validation_count'] += 1
    phrase['updated_at'] = datetime.now().isoformat()
    
    # Determinar status de validação
    correct_validations = sum(1 for v in validations_db.values() 
                             if v['phrase_id'] == phrase_id and v['validation_type'] == 'correct')
    
    if correct_validations >= 3:
        phrase['validation_status'] = 'validated'
    elif phrase['validation_count'] >= 5:
        phrase['validation_status'] = 'needs_review'
    
    # Dar pontos ao validador
    if data['validator_id'] in teachers_db:
        teacher = teachers_db[data['validator_id']]
        teacher['points'] += 5  # 5 pontos por validar
        teacher['last_active'] = datetime.now().isoformat()
        _check_and_award_badges(teacher)
    
    return jsonify({
        'success': True,
        'data': validation,
        'message': 'Validação registrada com sucesso!'
    })

@collaborative_bp.route('/phrases', methods=['GET'])
def get_phrases():
    """Obter lista de frases para validação"""
    language = request.args.get('language')
    category = request.args.get('category')
    status = request.args.get('status', 'pending')
    limit = int(request.args.get('limit', 10))
    
    filtered_phrases = []
    for phrase in phrases_db.values():
        if language and phrase['target_language'] != language:
            continue
        if category and phrase['category'] != category:
            continue
        if status and phrase['validation_status'] != status:
            continue
        
        filtered_phrases.append(phrase)
    
    # Ordenar por data de criação (mais recentes primeiro)
    filtered_phrases.sort(key=lambda x: x['created_at'], reverse=True)
    
    return jsonify({
        'success': True,
        'data': filtered_phrases[:limit],
        'total': len(filtered_phrases)
    })

@collaborative_bp.route('/ranking', methods=['GET'])
def get_ranking():
    """Obter ranking de professores"""
    language = request.args.get('language')
    period = request.args.get('period', 'all_time')  # 'today', 'week', 'month', 'all_time'
    
    # Filtrar professores
    teachers = list(teachers_db.values())
    
    if language:
        teachers = [t for t in teachers if language in t.get('languages_taught', [])]
    
    # Ordenar por pontos
    teachers.sort(key=lambda x: x['points'], reverse=True)
    
    # Atualizar posições
    for i, teacher in enumerate(teachers):
        teacher['ranking_position'] = i + 1
    
    return jsonify({
        'success': True,
        'data': teachers[:50],  # Top 50
        'total': len(teachers)
    })

@collaborative_bp.route('/provocation/generate', methods=['POST'])
def generate_provocation():
    """Gerar provocação ética"""
    data = request.get_json(force=True) or {}
    
    required_fields = ['user_input', 'language', 'teacher_id']
    for field in required_fields:
        if not data.get(field):
            return jsonify({'error': f'{field} é obrigatório'}), 400
    
    teacher_id = data['teacher_id']
    teacher = teachers_db.get(teacher_id, {})
    
    # Determinar nível de expertise
    teachings = teacher.get('total_teachings', 0)
    if teachings < 10:
        expertise = 'beginner'
    elif teachings < 50:
        expertise = 'intermediate'
    elif teachings < 200:
        expertise = 'advanced'
    else:
        expertise = 'expert'
    
    try:
        provocation = _generate_ethical_provocation_context(
            user_input=data['user_input'],
            language=data['language'],
            expertise=expertise,
            provocation_type=data.get('type', 'curiosity')
        )
        
        return jsonify({
            'success': True,
            'data': {
                'provocation': provocation,
                'type': data.get('type', 'curiosity'),
                'expertise_level': expertise
            }
        })
        
    except Exception as e:
        logger.error(f"Erro ao gerar provocação: {e}")
        return jsonify({
            'success': True,
            'data': {
                'provocation': f"Que interessante! '{data['user_input']}' em {data['language']}... Você poderia me ensinar mais palavras?",
                'type': 'safe_fallback',
                'expertise_level': expertise
            }
        })

@collaborative_bp.route('/duel/create', methods=['POST'])
def create_duel():
    """Criar duelo linguístico"""
    data = request.get_json(force=True) or {}
    
    required_fields = ['challenger_id', 'duel_type', 'language']
    for field in required_fields:
        if not data.get(field):
            return jsonify({'error': f'{field} é obrigatório'}), 400
    
    duel_id = str(uuid.uuid4())
    duel = {
        'id': duel_id,
        'challenger_id': data['challenger_id'],
        'opponent_id': data.get('opponent_id'),  # Pode ser None para duelo vs Bu Fala
        'duel_type': data['duel_type'],  # 'vs_bufala', 'vs_teacher', 'speed'
        'language': data['language'],
        'category': data.get('category', 'general'),
        'status': 'waiting' if data.get('opponent_id') else 'active',
        'rounds_total': data.get('rounds', 10),
        'rounds_completed': 0,
        'challenger_score': 0,
        'opponent_score': 0,
        'created_at': datetime.now().isoformat(),
        'expires_at': (datetime.now() + timedelta(hours=24)).isoformat()
    }
    
    duels_db[duel_id] = duel
    
    return jsonify({
        'success': True,
        'data': duel,
        'message': 'Duelo criado com sucesso!'
    })

@collaborative_bp.route('/duel/<duel_id>/answer', methods=['POST'])
def submit_duel_answer():
    """Submeter resposta em duelo"""
    duel_id = request.view_args['duel_id']
    data = request.json
    
    if duel_id not in duels_db:
        return jsonify({'error': 'Duelo não encontrado'}), 404
    
    duel = duels_db[duel_id]
    
    # Verificar se o duelo está ativo
    if duel['status'] != 'active':
        return jsonify({'error': 'Duelo não está ativo'}), 400
    
    # Processar resposta
    is_correct = _validate_duel_answer(data['question'], data['answer'], duel['language'])
    
    # Atualizar pontuação
    if data['player_id'] == duel['challenger_id']:
        if is_correct:
            duel['challenger_score'] += 1
    elif data['player_id'] == duel['opponent_id']:
        if is_correct:
            duel['opponent_score'] += 1
    
    duel['rounds_completed'] += 1
    
    # Verificar se o duelo terminou
    if duel['rounds_completed'] >= duel['rounds_total']:
        duel['status'] = 'completed'
        duel['winner'] = _determine_duel_winner(duel)
        
        # Dar pontos e badges aos participantes
        _award_duel_rewards(duel)
    
    return jsonify({
        'success': True,
        'data': {
            'is_correct': is_correct,
            'duel_status': duel['status'],
            'current_score': {
                'challenger': duel['challenger_score'],
                'opponent': duel['opponent_score']
            },
            'rounds_left': duel['rounds_total'] - duel['rounds_completed']
        }
    })

@collaborative_bp.route('/ethics/report', methods=['POST'])
def report_ethics_violation():
    """Reportar violação ética"""
    data = request.json
    
    required_fields = ['user_id', 'content', 'violation_type']
    for field in required_fields:
        if not data.get(field):
            return jsonify({'error': f'{field} é obrigatório'}), 400
    
    report_id = str(uuid.uuid4())
    report = {
        'id': report_id,
        'user_id': data['user_id'],
        'content': data['content'],
        'violation_type': data['violation_type'],
        'description': data.get('description'),
        'status': 'pending_review',
        'created_at': datetime.now().isoformat()
    }
    
    # Em produção, salvar no banco e notificar moderadores
    logger.warning(f"ETHICS VIOLATION REPORTED: {report}")
    
    # Resposta automática de desculpas
    apology = _generate_ethics_apology()
    
    return jsonify({
        'success': True,
        'data': {
            'report_id': report_id,
            'apology_message': apology,
            'status': 'received'
        },
        'message': 'Reporte recebido. Obrigado pelo feedback!'
    })

@collaborative_bp.route('/stats', methods=['GET'])
def get_stats():
    """Obter estatísticas do sistema"""
    teacher_id = request.args.get('teacher_id')
    
    global_stats = {
        'total_teachers': len(teachers_db),
        'total_phrases': len(phrases_db),
        'total_validations': len(validations_db),
        'languages_available': list(set(p['target_language'] for p in phrases_db.values())),
        'most_active_language': _get_most_active_language(),
        'total_duels': len(duels_db)
    }
    
    user_stats = None
    if teacher_id and teacher_id in teachers_db:
        teacher = teachers_db[teacher_id]
        user_phrases = [p for p in phrases_db.values() if p['teacher_id'] == teacher_id]
        user_validations = [v for v in validations_db.values() if v['validator_id'] == teacher_id]
        
        user_stats = {
            'teachings_today': len([p for p in user_phrases if _is_today(p['created_at'])]),
            'validations_today': len([v for v in user_validations if _is_today(v['created_at'])]),
            'streak_days': _calculate_streak(teacher_id),
            'favorite_language': _get_user_favorite_language(teacher_id),
            'next_badge': _get_next_badge(teacher)
        }
    
    return jsonify({
        'success': True,
        'data': {
            'global': global_stats,
            'user': user_stats
        }
    })

# Funções auxiliares

def _generate_ethical_provocation(phrase: Dict, teacher_id: str) -> str:
    """Gerar provocação ética usando IA"""
    try:
        # Obter serviço Gemma do contexto da aplicação
        gemma_service = g.get('gemma_service')
        if not gemma_service:
            return "Que interessante! Você poderia me ensinar mais uma palavra?"
        
        teacher = teachers_db.get(teacher_id, {})
        expertise = _determine_expertise_level(teacher.get('total_teachings', 0))
        
        prompt = f"""
Gere uma provocação ética e motivacional para um professor que ensinou:
- Português: "{phrase['portuguese_text']}"
- {phrase['target_language']}: "{phrase['translated_text']}"
- Nível do professor: {expertise}

A provocação deve:
1. Ser respeitosa e encorajadora
2. Despertar curiosidade
3. Motivar mais ensino
4. Nunca ofender ou desvalorizar
5. Celebrar a língua {phrase['target_language']}

Responda apenas com a provocação, sem explicações.
"""
        
        response = gemma_service.generate_response(prompt)
        return response.get('response', 'Que legal! Você poderia me ensinar mais palavras?')
        
    except Exception as e:
        logger.error(f"Erro na geração de provocação: {e}")
        return "Que interessante! Você poderia me ensinar mais uma palavra?"

def _generate_ethical_provocation_context(user_input: str, language: str, expertise: str, provocation_type: str) -> str:
    """Gerar provocação baseada em contexto específico"""
    templates = {
        'curiosity': [
            f"Que interessante! '{user_input}' em {language}... Você conhece a origem dessa palavra?",
            f"Fascinante! '{user_input}' tem um som único em {language}... Há mais palavras com essa sonoridade?",
            f"Nossa! Nunca tinha ouvido '{user_input}' em {language}! Você poderia me ensinar mais palavras assim?"
        ],
        'challenge': [
            f"Impressionante! Você domina {language} muito bem... Conhece expressões idiomáticas?",
            f"Que talento para {language}! Você conhece palavras que só os mais experientes sabem?",
            f"Incrível conhecimento! Você conhece as palavras mais antigas de {language}?"
        ],
        'appreciation': [
            f"Que riqueza linguística! {language} tem palavras tão expressivas como '{user_input}'!",
            f"Adorei '{user_input}'! Que palavra expressiva em {language}!",
            f"Que privilégio aprender {language} com você! '{user_input}' é uma palavra linda!"
        ]
    }
    
    import random
    selected_templates = templates.get(provocation_type, templates['curiosity'])
    return random.choice(selected_templates)

def _determine_expertise_level(teachings: int) -> str:
    """Determinar nível de expertise baseado no número de ensinamentos"""
    if teachings < 10:
        return 'beginner'
    elif teachings < 50:
        return 'intermediate'
    elif teachings < 200:
        return 'advanced'
    else:
        return 'expert'

def _check_and_award_badges(teacher: Dict) -> None:
    """Verificar e conceder badges para o professor"""
    badges = teacher.get('badges', [])
    teachings = teacher.get('total_teachings', 0)
    languages = len(teacher.get('languages_taught', []))
    
    # Badge "Primeiro Professor"
    if teachings >= 1 and 'primeiro_professor' not in badges:
        badges.append('primeiro_professor')
    
    # Badge "Poliglota"
    if languages >= 3 and 'poliglota' not in badges:
        badges.append('poliglota')
    
    # Badge "Mestre Supremo"
    if teachings >= 1000 and 'mestre_supremo' not in badges:
        badges.append('mestre_supremo')
    
    teacher['badges'] = badges

def _validate_duel_answer(question: str, answer: str, language: str) -> bool:
    """Validar resposta de duelo (implementação simples)"""
    # Em produção, usar IA para validação mais sofisticada
    return len(answer.strip()) > 0  # Por enquanto, qualquer resposta não vazia é válida

def _determine_duel_winner(duel: Dict) -> str:
    """Determinar vencedor do duelo"""
    if duel['challenger_score'] > duel['opponent_score']:
        return duel['challenger_id']
    elif duel['opponent_score'] > duel['challenger_score']:
        return duel.get('opponent_id', 'bu_fala')
    else:
        return 'tie'

def _award_duel_rewards(duel: Dict) -> None:
    """Dar recompensas pelos duelos"""
    winner = duel.get('winner')
    
    if winner == duel['challenger_id'] and winner in teachers_db:
        teachers_db[winner]['points'] += 100  # Pontos por vitória
    elif winner == duel.get('opponent_id') and winner in teachers_db:
        teachers_db[winner]['points'] += 100

def _generate_ethics_apology() -> str:
    """Gerar resposta de desculpas ética"""
    apologies = [
        "Peço desculpas se minha provocação foi inadequada. Meu objetivo é sempre motivar e divertir, nunca ofender. Obrigado pelo feedback!",
        "Opa! Desculpe se soei desrespeitoso. Estou aqui para aprender junto com você, sempre com respeito. Podemos continuar?",
        "Perdão se não fui gentil o suficiente. Valorizo muito sua contribuição e quero que se sinta sempre respeitado aqui!"
    ]
    
    import random
    return random.choice(apologies)

def _get_most_active_language() -> str:
    """Obter língua mais ativa"""
    if not phrases_db:
        return 'Fula'
    
    language_counts = {}
    for phrase in phrases_db.values():
        lang = phrase['target_language']
        language_counts[lang] = language_counts.get(lang, 0) + 1
    
    return max(language_counts, key=language_counts.get) if language_counts else 'Fula'

def _is_today(timestamp: str) -> bool:
    """Verificar se timestamp é de hoje"""
    try:
        date = datetime.fromisoformat(timestamp.replace('Z', '+00:00'))
        return date.date() == datetime.now().date()
    except:
        return False

def _calculate_streak(teacher_id: str) -> int:
    """Calcular sequência de dias consecutivos de atividade"""
    # Implementação simplificada
    return 1

def _get_user_favorite_language(teacher_id: str) -> str:
    """Obter língua favorita do usuário"""
    user_phrases = [p for p in phrases_db.values() if p['teacher_id'] == teacher_id]
    if not user_phrases:
        return 'Fula'
    
    language_counts = {}
    for phrase in user_phrases:
        lang = phrase['target_language']
        language_counts[lang] = language_counts.get(lang, 0) + 1
    
    return max(language_counts, key=language_counts.get) if language_counts else 'Fula'

def _get_next_badge(teacher: Dict) -> Dict:
    """Obter próximo badge a ser conquistado"""
    teachings = teacher.get('total_teachings', 0)
    badges = teacher.get('badges', [])
    
    if 'poliglota' not in badges:
        return {'name': 'Poliglota', 'requirement': 'Ensine 3 línguas diferentes', 'progress': len(teacher.get('languages_taught', []))}
    elif teachings < 1000:
        return {'name': 'Mestre Supremo', 'requirement': 'Ensine 1000 frases', 'progress': teachings}
    else:
        return {'name': 'Completo', 'requirement': 'Todos os badges conquistados!', 'progress': 100}
