#!/usr/bin/env python3
"""
Rotas para o Sistema Internacional "Bu Fala Professor para ONGs"
Inspirado no documento APRENDE_COMIGO.md
"""

from flask import Blueprint, request, jsonify, g
from datetime import datetime, timedelta
import logging
import uuid
from typing import Dict, List, Any

logger = logging.getLogger(__name__)

international_bp = Blueprint('international', __name__, url_prefix='/api/international')

# Base de dados simulada (em produção seria um banco real)
organizations_db = {}
professionals_db = {}
modules_db = {}
simulations_db = {}

# Inicializar dados padrão
def init_default_data():
    """Inicializar organizações e módulos padrão"""
    
    # Organizações Internacionais
    organizations_db.update({
        'msf': {
            'id': 'msf',
            'name': 'Médicos Sem Fronteiras',
            'type': 'medical_humanitarian',
            'logo_url': '🏥',
            'languages_needed': ['pt-GW', 'ff', 'mnk', 'bsc'],
            'priority_modules': ['medical_emergency', 'medical_consultation'],
            'urgency_level': 'high',
            'learning_pace': 'intensive',
            'settings': {
                'emergency_training': True,
                'cultural_sensitivity': True,
                'medical_ethics': True
            }
        },
        'unicef': {
            'id': 'unicef',
            'name': 'UNICEF',
            'type': 'education_humanitarian',
            'logo_url': '🎓',
            'languages_needed': ['pt-GW', 'ff', 'mnk', 'bsc'],
            'priority_modules': ['education_basic', 'child_protection'],
            'urgency_level': 'medium',
            'learning_pace': 'progressive',
            'settings': {
                'child_friendly': True,
                'community_engagement': True,
                'cultural_respect': True
            }
        },
        'world_bank': {
            'id': 'world_bank',
            'name': 'Banco Mundial',
            'type': 'development_economic',
            'logo_url': '💼',
            'languages_needed': ['pt-GW', 'ff'],
            'priority_modules': ['business_development', 'agricultural_cooperation'],
            'urgency_level': 'medium',
            'learning_pace': 'business_focused',
            'settings': {
                'economic_focus': True,
                'sustainability': True,
                'community_development': True
            }
        }
    })
    
    # Módulos Especializados
    modules_db.update({
        'medical_emergency_kriol': {
            'id': 'medical_emergency_kriol',
            'name': 'Emergências Médicas - Crioulo',
            'description': 'Vocabulário essencial para atendimento de emergência',
            'profession': 'doctor',
            'target_language': 'pt-GW',
            'difficulty_level': 'emergency',
            'estimated_duration_minutes': 120,
            'lessons': [
                {
                    'id': 'emergency_basics',
                    'title': 'Primeiros Contatos',
                    'description': 'Frases essenciais para emergências',
                    'type': 'emergency',
                    'items': [
                        {
                            'id': 'where_pain',
                            'type': 'phrase',
                            'source_text': 'Onde dói?',
                            'target_text': 'Undi ku bu ten dor?',
                            'pronunciation': 'un-di ku bu ten dor',
                            'context': 'Primeira pergunta em emergência',
                            'importance': 'critical'
                        },
                        {
                            'id': 'breathe_deep',
                            'type': 'phrase',
                            'source_text': 'Respire fundo',
                            'target_text': 'Suspira fundu',
                            'pronunciation': 'sus-pi-ra fun-du',
                            'context': 'Acalmar paciente',
                            'importance': 'critical'
                        },
                        {
                            'id': 'will_examine',
                            'type': 'phrase',
                            'source_text': 'Vou examinar você',
                            'target_text': 'N bai examina bu',
                            'pronunciation': 'n bai e-xa-mi-na bu',
                            'context': 'Antes do exame físico',
                            'importance': 'important'
                        }
                    ],
                    'cultural_context': {
                        'respect': 'Use sempre tom respeitoso',
                        'touch': 'Peça permissão antes de tocar',
                        'family': 'Família pode estar presente'
                    },
                    'is_completed': False
                }
            ],
            'prerequisites': [],
            'icon_url': '🚨',
            'metadata': {
                'urgency': 'critical',
                'scenario': 'hospital_emergency'
            }
        }
    })

# Inicializar dados ao carregar módulo
init_default_data()

