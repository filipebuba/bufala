import os
import kagglehub
from transformers import AutoTokenizer

print('=== Verificando modelos disponíveis ===')

# Verificar cache do KaggleHub
print('\n1. Cache do KaggleHub:')
try:
    cache_dir = kagglehub.cache_dir()
    print(f'Diretório: {cache_dir}')
    if os.path.exists(cache_dir):
        items = os.listdir(cache_dir)
        gemma_items = [item for item in items if 'gemma' in item.lower()]
        if gemma_items:
            for item in gemma_items:
                print(f'  {item}')
        else:
            print('  Nenhum modelo Gemma encontrado')
    else:
        print('  Diretório não encontrado')
except Exception as e:
    print(f'  Erro: {e}')

# Verificar cache do Hugging Face
print('\n2. Cache do Hugging Face:')
hf_cache = os.path.expanduser('~/.cache/huggingface')
print(f'Diretório: {hf_cache}')
if os.path.exists(hf_cache):
    for subdir in ['transformers', 'hub']:
        subdir_path = os.path.join(hf_cache, subdir)
        if os.path.exists(subdir_path):
            print(f'  {subdir}:')
            items = os.listdir(subdir_path)
            gemma_items = [item for item in items if 'gemma' in item.lower()]
            if gemma_items:
                for item in gemma_items[:5]:  # Mostrar apenas os primeiros 5
                    print(f'    {item}')
                if len(gemma_items) > 5:
                    print(f'    ... e mais {len(gemma_items) - 5} itens')
            else:
                print('    Nenhum modelo Gemma encontrado')
else:
    print('  Diretório não encontrado')

# Tentar carregar modelos Gemma conhecidos
print('\n3. Testando modelos Gemma conhecidos:')
gemma_models = [
    'google/gemma-3-2b-it',
    'google/gemma-3-1b-it', 
    'google/gemma-2-2b-it',
    'google/gemma-2b-it'
]

for model_name in gemma_models:
    try:
        print(f'  Testando {model_name}...')
        tokenizer = AutoTokenizer.from_pretrained(model_name, cache_dir=hf_cache)
        print(f'    ✓ {model_name} disponível')
        break
    except Exception as e:
        print(f'    ✗ {model_name} não disponível: {str(e)[:100]}...')

print('\n=== Verificação concluída ===')