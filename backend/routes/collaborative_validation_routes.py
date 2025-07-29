#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Routes para Sistema de Validação Comunitária - Moransa

Este módulo implementa:
- Geração de frases em português via Gemma-3n
- Sistema de validação comunitária
- Gamificação com pontos e rankings
- Modo Colaborador vs Modo Socorrista
"""

from flask import Blueprint, request, jsonify
from typing import List, Dict, Any, Optional
from datetime import datetime, timedelta
import logging
import json

from services.gemma_service import GemmaService
from config.settings import BackendConfig

logger = logging.getLogger(__name__)

# Configuração de pontos para gamificação - Sistema de Validação Colaborativa
POINTS_CONFIG = {
    'translation_submitted': 1,        # Pontos por propor uma tradução
    'validation_submitted': 2,         # Pontos por validar uma tradução
    'translation_validated_bonus': 10, # Bônus quando sua tradução é aprovada
    'daily_login': 1,
    'streak_bonus': 2,
    'challenge_completed': 10,
    'audio_recording': 3,              # Pontos por gravar áudio da tradução
    'first_validation': 5,             # Bônus pela primeira validação do dia
    'consensus_vote': 3,               # Bônus quando seu voto está na maioria
    'approved_translation': 25
}

VALIDATION_THRESHOLD = 3  # Votos necessários para validar
APPROVAL_RATIO = 0.7  # 70% de aprovação necessária

def generate_portuguese_phrases():
    """
    Gera novas frases em português usando Gemma-3n para serem traduzidas pela comunidade.
    Esta é a função principal do Gemma-3n no novo sistema com seleção inteligente baseada no dispositivo.
    """
    try:
        data = request.get_json()
        category = data.get('category', 'geral')
        difficulty = data.get('difficulty', 'básico')
        quantity = data.get('quantity', 10)
        
        # Especificações do dispositivo do usuário (opcional)
        device_specs = data.get('device_specs', {
            'ram_gb': data.get('ram_gb'),
            'cpu_cores': data.get('cpu_cores'),
            'has_gpu': data.get('has_gpu', False),
            'device_type': data.get('device_type', 'unknown')  # mobile, tablet, desktop
        })
        
        # Validações
        if quantity > 50:
            return jsonify({'success': False, 'error': 'Máximo de 50 frases por vez'}), 400
        
        logger.info(f"🎯 Gerando {quantity} frases para categoria '{category}' (dispositivo: {device_specs.get('device_type', 'unknown')})")
        
        # Inicializar Gemma-3n para geração de conteúdo
        gemma_service = GemmaService(domain="content_generation")
        
        # Gerar frases usando Gemma-3n com otimização para dispositivo
        result = gemma_service.generate_new_portuguese_phrases(
            category=category,
            difficulty=difficulty,
            quantity=quantity,
            existing_phrases=[],
            device_specs=device_specs
        )
        
        if not result['success']:
            return jsonify({'success': False, 'error': 'Erro ao gerar frases'}), 500
        
        # Simular dados salvos (temporário - sem banco de dados)
        saved_phrases = []
        for i, phrase_data in enumerate(result['phrases']):
            saved_phrases.append({
                "id": i + 1,
                "text": phrase_data.get('word', f"Frase exemplo {i+1}"),
                "context": phrase_data.get('context', 'Contexto médico'),
                "difficulty": difficulty,
                "category": category,
                "tags": phrase_data.get('tags', ['emergencia', 'saude'])
            })
        
        logger.info(f"✅ Geradas {len(saved_phrases)} frases para tradução")
        
        return jsonify({
            'success': True,
            'generated_count': len(result['phrases']),
            'saved_count': len(saved_phrases),
            'phrases': saved_phrases,
            'category': category,
            'difficulty': difficulty,
            'gemma_used': result.get('gemma_used', False),
            'message': f"Geradas {len(saved_phrases)} frases para tradução comunitária"
        })
        
    except Exception as e:
        logger.error(f"Erro ao gerar frases: {e}")
        return jsonify({'success': False, 'error': f'Erro interno: {str(e)}'}), 500

def get_phrases_to_translate():
    """
    Obtém frases em português que precisam de tradução para o idioma especificado.
    Agora usa Gemma-3n para gerar frases dinâmicas em vez de dados estáticos.
    """
    try:
        category = request.args.get('category', 'geral')
        language = request.args.get('language', 'crioulo')
        limit = int(request.args.get('limit', 20))
        
        logger.info(f"🎯 Gerando {limit} frases dinâmicas para categoria '{category}' e idioma '{language}'")
        
        # Inicializar Gemma-3n para geração de conteúdo
        gemma_service = GemmaService(domain="content_generation")
        
        # Especificações padrão do dispositivo (pode ser expandido para receber do cliente)
        device_specs = {
            'ram_gb': 8,
            'cpu_cores': 4,
            'has_gpu': False,
            'device_type': 'web'
        }
        
        # Gerar frases usando Gemma-3n
        result = gemma_service.generate_new_portuguese_phrases(
            category=category,
            difficulty='basico',
            quantity=min(limit, 10),  # Limitar para performance
            existing_phrases=[],
            device_specs=device_specs
        )
        
        if not result['success']:
            logger.warning(f"Falha na geração do Gemma-3n, usando fallback")
            # Fallback para dados mock apenas se Gemma-3n falhar
            mock_phrases = [
                {
                    'id': 1,
                    'text': 'Aplique pressão direta na ferida para controlar o sangramento',
                    'category': category,
                    'difficulty': 'basico',
                    'context': 'Emergência médica em área rural',
                    'tags': ['hemorragia', 'primeiros_socorros'],
                    'created_at': datetime.now().isoformat()
                },
                {
                    'id': 2,
                    'text': 'Verifique se a pessoa está consciente e respirando',
                    'category': category,
                    'difficulty': 'basico',
                    'context': 'Avaliação inicial de emergência',
                    'tags': ['consciencia', 'respiracao'],
                    'created_at': datetime.now().isoformat()
                }
            ]
            
            phrases_result = mock_phrases[:limit]
        else:
            # Converter frases do Gemma-3n para o formato esperado
            phrases_result = []
            for i, phrase_data in enumerate(result['phrases']):
                phrases_result.append({
                    'id': i + 1,
                    'text': phrase_data.get('text', phrase_data.get('word', f"Frase {i+1}")),
                    'category': category,
                    'difficulty': 'basico',
                    'context': phrase_data.get('context', 'Contexto gerado pelo Gemma-3n'),
                    'tags': phrase_data.get('tags', [category]),
                    'created_at': datetime.now().isoformat()
                })
            
            logger.info(f"✅ Geradas {len(phrases_result)} frases dinâmicas usando Gemma-3n")
        
        return jsonify({
            'success': True,
            'phrases': phrases_result,
            'count': len(phrases_result),
            'filters': {
                'category': category,
                'language': language
            },
            'gemma_generated': result.get('success', False),
            'device_optimized': result.get('device_optimized', False)
        })
        
    except Exception as e:
        logger.error(f"Erro ao buscar frases: {e}")
        return jsonify({'success': False, 'error': f'Erro interno: {str(e)}'}), 500

def propose_translation():
    """
    Propõe uma tradução para uma frase em português.
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'success': False, 'error': 'JSON inválido ou vazio'}), 400
            
        phrase_id = data.get('phrase_id')
        language = data.get('language')
        translation = data.get('translation')
        
        if not phrase_id or not language or not translation:
            return jsonify({'success': False, 'error': 'Campos obrigatórios: phrase_id, language, translation'}), 400
        
        # Mock response para demonstração
        return jsonify({
            'success': True,
            'translation_id': 1,
            'phrase_id': phrase_id,
            'language': language,
            'translation': translation,
            'status': 'pending_validation',
            'points_earned': POINTS_CONFIG['translation_submitted'],
            'message': 'Tradução proposta com sucesso! Aguardando validação da comunidade.'
        })
        
    except Exception as e:
        logger.error(f"Erro ao propor tradução: {e}")
        return jsonify({'success': False, 'error': f'Erro interno: {str(e)}'}), 500