@international_bp.route('/health', methods=['GET'])
def health_check():
    """Health check específico do sistema internacional"""
    return jsonify({
        'status': 'healthy',
        'service': 'international_learning',
        'timestamp': datetime.now().isoformat(),
        'stats': {
            'total_organizations': len(organizations_db),
            'total_professionals': len(professionals_db),
            'total_modules': len(modules_db)
        }
    })

# ========================================
# 🏢 ORGANIZAÇÕES INTERNACIONAIS
# ========================================

@international_bp.route('/organizations', methods=['GET'])
def get_organizations():
    """Listar todas as organizações disponíveis"""
    try:
        organizations = list(organizations_db.values())
        return jsonify({
            'success': True,
            'data': organizations,
            'total': len(organizations)
        })
    except Exception as e:
        logger.error(f"Erro ao listar organizações: {e}")
        return jsonify({'error': 'Erro interno do servidor'}), 500

@international_bp.route('/organizations/<org_id>', methods=['GET'])
def get_organization(org_id):
    """Obter detalhes de uma organização específica"""
    try:
        if org_id not in organizations_db:
            return jsonify({'error': 'Organização não encontrada'}), 404
        
        organization = organizations_db[org_id]
        return jsonify({
            'success': True,
            'data': organization
        })
    except Exception as e:
        logger.error(f"Erro ao obter organização {org_id}: {e}")
        return jsonify({'error': 'Erro interno do servidor'}), 500

# ========================================
# 👨‍💼 PROFISSIONAIS INTERNACIONAIS
# ========================================

@international_bp.route('/professionals/register', methods=['POST'])
def register_professional():
    """Registrar novo profissional internacional"""
    try:
        data = request.json
        
        required_fields = ['name', 'email', 'profession', 'native_language', 
                          'organization_id', 'assignment_location', 'target_languages']
        
        for field in required_fields:
            if not data.get(field):
                return jsonify({'error': f'{field} é obrigatório'}), 400
        
        # Verificar se organização existe
        if data['organization_id'] not in organizations_db:
            return jsonify({'error': 'Organização não encontrada'}), 404
        
        professional_id = str(uuid.uuid4())
        organization = organizations_db[data['organization_id']]
        
        professional = {
            'id': professional_id,
            'name': data['name'],
            'email': data['email'],
            'profession': data['profession'],
            'native_language': data['native_language'],
            'spoken_languages': data.get('spoken_languages', []),
            'organization_id': data['organization_id'],
            'organization_name': organization['name'],
            'assignment_location': data['assignment_location'],
            'arrival_date': data.get('arrival_date', datetime.now().isoformat()),
            'departure_date': data.get('departure_date'),
            'target_languages': data['target_languages'],
            'proficiency_levels': {},
            'completed_modules': [],
            'learning_preferences': data.get('learning_preferences', {}),
            'avatar_url': '',
            'created_at': datetime.now().isoformat(),
            'last_activity': datetime.now().isoformat()
        }
        
        # Inicializar níveis de proficiência
        for lang in data['target_languages']:
            professional['proficiency_levels'][lang] = 0
        
        professionals_db[professional_id] = professional
        
        # Gerar recomendações de módulos usando IA
        try:
            recommendations = _generate_module_recommendations(professional)
            professional['recommended_modules'] = recommendations
        except Exception as e:
            logger.warning(f"Erro ao gerar recomendações: {e}")
            professional['recommended_modules'] = []
        
        return jsonify({
            'success': True,
            'data': professional,
            'message': f'Profissional {data["name"]} registrado com sucesso!'
        })
        
    except Exception as e:
        logger.error(f"Erro ao registrar profissional: {e}")
        return jsonify({'error': 'Erro interno do servidor'}), 500

@international_bp.route('/professionals/<professional_id>', methods=['GET'])
def get_professional(professional_id):
    """Obter perfil de profissional"""
    try:
        if professional_id not in professionals_db:
            return jsonify({'error': 'Profissional não encontrado'}), 404
        
        professional = professionals_db[professional_id]
        professional['last_activity'] = datetime.now().isoformat()
        
        return jsonify({
            'success': True,
            'data': professional
        })
    except Exception as e:
        logger.error(f"Erro ao obter profissional {professional_id}: {e}")
        return jsonify({'error': 'Erro interno do servidor'}), 500

