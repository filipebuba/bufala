import re
import json
import logging
from typing import Optional, Dict, Any

logger = logging.getLogger(__name__)

def safe_parse_llm_json(response: str) -> Optional[Dict[Any, Any]]:
    """
    Tenta extrair e parsear um JSON de uma resposta de modelo de linguagem,
    aplicando múltiplas camadas de limpeza e correção.
    Retorna None se falhar.
    """
    if not isinstance(response, str):
        logger.error("Resposta não é string.")
        return None

    # 1. Limpeza inicial: remover caracteres de controle e normalizar quebras
    cleaned = re.sub(r'[\x00-\x1f\x7f-\x9f]', '', response)
    cleaned = cleaned.replace('\r\n', '\n').replace('\r', '\n')

    # 2. Remover blocos markdown de código (com ou sem 'json')
    cleaned = re.sub(r'```(?:json)?\s*', '', cleaned, flags=re.IGNORECASE)
    cleaned = re.sub(r'```$', '', cleaned)

    # 3. Extrair conteúdo entre { } (possível JSON) - versão simplificada
    json_match = re.search(r'\{.*\}', cleaned, re.DOTALL)
    if not json_match:
        logger.warning("Nenhum bloco JSON encontrado na resposta.")
        return None

    json_str = json_match.group(0)

    logger.info(f"🔍 JSON bruto extraído: {json_str[:300]}...")

    # 4. Correções comuns
    fix_mapping = {
        r'speciees': 'species',
        r'true': 'true',  # garantir booleanos
        r'false': 'false',
        r'null': 'null',
    }
    for bad, good in fix_mapping.items():
        json_str = re.sub(rf'\b{bad}\b', good, json_str, flags=re.IGNORECASE)

    # 5. Corrigir números decimais com espaços
    json_str = re.sub(r'(\d+)\s*\.\s*(\d+)', r'\1.\2', json_str)
    json_str = re.sub(r':\s*([0-9]+\s*\.\s*[0-9]+)', r': \1', json_str)

    # 6. Corrigir espaços em torno de vírgulas, dois pontos e chaves
    json_str = re.sub(r'\s*,\s*', ', ', json_str)
    json_str = re.sub(r'\s*:\s*', ': ', json_str)
    json_str = re.sub(r'\{\s*', '{', json_str)
    json_str = re.sub(r'\s*\}', '}', json_str)
    json_str = re.sub(r'\[\s*', '[', json_str)
    json_str = re.sub(r'\s*\]', ']', json_str)

    # 7. Garantir aspas duplas em chaves e strings
    # Corrigir aspas simples para duplas (cuidado: não dentro de strings!)
    # Simplificação: assumir que chaves estão sem aspas ou com aspas simples
    json_str = re.sub(r'([{,])\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*:', r'\1"\2":', json_str)

    # 8. Corrigir strings com aspas simples para duplas (caso simples)
    # Aviso: isso pode falhar em strings complexas, mas ajuda em casos simples
    def replace_single_quotes(match):
        content = match.group(1)
        return f'"{content}"'

    json_str = re.sub(r'"\s*:\s*\'([^\']*)\'', lambda m: f'": "{m.group(1)}"', json_str)
    json_str = re.sub(r':\s*\'([^\']*)\'', lambda m: f': "{m.group(1)}"', json_str)

    logger.info(f"🔧 JSON após correções básicas: {json_str[:300]}...")

    # 9. Tentar parse com json.loads
    try:
        return json.loads(json_str)
    except json.JSONDecodeError as e:
        logger.warning(f"Primeira tentativa de parse falhou: {e}")

    # 10. Última tentativa: limpeza agressiva (só ASCII, espaços, etc)
    aggressive = re.sub(r'[^\x20-\x7E]', '', json_str)  # Remove não-ASCII
    aggressive = re.sub(r'\s+', ' ', aggressive)  # Espaços múltiplos → um espaço
    aggressive = aggressive.strip()

    # Fechar chaves faltando (tentativa simples)
    open_braces = aggressive.count('{')
    close_braces = aggressive.count('}')
    if open_braces > close_braces:
        aggressive += '}' * (open_braces - close_braces)
    elif close_braces > open_braces:
        aggressive = '{' * (close_braces - open_braces) + aggressive

    # Fechar colchetes, se aplicável
    if '[' in aggressive and ']' not in aggressive:
        aggressive += ']'

    logger.info(f"🔧 JSON após limpeza agressiva: {aggressive[:300]}...")

    try:
        result = json.loads(aggressive)
        logger.info(f"✅ JSON parseado com sucesso após limpeza agressiva!")
        return result
    except json.JSONDecodeError as e:
        logger.error(f"❌ Falha ao parsear JSON mesmo após limpeza: {e}")
        logger.debug(f"Texto final tentado: {aggressive}")
        return None