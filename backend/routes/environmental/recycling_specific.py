#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Rota de Reciclagem Específica - Gemma 3n Otimizada
Backend modular para análise inteligente de reciclagem
Desenvolvido para o Hackathon Gemma 3n

Este módulo implementa uma rota especializada em análise de materiais
para reciclagem usando as capacidades multimodais do Gemma 3n.
Baseado na documentação técnica do Gemma 3n:e2b e gemma3n:e4b.
"""

import os
import base64
import logging
from datetime import datetime, timedelta
from flask import Blueprint, request, jsonify, current_app
from werkzeug.utils import secure_filename
import io
from PIL import Image

# Configurar logging
logger = logging.getLogger(__name__)

# Criar blueprint específico para reciclagem (nome único)
recycling_specific_bp = Blueprint('recycling_specific', __name__)

# Configurações específicas para reciclagem
RECYCLING_CONFIG = {
    'max_image_size': 10 * 1024 * 1024,  # 10MB
    'supported_formats': ['PNG', 'JPEG', 'JPG', 'WEBP'],
    'gemma_models': {
        'primary': 'gemma3n:e4b',    # Para análises detalhadas
        'fallback': 'gemma3n:e2b',   # Para dispositivos com menos recursos
        'generic': 'gemma3'          # Fallback garantido com multimodal
    },
    'confidence_threshold': 0.7,
    'bissau_collection_points': [
        {
            'id': 'central_bissau',
            'name': 'Ecoponto Central de Bissau',
            'address': 'Av. Amílcar Cabral, próximo ao Mercado Central',
            'coordinates': {'lat': 11.8639, 'lng': -15.5981},
            'materials': ['Plástico', 'Papel', 'Vidro', 'Metal'],
            'schedule': 'Segunda-Sexta: 8h-17h, Sábado: 8h-12h',
            'phone': '+245-955-0001',
            'capacity': 'Alta'
        },
        {
            'id': 'bandim_electronics',
            'name': 'Centro de Reciclagem Eletrônica Bandim',
            'address': 'Bairro de Bandim, Rua 15 de Agosto',
            'coordinates': {'lat': 11.8550, 'lng': -15.6020},
            'materials': ['Eletrônicos', 'Pilhas', 'Baterias', 'E-waste'],
            'schedule': 'Terça-Sábado: 9h-16h',
            'phone': '+245-955-0002',
            'capacity': 'Média'
        },
        {
            'id': 'ponto_verde_bissau',
            'name': 'Ponto Verde Bissau',
            'address': 'Rua Justino Lopes, próximo à Escola Nacional',
            'coordinates': {'lat': 11.8700, 'lng': -15.5900},
            'materials': ['Todos os materiais', 'Compostagem', 'Orgânicos'],
            'schedule': 'Segunda-Domingo: 7h-19h',
            'phone': '+245-955-0003',
            'capacity': 'Alta'
        },
        {
            'id': 'cooperativa_bandeira',
            'name': 'Cooperativa de Reciclagem Bandeira',
            'address': 'Bairro Militar, próximo ao Hospital Nacional',
            'coordinates': {'lat': 11.8580, 'lng': -15.5850},
            'materials': ['Papel', 'Cartão', 'Livros', 'Documentos'],
            'schedule': 'Segunda-Sexta: 7h-15h',
            'phone': '+245-955-0004',
            'capacity': 'Média'
        }
    ]
}

def validate_image(image_data):
    """Validar imagem conforme especificações Gemma 3n"""
    try:
        # Decodificar base64
        if isinstance(image_data, str):
            image_bytes = base64.b64decode(image_data)
        else:
            image_bytes = image_data
        
        # Verificar tamanho
        if len(image_bytes) > RECYCLING_CONFIG['max_image_size']:
            return False, "Imagem muito grande. Máximo 10MB."
        
        # Validar formato com PIL
        try:
            img = Image.open(io.BytesIO(image_bytes))
            if img.format not in RECYCLING_CONFIG['supported_formats']:
                return False, f"Formato não suportado. Use: {', '.join(RECYCLING_CONFIG['supported_formats'])}"
            
            # Verificar dimensões mínimas
            if img.width < 50 or img.height < 50:
                return False, "Imagem muito pequena. Mínimo 50x50 pixels."
            
            return True, "Válida"
        except Exception as e:
            return False, f"Formato de imagem inválido: {e}"
            
    except Exception as e:
        return False, f"Erro ao validar imagem: {e}"

def select_optimal_gemma_model():
    """Selecionar modelo Gemma 3n ideal baseado no documento técnico"""
    try:
        gemma_service = current_app.gemma_service
        if not gemma_service:
            return RECYCLING_CONFIG['gemma_models']['generic']
        
        # Verificar capacidade do sistema
        import psutil
        available_ram = psutil.virtual_memory().available / (1024**3)  # GB
        
        # Lógica baseada no documento gemma3n_imagem.md
        if available_ram >= 4:
            # Sistema com recursos suficientes - usar e4b (mais preciso)
            model = RECYCLING_CONFIG['gemma_models']['primary']
            logger.info(f"🚀 Sistema com {available_ram:.1f}GB RAM - usando {model}")
            return model
        elif available_ram >= 2:
            # Sistema com recursos limitados - usar e2b (eficiente)
            model = RECYCLING_CONFIG['gemma_models']['fallback']
            logger.info(f"⚡ Sistema com {available_ram:.1f}GB RAM - usando {model}")
            return model
        else:
            # Sistema com poucos recursos - usar gemma3 genérico
            model = RECYCLING_CONFIG['gemma_models']['generic']
            logger.info(f"💾 Sistema com {available_ram:.1f}GB RAM - usando {model} (fallback)")
            return model
            
    except Exception as e:
        logger.warning(f"Erro ao selecionar modelo: {e}. Usando fallback.")
        return RECYCLING_CONFIG['gemma_models']['generic']

def create_gemma3n_prompt(user_request, location="Bissau"):
    """Criar prompt otimizado para análise de reciclagem com Gemma 3n"""
    
    prompt = f"""Você é um especialista em reciclagem e sustentabilidade ambiental em {location}, Guiné-Bissau.