# ========================================
# 📚 MÓDULOS ESPECIALIZADOS
# ========================================

@international_bp.route('/modules', methods=['GET'])
def get_modules():
    """Obter módulos disponíveis"""
    try:
        profession = request.args.get('profession')
        target_language = request.args.get('target_language')
        difficulty_level = request.args.get('difficulty_level')
        
        modules = list(modules_db.values())
        
        # Filtrar por profissão
        if profession:
            modules = [m for m in modules if m['profession'] == profession or m['profession'] == 'general']
        
        # Filtrar por idioma
        if target_language:
            modules = [m for m in modules if m['target_language'] == target_language]
        
        # Filtrar por dificuldade
        if difficulty_level:
            modules = [m for m in modules if m['difficulty_level'] == difficulty_level]
        
        return jsonify({
            'success': True,
            'data': modules,
            'total': len(modules)
        })
    except Exception as e:
        logger.error(f"Erro ao listar módulos: {e}")
        return jsonify({'error': 'Erro interno do servidor'}), 500

@international_bp.route('/modules/<module_id>', methods=['GET'])
def get_module(module_id):
    """Obter módulo específico com lições"""
    try:
        if module_id not in modules_db:
            return jsonify({'error': 'Módulo não encontrado'}), 404
        
        module = modules_db[module_id]
        return jsonify({
            'success': True,
            'data': module
        })
    except Exception as e:
        logger.error(f"Erro ao obter módulo {module_id}: {e}")
        return jsonify({'error': 'Erro interno do servidor'}), 500

@international_bp.route('/modules/generate', methods=['POST'])
def generate_custom_module():
    """Gerar módulo personalizado usando IA"""
    try:
        data = request.json
        
        required_fields = ['professional_id', 'profession', 'target_language', 'scenario']
        for field in required_fields:
            if not data.get(field):
                return jsonify({'error': f'{field} é obrigatório'}), 400
        
        if data['professional_id'] not in professionals_db:
            return jsonify({'error': 'Profissional não encontrado'}), 404
        
        professional = professionals_db[data['professional_id']]
        
        # Gerar módulo personalizado usando IA
        custom_module = _generate_custom_module(
            professional=professional,
            profession=data['profession'],
            target_language=data['target_language'],
            scenario=data['scenario'],
            specific_needs=data.get('specific_needs'),
            urgency_hours=data.get('urgency_hours')
        )
        
        # Salvar módulo gerado
        module_id = str(uuid.uuid4())
        custom_module['id'] = module_id
        modules_db[module_id] = custom_module
        
        return jsonify({
            'success': True,
            'data': custom_module,
            'message': 'Módulo personalizado gerado com sucesso!'
        })
        
    except Exception as e:
        logger.error(f"Erro ao gerar módulo personalizado: {e}")
        return jsonify({'error': 'Erro interno do servidor'}), 500

# ========================================
# 🆘 FUNÇÕES DE EMERGÊNCIA
# ========================================

@international_bp.route('/emergency/module', methods=['POST'])
def generate_emergency_module():
    """Gerar módulo de emergência rápido"""
    try:
        data = request.json
        
        required_fields = ['professional_id', 'profession', 'target_language', 
                          'emergency_type', 'hours_until_deployment']
        
        for field in required_fields:
            if not data.get(field):
                return jsonify({'error': f'{field} é obrigatório'}), 400
        
        if data['professional_id'] not in professionals_db:
            return jsonify({'error': 'Profissional não encontrado'}), 404
        
        professional = professionals_db[data['professional_id']]
        
        # Gerar módulo de emergência ultrarrápido
        emergency_module = _generate_emergency_module(
            professional=professional,
            profession=data['profession'],
            target_language=data['target_language'],
            emergency_type=data['emergency_type'],
            hours_until_deployment=data['hours_until_deployment']
        )
        
        module_id = str(uuid.uuid4())
        emergency_module['id'] = module_id
        modules_db[module_id] = emergency_module
        
        return jsonify({
            'success': True,
            'data': emergency_module,
            'message': f'Módulo de emergência criado para {data["hours_until_deployment"]} horas!'
        })
        
    except Exception as e:
        logger.error(f"Erro ao gerar módulo de emergência: {e}")
        return jsonify({'error': 'Erro interno do servidor'}), 500

