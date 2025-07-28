from flask import Blueprint, request, jsonify
from datetime import datetime
import uuid
import os
import json
from werkzeug.utils import secure_filename
from services import gemma_service
from services.gemma_service import GemmaService
from services.audio_service import AudioService
from utils.validators import validate_language_code, validate_text_input
from utils.file_handler import save_audio_file, save_image_file

collaborative_bp = Blueprint('collaborative', __name__)

# Simulação de banco de dados em memória (em produção, usar banco real)
contributions_db = []
community_stats = {
    'total_contributions': 0,
    'active_contributors': 0,
    'languages_supported': ['pt', 'gcr'],  # Português e Crioulo
    'top_contributors': []
}

@collaborative_bp.route('/collaborative/contribute', methods=['POST'])
def contribute():
    """Nova rota para contribuições (compatível com app Flutter)"""
    return submit_contribution()

@collaborative_bp.route('/collaborative/teach-gemma', methods=['POST'])
def teach_gemma_new_language():
    """
    Ensinar novo idioma ao Gemma3 através de contribuições da comunidade
    
    Esta rota permite que contribuições validadas sejam enviadas ao Gemma3
    para aprendizado de novos idiomas e expressões locais.
    """
    try:
        data = request.get_json()
        
        # Parâmetros obrigatórios
        contributions = data.get('contributions', [])
        target_language = data.get('target_language', 'crioulo')
        learning_context = data.get('learning_context', 'community_contributions')
        
        # Parâmetros opcionais
        validation_level = data.get('validation_level', 'community_approved')
        cultural_context = data.get('cultural_context', 'Guiné-Bissau')
        contributor_profile = data.get('contributor_profile', {})
        
        if not contributions:
            return jsonify({
                'success': False,
                'error': 'Contribuições são obrigatórias'
            }), 400
        
        # Obter serviço Gemma
        from services.gemma_service import GemmaService
        gemma_service = GemmaService()
        
        if gemma_service:
            # Processar contribuições para ensino
            processed_contributions = _process_contributions_for_teaching(contributions)
            
            # Usar funcionalidade especializada de ensino de idiomas
            teaching_result = gemma_service.language_teaching(
                target_language=target_language,
                current_level='community_input',
                focus_area='vocabulary_expansion',
                learning_context=learning_context,
                user_profile={
                    'source': 'community_contributions',
                    'validation_level': validation_level,
                    'cultural_context': cultural_context,
                    'contributor_info': contributor_profile,
                    'contributions_data': processed_contributions
                }
            )
            
            # Registrar aprendizado no sistema
            learning_record = {
                'timestamp': datetime.now().isoformat(),
                'target_language': target_language,
                'contributions_count': len(contributions),
                'validation_level': validation_level,
                'teaching_result': teaching_result.get('success', False),
                'cultural_context': cultural_context
            }
            
            # Salvar registro de aprendizado (implementar persistência se necessário)
            _save_learning_record(learning_record)
            
            return jsonify({
                'success': True,
                'message': f'Gemma3 aprendeu {len(contributions)} novas contribuições em {target_language}',
                'teaching_result': teaching_result,
                'learning_record': learning_record,
                'metadata': {
                    'specialized_ai_learning': True,
                    'community_driven': True,
                    'language_preservation': True
                }
            })
        else:
            # Fallback se Gemma não estiver disponível
            return jsonify({
                'success': True,
                'message': 'Contribuições registradas para aprendizado futuro',
                'contributions_processed': len(contributions),
                'status': 'queued_for_learning',
                'fallback': True
            })
            
    except Exception as e:
        return jsonify({
            'success': False,
            'error': 'Erro interno do servidor',
            'details': str(e)
        }), 500

def _process_contributions_for_teaching(contributions):
    """Processa contribuições para formato adequado ao ensino do Gemma"""
    processed = []
    for contrib in contributions:
        processed.append({
            'word': contrib.get('word'),
            'translation': contrib.get('translation'),
            'source_language': contrib.get('source_language'),
            'target_language': contrib.get('target_language'),
            'context': contrib.get('context', ''),
            'category': contrib.get('category', 'general'),
            'audio_available': bool(contrib.get('audio_url')),
            'verification_level': contrib.get('votes', {}).get('up', 0)
        })
    return processed

