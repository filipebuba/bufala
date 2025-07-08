#!/usr/bin/env python3
"""
Teste simulando exatamente os erros que aparecem nos logs
"""

import requests
import json

def test_exact_flutter_calls():
    """Simula exatamente o que o Flutter está enviando baseado nos logs de erro"""
    
    print("🔍 Simulando exatamente as chamadas que estão falhando...\n")
    
    # Health check primeiro
    print("1️⃣ Health check...")
    try:
        response = requests.get("http://localhost:5000/health", timeout=10)
        print(f"✅ Health: {response.status_code}")
    except:
        print("❌ Backend offline")
        return
    
    # Test 1: Emergência (este está falhando nos logs)
    print("\n2️⃣ Emergência (dados que estão falhando)...")
    emergency_data = {
        'symptoms': "dor no peito e falta de ar",
        'language': 'pt-BR',
        'type': 'medical_question',
    }
    
    try:
        response = requests.post("http://localhost:5000/emergency/analyze", json=emergency_data, timeout=30)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 400:
            error = response.json()
            print(f"❌ Erro 400: {error.get('message', 'N/A')}")
        elif response.status_code == 200:
            print("✅ Emergência OK")
        else:
            print(f"⚠️ Status inesperado: {response.status_code}")
    except Exception as e:
        print(f"❌ Erro: {e}")
    
    # Test 2: Educação (este está falhando nos logs)
    print("\n3️⃣ Educação (dados que estão falhando)...")
    education_data = {
        'topic': "matemática básica",
        'language': 'pt-BR',
        'level': 'básico',
        'duration': 30,
    }
    
    try:
        response = requests.post("http://localhost:5000/education/generate", json=education_data, timeout=30)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 400:
            error = response.json()
            print(f"❌ Erro 400: {error.get('message', 'N/A')}")
        elif response.status_code == 200:
            print("✅ Educação OK")
        else:
            print(f"⚠️ Status inesperado: {response.status_code}")
    except Exception as e:
        print(f"❌ Erro: {e}")
    
    # Test 3: Teste com diferentes codificações
    print("\n4️⃣ Testando diferentes codificações...")
    
    # Teste com caracteres especiais diferentes
    test_cases = [
        ('pt-BR', 'básico'),
        ('pt-BR', 'basico'),  # sem acento
        ('pt', 'básico'),
        ('pt', 'basico'),
    ]
    
    for lang, level in test_cases:
        print(f"\n   Testando: language='{lang}', level='{level}'")
        test_data = {
            'topic': "teste",
            'language': lang,
            'level': level,
            'duration': 30,
        }
        
        try:
            response = requests.post("http://localhost:5000/education/generate", json=test_data, timeout=10)
            if response.status_code == 200:
                print(f"   ✅ OK")
            elif response.status_code == 400:
                error = response.json()
                print(f"   ❌ 400: {error.get('message', 'N/A')}")
            else:
                print(f"   ⚠️ {response.status_code}")
        except Exception as e:
            print(f"   ❌ Erro: {e}")

if __name__ == "__main__":
    test_exact_flutter_calls()