@international_bp.route('/emergency/phrases', methods=['GET'])
def get_emergency_phrases():
    """Obter frases essenciais para emergência"""
    try:
        profession = request.args.get('profession')
        target_language = request.args.get('target_language')
        emergency_type = request.args.get('emergency_type')
        
        if not all([profession, target_language, emergency_type]):
            return jsonify({'error': 'profession, target_language e emergency_type são obrigatórios'}), 400
        
        # Gerar frases de emergência específicas
        emergency_phrases = _get_emergency_phrases(profession, target_language, emergency_type)
        
        return jsonify({
            'success': True,
            'data': emergency_phrases,
            'total': len(emergency_phrases)
        })
        
    except Exception as e:
        logger.error(f"Erro ao obter frases de emergência: {e}")
        return jsonify({'error': 'Erro interno do servidor'}), 500

# ========================================
# 📊 DASHBOARD E RELATÓRIOS
# ========================================

@international_bp.route('/dashboard/<organization_id>', methods=['GET'])
def get_organization_dashboard(organization_id):
    """Obter dashboard da organização"""
    try:
        if organization_id not in organizations_db:
            return jsonify({'error': 'Organização não encontrada'}), 404
        
        organization = organizations_db[organization_id]
        
        # Obter profissionais da organização
        org_professionals = [p for p in professionals_db.values() 
                           if p['organization_id'] == organization_id]
        
        # Calcular estatísticas
        total_professionals = len(org_professionals)
        active_professionals = len([p for p in org_professionals 
                                  if _is_active_professional(p)])
        
        average_progress = 0
        if org_professionals:
            total_progress = sum(_calculate_professional_progress(p) for p in org_professionals)
            average_progress = total_progress / len(org_professionals)
        
        # Estatísticas por idioma
        language_stats = {}
        for prof in org_professionals:
            for lang in prof['target_languages']:
                language_stats[lang] = language_stats.get(lang, 0) + 1
        
        # Progresso detalhado dos profissionais
        professionals_progress = []
        for prof in org_professionals:
            progress = {
                'professional_id': prof['id'],
                'name': prof['name'],
                'profession': prof['profession'],
                'language_progress': prof['proficiency_levels'],
                'completed_modules': prof['completed_modules'],
                'current_module': _get_current_module(prof),
                'overall_progress': _calculate_professional_progress(prof),
                'status': _get_professional_status(prof),
                'last_activity': prof['last_activity']
            }
            professionals_progress.append(progress)
        
        # Alertas
        alerts = _generate_organization_alerts(organization_id, org_professionals)
        
        dashboard = {
            'organization_id': organization_id,
            'organization_name': organization['name'],
            'total_professionals': total_professionals,
            'active_professionals': active_professionals,
            'average_progress': round(average_progress, 2),
            'completed_modules': sum(len(p['completed_modules']) for p in org_professionals),
            'professionals': professionals_progress,
            'language_stats': language_stats,
            'module_stats': _calculate_module_stats(org_professionals),
            'alerts': alerts,
            'last_updated': datetime.now().isoformat()
        }
        
        return jsonify({
            'success': True,
            'data': dashboard
        })
        
    except Exception as e:
        logger.error(f"Erro ao gerar dashboard para {organization_id}: {e}")
        return jsonify({'error': 'Erro interno do servidor'}), 500

# ========================================
# 🔧 FUNÇÕES AUXILIARES
# ========================================

def _generate_module_recommendations(professional):
    """Gerar recomendações de módulos para um profissional"""
    try:
        # Usar o serviço Gemma para gerar recomendações personalizadas
        if hasattr(g, 'gemma_service'):
            prompt = f"""
            Como especialista em ensino de idiomas para organizações humanitárias, 
            recomende 3 módulos prioritários para:
            
            Profissional: {professional['name']}
            Profissão: {professional['profession']}
            Organização: {professional['organization_name']}
            Idiomas alvo: {', '.join(professional['target_languages'])}
            Localização: {professional['assignment_location']}
            
            Responda apenas com uma lista de módulos recomendados.
            """
            
            response = g.gemma_service.generate_response(prompt)
            return [{'module': 'personalizado', 'reason': response}]
        
        # Fallback: recomendações baseadas em regras
        recommendations = []
        if professional['profession'] == 'doctor':
            recommendations.append({'module': 'medical_emergency', 'reason': 'Essencial para médicos'})
        elif professional['profession'] == 'teacher':
            recommendations.append({'module': 'education_basic', 'reason': 'Fundamental para educadores'})
        
        return recommendations
        
    except Exception as e:
        logger.warning(f"Erro ao gerar recomendações: {e}")
        return []