def _save_learning_record(record):
    """Salva registro de aprendizado (implementar persistência conforme necessário)"""
    # Por enquanto, apenas log - implementar persistência em produção
    print(f"Learning record saved: {record['timestamp']} - {record['target_language']}")

@collaborative_bp.route('/collaborative/submit-contribution', methods=['POST'])
def submit_contribution():
    """Submete uma nova contribuição de idioma"""
    try:
        data = request.get_json()
        
        # Validação dos dados obrigatórios
        required_fields = ['word', 'translation']
        for field in required_fields:
            if not data.get(field):
                return jsonify({
                    'success': False,
                    'error': f'Campo obrigatório ausente: {field}'
                }), 400
        
        # Obter idioma (compatibilidade com Flutter)
        language = data.get('language', 'crioulo-gb')
        source_language = data.get('source_language', language)
        target_language = data.get('target_language', 'pt')
        
        # Validação dos idiomas
        if not validate_language_code(source_language) or not validate_language_code(target_language):
            return jsonify({
                'success': False,
                'error': 'Código de idioma inválido'
            }), 400
        
        # Validação do texto
        if not validate_text_input(data['word']) or not validate_text_input(data['translation']):
            return jsonify({
                'success': False,
                'error': 'Texto inválido ou muito longo'
            }), 400
        
        # Criar nova contribuição
        contribution = {
            'id': str(uuid.uuid4()),
            'word': data['word'].strip(),
            'translation': data['translation'].strip(),
            'source_language': source_language,
            'target_language': target_language,
            'category': data.get('category', 'geral'),
            'context': data.get('context', ''),
            'contributor_id': data.get('contributor_id', 'anonymous'),
            'audio_url': data.get('audio_path'),
            'image_url': data.get('image_path'),
            'created_at': datetime.now().isoformat(),
            'status': 'pending',
            'votes': {'up': 0, 'down': 0},
            'verified': False
        }
        
        # Adicionar à base de dados
        contributions_db.append(contribution)
        
        # Atualizar estatísticas
        community_stats['total_contributions'] += 1
        
        # Processar contribuição com Moransa (Gemma-3)
        try:
            gemma_service_instance = GemmaService()
            analysis = gemma_service_instance.process_user_contribution({
                'word': contribution['word'],
                'translation': contribution['translation'],
                'language': contribution['source_language'],
                'category': contribution['category'],
                'context': contribution['context']
            })
            
            # Enriquecer contribuição com análise da IA
            if analysis.get('success'):
                analysis_result = analysis.get('analysis_result', {})
                
                # Melhorar contexto se disponível
                enhanced_context = analysis_result.get('context_enhancement', contribution['context'])
                if enhanced_context != contribution['context']:
                    contribution['context'] = enhanced_context
                
                # Adicionar tags sugeridas
                suggested_tags = analysis_result.get('tag_suggestion', [])
                contribution['suggested_tags'] = suggested_tags
                
                # Ajustar status baseado na recomendação
                recommendation = analysis_result.get('approval_recommendation', 'pending_community_vote')
                if recommendation == 'requires_moderator_review':
                    contribution['status'] = 'pending_review'
                
                print(f"Contribuição analisada pela IA: score={analysis_result.get('quality_assessment', {}).get('score', 0)}")
        
        except Exception as e:
            print(f"Erro ao processar contribuição com IA: {e}")
            # Continuar sem análise da IA
            analysis = None
        
        return jsonify({
            'success': True,
            'contribution_id': contribution['id'],
            'message': 'Contribuição submetida com sucesso!',
            'ai_analysis': analysis.get('analysis_result') if analysis and analysis.get('success') else None
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Erro interno: {str(e)}'
        }), 500

# ========== ENDPOINTS ESPECÍFICOS DO MORANSA ==========

