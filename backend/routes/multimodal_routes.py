"""
Rotas para funcionalidades multimodais do Gemma 3n
Implementa endpoints para análise de imagem, áudio e vídeo
"""

from flask import Blueprint, request, jsonify, g
import logging
import base64
from typing import Dict, Any

from utils.decorators import handle_api_errors, log_request_response
from services.multimodal_service import MultimodalService

logger = logging.getLogger(__name__)

multimodal_bp = Blueprint('multimodal', __name__, url_prefix='/multimodal')

# Singleton para evitar reinicializações
_multimodal_service_instance = None

def get_multimodal_service():
    """Obter serviço multimodal (singleton para performance)"""
    global _multimodal_service_instance
    
    if _multimodal_service_instance is None:
        _multimodal_service_instance = MultimodalService(g.gemma_service)
    
    return _multimodal_service_instance

@multimodal_bp.route('/image/analyze', methods=['POST'])
@handle_api_errors
@log_request_response
def analyze_image():
    """
    Analisar imagem usando Gemma 3n
    
    Body:
    {
        "image": "base64_string_or_url",
        "prompt": "Descreva esta imagem",
        "language": "pt-BR"
    }
    """
    try:
        data = request.get_json()
        
        if not data or 'image' not in data:
            return jsonify({
                "error": "Imagem é obrigatória",
                "code": "MISSING_IMAGE"
            }), 400
        
        image_data = data['image']
        prompt = data.get('prompt', 'Descreva esta imagem em detalhes.')
        language = data.get('language', 'pt-BR')
        
        multimodal_service = get_multimodal_service()
        result = multimodal_service.analyze_image(image_data, prompt, language)
        
        if result.get('success'):
            return jsonify({
                "success": True,
                "analysis": result['analysis'],
                "method": result['method'],
                "language": language,
                "capabilities": {
                    "image_processed": result['image_processed'],
                    "model": "Gemma-3n Multimodal"
                }
            })
        else:
            return jsonify({
                "error": result.get('error', 'Falha na análise de imagem'),
                "analysis": result.get('analysis', ''),
                "method": result.get('method', 'unknown')
            }), 500
            
    except Exception as e:
        logger.error(f"❌ Erro no endpoint de análise de imagem: {e}")
        return jsonify({
            "error": "Erro interno no processamento de imagem",
            "details": str(e)
        }), 500

@multimodal_bp.route('/image/medical', methods=['POST'])
@handle_api_errors
@log_request_response
def analyze_medical_image():
    """
    Análise médica especializada de imagens
    
    Body:
    {
        "image": "base64_string_or_url",
        "symptoms": "Sintomas relatados pelo paciente",
        "language": "pt-BR"
    }
    """
    try:
        data = request.get_json()
        
        if not data or 'image' not in data:
            return jsonify({
                "error": "Imagem médica é obrigatória",
                "code": "MISSING_MEDICAL_IMAGE"
            }), 400
        
        image_data = data['image']
        symptoms = data.get('symptoms', '')
        language = data.get('language', 'pt-BR')
        
        multimodal_service = get_multimodal_service()
        result = multimodal_service.analyze_medical_image(image_data, symptoms, language)
        
        if result.get('success'):
            return jsonify({
                "success": True,
                "medical_analysis": result['analysis'],
                "symptoms_considered": symptoms,
                "method": result['method'],
                "disclaimer": result.get('disclaimer', ''),
                "language": language,
                "urgent_recommendation": "⚠️ Esta análise não substitui consulta médica profissional. Procure um médico para avaliação adequada."
            })
        else:
            return jsonify({
                "error": result.get('error', 'Falha na análise médica'),
                "analysis": result.get('analysis', ''),
                "disclaimer": "Consulte sempre um médico profissional"
            }), 500
            
    except Exception as e:
        logger.error(f"❌ Erro no endpoint de análise médica: {e}")
        return jsonify({
            "error": "Erro interno na análise médica",
            "details": str(e),
            "recommendation": "Consulte um médico profissional"
        }), 500