def _generate_custom_module(professional, profession, target_language, scenario, specific_needs=None, urgency_hours=None):
    """Gerar módulo personalizado usando IA"""
    try:
        if hasattr(g, 'gemma_service'):
            prompt = f"""
            Crie um módulo de ensino de {target_language} para um {profession} da {professional['organization_name']}.
            
            Cenário: {scenario}
            Necessidades específicas: {specific_needs or 'Não especificadas'}
            Urgência: {f'{urgency_hours} horas' if urgency_hours else 'Normal'}
            
            Crie 5 frases essenciais com:
            - Texto em português
            - Tradução para {target_language}
            - Contexto de uso
            - Nível de importância
            
            Formato: português -> tradução (contexto) [importância]
            """
            
            response = g.gemma_service.generate_response(prompt)
            
            # Processar resposta e criar módulo estruturado
            module = {
                'name': f'Módulo Personalizado - {profession.title()}',
                'description': f'Módulo gerado especialmente para {professional["name"]}',
                'profession': profession,
                'target_language': target_language,
                'difficulty_level': 'custom',
                'estimated_duration_minutes': urgency_hours * 60 if urgency_hours else 180,
                'lessons': _parse_ai_response_to_lessons(response),
                'prerequisites': [],
                'icon_url': '🎯',
                'metadata': {
                    'generated_by': 'ai',
                    'scenario': scenario,
                    'urgency_hours': urgency_hours
                }
            }
            
            return module
    
    except Exception as e:
        logger.warning(f"Erro ao gerar módulo personalizado com IA: {e}")
    
    # Fallback: módulo básico
    return {
        'name': f'Módulo Básico - {profession.title()}',
        'description': 'Módulo básico de comunicação',
        'profession': profession,
        'target_language': target_language,
        'difficulty_level': 'basic',
        'estimated_duration_minutes': 120,
        'lessons': [],
        'prerequisites': [],
        'icon_url': '📚',
        'metadata': {}
    }

def _generate_emergency_module(professional, profession, target_language, emergency_type, hours_until_deployment):
    """Gerar módulo de emergência ultrarrápido"""
    emergency_phrases = {
        'medical': [
            ('Onde dói?', 'Undi ku bu ten dor?', 'un-di ku bu ten dor', 'Primeira pergunta', 'critical'),
            ('Respire fundo', 'Suspira fundu', 'sus-pi-ra fun-du', 'Acalmar paciente', 'critical'),
            ('Vou ajudar', 'N bai djuda bu', 'n bai dju-da bu', 'Tranquilizar', 'important'),
            ('Chame a família', 'Chama familia', 'cha-ma fa-mi-lia', 'Envolver família', 'useful'),
            ('Vai ficar bem', 'Bu bai fica bon', 'bu bai fi-ca bon', 'Confortar', 'important')
        ],
        'disaster': [
            ('Você está seguro', 'Bu seguru', 'bu se-gu-ru', 'Primeiros socorros', 'critical'),
            ('Siga-me', 'Sigui n', 'si-gui n', 'Evacuação', 'critical'),
            ('Água potável', 'Agu limpu', 'a-gu lim-pu', 'Necessidades básicas', 'important'),
            ('Abrigo seguro', 'Lugar seguru', 'lu-gar se-gu-ru', 'Segurança', 'important'),
            ('Ajuda está vindo', 'Djuda ka ben', 'dju-da ka ben', 'Esperança', 'useful')
        ]
    }
    
    phrases = emergency_phrases.get(emergency_type, emergency_phrases['medical'])
    
    # Selecionar frases baseado no tempo disponível
    num_phrases = min(len(phrases), max(3, hours_until_deployment))
    selected_phrases = phrases[:num_phrases]
    
    lesson_items = []
    for i, (pt, tl, pron, context, importance) in enumerate(selected_phrases):
        lesson_items.append({
            'id': f'emergency_{i+1}',
            'type': 'phrase',
            'source_text': pt,
            'target_text': tl,
            'pronunciation': pron,
            'context': context,
            'importance': importance,
            'metadata': {'emergency': True}
        })
    
    return {
        'name': f'EMERGÊNCIA: {emergency_type.title()} - {hours_until_deployment}h',
        'description': f'Módulo de emergência para deployment em {hours_until_deployment} horas',
        'profession': profession,
        'target_language': target_language,
        'difficulty_level': 'emergency',
        'estimated_duration_minutes': hours_until_deployment * 60,
        'lessons': [{
            'id': 'emergency_lesson',
            'title': 'Frases Essenciais de Emergência',
            'description': 'Comunicação crítica para situações de emergência',
            'type': 'emergency',
            'items': lesson_items,
            'cultural_context': {
                'urgency': 'Situação de emergência - comunicação direta',
                'respect': 'Mantenha calma e respeito',
                'family': 'Família é muito importante na cultura local'
            },
            'is_completed': False
        }],
        'prerequisites': [],
        'icon_url': '🚨',
        'metadata': {
            'emergency': True,
            'hours_until_deployment': hours_until_deployment,
            'emergency_type': emergency_type
        }
    }

