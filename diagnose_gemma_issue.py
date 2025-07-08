#!/usr/bin/env python3
"""
🔍 DIAGNÓSTICO ESPECÍFICO: Por que o Gemma-3n não está sendo usado
"""

import os
import sys
import traceback
import torch
from transformers import AutoTokenizer, AutoModelForCausalLM

def diagnose_gemma_issue():
    print("🔍 DIAGNÓSTICO DO PROBLEMA GEMMA-3N")
    print("=" * 60)
    
    # 1. Verificar caminho do modelo
    model_path = r"C:\Users\fbg67\.cache\kagglehub\models\google\gemma-3n\transformers\gemma-3n-e2b-it\1"
    print(f"📁 Verificando caminho: {model_path}")
    
    if os.path.exists(model_path):
        print("✅ Caminho do modelo existe")
        
        # Listar arquivos no diretório
        files = os.listdir(model_path)
        print(f"📄 Arquivos encontrados: {files}")
        
        # Verificar arquivos essenciais
        essential_files = ['config.json', 'tokenizer.json', 'pytorch_model.bin']
        missing_files = [f for f in essential_files if f not in files]
        if missing_files:
            print(f"❌ Arquivos essenciais faltando: {missing_files}")
        else:
            print("✅ Arquivos essenciais presentes")
    else:
        print("❌ Caminho do modelo NÃO existe")
        return False
    
    # 2. Verificar se PyTorch funciona
    print("\n🧪 Testando PyTorch...")
    try:
        device = "cuda" if torch.cuda.is_available() else "cpu"
        print(f"🔧 Dispositivo disponível: {device}")
        
        # Teste básico de tensor
        test_tensor = torch.tensor([1, 2, 3])
        print(f"✅ PyTorch funcionando: {test_tensor}")
    except Exception as e:
        print(f"❌ Erro no PyTorch: {e}")
        return False
    
    # 3. Tentar carregar tokenizer
    print("\n📝 Testando carregamento do tokenizer...")
    try:
        tokenizer = AutoTokenizer.from_pretrained(
            model_path,
            local_files_only=True,
            trust_remote_code=True
        )
        print("✅ Tokenizer carregado com sucesso")
    except Exception as e:
        print(f"❌ Erro ao carregar tokenizer: {e}")
        print(f"❌ Traceback: {traceback.format_exc()}")
        return False
    
    # 4. Tentar carregar modelo (simplificado)
    print("\n🧠 Testando carregamento do modelo...")
    try:
        model = AutoModelForCausalLM.from_pretrained(
            model_path,
            local_files_only=True,
            trust_remote_code=True,
            torch_dtype=torch.float32,  # Usar float32 para compatibilidade
            device_map=None  # Não usar device_map automático
        )
        print("✅ Modelo carregado com sucesso")
        
        # 5. Teste simples de geração
        print("\n🚀 Testando geração de texto...")
        test_prompt = "Olá"
        inputs = tokenizer(test_prompt, return_tensors="pt")
        
        with torch.no_grad():
            outputs = model.generate(
                **inputs,
                max_new_tokens=5,
                do_sample=False,
                temperature=0.1
            )
        
        response = tokenizer.decode(outputs[0], skip_special_tokens=True)
        print(f"✅ Geração funcionando: {response}")
        
        return True
        
    except Exception as e:
        print(f"❌ Erro ao carregar modelo: {e}")
        print(f"❌ Traceback: {traceback.format_exc()}")
        return False

def check_backend_initialization():
    """Verificar especificamente o problema na inicialização do backend"""
    print("\n🔧 VERIFICANDO INICIALIZAÇÃO DO BACKEND")
    print("=" * 50)
    
    try:
        # Simular a classe do backend
        class TestBackend:
            def __init__(self):
                self.model = None
                self.tokenizer = None
                self.is_initialized = False
                self.transformers_model_path = r"C:\Users\fbg67\.cache\kagglehub\models\google\gemma-3n\transformers\gemma-3n-e2b-it\1"
                
                # Testar inicialização
                if self.load_gemma3n_model():
                    self.is_initialized = True
                    print("✅ Backend inicializado com sucesso")
                else:
                    print("❌ Falha na inicialização do backend")
            
            def load_gemma3n_model(self):
                try:
                    print("🔧 Carregando modelo no backend...")
                    
                    # Carregar tokenizer
                    self.tokenizer = AutoTokenizer.from_pretrained(
                        self.transformers_model_path,
                        local_files_only=True,
                        trust_remote_code=True
                    )
                    
                    # Carregar modelo
                    self.model = AutoModelForCausalLM.from_pretrained(
                        self.transformers_model_path,
                        local_files_only=True,
                        trust_remote_code=True,
                        torch_dtype=torch.float32
                    )
                    
                    print("✅ Modelo carregado no backend")
                    return True
                    
                except Exception as e:
                    print(f"❌ Erro no backend: {e}")
                    return False
            
            def test_generation(self):
                if not self.is_initialized:
                    print("❌ Backend não inicializado")
                    return False
                
                try:
                    prompt = "Coach de bem-estar: Como posso relaxar?\nOrientação:"
                    inputs = self.tokenizer(prompt, return_tensors="pt")
                    
                    with torch.no_grad():
                        outputs = self.model.generate(
                            **inputs,
                            max_new_tokens=20,
                            do_sample=True,
                            temperature=0.3,
                            pad_token_id=self.tokenizer.eos_token_id
                        )
                    
                    # Decodificar apenas a parte nova
                    generated_tokens = outputs[0][inputs['input_ids'].shape[1]:]
                    response = self.tokenizer.decode(generated_tokens, skip_special_tokens=True)
                    
                    print(f"✅ Resposta gerada: {response}")
                    return True
                    
                except Exception as e:
                    print(f"❌ Erro na geração: {e}")
                    return False
        
        # Testar backend
        backend = TestBackend()
        if backend.is_initialized:
            backend.test_generation()
        
    except Exception as e:
        print(f"❌ Erro no teste do backend: {e}")
        print(f"❌ Traceback: {traceback.format_exc()}")

if __name__ == "__main__":
    # Executar diagnósticos
    print("🔍 Iniciando diagnóstico completo...\n")
    
    # Diagnóstico básico
    basic_ok = diagnose_gemma_issue()
    
    if basic_ok:
        # Teste específico do backend
        check_backend_initialization()
        
        print("\n🎯 CONCLUSÃO:")
        print("Se todos os testes passaram, o problema pode estar em:")
        print("1. Condição no código que está forçando fallback")
        print("2. Erro silencioso na geração")
        print("3. Problema na lógica de verificação is_initialized")
    else:
        print("\n❌ PROBLEMA ENCONTRADO:")
        print("O modelo Gemma-3n não está carregando corretamente.")
        print("Verifique se o modelo foi baixado e está no caminho correto.")