def get_translations_to_validate():
    """
    Obtém traduções que precisam de validação pela comunidade.
    Implementa o sistema de "Jogo da Validação" conforme CORRECAO.md
    """
    try:
        language = request.args.get('language')
        category = request.args.get('category')
        limit = int(request.args.get('limit', 20))
        user_id = request.args.get('user_id', 1)  # ID do usuário atual
        
        # Mock data simulando proposed_translations da tabela
        # Em produção, buscar da tabela proposed_translations
        mock_translations = [
            {
                'id': 1,
                'portuguese_phrase_id': 1,
                'phrase': {
                    'id': 1,
                    'text': 'Aplique pressão direta na ferida para controlar o sangramento',
                    'category': 'saude',
                    'context': 'Instrução de primeiros socorros para controle de hemorragia',
                    'tags': ['emergencia', 'sangramento', 'primeiros_socorros']
                },
                'translation': 'Pone forsa na ferida pa para sangi',
                'language': language or 'crioulo',
                'context_notes': 'Tradução para emergência médica',
                'proposer_user_id': 2,  # Diferente do user_id atual
                'validation_score': 1,  # Começa com 1 (voto do proponente)
                'created_at': datetime.now().isoformat(),
                'votes': {
                    'approve': 1,
                    'reject': 0,
                    'improve': 0
                },
                'audio_filepath': None,
                'status': 'pending_validation'
            },
            {
                'id': 2,
                'portuguese_phrase_id': 2,
                'phrase': {
                    'id': 2,
                    'text': 'Você tem alguma dúvida?',
                    'category': 'educacao',
                    'context': 'Pergunta para verificar se há necessidade de esclarecimentos',
                    'tags': ['duvida', 'pergunta', 'clareza']
                },
                'translation': 'Bu tene alguma duvida?',
                'language': language or 'crioulo',
                'context_notes': 'Pergunta comum em sala de aula',
                'proposer_user_id': 3,
                'validation_score': 2,
                'created_at': datetime.now().isoformat(),
                'votes': {
                    'approve': 2,
                    'reject': 0,
                    'improve': 0
                },
                'audio_filepath': None,
                'status': 'pending_validation'
            }
        ]
        
        # Filtrar traduções que o usuário ainda não validou e que não são dele
        # Em produção, fazer JOIN com tabela de votos do usuário
        filtered_translations = [
            t for t in mock_translations 
            if t['proposer_user_id'] != int(user_id) and 
            t['validation_score'] < 3  # Ainda não atingiu o limiar
        ]
        
        result = filtered_translations[:limit]
        
        return jsonify({
            'success': True,
            'translations': result,
            'count': len(result),
            'filters': {
                'language': language,
                'category': category,
                'user_id': user_id
            },
            'validation_rules': {
                'threshold_score': 3,
                'points_for_validation': 2,
                'points_for_proposal': 1,
                'bonus_for_approved': 10
            }
        })
        
    except Exception as e:
        logger.error(f"Erro ao buscar traduções: {e}")
        return jsonify({'success': False, 'error': f'Erro interno: {str(e)}'}), 500