@collaborative_bp.route('/collaborative/generate-challenges', methods=['POST'])
def generate_translation_challenges():
    """Gerar desafios de tradução usando Moransa (Gemma-3)"""
    try:
        data = request.get_json()
        category = data.get('category', 'geral')
        difficulty = data.get('difficulty', 'básico')
        quantity = data.get('quantity', 5)
        existing_phrases = data.get('existing_phrases', [])
        
        # Validações
        if quantity > 20:
            return jsonify({'error': 'Máximo de 20 desafios por vez'}), 400
        
        if category not in ['médica', 'educação', 'agricultura', 'geral']:
            return jsonify({'error': 'Categoria inválida'}), 400
        
        # Gerar desafios com Moransa
        gemma_service_instance = GemmaService()
        
        # Executar de forma síncrona
        import asyncio
        try:
            loop = asyncio.get_event_loop()
        except RuntimeError:
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
        
        result = loop.run_until_complete(gemma_service_instance.generate_translation_challenges(
            category=category,
            difficulty=difficulty,
            quantity=quantity,
            existing_phrases=existing_phrases
        ))
        
        if result.get('success'):
            return jsonify({
                'success': True,
                'challenges': result['challenges'],
                'generated_count': result['generated_count'],
                'category': category,
                'difficulty': difficulty,
                'fallback_used': result.get('fallback', False)
            })
        else:
            return jsonify({
                'success': False,
                'error': result.get('error', 'Falha ao gerar desafios'),
                'challenges': result.get('challenges', [])
            }), 500
    
    except Exception as e:
        return jsonify({'error': 'Erro interno do servidor'}), 500

@collaborative_bp.route('/collaborative/educational-content', methods=['POST'])
def generate_educational_content():
    """Gerar conteúdo educacional usando Moransa (Gemma-3)"""
    try:
        data = request.get_json()
        subject = data.get('subject', 'primeiros socorros')
        level = data.get('level', 'básico')
        topic = data.get('topic')
        
        # Validações
        valid_subjects = ['primeiros socorros', 'agricultura', 'educação', 'saúde', 'comunidade']
        if subject not in valid_subjects:
            return jsonify({'error': f'Assunto deve ser um de: {", ".join(valid_subjects)}'}), 400
        
        valid_levels = ['básico', 'intermediário', 'avançado']
        if level not in valid_levels:
            return jsonify({'error': f'Nível deve ser um de: {", ".join(valid_levels)}'}), 400
        
        # Gerar conteúdo com Moransa
        gemma_service_instance = GemmaService()
        
        # Executar de forma síncrona
        import asyncio
        try:
            loop = asyncio.get_event_loop()
        except RuntimeError:
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
        
        result = loop.run_until_complete(gemma_service_instance.generate_educational_content(
            subject=subject,
            level=level,
            topic=topic
        ))
        
        if result.get('success'):
            return jsonify({
                'success': True,
                'educational_content': result['educational_content'],
                'subject': subject,
                'level': level,
                'topic': topic,
                'fallback_used': result.get('fallback', False)
            })
        else:
            return jsonify({
                'success': False,
                'error': result.get('error', 'Falha ao gerar conteúdo'),
                'educational_content': result.get('educational_content', {})
            }), 500
    
    except Exception as e:
        return jsonify({'error': 'Erro interno do servidor'}), 500

@collaborative_bp.route('/collaborative/analyze-contribution', methods=['POST'])
def analyze_contribution():
    """Analisar uma contribuição específica usando Moransa (Gemma-3)"""
    try:
        data = request.get_json()
        
        # Validar campos obrigatórios
        required_fields = ['word', 'translation']
        for field in required_fields:
            if not data.get(field):
                return jsonify({'error': f'Campo obrigatório: {field}'}), 400
        
        # Processar com Moransa
        gemma_service_instance = GemmaService()
        
        # Executar de forma síncrona
        import asyncio
        try:
            loop = asyncio.get_event_loop()
        except RuntimeError:
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
        
        result = loop.run_until_complete(gemma_service_instance.process_user_contribution(data))
        
        if result.get('success'):
            return jsonify({
                'success': True,
                'analysis': result['analysis_result'],
                'fallback_used': result.get('fallback', False)
            })
        else:
            return jsonify({
                'success': False,
                'error': result.get('error', 'Falha ao analisar contribuição'),
                'analysis': result.get('analysis_result', {})
            }), 500
    
    except Exception as e:
        return jsonify({'error': 'Erro interno do servidor'}), 500

