import re
from typing import Optional

def validate_language_code(language_code: str) -> bool:
    """
    Valida se o código de idioma está no formato correto.
    Aceita códigos ISO 639-1 (2 letras) e alguns códigos customizados.
    """
    if not isinstance(language_code, str):
        return False
    
    # Códigos de idioma suportados
    supported_languages = {
        'pt',   # Português
        'gcr',  # Crioulo da Guiné-Bissau
        'en',   # Inglês
        'fr',   # Francês
        'es',   # Espanhol
        'ar',   # Árabe
        'wo',   # Wolof
        'ff',   # Fula
        'mnk',  # Mandinka
        'bsc',  # Bassari
        'knf',  # Mankanya
        'bjt',  # Balanta-Ganja
        'pov',  # Papel
        'buy',  # Bullom So
    }
    
    return language_code.lower() in supported_languages

def validate_text_input(text: str, max_length: int = 500) -> bool:
    """
    Valida entrada de texto para contribuições.
    """
    if not isinstance(text, str):
        return False
    
    # Remover espaços em branco
    text = text.strip()
    
    # Verificar se não está vazio
    if not text:
        return False
    
    # Verificar comprimento
    if len(text) > max_length:
        return False
    
    # Verificar se contém apenas caracteres válidos
    # Permitir letras, números, espaços e pontuação básica
    pattern = r'^[\w\s\-\'".,!?()\[\]{}:;]+$'
    if not re.match(pattern, text, re.UNICODE):
        return False
    
    return True

def validate_category(category: str) -> bool:
    """
    Valida se a categoria é válida.
    """
    valid_categories = {
        'general',
        'health',
        'agriculture',
        'education',
        'family',
        'food',
        'nature',
        'work',
        'emotions',
        'numbers',
        'colors',
        'animals',
        'body_parts',
        'clothing',
        'transportation',
        'weather',
        'time',
        'greetings',
        'emergency'
    }
    
    return isinstance(category, str) and category.lower() in valid_categories

def validate_audio_format(filename: str) -> bool:
    """
    Valida se o formato de áudio é suportado.
    """
    if not isinstance(filename, str):
        return False
    
    supported_formats = {'.mp3', '.wav', '.ogg', '.m4a', '.aac'}
    file_extension = filename.lower().split('.')[-1] if '.' in filename else ''
    
    return f'.{file_extension}' in supported_formats

def validate_image_format(filename: str) -> bool:
    """
    Valida se o formato de imagem é suportado.
    """
    if not isinstance(filename, str):
        return False
    
    supported_formats = {'.jpg', '.jpeg', '.png', '.gif', '.webp'}
    file_extension = filename.lower().split('.')[-1] if '.' in filename else ''
    
    return f'.{file_extension}' in supported_formats

def validate_contributor_id(contributor_id: str) -> bool:
    """
    Valida ID do contribuidor.
    """
    if not isinstance(contributor_id, str):
        return False
    
    # Permitir 'anonymous' ou IDs alfanuméricos
    if contributor_id == 'anonymous':
        return True
    
    # ID deve ter entre 3 e 50 caracteres alfanuméricos
    pattern = r'^[a-zA-Z0-9_-]{3,50}$'
    return bool(re.match(pattern, contributor_id))

def validate_vote_type(vote_type: str) -> bool:
    """
    Valida tipo de voto.
    """
    return isinstance(vote_type, str) and vote_type in ['up', 'down']

def validate_report_reason(reason: str) -> bool:
    """
    Valida motivo de report.
    """
    if not isinstance(reason, str):
        return False
    
    valid_reasons = {
        'inappropriate_content',
        'incorrect_translation',
        'spam',
        'offensive_language',
        'copyright_violation',
        'poor_audio_quality',
        'duplicate_content',
        'other'
    }
    
    return reason in valid_reasons

def sanitize_text(text: str) -> str:
    """
    Sanitiza texto removendo caracteres perigosos.
    """
    if not isinstance(text, str):
        return ''
    
    # Remover caracteres de controle
    text = re.sub(r'[\x00-\x1f\x7f-\x9f]', '', text)
    
    # Remover múltiplos espaços
    text = re.sub(r'\s+', ' ', text)
    
    # Remover espaços no início e fim
    text = text.strip()
    
    return text

def validate_search_query(query: str) -> bool:
    """
    Valida query de busca.
    """
    if not isinstance(query, str):
        return False
    
    query = query.strip()
    
    # Deve ter pelo menos 2 caracteres
    if len(query) < 2:
        return False
    
    # Não deve ser muito longa
    if len(query) > 100:
        return False
    
    # Deve conter apenas caracteres válidos
    pattern = r'^[\w\s\-\'".,!?()]+$'
    return bool(re.match(pattern, query, re.UNICODE))

def validate_pagination_params(limit: Optional[int], offset: Optional[int]) -> tuple[int, int]:
    """
    Valida e normaliza parâmetros de paginação.
    """
    # Validar limit
    if limit is None:
        limit = 20
    elif not isinstance(limit, int) or limit < 1:
        limit = 20
    elif limit > 100:
        limit = 100
    
    # Validar offset
    if offset is None:
        offset = 0
    elif not isinstance(offset, int) or offset < 0:
        offset = 0
    
    return limit, offset