TAREFA: Analise esta imagem de material para reciclagem e forneça insights detalhados.

CONTEXTO LOCAL:
- Localização: {location}, Guiné-Bissau
- Infraestrutura: Pontos de coleta específicos disponíveis
- Desafios: Recursos limitados, educação ambiental necessária
- Oportunidades: Economia circular, impacto comunitário

ANÁLISE SOLICITADA:
{user_request}

RESPONDA EM FORMATO ESTRUTURADO:

**MATERIAL IDENTIFICADO:**
- Tipo principal: [especificar]
- Categoria de reciclagem: [Plástico/Papel/Vidro/Metal/Orgânico/Eletrônico]
- Reciclável: [Sim/Não] - [justificar]

**INSTRUÇÃO DE DESCARTE EM {location.upper()}:**
- Preparação necessária: [limpar, separar, etc.]
- Local de descarte ideal: [ecoponto específico]
- Processo recomendado: [passo a passo]

**IMPACTO AMBIENTAL:**
- CO2 economizado: [estimativa]
- Benefício energético: [estimativa]
- Importância para comunidade: [explicar]

**DICAS ESPECÍFICAS PARA GUINÉ-BISSAU:**
- Considerações climáticas
- Práticas culturais relevantes
- Alternativas criativas de reutilização

**CONFIANÇA DA ANÁLISE:** [0-100%]

