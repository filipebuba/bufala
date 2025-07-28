import os
import uuid
import hashlib
from datetime import datetime
from typing import Optional, Tuple
from werkzeug.utils import secure_filename
from werkzeug.datastructures import FileStorage
from utils.validators import validate_audio_format, validate_image_format

# Configurações de upload
UPLOAD_FOLDER = 'uploads'
AUDIO_FOLDER = os.path.join(UPLOAD_FOLDER, 'audio')
IMAGE_FOLDER = os.path.join(UPLOAD_FOLDER, 'images')
MAX_AUDIO_SIZE = 10 * 1024 * 1024  # 10MB
MAX_IMAGE_SIZE = 5 * 1024 * 1024   # 5MB

def ensure_upload_directories():
    """
    Garante que os diretórios de upload existam.
    """
    directories = [UPLOAD_FOLDER, AUDIO_FOLDER, IMAGE_FOLDER]
    for directory in directories:
        os.makedirs(directory, exist_ok=True)

def generate_unique_filename(original_filename: str, prefix: str = '') -> str:
    """
    Gera um nome de arquivo único baseado no timestamp e UUID.
    """
    # Obter extensão do arquivo original
    file_extension = ''
    if '.' in original_filename:
        file_extension = '.' + original_filename.rsplit('.', 1)[1].lower()
    
    # Gerar nome único
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    unique_id = str(uuid.uuid4())[:8]
    
    if prefix:
        filename = f"{prefix}_{timestamp}_{unique_id}{file_extension}"
    else:
        filename = f"{timestamp}_{unique_id}{file_extension}"
    
    return secure_filename(filename)

def calculate_file_hash(file_path: str) -> str:
    """
    Calcula hash MD5 do arquivo para detectar duplicatas.
    """
    hash_md5 = hashlib.md5()
    try:
        with open(file_path, 'rb') as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
        return hash_md5.hexdigest()
    except Exception:
        return ''

def save_audio_file(file: FileStorage, contributor_id: str = 'anonymous') -> Tuple[bool, str, Optional[str]]:
    """
    Salva arquivo de áudio e retorna (sucesso, mensagem, caminho_do_arquivo).
    """
    try:
        # Verificar se arquivo foi enviado
        if not file or not file.filename:
            return False, 'Nenhum arquivo de áudio foi enviado', None
        
        # Validar formato
        if not validate_audio_format(file.filename):
            return False, 'Formato de áudio não suportado', None
        
        # Verificar tamanho
        file.seek(0, os.SEEK_END)
        file_size = file.tell()
        file.seek(0)
        
        if file_size > MAX_AUDIO_SIZE:
            return False, f'Arquivo muito grande. Máximo: {MAX_AUDIO_SIZE // (1024*1024)}MB', None
        
        if file_size == 0:
            return False, 'Arquivo de áudio está vazio', None
        
        # Garantir que diretório existe
        ensure_upload_directories()
        
        # Gerar nome único
        filename = generate_unique_filename(file.filename, f'audio_{contributor_id}')
        file_path = os.path.join(AUDIO_FOLDER, filename)
        
        # Salvar arquivo
        file.save(file_path)
        
        # Verificar se foi salvo corretamente
        if not os.path.exists(file_path):
            return False, 'Erro ao salvar arquivo de áudio', None
        
        # Retornar caminho relativo
        relative_path = os.path.join('audio', filename).replace('\\', '/')
        return True, 'Arquivo de áudio salvo com sucesso', relative_path
        
    except Exception as e:
        return False, f'Erro interno ao salvar áudio: {str(e)}', None

def save_image_file(file: FileStorage, contributor_id: str = 'anonymous') -> Tuple[bool, str, Optional[str]]:
    """
    Salva arquivo de imagem e retorna (sucesso, mensagem, caminho_do_arquivo).
    """
    try:
        # Verificar se arquivo foi enviado
        if not file or not file.filename:
            return False, 'Nenhum arquivo de imagem foi enviado', None
        
        # Validar formato
        if not validate_image_format(file.filename):
            return False, 'Formato de imagem não suportado', None
        
        # Verificar tamanho
        file.seek(0, os.SEEK_END)
        file_size = file.tell()
        file.seek(0)
        
        if file_size > MAX_IMAGE_SIZE:
            return False, f'Arquivo muito grande. Máximo: {MAX_IMAGE_SIZE // (1024*1024)}MB', None
        
        if file_size == 0:
            return False, 'Arquivo de imagem está vazio', None
        
        # Garantir que diretório existe
        ensure_upload_directories()
        
        # Gerar nome único
        filename = generate_unique_filename(file.filename, f'img_{contributor_id}')
        file_path = os.path.join(IMAGE_FOLDER, filename)
        
        # Salvar arquivo
        file.save(file_path)
        
        # Verificar se foi salvo corretamente
        if not os.path.exists(file_path):
            return False, 'Erro ao salvar arquivo de imagem', None
        
        # Retornar caminho relativo
        relative_path = os.path.join('images', filename).replace('\\', '/')
        return True, 'Arquivo de imagem salvo com sucesso', relative_path
        
    except Exception as e:
        return False, f'Erro interno ao salvar imagem: {str(e)}', None