def _get_emergency_phrases(profession, target_language, emergency_type):
    """Obter frases específicas para emergência"""
    # Banco de frases de emergência por profissão e tipo
    emergency_db = {
        'doctor': {
            'medical': [
                {
                    'id': 'er_1',
                    'type': 'phrase',
                    'source_text': 'Onde dói?',
                    'target_text': 'Undi ku bu ten dor?',
                    'pronunciation': 'un-di ku bu ten dor',
                    'context': 'Primeira pergunta em emergência',
                    'importance': 'critical'
                },
                {
                    'id': 'er_2',
                    'type': 'phrase',
                    'source_text': 'Precisa de cirurgia',
                    'target_text': 'Misti operação',
                    'pronunciation': 'mis-ti o-pe-ra-são',
                    'context': 'Informar necessidade cirúrgica',
                    'importance': 'critical'
                }
            ]
        }
    }
    
    return emergency_db.get(profession, {}).get(emergency_type, [])

def _parse_ai_response_to_lessons(response):
    """Converter resposta da IA em lições estruturadas"""
    # Implementação básica - em produção seria mais sofisticada
    return [{
        'id': 'ai_generated',
        'title': 'Lição Gerada por IA',
        'description': 'Conteúdo personalizado',
        'type': 'custom',
        'items': [],
        'cultural_context': {},
        'is_completed': False
    }]

def _is_active_professional(professional):
    """Verificar se profissional está ativo"""
    last_activity = datetime.fromisoformat(professional['last_activity'].replace('Z', '+00:00'))
    return (datetime.now() - last_activity.replace(tzinfo=None)).days < 7

def _calculate_professional_progress(professional):
    """Calcular progresso geral do profissional"""
    if not professional['target_languages']:
        return 0
    
    total_progress = sum(professional['proficiency_levels'].values())
    max_possible = len(professional['target_languages']) * 5  # Máximo 5 por idioma
    
    return (total_progress / max_possible * 100) if max_possible > 0 else 0

def _get_current_module(professional):
    """Obter módulo atual do profissional"""
    # Lógica para determinar módulo atual
    return professional.get('current_module', 'Nenhum')

def _get_professional_status(professional):
    """Obter status do profissional"""
    progress = _calculate_professional_progress(professional)
    
    if progress >= 80:
        return 'completed'
    elif progress >= 20:
        return 'active'
    else:
        return 'starting'

def _generate_organization_alerts(organization_id, professionals):
    """Gerar alertas para a organização"""
    alerts = []
    
    # Verificar profissionais inativos
    inactive = [p for p in professionals if not _is_active_professional(p)]
    if inactive:
        alerts.append(f'{len(inactive)} profissionais inativos há mais de 7 dias')
    
    # Verificar progresso baixo
    low_progress = [p for p in professionals if _calculate_professional_progress(p) < 20]
    if low_progress:
        alerts.append(f'{len(low_progress)} profissionais com progresso baixo')
    
    return alerts

def _calculate_module_stats(professionals):
    """Calcular estatísticas de módulos"""
    module_stats = {}
    
    for prof in professionals:
        for module in prof['completed_modules']:
            module_stats[module] = module_stats.get(module, 0) + 1
    
    return module_stats