@multimodal_bp.route('/audio/transcribe', methods=['POST'])
@handle_api_errors
@log_request_response
def transcribe_audio():
    """
    Transcrever e processar áudio usando Gemma 3n
    
    Body:
    {
        "audio": "base64_string_or_url",
        "prompt": "Transcreva este áudio",
        "language": "pt-BR"
    }
    """
    try:
        data = request.get_json()
        
        if not data or 'audio' not in data:
            return jsonify({
                "error": "Dados de áudio são obrigatórios",
                "code": "MISSING_AUDIO"
            }), 400
        
        audio_data = data['audio']
        prompt = data.get('prompt', 'Transcreva este áudio e complete o que foi dito.')
        language = data.get('language', 'pt-BR')
        
        multimodal_service = get_multimodal_service()
        result = multimodal_service.process_audio(audio_data, prompt, language)
        
        if result.get('success'):
            return jsonify({
                "success": True,
                "transcription": result['transcription'],
                "method": result['method'],
                "language": language,
                "capabilities": {
                    "audio_processed": result['audio_processed'],
                    "model": "Gemma-3n Multimodal"
                }
            })
        else:
            return jsonify({
                "error": result.get('error', 'Falha na transcrição de áudio'),
                "transcription": result.get('transcription', ''),
                "method": result.get('method', 'unknown')
            }), 500
            
    except Exception as e:
        logger.error(f"❌ Erro no endpoint de transcrição: {e}")
        return jsonify({
            "error": "Erro interno no processamento de áudio",
            "details": str(e)
        }), 500

@multimodal_bp.route('/capabilities', methods=['GET'])
@handle_api_errors
def get_multimodal_capabilities():
    """
    Obter capacidades multimodais disponíveis
    """
    try:
        multimodal_service = get_multimodal_service()
        capabilities = multimodal_service.get_capabilities()
        
        return jsonify({
            "success": True,
            "capabilities": capabilities,
            "model": "Gemma-3n Multimodal",
            "version": "E4B",
            "documentation": "https://ai.google.dev/gemma/docs/gemma-3n",
            "supported_modalities": {
                "text": True,
                "image": capabilities["image_analysis"],
                "audio": capabilities["audio_processing"],
                "video": capabilities["video_processing"]
            }
        })
        
    except Exception as e:
        logger.error(f"❌ Erro ao obter capacidades: {e}")
        return jsonify({
            "error": "Erro ao obter capacidades multimodais",
            "details": str(e)
        }), 500

@multimodal_bp.route('/test/image', methods=['POST'])
@handle_api_errors
def test_image_processing():
    """
    Endpoint de teste para processamento de imagem
    Usa uma imagem de exemplo da documentação
    """
    try:
        # URL de exemplo da documentação do Gemma 3n
        test_image_url = "https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/bee.jpg"
        test_prompt = "Descreva esta imagem em detalhes usando português brasileiro."
        
        multimodal_service = get_multimodal_service()
        result = multimodal_service.analyze_image(test_image_url, test_prompt, "pt-BR")
        
        return jsonify({
            "test": "image_processing",
            "test_image": test_image_url,
            "result": result,
            "status": "success" if result.get('success') else "failed"
        })
        
    except Exception as e:
        logger.error(f"❌ Erro no teste de imagem: {e}")
        return jsonify({
            "test": "image_processing",
            "error": str(e),
            "status": "failed"
        }), 500

@multimodal_bp.route('/batch/analyze', methods=['POST'])
@handle_api_errors
@log_request_response
def batch_multimodal_analysis():
    """
    Análise em lote de múltiplas modalidades
    
    Body:
    {
        "items": [
            {
                "type": "image",
                "data": "base64_or_url",
                "prompt": "Descreva esta imagem"
            },
            {
                "type": "audio", 
                "data": "base64_or_url",
                "prompt": "Transcreva este áudio"
            }
        ],
        "language": "pt-BR"
    }
    """
    try:
        data = request.get_json()
        
        if not data or 'items' not in data:
            return jsonify({
                "error": "Lista de itens é obrigatória",
                "code": "MISSING_ITEMS"
            }), 400
        
        items = data['items']
        language = data.get('language', 'pt-BR')
        results = []
        
        multimodal_service = get_multimodal_service()
        
        for i, item in enumerate(items):
            try:
                item_type = item.get('type')
                item_data = item.get('data')
                item_prompt = item.get('prompt', '')
                
                if item_type == 'image':
                    result = multimodal_service.analyze_image(item_data, item_prompt, language)
                elif item_type == 'audio':
                    result = multimodal_service.process_audio(item_data, item_prompt, language)
                else:
                    result = {"error": f"Tipo não suportado: {item_type}"}
                
                results.append({
                    "index": i,
                    "type": item_type,
                    "result": result
                })
                
            except Exception as e:
                results.append({
                    "index": i,
                    "type": item.get('type', 'unknown'),
                    "error": str(e)
                })
        
        return jsonify({
            "success": True,
            "batch_results": results,
            "total_items": len(items),
            "language": language
        })
        
    except Exception as e:
        logger.error(f"❌ Erro na análise em lote: {e}")
        return jsonify({
            "error": "Erro na análise em lote",
            "details": str(e)
        }), 500
