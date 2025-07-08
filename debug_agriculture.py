#!/usr/bin/env python3
"""
Teste Debug para entender o erro 500 na rota de agricultura
"""

import requests
import json

def debug_agriculture_error():
    """Debug do erro na rota de agricultura"""
    base_url = "http://localhost:5000"
    
    print("🔍 DEBUGANDO ERRO NA ROTA DE AGRICULTURA")
    print("=" * 50)
    
    # Teste com dados mínimos
    test_data = {
        "question": "Como plantar arroz?",
        "language": "pt-BR"
    }
    
    print(f"📤 Testando com dados mínimos: {test_data}")
    
    try:
        response = requests.post(
            f"{base_url}/agriculture",
            json=test_data,
            timeout=30
        )
        
        print(f"📊 Status Code: {response.status_code}")
        print(f"📄 Headers: {dict(response.headers)}")
        print(f"📝 Response: {response.text}")
        
        if response.status_code != 200:
            print("\n🔍 Tentando com campo 'prompt' em vez de 'question'...")
            
            test_data2 = {
                "prompt": "Como plantar arroz?",
                "language": "pt-BR"
            }
            
            response2 = requests.post(
                f"{base_url}/agriculture",
                json=test_data2,
                timeout=30
            )
            
            print(f"📊 Status Code (prompt): {response2.status_code}")
            print(f"📝 Response (prompt): {response2.text}")
        
    except Exception as e:
        print(f"❌ Erro na requisição: {e}")

if __name__ == "__main__":
    debug_agriculture_error()