Use linguagem clara, educativa e culturalmente apropriada para Guiné-Bissau."""
    
    return prompt

def analyze_with_gemma3n(image_data, prompt, model_name):
    """Analisar imagem usando Gemma 3n com fallback inteligente"""
    try:
        gemma_service = current_app.gemma_service
        if not gemma_service:
            raise ValueError("GemmaService não disponível")
        
        logger.info(f"🤖 Analisando com modelo: {model_name}")
        logger.info(f"🔍 Dados da imagem: {len(image_data)} bytes")
        logger.info(f"📝 Prompt length: {len(prompt)} caracteres")
        
        # Tentar análise multimodal (conforme documento)
        try:
            logger.info("🔄 Iniciando análise multimodal...")
            # Método principal - análise de imagem atualizada
            result = gemma_service.analyze_image(image_data, prompt)
            logger.info(f"✅ Análise retornada, tipo: {type(result)}")
            
            # Verificar se recebemos uma string (análise bem-sucedida) ou dict (erro)
            if isinstance(result, str) and len(result.strip()) > 50:
                logger.info(f"✅ Análise multimodal bem-sucedida: {len(result)} caracteres")
                logger.info(f"📄 Preview: {result[:100]}...")
                return {
                    'success': True,
                    'analysis': result,
                    'model_used': model_name,
                    'method': 'multimodal',
                    'confidence': extract_confidence_from_response(result)
                }
            elif isinstance(result, dict) and result.get('success'):
                # Compatibilidade com resposta em dict
                analysis_text = result.get('response', result.get('analysis', ''))
                if analysis_text and len(analysis_text.strip()) > 50:
                    logger.info(f"✅ Análise multimodal bem-sucedida (formato dict): {len(analysis_text)} caracteres")
                    return {
                        'success': True,
                        'analysis': analysis_text,
                        'model_used': model_name,
                        'method': 'multimodal',
                        'confidence': extract_confidence_from_response(analysis_text)
                    }
            else:
                logger.warning(f"⚠️ Resultado insuficiente - tipo: {type(result)}, tamanho: {len(str(result))}")
                
        except Exception as e:
            logger.error(f"💥 Falha na análise multimodal com {model_name}: {e}")
            import traceback
            logger.error(f"Traceback: {traceback.format_exc()}")
        
        # Fallback - análise textual contextual
        logger.info("🔄 Usando fallback textual contextual")
        contextual_prompt = f"""
        {prompt}
        
        NOTA: Baseie sua análise no contexto de reciclagem em Bissau, Guiné-Bissau.
        Assuma que o usuário está com um material típico para reciclagem (plástico, papel, vidro, metal).
        Forneça orientações gerais mas específicas para a região.
        """
        
        result = gemma_service.generate_response(contextual_prompt)
        
        return {
            'success': True,
            'analysis': result['response'] if isinstance(result, dict) else result,
            'model_used': model_name,
            'method': 'textual_contextual',
            'confidence': 0.65  # Confiança menor para análise sem imagem
        }
        
    except Exception as e:
        logger.error(f"Erro na análise Gemma 3n: {e}")
        return {
            'success': False,
            'error': str(e),
            'model_used': model_name
        }

def extract_confidence_from_response(text):
    """Extrair nível de confiança da resposta do Gemma 3n"""
    import re
    
    # Procurar por indicadores de confiança no texto
    confidence_patterns = [
        r'CONFIANÇA.*?(\d+)%',
        r'confiança.*?(\d+)%',
        r'certeza.*?(\d+)%',
        r'(\d+)%.*confiança'
    ]
    
    for pattern in confidence_patterns:
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            return int(match.group(1)) / 100
    
    # Análise heurística da qualidade da resposta
    quality_score = 0.5
    
    # Fator: comprimento e detalhamento
    if len(text) > 500:
        quality_score += 0.15
    elif len(text) > 300:
        quality_score += 0.10
    
    # Fator: termos técnicos específicos
    technical_terms = [
        'reciclagem', 'sustentável', 'impacto ambiental', 
        'ecoponto', 'bissau', 'guiné-bissau', 'co2'
    ]
    
    term_count = sum(1 for term in technical_terms if term.lower() in text.lower())
    quality_score += min(term_count * 0.05, 0.25)
    
    # Fator: estrutura organizada
    if '**' in text or 'MATERIAL IDENTIFICADO' in text:
        quality_score += 0.10
    
    return min(quality_score, 0.95)

def find_best_collection_points(material_type, _location=None):
    """Encontrar pontos de coleta ideais baseado no material"""
    points = RECYCLING_CONFIG['bissau_collection_points']
    
    # Filtrar por tipo de material
    suitable_points = []
    for point in points:
        if ('Todos os materiais' in point['materials'] or 
            any(material_type.lower() in mat.lower() for mat in point['materials'])):
            suitable_points.append(point)
    
    # Ordenar por capacidade e proximidade (simulada)
    suitable_points.sort(key=lambda x: x['capacity'] == 'Alta', reverse=True)
    
    return suitable_points[:3]  # Retornar os 3 melhores

@recycling_specific_bp.route('/analyze', methods=['POST'])
def analyze_recycling_material():
    """
    Analisar material para reciclagem usando Gemma 3n otimizado
    ---
    tags:
      - Reciclagem Específica
    summary: Análise inteligente de materiais com Gemma 3n
    description: |
      Endpoint especializado que usa as capacidades multimodais do Gemma 3n
      para análise detalhada de materiais de reciclagem específicos para Bissau.
      
      Baseado na documentação técnica do Gemma 3n:e2b e gemma3n:e4b,
      seleciona automaticamente o modelo ideal baseado nos recursos do sistema.
    """
    try:
        start_time = datetime.now()
        
        # Validar dados de entrada
        if request.is_json:
            data = request.get_json()
        else:
            return jsonify({
                'success': False,
                'error': 'Content-Type deve ser application/json',
                'timestamp': datetime.now().isoformat()
            }), 400
        
        # Verificar campos obrigatórios
        if 'image' not in data:
            return jsonify({
                'success': False,
                'error': 'Campo "image" (base64) é obrigatório',
                'timestamp': datetime.now().isoformat()
            }), 400
        
        # Extrair parâmetros
        image_data = data['image']
        location = data.get('location', 'Bissau')
        user_request = data.get('user_request', 
            'Analise este material para reciclagem e forneça orientações específicas para Bissau')
        
        # Validar imagem
        is_valid, validation_message = validate_image(image_data)
        if not is_valid:
            return jsonify({
                'success': False,
                'error': f'Imagem inválida: {validation_message}',
                'timestamp': datetime.now().isoformat()
            }), 400
        
        # Selecionar modelo Gemma 3n ideal
        model_name = select_optimal_gemma_model()
        
        # Criar prompt otimizado
        prompt = create_gemma3n_prompt(user_request, location)
        
        # Converter para bytes se necessário
        if isinstance(image_data, str):
            image_bytes = base64.b64decode(image_data)
        else:
            image_bytes = image_data
        
        # Analisar com Gemma 3n
        analysis_result = analyze_with_gemma3n(image_bytes, prompt, model_name)
        
        if not analysis_result['success']:
            return jsonify({
                'success': False,
                'error': f'Falha na análise: {analysis_result.get("error", "Erro desconhecido")}',
                'model_attempted': analysis_result.get('model_used'),
                'timestamp': datetime.now().isoformat()
            }), 500
        
        # Processar resposta
        analysis_text = analysis_result['analysis']
        
        # Se analysis_text for um dict, extrair o texto principal
        if isinstance(analysis_text, dict):
            # Extrair texto da resposta do Gemma
            raw_text = analysis_text.get('response', 
                      analysis_text.get('text', 
                      analysis_text.get('content', str(analysis_text))))
        else:
            raw_text = str(analysis_text)
        
        # Extrair informações estruturadas (parsing inteligente)
        material_info = parse_gemma_response(raw_text)
        
        # Encontrar pontos de coleta ideais
        collection_points = find_best_collection_points(
            material_info.get('material_type', ''), location
        )
        
        # Calcular tempo de processamento
        processing_time = (datetime.now() - start_time).total_seconds()
        
        # Resposta estruturada
        response = {
            'success': True,
            'data': {
                'material_analysis': material_info,
                'gemma_raw_response': raw_text,  # Usar texto extraído
                'collection_points': collection_points,
                'processing_info': {
                    'model_used': analysis_result['model_used'],
                    'method': analysis_result['method'],
                    'confidence': analysis_result.get('confidence', 0.75),
                    'processing_time_seconds': round(processing_time, 2)
                },
                'location_context': {
                    'city': location,
                    'country': 'Guiné-Bissau',
                    'local_initiatives': True
                }
            },
            'timestamp': datetime.now().isoformat()
        }
        
        logger.info(f"✅ Análise concluída em {processing_time:.2f}s com {model_name}")
        return jsonify(response)
        
    except Exception as e:
        logger.error(f"Erro no endpoint de reciclagem: {e}")
        return jsonify({
            'success': False,
            'error': 'Erro interno do servidor',
            'details': str(e) if current_app.debug else None,
            'timestamp': datetime.now().isoformat()
        }), 500

def parse_gemma_response(text):
    """Parse inteligente da resposta estruturada do Gemma 3n"""
    import re
    
    result = {
        'material_type': 'Material não identificado',
        'category': 'Geral',
        'recyclable': True,
        'preparation_steps': [],
        'disposal_location': 'Ecoponto mais próximo',
        'environmental_impact': {},
        'local_tips': [],
        'confidence': 0.75
    }
    
    try:
        # Extrair tipo de material
        material_match = re.search(r'Tipo principal:\s*([^\n\*]+)', text, re.IGNORECASE)
        if material_match:
            result['material_type'] = material_match.group(1).strip()
        
        # Extrair categoria
        category_match = re.search(r'Categoria.*?:\s*([^\n\*]+)', text, re.IGNORECASE)
        if category_match:
            result['category'] = category_match.group(1).strip()
        
        # Extrair reciclabilidade
        recyclable_match = re.search(r'Reciclável:\s*(Sim|Não)', text, re.IGNORECASE)
        if recyclable_match:
            result['recyclable'] = recyclable_match.group(1).lower() == 'sim'
        
        # Extrair dicas locais
        if 'DICAS ESPECÍFICAS' in text.upper():
            tips_start = text.upper().find('DICAS ESPECÍFICAS')
            if tips_start != -1:
                tips_text = text[tips_start:tips_start+500]  # Próximos 500 chars
                tips = [tip.strip() for tip in tips_text.split('-') if tip.strip() and len(tip.strip()) > 10]
                result['local_tips'] = tips[:5]  # Máximo 5 dicas
        
        # Extrair confiança
        confidence = extract_confidence_from_response(text)
        result['confidence'] = confidence
        
    except Exception as e:
        logger.warning(f"Erro no parsing da resposta: {e}")
    
    return result

@recycling_specific_bp.route('/collection-points', methods=['GET'])
def get_collection_points():
    """Obter pontos de coleta disponíveis em Bissau"""
    try:
        material_filter = request.args.get('material', '').lower()
        
        points = RECYCLING_CONFIG['bissau_collection_points']
        
        if material_filter:
            filtered_points = []
            for point in points:
                if (material_filter in 'todos os materiais' or
                    any(material_filter in mat.lower() for mat in point['materials'])):
                    filtered_points.append(point)
            points = filtered_points
        
        return jsonify({
            'success': True,
            'data': {
                'collection_points': points,
                'total_count': len(points),
                'material_filter': material_filter or 'todos'
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Erro ao obter pontos de coleta: {e}")
        return jsonify({
            'success': False,
            'error': 'Erro ao obter pontos de coleta',
            'timestamp': datetime.now().isoformat()
        }), 500

@recycling_specific_bp.route('/models/status', methods=['GET'])
def get_model_status():
    """Verificar status dos modelos Gemma 3n"""
    try:
        gemma_service = getattr(current_app, 'gemma_service', None)
        
        if not gemma_service:
            return jsonify({
                'success': False,
                'error': 'GemmaService não disponível',
                'timestamp': datetime.now().isoformat()
            }), 503
        
        # Verificar modelos disponíveis
        available_models = []
        for model_key, model_name in RECYCLING_CONFIG['gemma_models'].items():
            try:
                # Teste simples de disponibilidade
                _ = gemma_service.generate_response(
                    "Teste de disponibilidade", model_name=model_name
                )
                available_models.append({
                    'key': model_key,
                    'name': model_name,
                    'status': 'available',
                    'multimodal': model_key != 'generic'  # Baseado no documento
                })
            except Exception as e:
                available_models.append({
                    'key': model_key,
                    'name': model_name,
                    'status': 'unavailable',
                    'error': str(e)
                })
        
        # Modelo recomendado baseado no sistema
        recommended_model = select_optimal_gemma_model()
        
        return jsonify({
            'success': True,
            'data': {
                'models': available_models,
                'recommended': recommended_model,
                'system_info': {
                    'ram_available': f"{__import__('psutil').virtual_memory().available / (1024**3):.1f}GB"
                }
            },
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Erro ao verificar status dos modelos: {e}")
        return jsonify({
            'success': False,
            'error': 'Erro ao verificar modelos',
            'timestamp': datetime.now().isoformat()
        }), 500

@recycling_specific_bp.route('/scan', methods=['POST'])
def scan_recycling_compatibility():
    """
    Rota de compatibilidade para o Flutter - redireciona para /analyze
    Mantém compatibilidade com o código Flutter existente
    """
    # Redirecionar para a função de análise principal
    return analyze_recycling_material()

# Registrar rotas de erro específicas
@recycling_specific_bp.errorhandler(413)
def handle_large_file(e):
    return jsonify({
        'success': False,
        'error': 'Arquivo muito grande. Máximo 10MB.',
        'timestamp': datetime.now().isoformat()
    }), 413

@recycling_specific_bp.errorhandler(415)
def handle_unsupported_media(e):
    return jsonify({
        'success': False,
        'error': f'Formato não suportado. Use: {", ".join(RECYCLING_CONFIG["supported_formats"])}',
        'timestamp': datetime.now().isoformat()
    }), 415
