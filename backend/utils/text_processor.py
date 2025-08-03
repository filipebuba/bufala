#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Módulo de Tratamento de Texto para Respostas do Gemma 3n
Limpa, formata e normaliza as saídas do modelo para apresentação adequada
"""

import re
import html
import unicodedata
import logging
from typing import Dict, Any, Optional, List
import json

logger = logging.getLogger(__name__)

class TextProcessor:
    """Processador de texto para respostas do Gemma 3n"""
    
    # Caracteres problemáticos que aparecem nas respostas
    PROBLEMATIC_CHARS = {
        '\u00e9': 'é',  # é
        '\u00e1': 'á',  # á  
        '\u00e0': 'à',  # à
        '\u00e3': 'ã',  # ã
        '\u00f5': 'õ',  # õ
        '\u00ea': 'ê',  # ê
        '\u00f4': 'ô',  # ô
        '\u00e7': 'ç',  # ç
        '\u00fa': 'ú',  # ú
        '\u00fc': 'ü',  # ü
        '\u00ed': 'í',  # í
        '\u00f3': 'ó',  # ó
        '\u2019': "'",  # aspas curvas
        '\u201c': '"',  # aspas duplas esquerda
        '\u201d': '"',  # aspas duplas direita
        '\u2013': '-',  # en dash
        '\u2014': '--', # em dash
        '\u2026': '...', # reticências
    }
    
    # Padrões de limpeza
    CLEANUP_PATTERNS = [
        # Remove caracteres de controle
        (r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\x9F]', ''),
        # Remove sequências de escape ANSI
        (r'\x1b\[[0-9;]*m', ''),
        # Remove múltiplas quebras de linha
        (r'\n{3,}', '\n\n'),
        # Remove espaços no final de linhas
        (r'[ \t]+$', '', re.MULTILINE),
        # Remove múltiplos espaços
        (r'[ ]{2,}', ' '),
        # Corrige pontuação duplicada
        (r'([.!?]){2,}', r'\1'),
        # Remove espaços antes de pontuação
        (r'\s+([.!?,:;])', r'\1'),
    ]
    
    # Padrões de formatação
    FORMATTING_PATTERNS = [
        # Adiciona espaço após pontuação quando necessário
        (r'([.!?])([A-ZÁÉÍÓÚÀÂÊÔÃÕÇ])', r'\1 \2'),
        # Corrige espaçamento em listas
        (r'^(\s*[-*•]\s*)', r'\n\1', re.MULTILINE),
        # Adiciona quebra de linha antes de títulos
        (r'\n?([A-ZÁÉÍÓÚÀÂÊÔÃÕÇ][^.!?]*:)\s*', r'\n\n\1\n'),
        # Corrige numeração de listas
        (r'\n(\d+)\.\s*', r'\n\1. '),
    ]

    @classmethod
    def clean_response(cls, text: str) -> str:
        """Limpa e normaliza texto de resposta do Gemma 3n"""
        if not text or not isinstance(text, str):
            return ""
        
        try:
            # 1. Decodificar HTML entities
            text = html.unescape(text)
            
            # 2. Normalizar caracteres Unicode
            text = unicodedata.normalize('NFC', text)
            
            # 3. Substituir caracteres problemáticos
            for problematic, replacement in cls.PROBLEMATIC_CHARS.items():
                text = text.replace(problematic, replacement)
            
            # 4. Aplicar padrões de limpeza
            for pattern, replacement, *flags in cls.CLEANUP_PATTERNS:
                flags = flags[0] if flags else 0
                text = re.sub(pattern, replacement, text, flags=flags)
            
            # 5. Aplicar formatação
            for pattern, replacement, *flags in cls.FORMATTING_PATTERNS:
                flags = flags[0] if flags else 0
                text = re.sub(pattern, replacement, text, flags=flags)
            
            # 6. Limpar início e fim
            text = text.strip()
            
            # 7. Garantir que não está vazio
            if not text:
                return "Resposta vazia ou inválida."
            
            return text
            
        except Exception as e:
            logger.error(f"Erro ao limpar texto: {e}")
            return text.strip() if text else "Erro no processamento da resposta."
    
    @classmethod
    def format_medical_response(cls, text: str) -> str:
        """Formatação específica para respostas médicas"""
        text = cls.clean_response(text)
        
        # Adicionar estrutura para respostas médicas
        if not re.search(r'^\*\*|^#|^\d+\.', text, re.MULTILINE):
            # Se não tem formatação, adicionar estrutura básica
            lines = text.split('\n')
            formatted_lines = []
            
            for line in lines:
                line = line.strip()
                if not line:
                    continue
                    
                # Detectar se é um título ou subtítulo
                if len(line) < 100 and line.endswith(':'):
                    formatted_lines.append(f"\n**{line}**")
                # Detectar se é uma lista
                elif line.startswith(('-', '•', '*')):
                    formatted_lines.append(f"• {line[1:].strip()}")
                # Detectar passos numerados
                elif re.match(r'^\d+\.', line):
                    formatted_lines.append(line)
                else:
                    formatted_lines.append(line)
            
            text = '\n'.join(formatted_lines)
        
        return text
    
    @classmethod
    def format_educational_response(cls, text: str) -> str:
        """Formatação específica para respostas educacionais"""
        text = cls.clean_response(text)
        
        # Adicionar emojis educativos quando apropriado
        text = re.sub(r'\b(aprend|estud|escola|professor)', r'📚 \1', text, flags=re.IGNORECASE)
        text = re.sub(r'\b(experiment|test|prática)', r'🔬 \1', text, flags=re.IGNORECASE)
        text = re.sub(r'\b(matemática|número|cálculo)', r'🔢 \1', text, flags=re.IGNORECASE)
        
        return text
    
    @classmethod
    def format_agriculture_response(cls, text: str) -> str:
        """Formatação específica para respostas agrícolas"""
        text = cls.clean_response(text)
        
        # Adicionar emojis agrícolas quando apropriado
        text = re.sub(r'\b(plant|cultiv|semel)', r'🌱 \1', text, flags=re.IGNORECASE)
        text = re.sub(r'\b(solo|terra|fertilizante)', r'🌍 \1', text, flags=re.IGNORECASE)
        text = re.sub(r'\b(colheit|safra)', r'🌾 \1', text, flags=re.IGNORECASE)
        
        return text
    
    @classmethod
    def process_gemma_response(cls, response: Dict[str, Any], context: str = "general") -> Dict[str, Any]:
        """Processa resposta completa do Gemma 3n com contexto específico"""
        try:
            if not response or not isinstance(response, dict):
                return {
                    'success': False,
                    'response': 'Resposta inválida recebida.',
                    'error': 'Invalid response format'
                }
            
            # Extrair texto da resposta
            response_text = response.get('response', '')
            
            if not response_text:
                return {
                    'success': False,
                    'response': 'Resposta vazia recebida.',
                    'error': 'Empty response'
                }
            
            # Aplicar formatação baseada no contexto
            if context == 'medical' or context == 'emergency':
                formatted_text = cls.format_medical_response(response_text)
            elif context == 'education':
                formatted_text = cls.format_educational_response(response_text)
            elif context == 'agriculture':
                formatted_text = cls.format_agriculture_response(response_text)
            else:
                formatted_text = cls.clean_response(response_text)
            
            # Preparar resposta processada
            processed_response = response.copy()
            processed_response['response'] = formatted_text
            processed_response['original_response'] = response_text
            processed_response['processed'] = True
            processed_response['context'] = context
            
            # Adicionar metadata de processamento
            if 'metadata' not in processed_response:
                processed_response['metadata'] = {}
            
            processed_response['metadata'].update({
                'text_processed': True,
                'original_length': len(response_text),
                'processed_length': len(formatted_text),
                'context_applied': context
            })
            
            return processed_response
            
        except Exception as e:
            logger.error(f"Erro ao processar resposta do Gemma: {e}")
            return {
                'success': False,
                'response': 'Erro no processamento da resposta.',
                'error': str(e),
                'original_response': response.get('response', '') if response else ''
            }
    
    @classmethod
    def extract_key_points(cls, text: str, max_points: int = 5) -> List[str]:
        """Extrai pontos-chave de uma resposta longa"""
        text = cls.clean_response(text)
        
        # Procurar por listas existentes
        list_items = re.findall(r'^[-•*]\s*(.+)$', text, re.MULTILINE)
        if list_items and len(list_items) <= max_points:
            return list_items[:max_points]
        
        # Procurar por itens numerados
        numbered_items = re.findall(r'^\d+\.\s*(.+)$', text, re.MULTILINE)
        if numbered_items and len(numbered_items) <= max_points:
            return numbered_items[:max_points]
        
        # Dividir por sentenças e pegar as principais
        sentences = re.split(r'[.!?]+', text)
        key_sentences = [s.strip() for s in sentences if len(s.strip()) > 20 and len(s.strip()) < 200]
        
        return key_sentences[:max_points]
    
    @classmethod
    def create_summary(cls, text: str, max_length: int = 200) -> str:
        """Cria um resumo conciso da resposta"""
        text = cls.clean_response(text)
        
        if len(text) <= max_length:
            return text
        
        # Pegar as primeiras sentenças até o limite
        sentences = re.split(r'[.!?]+', text)
        summary = ""
        
        for sentence in sentences:
            sentence = sentence.strip()
            if not sentence:
                continue
                
            if len(summary + sentence) <= max_length - 3:
                summary += sentence + ". "
            else:
                break
        
        if not summary:
            summary = text[:max_length-3]
        
        return summary.strip() + "..."

# Função de conveniência para uso direto
def clean_gemma_response(response: Dict[str, Any], context: str = "general") -> Dict[str, Any]:
    """Função principal para limpeza de respostas do Gemma 3n"""
    return TextProcessor.process_gemma_response(response, context)
