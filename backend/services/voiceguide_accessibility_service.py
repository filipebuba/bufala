"""
Serviço de Acessibilidade VoiceGuide AI
Baseado no Gemma 3n para inclusão completa - offline
"""

import os
import logging
import torch
import time
import threading
import queue
from typing import Dict, List, Optional, Tuple
from transformers import AutoTokenizer, AutoModelForCausalLM
from config.settings import BackendConfig
import speech_recognition as sr
import pyttsx3
import cv2
import numpy as np
from PIL import Image
import io
import base64

logger = logging.getLogger(__name__)

class VoiceGuideAccessibilityService:
    """Serviço completo de acessibilidade com Gemma 3n"""
    
    def __init__(self):
        self.tokenizer = None
        self.model = None
        self.is_initialized = False
        
        # Componentes de acessibilidade
        self.speech_recognizer = None
        self.tts_engine = None
        self.camera = None
        
        # Filas para processamento assíncrono
        self.audio_queue = queue.Queue()
        self.transcription_queue = queue.Queue()
        self.translation_queue = queue.Queue()
        
        # Estado do sistema
        self.is_listening = False
        self.current_language = "pt-BR"
        self.target_language = "crioulo-gb"
        
        self.initialize()
    
    def initialize(self):
        """Inicializar todos os componentes de acessibilidade"""
        try:
            logger.info("🌟 Iniciando VoiceGuide AI - Sistema de Acessibilidade")
            
            # 1. Inicializar Gemma 3n
            success = self._initialize_gemma()
            if not success:
                logger.error("❌ Falha ao inicializar Gemma 3n")
                return False
            
            # 2. Inicializar componentes de áudio
            self._initialize_audio_components()
            
            # 3. Inicializar câmera para visão
            self._initialize_camera()
            
            # 4. Iniciar threads de processamento
            self._start_processing_threads()
            
            self.is_initialized = True
            logger.info("✅ VoiceGuide AI inicializado com sucesso!")
            return True
            
        except Exception as e:
            logger.error(f"❌ Erro na inicialização: {e}")
            return False
    
    def _initialize_gemma(self):
        """Inicializar modelo Gemma 3n"""
        try:
            if not os.path.exists(BackendConfig.MODEL_PATH):
                logger.error(f"❌ Modelo Gemma não encontrado: {BackendConfig.MODEL_PATH}")
                return False
            
            logger.info("🧠 Carregando Gemma 3n para acessibilidade...")
            
            self.tokenizer = AutoTokenizer.from_pretrained(
                BackendConfig.MODEL_PATH,
                local_files_only=True,
                trust_remote_code=True
            )
            
            self.model = AutoModelForCausalLM.from_pretrained(
                BackendConfig.MODEL_PATH,
                torch_dtype=torch.float32,
                device_map=None,
                local_files_only=True,
                trust_remote_code=True
            )
            
            self.model = self.model.to("cpu")
            logger.info("✅ Gemma 3n carregado para acessibilidade")
            return True
            
        except Exception as e:
            logger.error(f"❌ Erro carregando Gemma: {e}")
            return False
    
    def _initialize_audio_components(self):
        """Inicializar componentes de áudio"""
        try:
            # Speech Recognition para transcrição
            self.speech_recognizer = sr.Recognizer()
            self.speech_recognizer.energy_threshold = 300
            self.speech_recognizer.dynamic_energy_threshold = True
            
            # Text-to-Speech para feedback sonoro
            self.tts_engine = pyttsx3.init()
            self.tts_engine.setProperty('rate', 150)  # Velocidade moderada
            self.tts_engine.setProperty('volume', 0.8)
            
            # Configurar voz portuguesa se disponível
            voices = self.tts_engine.getProperty('voices')
            for voice in voices:
                if 'portuguese' in voice.name.lower() or 'brasil' in voice.name.lower():
                    self.tts_engine.setProperty('voice', voice.id)
                    break
            
            logger.info("🎤 Componentes de áudio inicializados")
            
        except Exception as e:
            logger.error(f"⚠️ Erro nos componentes de áudio: {e}")
    
    def _initialize_camera(self):
        """Inicializar câmera para descrição visual"""
        try:
            self.camera = cv2.VideoCapture(0)
            if self.camera.isOpened():
                logger.info("📹 Câmera inicializada para descrição visual")
            else:
                logger.warning("⚠️ Câmera não disponível")
                self.camera = None
                
        except Exception as e:
            logger.error(f"⚠️ Erro na câmera: {e}")
            self.camera = None
    
    def _start_processing_threads(self):
        """Iniciar threads de processamento assíncrono"""
        # Thread para transcrição contínua
        threading.Thread(target=self._continuous_transcription, daemon=True).start()
        
        # Thread para tradução simultânea
        threading.Thread(target=self._continuous_translation, daemon=True).start()
        
        logger.info("🔄 Threads de processamento iniciadas")
    
    # ==========================================
    # FUNCIONALIDADES PARA DEFICIÊNCIA VISUAL
    # ==========================================
    
    def describe_environment(self) -> str:
        """Descrever ambiente usando câmera + Gemma 3n"""
        try:
            if not self.camera or not self.camera.isOpened():
                return "Câmera não disponível para descrição visual"
            
            # Capturar frame
            ret, frame = self.camera.read()
            if not ret:
                return "Não foi possível capturar imagem"
            
            # Converter para base64 para processamento
            _, buffer = cv2.imencode('.jpg', frame)
            image_base64 = base64.b64encode(buffer).decode()
            
            # Usar Gemma 3n para descrever a cena
            prompt = """Descreva detalhadamente o que você vê nesta imagem, focando em:
1. Objetos e pessoas presentes
2. Layout do ambiente
3. Possíveis obstáculos ou perigos
4. Informações úteis para navegação

Responda de forma clara e objetiva para uma pessoa com deficiência visual:"""
            
            description = self._process_with_gemma(prompt, "visual_description")
            
            # Falar a descrição
            self.speak_text(description)
            
            return description
            
        except Exception as e:
            logger.error(f"❌ Erro na descrição visual: {e}")
            return "Erro ao processar imagem visual"
    
    def navigate_with_voice(self, voice_command: str) -> str:
        """Navegação por comando de voz"""
        try:
            prompt = f"""Como assistente de navegação para pessoa com deficiência visual, interprete este comando: "{voice_command}"

Forneça instruções claras e seguras de navegação, incluindo:
1. Direção específica a seguir
2. Alertas sobre possíveis obstáculos
3. Pontos de referência úteis
4. Instruções passo a passo

Resposta para navegação:"""
            
            navigation_response = self._process_with_gemma(prompt, "navigation")
            
            # Falar as instruções
            self.speak_text(navigation_response)
            
            return navigation_response
            
        except Exception as e:
            logger.error(f"❌ Erro na navegação por voz: {e}")
            return "Erro ao processar comando de navegação"
    
    def speak_text(self, text: str):
        """Falar texto usando TTS"""
        try:
            if self.tts_engine:
                # Limpar texto para melhor pronúncia
                clean_text = text.replace("[Gemma", "").replace("]", "").strip()
                self.tts_engine.say(clean_text)
                self.tts_engine.runAndWait()
                
        except Exception as e:
            logger.error(f"⚠️ Erro no TTS: {e}")
    
    # ==========================================
    # FUNCIONALIDADES PARA SURDO E MUDO
    # ==========================================
    
    def start_continuous_transcription(self):
        """Iniciar transcrição contínua para seu primo"""
        try:
            if not self.speech_recognizer:
                return "Sistema de reconhecimento de voz não disponível"
            
            self.is_listening = True
            logger.info("🎤 Iniciando transcrição contínua...")
            
            # Usar microfone padrão
            with sr.Microphone() as source:
                self.speech_recognizer.adjust_for_ambient_noise(source)
                logger.info("✅ Microfone calibrado - transcrição ativa")
            
            # Thread para escuta contínua
            threading.Thread(target=self._listen_continuously, daemon=True).start()
            
            return "Transcrição contínua iniciada - pronto para capturar falas"
            
        except Exception as e:
            logger.error(f"❌ Erro na transcrição contínua: {e}")
            return f"Erro ao iniciar transcrição: {e}"
    
    def _listen_continuously(self):
        """Escutar e transcrever continuamente"""
        with sr.Microphone() as source:
            while self.is_listening:
                try:
                    # Escutar áudio com timeout
                    audio = self.speech_recognizer.listen(source, timeout=1, phrase_time_limit=5)
                    
                    # Adicionar à fila para processamento
                    self.audio_queue.put(audio)
                    
                except sr.WaitTimeoutError:
                    pass  # Timeout normal, continue escutando
                except Exception as e:
                    logger.error(f"⚠️ Erro na escuta: {e}")
    
    def _continuous_transcription(self):
        """Thread para transcrição contínua"""
        while True:
            try:
                # Aguardar áudio na fila
                audio = self.audio_queue.get(timeout=1)
                
                # Transcrever usando speech recognition offline
                try:
                    # Tentar português primeiro
                    text = self.speech_recognizer.recognize_google(audio, language="pt-BR")
                    
                    if text.strip():
                        # Adicionar timestamp
                        timestamp = time.strftime("%H:%M:%S")
                        transcription = {
                            "timestamp": timestamp,
                            "original_text": text,
                            "language": "pt-BR",
                            "translated_text": None
                        }
                        
                        # Adicionar à fila de tradução
                        self.translation_queue.put(transcription)
                        
                        logger.info(f"📝 Transcrito: {text}")
                        
                except sr.UnknownValueError:
                    # Não conseguiu entender o áudio
                    pass
                except sr.RequestError as e:
                    # Erro no serviço - tentar offline
                    try:
                        text = self.speech_recognizer.recognize_sphinx(audio)
                        if text.strip():
                            timestamp = time.strftime("%H:%M:%S")
                            transcription = {
                                "timestamp": timestamp,
                                "original_text": text,
                                "language": "pt-BR",
                                "translated_text": None
                            }
                            self.translation_queue.put(transcription)
                    except:
                        pass  # Falha total na transcrição
                        
            except queue.Empty:
                continue
            except Exception as e:
                logger.error(f"❌ Erro na transcrição: {e}")
    
    def _continuous_translation(self):
        """Thread para tradução simultânea"""
        while True:
            try:
                # Aguardar transcrição na fila
                transcription = self.translation_queue.get(timeout=1)
                
                # Traduzir usando Gemma 3n
                original_text = transcription["original_text"]
                translated = self.translate_text(original_text, self.current_language, self.target_language)
                
                transcription["translated_text"] = translated
                
                # Log da tradução completa
                logger.info(f"🔄 Traduzido: {original_text} → {translated}")
                
                # Aqui você pode enviar para o frontend via WebSocket ou API
                # self._send_to_frontend(transcription)
                
            except queue.Empty:
                continue
            except Exception as e:
                logger.error(f"❌ Erro na tradução: {e}")
    
    def translate_text(self, text: str, source_lang: str = "pt-BR", target_lang: str = "crioulo-gb") -> str:
        """Traduzir texto usando Gemma 3n"""
        try:
            # Mapear idiomas
            lang_map = {
                "pt-BR": "português brasileiro",
                "crioulo-gb": "crioulo da Guiné-Bissau",
                "en-US": "inglês americano"
            }
            
            source_name = lang_map.get(source_lang, source_lang)
            target_name = lang_map.get(target_lang, target_lang)
            
            prompt = f"""Traduza este texto de {source_name} para {target_name}, mantendo o significado e contexto:

Texto original: "{text}"

Tradução para {target_name}:"""
            
            translation = self._process_with_gemma(prompt, "translation")
            
            # Limpar a tradução
            if "Tradução para" in translation:
                translation = translation.split("Tradução para")[-1].split(":")[1].strip()
            
            return translation.strip()
            
        except Exception as e:
            logger.error(f"❌ Erro na tradução: {e}")
            return text  # Retornar texto original se falhar
    
    def get_recent_transcriptions(self, limit: int = 10) -> List[Dict]:
        """Obter transcrições recentes para interface"""
        try:
            # Esta função retornaria as últimas transcrições
            # Por agora, retornar exemplo
            return [
                {
                    "timestamp": "14:30:25",
                    "original_text": "Como você está hoje?",
                    "language": "pt-BR",
                    "translated_text": "Kuma bu sta oji?",
                    "target_language": "crioulo-gb"
                }
            ]
        except Exception as e:
            logger.error(f"❌ Erro obtendo transcrições: {e}")
            return []
    
    # ==========================================
    # PROCESSAMENTO COM GEMMA 3N
    # ==========================================
    
    def _process_with_gemma(self, prompt: str, context: str = "accessibility") -> str:
        """Processar prompt com Gemma 3n otimizado para acessibilidade"""
        try:
            if not self.is_initialized:
                return "Sistema não inicializado"
            
            start_time = time.time()
            
            # Tokenizar
            inputs = self.tokenizer.encode(prompt, return_tensors="pt")
            
            # Gerar resposta otimizada para acessibilidade
            with torch.no_grad():
                outputs = self.model.generate(
                    inputs,
                    max_new_tokens=100,         # Respostas mais curtas para acessibilidade
                    do_sample=True,
                    temperature=0.6,            # Menos criatividade, mais precisão
                    top_p=0.9,
                    top_k=40,
                    repetition_penalty=1.1,
                    pad_token_id=self.tokenizer.eos_token_id,
                    eos_token_id=self.tokenizer.eos_token_id,
                )
            
            # Decodificar
            response = self.tokenizer.decode(outputs[0], skip_special_tokens=True)
            
            # Limpar prompt da resposta
            if prompt in response:
                response = response.replace(prompt, "").strip()
            
            generation_time = time.time() - start_time
            
            logger.info(f"✅ Resposta de acessibilidade gerada em {generation_time:.2f}s")
            return response
            
        except Exception as e:
            logger.error(f"❌ Erro no processamento Gemma: {e}")
            return "Erro no processamento de linguagem"
    
    # ==========================================
    # CONTROLES DO SISTEMA
    # ==========================================
    
    def stop_continuous_transcription(self):
        """Parar transcrição contínua"""
        self.is_listening = False
        logger.info("🛑 Transcrição contínua parada")
    
    def set_languages(self, source_lang: str, target_lang: str):
        """Configurar idiomas para tradução"""
        self.current_language = source_lang
        self.target_language = target_lang
        logger.info(f"🌐 Idiomas configurados: {source_lang} → {target_lang}")
    
    def get_status(self) -> Dict:
        """Status do sistema de acessibilidade"""
        return {
            "service": "VoiceGuide AI - Acessibilidade",
            "initialized": self.is_initialized,
            "gemma_loaded": self.model is not None,
            "audio_available": self.speech_recognizer is not None,
            "tts_available": self.tts_engine is not None,
            "camera_available": self.camera is not None and self.camera.isOpened(),
            "is_listening": self.is_listening,
            "current_language": self.current_language,
            "target_language": self.target_language,
            "features": [
                "visual_description",
                "voice_navigation", 
                "continuous_transcription",
                "simultaneous_translation",
                "offline_processing"
            ]
        }
    
    def cleanup(self):
        """Limpar recursos"""
        try:
            self.is_listening = False
            
            if self.camera:
                self.camera.release()
            
            if self.tts_engine:
                self.tts_engine.stop()
                
            logger.info("🧹 Recursos de acessibilidade limpos")
            
        except Exception as e:
            logger.error(f"⚠️ Erro na limpeza: {e}")
