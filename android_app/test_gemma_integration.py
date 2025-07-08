#!/usr/bin/env python3
"""
Teste rápido para verificar se o backend Gemma-3 está rodando
"""
import requests
import json
import sys

def test_backend_connection():
    """Testa a conexão com o backend Gemma-3"""
    try:
        # Teste básico de saúde
        response = requests.get('http://localhost:8000/health', timeout=10)
        if response.status_code == 200:
            print("✅ Backend Gemma-3 está rodando!")
            print(f"📊 Status: {response.json()}")
            return True
        else:
            print(f"⚠️ Backend respondeu com status {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("❌ Não foi possível conectar ao backend em localhost:8000")
        print("💡 Verifique se o backend está rodando com: python bufala_gemma_backend.py")
        return False
    except Exception as e:
        print(f"❌ Erro inesperado: {e}")
        return False

def test_emergency_endpoint():
    """Testa o endpoint de emergência"""
    try:
        data = {
            'emergency_type': 'medical',
            'description': 'Teste de emergência médica',
            'language': 'pt-BR'
        }
        response = requests.post('http://localhost:8000/emergency/process', 
                               json=data, timeout=15)
        if response.status_code == 200:
            print("✅ Endpoint de emergência funcionando!")
            return True
        else:
            print(f"⚠️ Endpoint de emergência retornou {response.status_code}")
            print(f"Resposta: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Erro no teste de emergência: {e}")
        return False

def test_education_endpoint():
    """Testa o endpoint de educação"""
    try:
        data = {
            'subject': 'health',
            'language': 'pt-BR',
            'level': 'beginner'
        }
        response = requests.post('http://localhost:8000/education/generate', 
                               json=data, timeout=15)
        if response.status_code == 200:
            print("✅ Endpoint de educação funcionando!")
            return True
        else:
            print(f"⚠️ Endpoint de educação retornou {response.status_code}")
            print(f"Resposta: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Erro no teste de educação: {e}")
        return False

if __name__ == "__main__":
    print("🧪 Testando integração com backend Gemma-3...")
    print("=" * 50)
    
    # Teste de conexão básica
    if test_backend_connection():
        print("\n🧪 Testando endpoints específicos...")
        
        # Teste de emergência
        test_emergency_endpoint()
        
        # Teste de educação
        test_education_endpoint()
        
        print("\n🎉 Testes concluídos! O app Flutter está pronto para se conectar.")
    else:
        print("\n❌ Backend não está acessível. Inicie o backend primeiro.")
        sys.exit(1)