def validate_translation():
    """
    Valida uma tradução proposta pela comunidade.
    Implementa o sistema de votação e promoção conforme CORRECAO.md
    """
    try:
        data = request.get_json()
        translation_id = data.get('translation_id')
        user_id = data.get('user_id', 1)
        vote_type = data.get('vote_type')  # 'approve', 'reject', 'improve'
        feedback = data.get('feedback', '')
        
        if not translation_id or not vote_type:
            return jsonify({'success': False, 'error': 'translation_id e vote_type são obrigatórios'}), 400
            
        if vote_type not in ['approve', 'reject', 'improve']:
            return jsonify({'success': False, 'error': 'vote_type deve ser approve, reject ou improve'}), 400
        
        # Simular busca da tradução na tabela proposed_translations
        # Em produção, buscar do banco de dados
        translation = {
            'id': translation_id,
            'portuguese_phrase_id': 1,
            'proposer_user_id': 2,
            'validation_score': 2,
            'language': 'crioulo',
            'translation': 'Pone forsa na ferida pa para sangi',
            'status': 'pending_validation'
        }
        
        if not translation:
            return jsonify({'success': False, 'error': 'Tradução não encontrada'}), 404
            
        # Verificar se o usuário já votou nesta tradução
        # Em produção, verificar na tabela de votos
        user_already_voted = False  # Mock
        
        if user_already_voted:
            return jsonify({'success': False, 'error': 'Você já votou nesta tradução'}), 400
            
        # Verificar se o usuário não é o proponente
        if translation['proposer_user_id'] == int(user_id):
            return jsonify({'success': False, 'error': 'Você não pode votar na sua própria tradução'}), 400
        
        # Calcular novo score baseado no voto
        score_change = 0
        if vote_type == 'approve':
            score_change = 1
        elif vote_type == 'reject':
            score_change = -1
        elif vote_type == 'improve':
            score_change = 0  # Neutro, mas registra feedback
            
        new_score = translation['validation_score'] + score_change
        
        # Verificar se atingiu o limiar para promoção (score >= 3)
        promoted_to_validated = False
        bonus_points = 0
        
        if new_score >= 3 and translation['status'] == 'pending_validation':
            promoted_to_validated = True
            bonus_points = POINTS_CONFIG.get('translation_validated_bonus', 10)
            
            # Em produção:
            # 1. Mover para tabela validated_translations
            # 2. Atualizar status para 'validated'
            # 3. Dar bônus ao proponente original
            
        # Registrar o voto (em produção, inserir na tabela de votos)
        # INSERT INTO translation_votes (translation_id, user_id, vote_type, feedback, created_at)
        
        # Atualizar score da tradução (em produção, UPDATE proposed_translations)
        
        # Dar pontos ao validador
        validation_points = POINTS_CONFIG.get('validation_submitted', 2)
        
        return jsonify({
            'success': True,
            'message': 'Voto registrado com sucesso!',
            'points_earned': validation_points,
            'new_score': new_score,
            'promoted_to_validated': promoted_to_validated,
            'bonus_points_to_proposer': bonus_points if promoted_to_validated else 0,
            'vote_details': {
                'translation_id': translation_id,
                'vote_type': vote_type,
                'feedback': feedback,
                'voter_id': user_id
            }
        })
        
    except Exception as e:
        logger.error(f"Erro ao validar tradução: {e}")
        return jsonify({'success': False, 'error': f'Erro interno: {str(e)}'}), 500

