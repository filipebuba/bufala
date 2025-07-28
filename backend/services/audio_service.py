import os
import wave
import json
from typing import Optional, Dict, Any, Tuple
from datetime import datetime
import tempfile

class AudioService:
    """
    Serviço para processamento e análise de áudio.
    """
    
    def __init__(self):
        self.supported_formats = ['.wav', '.mp3', '.ogg', '.m4a', '.aac']
        self.max_duration = 30  # segundos
        self.min_duration = 0.5  # segundos
    
    def validate_audio_file(self, file_path: str) -> Tuple[bool, str, Optional[Dict[str, Any]]]:
        """
        Valida arquivo de áudio e retorna informações básicas.
        """
        try:
            if not os.path.exists(file_path):
                return False, 'Arquivo não encontrado', None
            
            # Verificar extensão
            file_extension = os.path.splitext(file_path)[1].lower()
            if file_extension not in self.supported_formats:
                return False, f'Formato não suportado: {file_extension}', None
            
            # Obter informações básicas do arquivo
            file_size = os.path.getsize(file_path)
            if file_size == 0:
                return False, 'Arquivo de áudio está vazio', None
            
            # Para arquivos WAV, podemos obter mais informações
            audio_info = {
                'file_size': file_size,
                'format': file_extension,
                'created_at': datetime.fromtimestamp(os.path.getctime(file_path)).isoformat()
            }
            
            if file_extension == '.wav':
                try:
                    with wave.open(file_path, 'rb') as wav_file:
                        frames = wav_file.getnframes()
                        sample_rate = wav_file.getframerate()
                        duration = frames / float(sample_rate)
                        
                        audio_info.update({
                            'duration': duration,
                            'sample_rate': sample_rate,
                            'channels': wav_file.getnchannels(),
                            'sample_width': wav_file.getsampwidth()
                        })
                        
                        # Validar duração
                        if duration < self.min_duration:
                            return False, f'Áudio muito curto. Mínimo: {self.min_duration}s', None
                        
                        if duration > self.max_duration:
                            return False, f'Áudio muito longo. Máximo: {self.max_duration}s', None
                        
                except Exception as e:
                    return False, f'Erro ao analisar arquivo WAV: {str(e)}', None
            
            return True, 'Arquivo de áudio válido', audio_info
            
        except Exception as e:
            return False, f'Erro ao validar áudio: {str(e)}', None
    
    def analyze_audio_quality(self, file_path: str) -> Dict[str, Any]:
        """
        Analisa a qualidade do áudio (implementação básica).
        """
        try:
            is_valid, message, info = self.validate_audio_file(file_path)
            
            if not is_valid:
                return {
                    'quality_score': 0.0,
                    'issues': [message],
                    'recommendations': ['Verifique o arquivo de áudio']
                }
            
            quality_score = 0.5  # Score base
            issues = []
            recommendations = []
            
            if info and 'duration' in info:
                duration = info['duration']
                
                # Penalizar áudios muito curtos ou muito longos
                if duration < 1.0:
                    quality_score -= 0.2
                    issues.append('Áudio muito curto')
                    recommendations.append('Grave por pelo menos 1 segundo')
                elif duration > 10.0:
                    quality_score -= 0.1
                    issues.append('Áudio longo')
                    recommendations.append('Mantenha gravações concisas')
                else:
                    quality_score += 0.2
                
                # Verificar taxa de amostragem
                if 'sample_rate' in info:
                    sample_rate = info['sample_rate']
                    if sample_rate >= 44100:
                        quality_score += 0.2
                    elif sample_rate >= 22050:
                        quality_score += 0.1
                    else:
                        issues.append('Taxa de amostragem baixa')
                        recommendations.append('Use taxa de amostragem de pelo menos 22kHz')
                
                # Verificar canais
                if 'channels' in info:
                    channels = info['channels']
                    if channels == 1:  # Mono é preferível para voz
                        quality_score += 0.1
            
            # Verificar tamanho do arquivo
            if info and 'file_size' in info:
                file_size = info['file_size']
                if file_size < 1024:  # Muito pequeno
                    quality_score -= 0.2
                    issues.append('Arquivo muito pequeno')
                elif file_size > 5 * 1024 * 1024:  # Muito grande
                    quality_score -= 0.1
                    issues.append('Arquivo muito grande')
                    recommendations.append('Considere comprimir o áudio')
            
            # Garantir que o score está entre 0 e 1
            quality_score = max(0.0, min(1.0, quality_score))
            
            return {
                'quality_score': quality_score,
                'issues': issues,
                'recommendations': recommendations,
                'audio_info': info
            }
            
        except Exception as e:
            return {
                'quality_score': 0.0,
                'issues': [f'Erro na análise: {str(e)}'],
                'recommendations': ['Verifique o arquivo de áudio']
            }
    
    def transcribe_audio(self, file_path: str, expected_text: Optional[str] = None) -> Dict[str, Any]:
        """
        Transcreve áudio para texto (implementação simulada).
        Em produção, integrar com serviços como Google Speech-to-Text, Azure Speech, etc.
        """
        try:
            is_valid, message, info = self.validate_audio_file(file_path)
            
            if not is_valid:
                return {
                    'success': False,
                    'error': message,
                    'transcription': '',
                    'confidence': 0.0
                }
            
            # Simulação de transcrição
            # Em produção, aqui seria feita a chamada para o serviço de STT
            if expected_text:
                # Simular que a transcrição é similar ao texto esperado
                transcription = expected_text.lower().strip()
                confidence = 0.85  # Simular alta confiança
            else:
                # Simular transcrição genérica
                transcription = "[transcrição simulada]"
                confidence = 0.5
            
            return {
                'success': True,
                'transcription': transcription,
                'confidence': confidence,
                'language_detected': 'pt',  # Simular detecção de português
                'duration': info.get('duration', 0) if info else 0
            }
            
        except Exception as e:
            return {
                'success': False,
                'error': f'Erro na transcrição: {str(e)}',
                'transcription': '',
                'confidence': 0.0
            }
    
    def compare_audio_text(self, audio_path: str, expected_text: str) -> Dict[str, Any]:
        """
        Compara áudio transcrito com texto esperado.
        """
        try:
            transcription_result = self.transcribe_audio(audio_path, expected_text)
            
            if not transcription_result['success']:
                return {
                    'match_score': 0.0,
                    'is_match': False,
                    'error': transcription_result['error']
                }
            
            transcribed_text = transcription_result['transcription']
            expected_text_clean = expected_text.lower().strip()
            
            # Calcular similaridade simples
            if transcribed_text == expected_text_clean:
                match_score = 1.0
            elif expected_text_clean in transcribed_text or transcribed_text in expected_text_clean:
                match_score = 0.8
            else:
                # Calcular similaridade por palavras
                expected_words = set(expected_text_clean.split())
                transcribed_words = set(transcribed_text.split())
                
                if expected_words and transcribed_words:
                    intersection = expected_words.intersection(transcribed_words)
                    union = expected_words.union(transcribed_words)
                    match_score = len(intersection) / len(union) if union else 0.0
                else:
                    match_score = 0.0
            
            is_match = match_score >= 0.7  # Threshold para considerar match
            
            return {
                'match_score': match_score,
                'is_match': is_match,
                'transcribed_text': transcribed_text,
                'expected_text': expected_text_clean,
                'confidence': transcription_result['confidence']
            }
            
        except Exception as e:
            return {
                'match_score': 0.0,
                'is_match': False,
                'error': f'Erro na comparação: {str(e)}'
            }
    
    def generate_audio_fingerprint(self, file_path: str) -> Optional[str]:
        """
        Gera fingerprint do áudio para detectar duplicatas.
        """
        try:
            import hashlib
            
            # Para uma implementação simples, usar hash do arquivo
            with open(file_path, 'rb') as f:
                file_hash = hashlib.md5(f.read()).hexdigest()
            
            # Em produção, usar algoritmos de audio fingerprinting como:
            # - Chromaprint (usado pelo AcoustID)
            # - Echoprint
            # - Shazam-like algorithms
            
            return file_hash
            
        except Exception:
            return None
    
    def detect_language(self, file_path: str) -> Dict[str, Any]:
        """
        Detecta idioma do áudio (implementação simulada).
        """
        try:
            # Simular detecção de idioma
            # Em produção, usar serviços como Google Cloud Speech-to-Text
            # que suportam detecção automática de idioma
            
            detected_languages = [
                {'language': 'pt', 'confidence': 0.7, 'name': 'Português'},
                {'language': 'gcr', 'confidence': 0.2, 'name': 'Crioulo da Guiné-Bissau'},
                {'language': 'en', 'confidence': 0.1, 'name': 'Inglês'}
            ]
            
            return {
                'success': True,
                'detected_languages': detected_languages,
                'primary_language': detected_languages[0]['language']
            }
            
        except Exception as e:
            return {
                'success': False,
                'error': f'Erro na detecção de idioma: {str(e)}',
                'detected_languages': [],
                'primary_language': 'unknown'
            }
    
    def convert_audio_format(self, input_path: str, output_format: str = 'wav') -> Tuple[bool, str, Optional[str]]:
        """
        Converte áudio para formato específico (implementação básica).
        """
        try:
            if not os.path.exists(input_path):
                return False, 'Arquivo de entrada não encontrado', None
            
            # Em produção, usar bibliotecas como pydub ou ffmpeg
            # Por enquanto, apenas simular a conversão
            
            input_ext = os.path.splitext(input_path)[1].lower()
            if input_ext == f'.{output_format}':
                return True, 'Arquivo já está no formato desejado', input_path
            
            # Simular conversão bem-sucedida
            output_path = input_path.replace(input_ext, f'.{output_format}')
            
            return True, f'Conversão para {output_format} simulada', output_path
            
        except Exception as e:
            return False, f'Erro na conversão: {str(e)}', None
    
    def cleanup_temp_files(self) -> int:
        """
        Remove arquivos temporários de áudio.
        """
        cleaned_count = 0
        try:
            temp_dir = tempfile.gettempdir()
            for filename in os.listdir(temp_dir):
                if filename.startswith('audio_temp_') and any(filename.endswith(ext) for ext in self.supported_formats):
                    try:
                        os.remove(os.path.join(temp_dir, filename))
                        cleaned_count += 1
                    except Exception:
                        continue
        except Exception:
            pass
        
        return cleaned_count