#!/usr/bin/env python3
"""
Debug específico para verificar exatamente o que está sendo enviado
"""

import requests
import json

def debug_education_request():
    """Debug do request de educação"""
    print("🔍 DEBUG: Testando request de educação...")
    
    url = "http://localhost:5000/education/generate"
    
    # Teste com dados exatos
    test_data = {
        'topic': "prevenção de malária",
        'language': 'pt-BR',
        'level': 'básico',
        'duration': 30,
    }
    
    print(f"📤 Enviando: {json.dumps(test_data, indent=2, ensure_ascii=False)}")
    
    try:
        response = requests.post(url, json=test_data, timeout=30)
        print(f"📨 Status: {response.status_code}")
        print(f"📨 Response: {response.text}")
        
        if response.status_code == 400:
            # Vamos ver o erro detalhado
            try:
                error_data = response.json()
                print(f"🚫 Erro detalhado: {json.dumps(error_data, indent=2, ensure_ascii=False)}")
            except:
                print(f"🚫 Erro raw: {response.text}")
                
    except Exception as e:
        print(f"❌ Erro de conexão: {e}")

def debug_emergency_request():
    """Debug do request de emergência"""
    print("\n🔍 DEBUG: Testando request de emergência...")
    
    url = "http://localhost:5000/emergency/analyze"
    
    # Teste com dados exatos
    test_data = {
        'symptoms': "dor no peito",
        'language': 'pt-BR',
    }
    
    print(f"📤 Enviando: {json.dumps(test_data, indent=2, ensure_ascii=False)}")
    
    try:
        response = requests.post(url, json=test_data, timeout=30)
        print(f"📨 Status: {response.status_code}")
        
        if response.status_code == 400:
            try:
                error_data = response.json()
                print(f"🚫 Erro detalhado: {json.dumps(error_data, indent=2, ensure_ascii=False)}")
            except:
                print(f"🚫 Erro raw: {response.text}")
        elif response.status_code == 200:
            print("✅ Emergência funcionando!")
                
    except Exception as e:
        print(f"❌ Erro de conexão: {e}")

if __name__ == "__main__":
    debug_emergency_request()
    debug_education_request()