@collaborative_bp.route('/collaborative/moransa-status', methods=['GET'])
def get_moransa_status():
    """Verificar status do sistema Moransa"""
    try:
        gemma_service_instance = GemmaService()
        
        # Verificar se o serviço está disponível
        status = {
            'moransa_available': True,
            'gemma_service_loaded': hasattr(gemma_service_instance, 'model'),
            'ollama_available': False,
            'fallback_mode': True,
            'supported_categories': ['médica', 'educação', 'agricultura', 'geral'],
            'supported_languages': ['português', 'crioulo', 'fula', 'mandinga', 'balanta'],
            'max_challenges_per_request': 20,
            'version': '1.0.0'
        }
        
        # Tentar verificar Ollama se disponível
        try:
            import asyncio
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            ollama_status = loop.run_until_complete(gemma_service_instance._check_ollama_availability())
            status['ollama_available'] = ollama_status
            status['fallback_mode'] = not ollama_status
            loop.close()
        except:
            pass
        
        return jsonify({
            'success': True,
            'status': status
        })
    
    except Exception as e:
        return jsonify({
            'success': False,
            'error': 'Erro ao verificar status',
            'status': {
                'moransa_available': False,
                'error': str(e)
            }
        }), 500

@collaborative_bp.route('/collaborative/contributions', methods=['GET'])
def get_contributions():
    """Obtém contribuições da comunidade com filtros"""
    try:
        # Parâmetros de filtro
        language = request.args.get('language')
        category = request.args.get('category')
        status = request.args.get('status', 'approved')
        limit = int(request.args.get('limit', 50))
        offset = int(request.args.get('offset', 0))
        
        # Filtrar contribuições
        filtered_contributions = contributions_db.copy()
        
        if language:
            filtered_contributions = [
                c for c in filtered_contributions 
                if c['source_language'] == language or c['target_language'] == language
            ]
        
        if category:
            filtered_contributions = [
                c for c in filtered_contributions 
                if c['category'] == category
            ]
        
        if status:
            filtered_contributions = [
                c for c in filtered_contributions 
                if c['status'] == status
            ]
        
        # Paginação
        total = len(filtered_contributions)
        paginated_contributions = filtered_contributions[offset:offset + limit]
        
        return jsonify({
            'success': True,
            'contributions': paginated_contributions,
            'total': total,
            'offset': offset,
            'limit': limit
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Erro interno: {str(e)}'
        }), 500

@collaborative_bp.route('/collaborative/vote-contribution', methods=['POST'])
def vote_contribution():
    """Vota em uma contribuição"""
    try:
        data = request.get_json()
        contribution_id = data.get('contribution_id')
        vote_type = data.get('vote_type')  # 'up' ou 'down'
        
        if not contribution_id or vote_type not in ['up', 'down']:
            return jsonify({
                'success': False,
                'error': 'Dados de voto inválidos'
            }), 400
        
        # Encontrar contribuição
        contribution = next((c for c in contributions_db if c['id'] == contribution_id), None)
        if not contribution:
            return jsonify({
                'success': False,
                'error': 'Contribuição não encontrada'
            }), 404
        
        # Atualizar voto
        contribution['votes'][vote_type] += 1
        
        # Auto-aprovar se tiver votos suficientes
        if contribution['votes']['up'] >= 3 and contribution['status'] == 'pending':
            contribution['status'] = 'approved'
            contribution['verified'] = True
        
        return jsonify({
            'success': True,
            'votes': contribution['votes'],
            'status': contribution['status']
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Erro interno: {str(e)}'
        }), 500

@collaborative_bp.route('/collaborative/community-stats', methods=['GET'])
def get_community_stats():
    """Obtém estatísticas da comunidade"""
    try:
        # Calcular estatísticas em tempo real
        approved_contributions = [c for c in contributions_db if c['status'] == 'approved']
        unique_contributors = set(c['contributor_id'] for c in contributions_db if c['contributor_id'] != 'anonymous')
        
        # Top contribuidores
        contributor_counts = {}
        for contribution in approved_contributions:
            contributor_id = contribution['contributor_id']
            if contributor_id != 'anonymous':
                contributor_counts[contributor_id] = contributor_counts.get(contributor_id, 0) + 1
        
        top_contributors = [
            {'id': contributor_id, 'contributions': count}
            for contributor_id, count in sorted(contributor_counts.items(), key=lambda x: x[1], reverse=True)[:10]
        ]
        
        stats = {
            'total_contributions': len(approved_contributions),
            'pending_contributions': len([c for c in contributions_db if c['status'] == 'pending']),
            'active_contributors': len(unique_contributors),
            'languages_supported': list(set(
                [c['source_language'] for c in approved_contributions] + 
                [c['target_language'] for c in approved_contributions]
            )),
            'top_contributors': top_contributors,
            'categories': list(set(c['category'] for c in approved_contributions))
        }
        
        return jsonify({
            'success': True,
            'stats': stats
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Erro interno: {str(e)}'
        }), 500

