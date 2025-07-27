#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de Configuração Automática do Moransa
Hackathon Gemma 3n

Este script configura automaticamente o sistema para usar os modelos
Gemma-3n otimizados com base nos recursos disponíveis.
"""

import os
import sys
import logging
import json
import time
from pathlib import Path
from typing import Dict, Any, List

# Adicionar o diretório pai ao path
sys.path.append(str(Path(__file__).parent.parent))

from services.model_selector import ModelSelector
from config.settings import BackendConfig

class MoransaAutoSetup:
    """Configuração automática do sistema Moransa"""
    
    def __init__(self):
        self.logger = self._setup_logging()
        self.config = BackendConfig
        self.setup_results = {}
        
    def _setup_logging(self) -> logging.Logger:
        """Configurar logging para o setup"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.StreamHandler(sys.stdout),
                logging.FileHandler('moransa_setup.log')
            ]
        )
        return logging.getLogger(__name__)
    
    def run_complete_setup(self) -> Dict[str, Any]:
        """Executar configuração completa do sistema"""
        self.logger.info("="*60)
        self.logger.info("🚀 MORANSA - CONFIGURAÇÃO AUTOMÁTICA")
        self.logger.info("📱 App Android para Comunidades da Guiné-Bissau")
        self.logger.info("🏆 Hackathon Gemma 3n")
        self.logger.info("="*60)
        
        try:
            # 1. Verificar recursos do sistema
            self._check_system_resources()
            
            # 2. Configurar modelos automaticamente
            self._setup_models()
            
            # 3. Verificar dependências
            self._check_dependencies()
            
            # 4. Configurar variáveis de ambiente
            self._setup_environment()
            
            # 5. Testar configuração
            self._test_configuration()
            
            # 6. Gerar relatório
            self._generate_report()
            
            self.logger.info("✅ Configuração automática concluída com sucesso!")
            return self.setup_results
            
        except Exception as e:
            self.logger.error(f"❌ Erro na configuração automática: {e}")
            self.setup_results['error'] = str(e)
            return self.setup_results
    
    def _check_system_resources(self):
        """Verificar recursos do sistema"""
        self.logger.info("🔍 Verificando recursos do sistema...")
        
        try:
            resources = ModelSelector.get_system_resources()
            
            self.setup_results['system_resources'] = {
                'total_ram_gb': resources.total_ram_gb,
                'available_ram_gb': resources.available_ram_gb,
                'cpu_count': resources.cpu_cores,
                'has_cuda': resources.has_cuda,
                'gpu_memory_gb': resources.gpu_memory_gb,
                'gpu_name': getattr(resources, 'gpu_name', 'N/A')
            }
            
            self.logger.info(f"💾 RAM Total: {resources.total_ram_gb:.1f}GB")
            self.logger.info(f"💾 RAM Disponível: {resources.available_ram_gb:.1f}GB")
            self.logger.info(f"🖥️ CPUs: {resources.cpu_cores}")
            self.logger.info(f"🎮 CUDA: {'✅ Disponível' if resources.has_cuda else '❌ Não disponível'}")
            
            if resources.has_cuda:
                self.logger.info(f"🎮 GPU Memory: {resources.gpu_memory_gb:.1f}GB")
            
            # Verificar se o sistema atende aos requisitos mínimos
            if resources.available_ram_gb < 4.0:
                self.logger.warning("⚠️ RAM baixa detectada. Alguns modelos podem não funcionar.")
            
            if resources.available_ram_gb >= 8.0:
                self.logger.info("✅ Sistema com recursos suficientes para modelos grandes")
            
        except Exception as e:
            self.logger.error(f"❌ Erro ao verificar recursos: {e}")
            raise
    
    def _setup_models(self):
        """Configurar modelos automaticamente"""
        self.logger.info("🤖 Configurando modelos Gemma-3n automaticamente...")
        
        try:
            # Obter configuração automática
            auto_config = ModelSelector.auto_configure_for_system()
            
            self.setup_results['model_configuration'] = {
                'selected_model': auto_config['selected_model'],
                'fallback_models': auto_config['fallback_models'],
                'quantization_settings': auto_config['quantization_settings']
            }
            
            self.logger.info(f"🎯 Modelo principal selecionado: {auto_config['selected_model']}")
            self.logger.info(f"🔄 Modelos fallback: {len(auto_config['fallback_models'])}")
            
            # Configurar modelos por domínio
            domains = ['medical', 'education', 'agriculture', 'wellness', 'translation']
            domain_models = {}
            
            for domain in domains:
                model, config = ModelSelector.get_model_for_domain(domain)
                domain_models[domain] = {
                    'model': model,
                    'config': config
                }
                self.logger.info(f"📚 {domain.capitalize()}: {model}")
            
            self.setup_results['domain_models'] = domain_models
            
            # Verificar disponibilidade dos modelos
            available_models = []
            for model in ModelSelector.FOURBIT_MODELS[:5]:  # Verificar os 5 primeiros
                if ModelSelector.validate_model_availability(model):
                    available_models.append(model)
            
            self.setup_results['available_models'] = available_models
            self.logger.info(f"✅ {len(available_models)} modelos verificados como disponíveis")
            
        except Exception as e:
            self.logger.error(f"❌ Erro na configuração de modelos: {e}")
            raise
    
    def _check_dependencies(self):
        """Verificar dependências necessárias"""
        self.logger.info("📦 Verificando dependências...")
        
        dependencies = {
            'torch': 'PyTorch',
            'transformers': 'Hugging Face Transformers',
            'flask': 'Flask',
            'requests': 'Requests',
            'psutil': 'PSUtil',
            'kaggle': 'Kaggle API'
        }
        
        optional_dependencies = {
            'unsloth': 'Unsloth (otimização)',
            'bitsandbytes': 'BitsAndBytes (quantização)',
            'accelerate': 'Accelerate (otimização)',
            'peft': 'PEFT (fine-tuning)'
        }
        
        installed = []
        missing = []
        optional_installed = []
        optional_missing = []
        
        # Verificar dependências obrigatórias
        for package, description in dependencies.items():
            try:
                __import__(package)
                installed.append(f"✅ {description}")
            except ImportError:
                missing.append(f"❌ {description}")
        
        # Verificar dependências opcionais
        for package, description in optional_dependencies.items():
            try:
                __import__(package)
                optional_installed.append(f"✅ {description}")
            except ImportError:
                optional_missing.append(f"⚠️ {description}")
        
        self.setup_results['dependencies'] = {
            'required_installed': len(installed),
            'required_missing': len(missing),
            'optional_installed': len(optional_installed),
            'optional_missing': len(optional_missing)
        }
        
        # Log resultados
        for item in installed:
            self.logger.info(item)
        
        for item in missing:
            self.logger.error(item)
        
        for item in optional_installed:
            self.logger.info(item)
        
        for item in optional_missing:
            self.logger.warning(item)
        
        if missing:
            self.logger.error("❌ Dependências obrigatórias em falta. Execute: pip install -r requirements.txt")
            raise Exception(f"Dependências em falta: {missing}")
        
        self.logger.info("✅ Todas as dependências obrigatórias estão instaladas")
    
    def _setup_environment(self):
        """Configurar variáveis de ambiente"""
        self.logger.info("🔧 Configurando variáveis de ambiente...")
        
        try:
            # Verificar arquivo .env
            env_path = Path(__file__).parent.parent / '.env'
            env_example_path = Path(__file__).parent.parent / '.env.example'
            
            if not env_path.exists() and env_example_path.exists():
                self.logger.info("📋 Copiando .env.example para .env")
                import shutil
                shutil.copy2(env_example_path, env_path)
            
            # Verificar configurações críticas
            critical_vars = [
                'GEMMA_MODEL_NAME',
                'USE_UNSLOTH',
                'USE_QUANTIZATION',
                'KAGGLE_USERNAME',
                'KAGGLE_KEY'
            ]
            
            missing_vars = []
            for var in critical_vars:
                if not os.getenv(var):
                    missing_vars.append(var)
            
            self.setup_results['environment'] = {
                'env_file_exists': env_path.exists(),
                'missing_critical_vars': missing_vars
            }
            
            if missing_vars:
                self.logger.warning(f"⚠️ Variáveis de ambiente em falta: {missing_vars}")
                self.logger.info("📝 Configure essas variáveis no arquivo .env")
            else:
                self.logger.info("✅ Todas as variáveis críticas configuradas")
            
        except Exception as e:
            self.logger.error(f"❌ Erro na configuração de ambiente: {e}")
            raise
    
    def _test_configuration(self):
        """Testar configuração do sistema"""
        self.logger.info("🧪 Testando configuração...")
        
        try:
            # Testar seleção de modelo
            selected_model, config = ModelSelector.select_optimal_model()
            
            # Testar configuração automática
            auto_config = ModelSelector.auto_configure_for_system()
            
            # Simular carregamento de modelo
            test_results = {
                'model_selection': True,
                'auto_configuration': True,
                'selected_model': selected_model,
                'config_valid': bool(config)
            }
            
            self.setup_results['test_results'] = test_results
            
            self.logger.info(f"✅ Modelo selecionado: {selected_model}")
            self.logger.info("✅ Configuração automática funcionando")
            self.logger.info("✅ Sistema pronto para uso")
            
        except Exception as e:
            self.logger.error(f"❌ Erro nos testes: {e}")
            self.setup_results['test_results'] = {'error': str(e)}
    
    def _generate_report(self):
        """Gerar relatório de configuração"""
        self.logger.info("📊 Gerando relatório de configuração...")
        
        try:
            report_path = Path(__file__).parent.parent / 'moransa_setup_report.json'
            
            report = {
                'timestamp': time.time(),
                'setup_version': '1.0.0',
                'hackathon': 'Gemma 3n',
                'project': 'Moransa - App Android para Guiné-Bissau',
                'results': self.setup_results
            }
            
            with open(report_path, 'w', encoding='utf-8') as f:
                json.dump(report, f, indent=2, ensure_ascii=False)
            
            self.logger.info(f"📄 Relatório salvo em: {report_path}")
            
            # Gerar resumo
            self._print_summary()
            
        except Exception as e:
            self.logger.error(f"❌ Erro ao gerar relatório: {e}")
    
    def _print_summary(self):
        """Imprimir resumo da configuração"""
        self.logger.info("\n" + "="*60)
        self.logger.info("📋 RESUMO DA CONFIGURAÇÃO")
        self.logger.info("="*60)
        
        # Recursos do sistema
        if 'system_resources' in self.setup_results:
            resources = self.setup_results['system_resources']
            self.logger.info(f"💾 RAM: {resources['available_ram_gb']:.1f}GB disponível")
            self.logger.info(f"🎮 CUDA: {'Sim' if resources['has_cuda'] else 'Não'}")
        
        # Modelos
        if 'model_configuration' in self.setup_results:
            config = self.setup_results['model_configuration']
            self.logger.info(f"🤖 Modelo principal: {config['selected_model']}")
            self.logger.info(f"🔄 Fallbacks: {len(config['fallback_models'])}")
        
        # Dependências
        if 'dependencies' in self.setup_results:
            deps = self.setup_results['dependencies']
            self.logger.info(f"📦 Dependências: {deps['required_installed']}/{deps['required_installed'] + deps['required_missing']}")
        
        # Status final
        if 'test_results' in self.setup_results and not self.setup_results['test_results'].get('error'):
            self.logger.info("✅ SISTEMA PRONTO PARA USO!")
        else:
            self.logger.warning("⚠️ Sistema configurado com avisos")
        
        self.logger.info("="*60)
        self.logger.info("🚀 Para iniciar o servidor: python app.py")
        self.logger.info("📱 Para testar a API: http://localhost:5000")
        self.logger.info("📚 Documentação: http://localhost:5000/docs")
        self.logger.info("="*60)

def main():
    """Função principal"""
    setup = MoransaAutoSetup()
    results = setup.run_complete_setup()
    
    # Retornar código de saída apropriado
    if 'error' in results:
        sys.exit(1)
    else:
        sys.exit(0)

if __name__ == '__main__':
    main()