# Funções auxiliares simplificadas
def _check_user_vote_exists(translation_id, user_id):
    """Valida uma tradução"""
    return jsonify({'success': True, 'message': 'Validação registrada'})

def get_user_stats(user_id):
    """Obtém estatísticas detalhadas do usuário"""
    try:
        # Simular dados mais completos do usuário
        # Em produção, buscar do banco de dados
        user_stats = {
            'user_id': int(user_id),
            'username': f'Usuário {user_id}',
            'total_points': 1250,
            'level': 'Avançado',
            'rank_position': 5,
            'translations_proposed': 45,
            'translations_validated': 78,
            'translations_approved': 32,
            'badges': [
                'Primeiro Tradutor',
                'Tradutor Ativo', 
                'Validador',
                'Aprovado pela Comunidade'
            ],
            'level_progress': {
                'current_level': 'Avançado',
                'current_points': 1250,
                'next_level': 'Especialista',
                'points_to_next': 250,
                'progress_percentage': 83
            },
            'activity_stats': {
                'daily_streak': 7,
                'weekly_contributions': 12,
                'monthly_contributions': 45,
                'favorite_category': 'saúde',
                'favorite_language': 'crioulo'
            },
            'achievements': [
                {
                    'name': 'Tradutor Bronze',
                    'description': 'Completou 10 traduções',
                    'icon': '🥉',
                    'earned_at': '2024-01-15T10:30:00Z'
                },
                {
                    'name': 'Validador Experiente',
                    'description': 'Validou 50 traduções',
                    'icon': '⚖️',
                    'earned_at': '2024-01-20T14:15:00Z'
                },
                {
                    'name': 'Guardião da Qualidade',
                    'description': 'Manteve 90% de precisão nas validações',
                    'icon': '🛡️',
                    'earned_at': '2024-01-25T09:00:00Z'
                }
            ]
        }
        
        return jsonify({
            'success': True,
            'user_stats': user_stats
        })
        
    except Exception as e:
        logger.error(f'Erro ao obter estatísticas do usuário {user_id}: {e}')
        return jsonify({
            'success': False,
            'error': 'Erro interno do servidor'
        }), 500