@collaborative_bp.route('/collaborative/language-progress', methods=['GET'])
def get_language_progress():
    """Obtém progresso de aprendizado de idiomas"""
    try:
        language = request.args.get('language', 'gcr')  # Default para Crioulo
        
        # Calcular progresso
        language_contributions = [
            c for c in contributions_db 
            if (c['source_language'] == language or c['target_language'] == language) 
            and c['status'] == 'approved'
        ]
        
        # Categorizar por tipo
        categories = {}
        for contribution in language_contributions:
            category = contribution['category']
            if category not in categories:
                categories[category] = {
                    'total': 0,
                    'with_audio': 0,
                    'verified': 0
                }
            
            categories[category]['total'] += 1
            if contribution.get('audio_url'):
                categories[category]['with_audio'] += 1
            if contribution.get('verified'):
                categories[category]['verified'] += 1
        
        progress = {
            'language': language,
            'total_words': len(language_contributions),
            'categories': categories,
            'completion_percentage': min(100, (len(language_contributions) / 1000) * 100),  # Meta de 1000 palavras
            'last_updated': datetime.now().isoformat()
        }
        
        return jsonify({
            'success': True,
            'progress': progress
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Erro interno: {str(e)}'
        }), 500

@collaborative_bp.route('/collaborative/validate-audio', methods=['POST'])
def validate_audio():
    """Valida contribuição de áudio"""
    try:
        # Implementação básica - em produção, usar serviços de reconhecimento de voz
        data = request.get_json()
        audio_url = data.get('audio_url')
        expected_text = data.get('expected_text')
        
        if not audio_url or not expected_text:
            return jsonify({
                'success': False,
                'error': 'URL de áudio e texto esperado são obrigatórios'
            }), 400
        
        # Simulação de validação (em produção, usar STT)
        validation_result = {
            'is_valid': True,  # Assumir válido por enquanto
            'confidence': 0.85,
            'transcribed_text': expected_text,  # Simulação
            'quality_score': 0.9
        }
        
        return jsonify({
            'success': True,
            'validation': validation_result
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Erro interno: {str(e)}'
        }), 500

@collaborative_bp.route('/collaborative/search-contributions', methods=['GET'])
def search_contributions():
    """Busca contribuições por texto"""
    try:
        query = request.args.get('q', '').strip().lower()
        language = request.args.get('language')
        limit = int(request.args.get('limit', 20))
        
        if not query:
            return jsonify({
                'success': False,
                'error': 'Query de busca é obrigatória'
            }), 400
        
        # Buscar em contribuições aprovadas
        results = []
        for contribution in contributions_db:
            if contribution['status'] != 'approved':
                continue
            
            # Filtrar por idioma se especificado
            if language and contribution['source_language'] != language and contribution['target_language'] != language:
                continue
            
            # Buscar no texto
            if (query in contribution['word'].lower() or 
                query in contribution['translation'].lower() or 
                query in contribution.get('context', '').lower()):
                results.append(contribution)
        
        # Limitar resultados
        results = results[:limit]
        
        return jsonify({
            'success': True,
            'results': results,
            'total': len(results)
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Erro interno: {str(e)}'
        }), 500

