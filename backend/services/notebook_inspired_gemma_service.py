#!/usr/bin/env python3
"""
Backend Otimizado Bu Fala - Inspirado no Notebook Local
Aplicando as otimizações descobertas no notebook para o DocsGemmaService
"""

import os
import logging
import torch
import time
from transformers import AutoProcessor, AutoModelForCausalLM, AutoTokenizer
from config.settings import BackendConfig
from utils.fallback_responses import FallbackResponseGenerator

logger = logging.getLogger(__name__)

class NotebookInspiredGemmaService:
    """
    Serviço Gemma otimizado baseado nas descobertas do notebook local
    Implementa as mesmas técnicas que funcionaram no Jupyter
    """
    
    def __init__(self):
        self.tokenizer = None
        self.model = None
        self.is_initialized = False
        self.fallback_generator = FallbackResponseGenerator()
        
        # Configurações otimizadas inspiradas no notebook
        self.optimized_config = {
            "max_new_tokens": 100,      # ⚡ Reduzido de 400
            "temperature": 0.7,         # 📊 Mesmo do notebook 
            "top_p": 0.9,              # 📊 Mesmo do notebook
            "do_sample": True,          # 📊 Mesmo do notebook
            "pad_token_id": None,       # 🔧 Será definido após carregar tokenizer
            "torch_dtype": torch.float32  # 🎯 CPU otimizado
        }
        
        self.initialize()
    
    def initialize(self):
        """Inicializar modelo seguindo a abordagem do notebook"""
        try:
            logger.info("🚀 Inicializando Notebook-Inspired Gemma Service...")
            
            # Usar o mesmo caminho que funcionou no notebook
            model_path = r"C:\Users\fbg67\.cache\kagglehub\models\google\gemma-3n\transformers\gemma-3n-e2b-it\1"
            
            if not os.path.exists(model_path):
                logger.error(f"❌ Modelo não encontrado: {model_path}")
                logger.info("💡 Execute o notebook primeiro para baixar o modelo")
                return False
            
            start_time = time.time()
            
            logger.info("📦 Carregando tokenizer (inspirado no notebook)...")
            self.tokenizer = AutoTokenizer.from_pretrained(
                model_path,
                trust_remote_code=True,
                local_files_only=True
            )
            
            logger.info("🧠 Carregando modelo (inspirado no notebook)...")
            self.model = AutoModelForCausalLM.from_pretrained(
                model_path,
                trust_remote_code=True,
                local_files_only=True,
                torch_dtype=self.optimized_config["torch_dtype"]
            )
            
            # Configurar pad_token_id como no notebook
            self.optimized_config["pad_token_id"] = self.tokenizer.eos_token_id
            
            # Usar CPU como no notebook (mais estável)
            device = "cpu"  # Forçar CPU como funcionou no notebook
            logger.info(f"📱 Usando dispositivo: {device}")
            
            # Não chamar .to(device) se já está na CPU por padrão
            
            load_time = time.time() - start_time
            self.is_initialized = True
            
            logger.info(f"✅ Notebook-Inspired Gemma carregado em {load_time:.2f}s!")
            logger.info("🎯 Configuração otimizada ativa - respostas em ~60s")
            return True
            
        except Exception as e:
            logger.error(f"❌ Erro na inicialização inspirada: {e}")
            return False
    
    def notebook_style_query(self, input_text, context="agricultura"):
        """
        Função gemma_query() inspirada diretamente no notebook
        Implementação quase idêntica à que funcionou no Jupyter
        """
        try:
            if not self.is_initialized:
                logger.warning("⚠️ Modelo não inicializado")
                return self._fallback_response(input_text, context)
            
            # Verificar se o input não está vazio (como no notebook)
            if not input_text.strip():
                return "Por favor, digite uma pergunta."
            
            start_time = time.time()
            logger.info(f"🤖 Processando (notebook style): {input_text[:50]}...")
            
            # Preparar input exatamente como no notebook
            inputs = self.tokenizer(input_text, return_tensors="pt")
            
            # Mover para mesmo device que o modelo (CPU)
            inputs = inputs.to(self.model.device)
            
            # Gerar resposta com configurações do notebook
            with torch.no_grad():  # Exatamente como no notebook
                outputs = self.model.generate(
                    **inputs,
                    max_new_tokens=self.optimized_config["max_new_tokens"],  # 100
                    do_sample=self.optimized_config["do_sample"],            # True
                    temperature=self.optimized_config["temperature"],        # 0.7
                    top_p=self.optimized_config["top_p"],                   # 0.9
                    pad_token_id=self.optimized_config["pad_token_id"]      # eos_token_id
                )
            
            # Decodificar resposta exatamente como no notebook
            response = self.tokenizer.decode(outputs[0], skip_special_tokens=True)
            
            # Remover o prompt original da resposta (como no notebook)
            if input_text in response:
                response = response.replace(input_text, "").strip()
            
            generation_time = time.time() - start_time
            
            if response and len(response) > 5:
                logger.info(f"✅ Resposta notebook-style gerada em {generation_time:.2f}s")
                return f"{response}\n\n[Notebook-Inspired Gemma • {generation_time:.1f}s]"
            else:
                logger.warning("⚠️ Resposta vazia ou muito curta")
                return self._fallback_response(input_text, context)
            
        except Exception as e:
            logger.error(f"❌ Erro na geração notebook-style: {e}")
            return self._fallback_response(input_text, context)
    
    def create_optimized_prompt(self, prompt, context="agricultura"):
        """
        Criar prompts otimizados e concisos (inspirado no notebook)
        Evitar contexto excessivo que causa lentidão
        """
        
        # Templates super concisos - inspirados no notebook
        concise_templates = {
            "agricultura": f"Como especialista agrícola, responda: {prompt}",
            "medico": f"Como médico, responda: {prompt}",
            "educacao": f"Como educador, responda: {prompt}",
            "geral": prompt  # Prompt direto como no notebook
        }
        
        # Retornar prompt conciso
        return concise_templates.get(context, prompt)
    
    def generate_response(self, prompt, language="pt-BR", context="agricultura"):
        """Método de compatibilidade - usando abordagem do notebook"""
        try:
            logger.info(f"🔄 Usando abordagem notebook para: {prompt[:50]}...")
            
            # Criar prompt otimizado e conciso
            optimized_prompt = self.create_optimized_prompt(prompt, context)
            
            # Usar função notebook-style
            response = self.notebook_style_query(optimized_prompt, context)
            
            logger.info(f"✅ Resposta notebook-inspired gerada com sucesso")
            return response
            
        except Exception as e:
            logger.error(f"❌ Erro no método compatibilidade: {e}")
            return self._fallback_response(prompt, context)
    
    def _fallback_response(self, prompt, context="agricultura"):
        """Resposta de fallback contextualizada"""
        response = self.fallback_generator.generate_response(prompt, context)
        return f"{response}\n\n[Fallback Response • Notebook-Gemma indisponível]"
    
    def get_status(self):
        """Status do serviço inspirado no notebook"""
        return {
            "service": "Notebook-Inspired Gemma Service",
            "initialized": self.is_initialized,
            "model_path": r"C:\Users\fbg67\.cache\kagglehub\models\google\gemma-3n\transformers\gemma-3n-e2b-it\1",
            "backend": "AutoModelForCausalLM",
            "device": "cpu",
            "optimizations": [
                "notebook_inspired", "max_new_tokens_100", "concise_prompts",
                "torch_no_grad", "cpu_stable", "eos_pad_token"
            ],
            "expected_response_time": "60-90 seconds",
            "config": self.optimized_config
        }
    
    def test_connection(self):
        """Teste usando mesma abordagem do notebook"""
        try:
            if not self.is_initialized:
                return False, "Notebook-Gemma não inicializado"
            
            test_prompt = "Como plantar alface?"
            start_time = time.time()
            
            response = self.notebook_style_query(test_prompt, context="agricultura")
            test_time = time.time() - start_time
            
            if "Fallback" not in response:
                return True, f"Notebook-Gemma funcionando ({test_time:.1f}s)"
            else:
                return False, "Notebook-Gemma retornou fallback"
                
        except Exception as e:
            return False, f"Erro no teste notebook: {e}"
    
    def benchmark_vs_docs_service(self):
        """Comparar performance com DocsGemmaService"""
        logger.info("📊 BENCHMARK: Notebook-Style vs Docs-Style")
        
        test_prompts = [
            "Como preparar solo para arroz?",
            "Sintomas de malária?", 
            "O que é fotossíntese?"
        ]
        
        results = {}
        
        for prompt in test_prompts:
            start_time = time.time()
            response = self.notebook_style_query(prompt)
            elapsed = time.time() - start_time
            
            results[prompt] = {
                "time": elapsed,
                "length": len(response),
                "success": "Fallback" not in response
            }
            
            logger.info(f"📋 {prompt[:20]}... -> {elapsed:.1f}s")
        
        return results

# Teste rápido de integração
if __name__ == "__main__":
    print("🧪 TESTANDO NOTEBOOK-INSPIRED GEMMA SERVICE")
    print("=" * 55)
    
    service = NotebookInspiredGemmaService()
    
    if service.is_initialized:
        print("✅ Serviço inicializado com sucesso!")
        
        # Teste rápido
        test_response = service.generate_response(
            "Como plantar milho na época das chuvas?",
            context="agricultura"
        )
        
        print(f"📋 Teste concluído: {len(test_response)} chars")
        print(f"🎯 Primeira linha: {test_response.split('\n')[0]}")
        
        # Status
        status = service.get_status()
        print(f"⚙️ Config: {status['expected_response_time']}")
    else:
        print("❌ Falha na inicialização - execute o notebook primeiro!")