def get_leaderboard():
    """Obtém ranking detalhado da comunidade"""
    try:
        limit = int(request.args.get('limit', 50))
        time_period = request.args.get('time_period', 'all_time')  # all_time, monthly, weekly
        category = request.args.get('category', 'all')  # all, saude, educacao, agricultura
        
        # Simular dados mais completos do leaderboard
        # Em produção, buscar do banco de dados com filtros
        mock_leaderboard = [
            {
                'position': 1,
                'user_id': 1,
                'username': 'Maria Silva',
                'points': 2150,
                'level': 'Mestre',
                'badges_count': 12,
                'activity': {
                    'proposed': 85,
                    'validated': 156,
                    'approved': 72
                },
                'specialties': ['saúde', 'emergência'],
                'streak_days': 15,
                'avatar': '👩‍⚕️'
            },
            {
                'position': 2,
                'user_id': 2,
                'username': 'João Santos',
                'points': 1890,
                'level': 'Especialista',
                'badges_count': 9,
                'activity': {
                    'proposed': 67,
                    'validated': 134,
                    'approved': 58
                },
                'specialties': ['educação', 'agricultura'],
                'streak_days': 8,
                'avatar': '👨‍🌾'
            },
            {
                'position': 3,
                'user_id': 3,
                'username': 'Fatima Djaló',
                'points': 1650,
                'level': 'Especialista',
                'badges_count': 8,
                'activity': {
                    'proposed': 52,
                    'validated': 98,
                    'approved': 45
                },
                'specialties': ['família', 'cultura'],
                'streak_days': 12,
                'avatar': '👩‍🏫'
            },
            {
                'position': 4,
                'user_id': 4,
                'username': 'Carlos Mendes',
                'points': 1420,
                'level': 'Avançado',
                'badges_count': 6,
                'activity': {
                    'proposed': 43,
                    'validated': 87,
                    'approved': 38
                },
                'specialties': ['comércio', 'natureza'],
                'streak_days': 5,
                'avatar': '👨‍💼'
            },
            {
                'position': 5,
                'user_id': 1,  # Usuário atual
                'username': 'Você',
                'points': 1250,
                'level': 'Avançado',
                'badges_count': 4,
                'activity': {
                    'proposed': 45,
                    'validated': 78,
                    'approved': 32
                },
                'specialties': ['saúde', 'geral'],
                'streak_days': 7,
                'avatar': '👤'
            },
            {
                'position': 6,
                'user_id': 6,
                'username': 'Ana Costa',
                'points': 980,
                'level': 'Intermediário',
                'badges_count': 5,
                'activity': {
                    'proposed': 32,
                    'validated': 65,
                    'approved': 28
                },
                'specialties': ['educação'],
                'streak_days': 3,
                'avatar': '👩‍🎓'
            },
            {
                'position': 7,
                'user_id': 7,
                'username': 'Pedro Gomes',
                'points': 750,
                'level': 'Intermediário',
                'badges_count': 3,
                'activity': {
                    'proposed': 28,
                    'validated': 45,
                    'approved': 22
                },
                'specialties': ['agricultura'],
                'streak_days': 1,
                'avatar': '👨‍🌾'
            }
        ]
        
        # Filtrar por categoria se especificado
        if category != 'all':
            # Em produção, aplicar filtro real no banco de dados
            filtered_leaderboard = []
            for user in mock_leaderboard:
                if category in user.get('specialties', []):
                    filtered_leaderboard.append(user)
            mock_leaderboard = filtered_leaderboard
        
        # Aplicar limite
        leaderboard_data = mock_leaderboard[:limit]
        
        # Estatísticas gerais da comunidade
        community_stats = {
            'total_users': len(mock_leaderboard),
            'active_users_today': 15,
            'translations_today': 42,
            'validations_today': 38,
            'top_category': 'saúde',
            'top_language': 'crioulo'
        }
        
        return jsonify({
            'success': True,
            'leaderboard': leaderboard_data,
            'community_stats': community_stats,
            'filters': {
                'time_period': time_period,
                'category': category,
                'limit': limit
            }
        })
        
    except Exception as e:
        logger.error(f'Erro ao obter leaderboard: {e}')
        return jsonify({
            'success': False,
            'error': 'Erro interno do servidor'
        }), 500