@collaborative_bp.route('/collaborative/word-suggestions', methods=['GET'])
def get_word_suggestions():
    """Obtém sugestões de palavras para contribuir"""
    try:
        language = request.args.get('language', 'gcr')
        category = request.args.get('category', 'general')
        
        # Palavras básicas sugeridas por categoria
        suggestions = {
            'health': ['dor', 'febre', 'remédio', 'médico', 'hospital', 'doente', 'saúde'],
            'agriculture': ['planta', 'colheita', 'terra', 'água', 'semente', 'fruto', 'árvore'],
            'education': ['escola', 'professor', 'livro', 'aprender', 'estudar', 'conhecimento'],
            'family': ['mãe', 'pai', 'filho', 'filha', 'irmão', 'irmã', 'família'],
            'general': ['casa', 'comida', 'água', 'trabalho', 'dinheiro', 'tempo', 'pessoa']
        }
        
        # Filtrar palavras já contribuídas
        existing_words = set(
            c['word'].lower() for c in contributions_db 
            if c['source_language'] == 'pt' and c['target_language'] == language
        )
        
        category_suggestions = suggestions.get(category, suggestions['general'])
        needed_words = [word for word in category_suggestions if word.lower() not in existing_words]
        
        return jsonify({
            'success': True,
            'suggestions': needed_words[:10],  # Máximo 10 sugestões
            'category': category,
            'language': language
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Erro interno: {str(e)}'
        }), 500

@collaborative_bp.route('/collaborative/report-contribution', methods=['POST'])
def report_contribution():
    """Reporta uma contribuição inadequada"""
    try:
        data = request.get_json()
        contribution_id = data.get('contribution_id')
        reason = data.get('reason')
        
        if not contribution_id or not reason:
            return jsonify({
                'success': False,
                'error': 'ID da contribuição e motivo são obrigatórios'
            }), 400
        
        # Encontrar contribuição
        contribution = next((c for c in contributions_db if c['id'] == contribution_id), None)
        if not contribution:
            return jsonify({
                'success': False,
                'error': 'Contribuição não encontrada'
            }), 404
        
        # Adicionar report
        if 'reports' not in contribution:
            contribution['reports'] = []
        
        contribution['reports'].append({
            'reason': reason,
            'reported_at': datetime.now().isoformat(),
            'reporter_id': data.get('reporter_id', 'anonymous')
        })
        
        # Auto-remover se muitos reports
        if len(contribution['reports']) >= 3:
            contribution['status'] = 'rejected'
        
        return jsonify({
            'success': True,
            'message': 'Contribuição reportada com sucesso'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Erro interno: {str(e)}'
        }), 500

# Rotas de Gamificação

@collaborative_bp.route('/gamification/challenge', methods=['POST'])
def generate_gamification_challenge():
    """Gera um desafio de gamificação personalizado"""
    try:
        data = request.get_json()
        
        # Parâmetros obrigatórios
        challenge_type = data.get('challenge_type', 'translation')
        user_level = data.get('user_level', 'iniciante')
        
        # Parâmetros opcionais
        category = data.get('category')
        user_profile = data.get('user_profile', {})
        
        # Obter serviço Gemma
        from services.gemma_service import GemmaService
        gemma_service = GemmaService()
        
        if gemma_service:
            # Gerar desafio usando Gemma-3
            challenge_result = gemma_service.generate_gamification_challenge(
                challenge_type=challenge_type,
                user_level=user_level,
                category=category,
                user_profile=user_profile
            )
            
            return jsonify({
                'success': True,
                'challenge': challenge_result.get('challenge'),
                'metadata': {
                    'ai_generated': True,
                    'personalized': True,
                    'adaptive_difficulty': True
                }
            })
        else:
            return jsonify({
                'success': False,
                'error': 'Serviço de IA não disponível'
            }), 503
            
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Erro interno: {str(e)}'
        }), 500

@collaborative_bp.route('/gamification/reward', methods=['POST'])
def generate_reward_message():
    """Gera mensagem de recompensa personalizada"""
    try:
        data = request.get_json()
        
        # Parâmetros obrigatórios
        achievement_type = data.get('achievement_type', 'challenge_completed')
        points_earned = data.get('points_earned', 0)
        
        # Parâmetros opcionais
        user_data = data.get('user_data', {})
        
        # Obter serviço Gemma
        from services.gemma_service import GemmaService
        gemma_service = GemmaService()
        
        if gemma_service:
            # Gerar mensagem de recompensa usando Gemma-3
            reward_result = gemma_service.generate_reward_message(
                achievement_type=achievement_type,
                points_earned=points_earned,
                user_data=user_data
            )
            
            return jsonify({
                'success': True,
                'reward_message': reward_result.get('reward_message'),
                'metadata': {
                    'ai_generated': True,
                    'personalized': True,
                    'motivational': True
                }
            })
        else:
            return jsonify({
                'success': False,
                'error': 'Serviço de IA não disponível'
            }), 503
            
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Erro interno: {str(e)}'
        }), 500

