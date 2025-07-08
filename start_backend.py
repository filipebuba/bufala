#!/usr/bin/env python3
"""
Script para iniciar o backend Bu Fala automaticamente
Verifica dependências e inicia o servidor
"""

import os
import sys
import subprocess
import time
import requests
from pathlib import Path

def check_python_version():
    """Verificar se a versão do Python é adequada"""
    if sys.version_info < (3, 8):
        print("❌ Python 3.8+ é necessário")
        return False
    print(f"✅ Python {sys.version.split()[0]} detectado")
    return True

def check_backend_directory():
    """Verificar se estamos no diretório correto"""
    backend_dir = Path("backend")
    if not backend_dir.exists():
        print("❌ Diretório 'backend' não encontrado")
        print("Execute este script a partir do diretório raiz do projeto")
        return False
    
    app_py = backend_dir / "app.py"
    if not app_py.exists():
        print("❌ Arquivo 'backend/app.py' não encontrado")
        return False
    
    print("✅ Estrutura do backend encontrada")
    return True

def install_requirements():
    """Instalar dependências do backend"""
    requirements_file = Path("backend") / "requirements.txt"
    
    if not requirements_file.exists():
        print("⚠️ Arquivo requirements.txt não encontrado, criando um básico...")
        create_basic_requirements()
    
    try:
        print("📦 Instalando dependências...")
        subprocess.run([
            sys.executable, "-m", "pip", "install", "-r", str(requirements_file)
        ], check=True, capture_output=True)
        print("✅ Dependências instaladas com sucesso")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Erro ao instalar dependências: {e}")
        return False

def create_basic_requirements():
    """Criar arquivo requirements.txt básico"""
    requirements_content = """flask>=2.3.0
flask-cors>=4.0.0
requests>=2.31.0
transformers>=4.35.0
torch>=2.1.0
numpy>=1.24.0
pillow>=10.0.0
speech-recognition>=3.10.0
pyttsx3>=2.90
loguru>=0.7.0
python-dotenv>=1.0.0
"""
    
    requirements_file = Path("backend") / "requirements.txt"
    with open(requirements_file, 'w', encoding='utf-8') as f:
        f.write(requirements_content)
    print("✅ Arquivo requirements.txt criado")

def check_backend_running():
    """Verificar se o backend já está rodando"""
    try:
        response = requests.get("http://localhost:5000/health", timeout=5)
        if response.status_code == 200:
            print("✅ Backend já está rodando em http://localhost:5000")
            return True
    except requests.exceptions.RequestException:
        pass
    
    print("ℹ️ Backend não está rodando")
    return False

def start_backend():
    """Iniciar o backend"""
    try:
        print("🚀 Iniciando backend Bu Fala...")
        
        # Mudar para o diretório backend
        os.chdir("backend")
        
        # Iniciar o servidor
        process = subprocess.Popen([
            sys.executable, "app.py"
        ], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        
        # Aguardar um pouco para o servidor iniciar
        time.sleep(3)
        
        # Verificar se o processo ainda está rodando
        if process.poll() is None:
            print("✅ Backend iniciado com sucesso!")
            print("🌐 Acesse: http://localhost:5000")
            print("🔍 Health check: http://localhost:5000/health")
            print("\n📱 Agora você pode executar o aplicativo Flutter")
            print("\n⏹️ Para parar o backend, pressione Ctrl+C")
            
            try:
                # Aguardar o processo terminar
                process.wait()
            except KeyboardInterrupt:
                print("\n🛑 Parando backend...")
                process.terminate()
                process.wait()
                print("✅ Backend parado")
        else:
            stdout, stderr = process.communicate()
            print(f"❌ Erro ao iniciar backend:")
            print(f"STDOUT: {stdout}")
            print(f"STDERR: {stderr}")
            return False
            
    except Exception as e:
        print(f"❌ Erro inesperado: {e}")
        return False
    
    return True

def main():
    """Função principal"""
    print("🌟 Bu Fala Backend Starter")
    print("=" * 30)
    
    # Verificações preliminares
    if not check_python_version():
        return 1
    
    if not check_backend_directory():
        return 1
    
    # Verificar se já está rodando
    if check_backend_running():
        response = input("\n❓ Backend já está rodando. Deseja continuar mesmo assim? (s/N): ")
        if response.lower() not in ['s', 'sim', 'y', 'yes']:
            print("✅ Operação cancelada")
            return 0
    
    # Instalar dependências
    if not install_requirements():
        print("❌ Falha ao instalar dependências")
        return 1
    
    # Iniciar backend
    if not start_backend():
        print("❌ Falha ao iniciar backend")
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())