def delete_file(file_path: str) -> bool:
    """
    Remove arquivo do sistema de arquivos.
    """
    try:
        if file_path and os.path.exists(file_path):
            os.remove(file_path)
            return True
        return False
    except Exception:
        return False

def get_file_info(file_path: str) -> Optional[dict]:
    """
    Obtém informações sobre um arquivo.
    """
    try:
        if not os.path.exists(file_path):
            return None
        
        stat = os.stat(file_path)
        return {
            'size': stat.st_size,
            'created': datetime.fromtimestamp(stat.st_ctime).isoformat(),
            'modified': datetime.fromtimestamp(stat.st_mtime).isoformat(),
            'hash': calculate_file_hash(file_path)
        }
    except Exception:
        return None

def cleanup_old_files(days_old: int = 30) -> int:
    """
    Remove arquivos antigos para liberar espaço.
    Retorna número de arquivos removidos.
    """
    removed_count = 0
    cutoff_time = datetime.now().timestamp() - (days_old * 24 * 60 * 60)
    
    try:
        for folder in [AUDIO_FOLDER, IMAGE_FOLDER]:
            if not os.path.exists(folder):
                continue
            
            for filename in os.listdir(folder):
                file_path = os.path.join(folder, filename)
                
                if os.path.isfile(file_path):
                    file_mtime = os.path.getmtime(file_path)
                    
                    if file_mtime < cutoff_time:
                        try:
                            os.remove(file_path)
                            removed_count += 1
                        except Exception:
                            continue
    except Exception:
        pass
    
    return removed_count

def get_storage_stats() -> dict:
    """
    Obtém estatísticas de uso de armazenamento.
    """
    stats = {
        'audio_files': 0,
        'image_files': 0,
        'total_audio_size': 0,
        'total_image_size': 0,
        'total_files': 0,
        'total_size': 0
    }
    
    try:
        # Contar arquivos de áudio
        if os.path.exists(AUDIO_FOLDER):
            for filename in os.listdir(AUDIO_FOLDER):
                file_path = os.path.join(AUDIO_FOLDER, filename)
                if os.path.isfile(file_path):
                    stats['audio_files'] += 1
                    stats['total_audio_size'] += os.path.getsize(file_path)
        
        # Contar arquivos de imagem
        if os.path.exists(IMAGE_FOLDER):
            for filename in os.listdir(IMAGE_FOLDER):
                file_path = os.path.join(IMAGE_FOLDER, filename)
                if os.path.isfile(file_path):
                    stats['image_files'] += 1
                    stats['total_image_size'] += os.path.getsize(file_path)
        
        stats['total_files'] = stats['audio_files'] + stats['image_files']
        stats['total_size'] = stats['total_audio_size'] + stats['total_image_size']
        
    except Exception:
        pass
    
    return stats

def validate_file_upload(file: FileStorage, file_type: str) -> Tuple[bool, str]:
    """
    Valida upload de arquivo antes de salvar.
    """
    if not file or not file.filename:
        return False, f'Nenhum arquivo de {file_type} foi enviado'
    
    # Verificar formato baseado no tipo
    if file_type == 'audio':
        if not validate_audio_format(file.filename):
            return False, 'Formato de áudio não suportado'
        max_size = MAX_AUDIO_SIZE
    elif file_type == 'image':
        if not validate_image_format(file.filename):
            return False, 'Formato de imagem não suportado'
        max_size = MAX_IMAGE_SIZE
    else:
        return False, 'Tipo de arquivo não suportado'
    
    # Verificar tamanho
    file.seek(0, os.SEEK_END)
    file_size = file.tell()
    file.seek(0)
    
    if file_size > max_size:
        return False, f'Arquivo muito grande. Máximo: {max_size // (1024*1024)}MB'
    
    if file_size == 0:
        return False, f'Arquivo de {file_type} está vazio'
    
    return True, 'Arquivo válido'