@collaborative_bp.route('/gamification/badge', methods=['POST'])
def create_badge():
    """Cria um badge dinâmico baseado em conquistas"""
    try:
        data = request.get_json()
        
        # Parâmetros obrigatórios
        achievement_data = data.get('achievement_data', {})
        
        if not achievement_data:
            return jsonify({
                'success': False,
                'error': 'Dados de conquista são obrigatórios'
            }), 400
        
        # Obter serviço Gemma
        from services.gemma_service import GemmaService
        gemma_service = GemmaService()
        
        if gemma_service:
            # Criar badge usando Gemma-3
            badge_result = gemma_service.create_badge(
                achievement_data=achievement_data
            )
            
            return jsonify({
                'success': True,
                'badge': badge_result.get('badge'),
                'metadata': {
                    'ai_generated': True,
                    'dynamic_design': True,
                    'achievement_based': True
                }
            })
        else:
            return jsonify({
                'success': False,
                'error': 'Serviço de IA não disponível'
            }), 503
            
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Erro interno: {str(e)}'
        }), 500

@collaborative_bp.route('/gamification/leaderboard', methods=['GET'])
def get_leaderboard():
    """Obtém ranking de usuários"""
    try:
        category = request.args.get('category', 'all')
        time_period = request.args.get('time_period', 'all_time')  # all_time, monthly, weekly
        limit = int(request.args.get('limit', 10))
        
        # Simulação de dados de leaderboard (em produção, usar banco real)
        leaderboard_data = [
            {
                'user_id': 'user1',
                'username': 'Maria Silva',
                'points': 1250,
                'level': 'Avançado',
                'badges': 8,
                'contributions': 45,
                'rank': 1
            },
            {
                'user_id': 'user2',
                'username': 'João Santos',
                'points': 980,
                'level': 'Intermediário',
                'badges': 6,
                'contributions': 32,
                'rank': 2
            },
            {
                'user_id': 'user3',
                'username': 'Ana Costa',
                'points': 750,
                'level': 'Intermediário',
                'badges': 4,
                'contributions': 28,
                'rank': 3
            }
        ]
        
        # Filtrar por categoria se especificado
        if category != 'all':
            # Em produção, filtrar dados reais por categoria
            pass
        
        # Limitar resultados
        leaderboard_data = leaderboard_data[:limit]
        
        return jsonify({
            'success': True,
            'leaderboard': leaderboard_data,
            'metadata': {
                'category': category,
                'time_period': time_period,
                'total_users': len(leaderboard_data)
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Erro interno: {str(e)}'
        }), 500

@collaborative_bp.route('/gamification/user-progress', methods=['GET'])
def get_user_progress():
    """Obtém progresso do usuário"""
    try:
        user_id = request.args.get('user_id')
        
        if not user_id:
            return jsonify({
                'success': False,
                'error': 'ID do usuário é obrigatório'
            }), 400
        
        # Simulação de dados de progresso (em produção, usar banco real)
        user_progress = {
            'user_id': user_id,
            'current_level': 'Intermediário',
            'total_points': 750,
            'points_to_next_level': 250,
            'badges_earned': [
                {
                    'name': 'Tradutor Bronze',
                    'description': 'Completou 10 traduções',
                    'icon': '🌐',
                    'earned_at': '2024-01-15T10:30:00Z'
                },
                {
                    'name': 'Ajudante Comunitário',
                    'description': 'Ajudou 5 pessoas',
                    'icon': '🤝',
                    'earned_at': '2024-01-20T14:15:00Z'
                }
            ],
            'recent_achievements': [
                {
                    'type': 'challenge_completed',
                    'description': 'Completou desafio de tradução',
                    'points': 15,
                    'date': '2024-01-25T09:00:00Z'
                }
            ],
            'statistics': {
                'challenges_completed': 12,
                'contributions_made': 28,
                'words_translated': 45,
                'community_helps': 8
            }
        }
        
        return jsonify({
            'success': True,
            'progress': user_progress
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Erro interno: {str(e)}'
        }), 500