def get_categories():
    """Obtém categorias disponíveis"""
    return jsonify({
        'categories': [
            {'id': 'health', 'name': 'Saúde', 'description': 'Termos médicos e de primeiros socorros'},
            {'id': 'education', 'name': 'Educação', 'description': 'Vocabulário educacional'},
            {'id': 'agriculture', 'name': 'Agricultura', 'description': 'Termos agrícolas e rurais'},
            {'id': 'family', 'name': 'Família', 'description': 'Relações familiares e sociais'}
        ]
    })

def get_supported_languages():
    """Obtém idiomas suportados"""
    return jsonify({
        'languages': [
            {'code': 'gcr', 'name': 'Crioulo da Guiné-Bissau', 'native_name': 'Kriol'},
            {'code': 'ff', 'name': 'Fula', 'native_name': 'Fulfulde'},
            {'code': 'mnk', 'name': 'Mandinga', 'native_name': 'Mandinka'},
            {'code': 'bla', 'name': 'Balanta', 'native_name': 'Balanta'},
            {'code': 'pap', 'name': 'Papel', 'native_name': 'Papel'}
        ]
    })

# Funções auxiliares
def _calculate_user_badges(proposed: int, validated: int, approved: int) -> List[str]:
    """Calcula badges do usuário baseado na atividade."""
    badges = []
    
    if proposed >= 1:
        badges.append("Primeiro Tradutor")
    if proposed >= 10:
        badges.append("Tradutor Ativo")
    if proposed >= 50:
        badges.append("Mestre Tradutor")
    
    if validated >= 10:
        badges.append("Validador")
    if validated >= 50:
        badges.append("Guardião da Qualidade")
    
    if approved >= 5:
        badges.append("Aprovado pela Comunidade")
    if approved >= 20:
        badges.append("Especialista Reconhecido")
    
    return badges

def _calculate_user_level(points: int) -> str:
    """Calcula o nível do usuário baseado nos pontos."""
    if points < 50:
        return "Iniciante"
    elif points < 200:
        return "Colaborador"
    elif points < 500:
        return "Especialista"
    elif points < 1000:
        return "Mestre"
    else:
        return "Lenda"

async def check_validation_threshold(translation_id: int):
    """
    Verifica se uma tradução atingiu o limiar de validação e a promove se necessário.
    """
    from database.database import SessionLocal
    
    db = SessionLocal()
    try:
        translation = db.query(ProposedTranslation).filter(
            ProposedTranslation.id == translation_id
        ).first()
        
        if not translation:
            return
        
        # Contar votos
        votes = db.query(ValidationVote).filter(
            ValidationVote.translation_id == translation_id
        ).all()
        
        if len(votes) >= VALIDATION_THRESHOLD:
            approve_count = len([v for v in votes if v.vote == 'approve'])
            total_votes = len(votes)
            approval_ratio = approve_count / total_votes
            
            if approval_ratio >= APPROVAL_RATIO:
                # Promover para tradução validada
                validated_translation = ValidatedTranslation(
                    phrase_id=translation.phrase_id,
                    language=translation.language,
                    translation=translation.translation,
                    audio_url=translation.audio_url,
                    context_notes=translation.context_notes,
                    original_proposer=translation.proposed_by,
                    validation_score=approval_ratio,
                    total_votes=total_votes
                )
                
                db.add(validated_translation)
                
                # Atualizar status da tradução original
                translation.validation_status = 'approved'
                
                # Dar pontos de bônus ao autor
                author = db.query(User).filter(User.id == translation.proposed_by).first()
                if author:
                    author.points += POINTS_CONFIG['approved_translation']
                
                db.commit()
                
                logger.info(f"✅ Tradução {translation_id} promovida para corpus validado")
            
            elif approval_ratio < 0.3:  # Muito rejeitada
                translation.validation_status = 'rejected'
                db.commit()
                logger.info(f"❌ Tradução {translation_id} rejeitada pela comunidade")
    
    except Exception as e:
        logger.error(f"Erro ao verificar limiar de validação: {e}")
        db.rollback()
    finally:
        db.close()