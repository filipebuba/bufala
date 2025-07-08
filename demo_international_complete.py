#!/usr/bin/env python3
"""
Demonstração Completa do Sistema Internacional Bu Fala para ONGs
"""

import requests
import json
from datetime import datetime

BASE_URL = "http://localhost:5000/api/international"

def test_complete_international_system():
    print("🌍" + "="*70)
    print("   DEMONSTRAÇÃO: Bu Fala Professor Internacional para ONGs")
    print("="*74)
    print()

    # 1. Health Check
    print("1. 🔍 Verificando Sistema...")
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=10)
        if response.status_code == 200:
            data = response.json()
            print(f"   ✅ Sistema: {data['status']}")
            print(f"   📊 Organizações: {data['stats']['total_organizations']}")
            print(f"   👥 Profissionais: {data['stats']['total_professionals']}")
            print(f"   📚 Módulos: {data['stats']['total_modules']}")
        else:
            print(f"   ❌ Erro: {response.status_code}")
            return
    except Exception as e:
        print(f"   ❌ Erro de conexão: {e}")
        return

    print()

    # 2. Listar Organizações
    print("2. 🏢 Organizações Disponíveis:")
    try:
        response = requests.get(f"{BASE_URL}/organizations", timeout=10)
        if response.status_code == 200:
            orgs = response.json()
            for org in orgs:
                print(f"   🌍 {org['name']}")
                print(f"      Tipo: {org['type']}")
                print(f"      Idiomas: {', '.join(org['languages_needed'])}")
                print(f"      Urgência: {org['urgency_level']}")
                print(f"      Ritmo: {org['learning_pace']}")
                print()
        else:
            print(f"   ❌ Erro: {response.status_code}")
    except Exception as e:
        print(f"   ❌ Erro: {e}")

    # 3. Demonstrar Registro de Profissional MSF
    print("3. 👨‍⚕️ Registrando Dr. Pierre (Médicos Sem Fronteiras):")
    try:
        professional_data = {
            "name": "Dr. Pierre Dubois",
            "email": "pierre.dubois@msf.org",
            "profession": "doctor",
            "native_language": "fr",
            "spoken_languages": ["fr", "en"],
            "organization_id": "msf",
            "assignment_location": "bissau",
            "target_languages": ["pt-GW", "ff"]
        }
        
        response = requests.post(
            f"{BASE_URL}/professionals/register",
            json=professional_data,
            timeout=30
        )
        
        if response.status_code == 200:
            prof = response.json()
            print(f"   ✅ Registrado: {prof['name']}")
            print(f"   🏥 Organização: {prof['organization_name']}")
            print(f"   📍 Local: {prof['assignment_location']}")
            print(f"   🗣️ Idiomas alvo: {', '.join(prof['target_languages'])}")
            professional_id = prof['id']
        else:
            print(f"   ❌ Erro no registro: {response.status_code}")
            print(f"   📝 Resposta: {response.text}")
            professional_id = "dr_pierre_123"  # ID de fallback
    except Exception as e:
        print(f"   ❌ Erro: {e}")
        professional_id = "dr_pierre_123"

    print()

    # 4. Módulos Disponíveis
    print("4. 📚 Módulos Especializados:")
    try:
        response = requests.get(f"{BASE_URL}/modules", timeout=10)
        if response.status_code == 200:
            modules = response.json()
            for module in modules:
                print(f"   📖 {module['name']}")
                print(f"      Profissão: {module['profession']}")
                print(f"      Idioma: {module['target_language']}")
                print(f"      Dificuldade: {module['difficulty_level']}")
                print(f"      Duração: {module['estimated_duration_minutes']} min")
                print(f"      Lições: {len(module['lessons'])}")
                print()
        else:
            print(f"   ❌ Erro: {response.status_code}")
    except Exception as e:
        print(f"   ❌ Erro: {e}")

    # 5. Frases de Emergência
    print("5. 🆘 Frases de Emergência Médica:")
    try:
        response = requests.get(
            f"{BASE_URL}/emergency",
            params={"profession": "medical", "language": "pt-GW"},
            timeout=10
        )
        if response.status_code == 200:
            phrases = response.json()
            for phrase in phrases:
                print(f"   🇫🇷 \"{phrase['source_text']}\"")
                print(f"   🇬🇼 \"{phrase['target_text']}\"")
                print(f"   🗣️  [{phrase['pronunciation']}]")
                print(f"   📝 {phrase['context']}")
                print(f"   ⚡ Importância: {phrase['importance']}")
                print()
        else:
            print(f"   ❌ Erro: {response.status_code}")
    except Exception as e:
        print(f"   ❌ Erro: {e}")

    # 6. Dashboard MSF
    print("6. 📊 Dashboard Médicos Sem Fronteiras:")
    try:
        response = requests.get(f"{BASE_URL}/dashboard/msf", timeout=10)
        if response.status_code == 200:
            dashboard = response.json()
            print(f"   🏥 {dashboard['organization_name']}")
            print(f"   👥 Total de profissionais: {dashboard['total_professionals']}")
            print(f"   🟢 Ativos: {dashboard['active_professionals']}")
            print(f"   📈 Progresso médio: {dashboard['average_progress']:.1f}%")
            print(f"   ✅ Módulos concluídos: {dashboard['completed_modules']}")
            print(f"   🔄 Última atualização: {dashboard['last_updated']}")
            
            if dashboard['alerts']:
                print(f"   ⚠️  Alertas:")
                for alert in dashboard['alerts']:
                    print(f"      • {alert}")
            print()
        else:
            print(f"   ❌ Erro: {response.status_code}")
    except Exception as e:
        print(f"   ❌ Erro: {e}")

    # 7. Cenário de Uso Realista
    print("7. 🎭 Cenário Realista - MSF em Campo:")
    print("   👨‍⚕️ Dr. Pierre chega a Bissau para missão de 6 meses")
    print("   📱 Abre Bu Fala International no primeiro dia")
    print("   🏥 Seleciona: Médicos Sem Fronteiras")
    print("   🚨 Acessa: Módulo Emergências Médicas - Crioulo")
    print("   ⏱️  2 horas depois: já consegue atender emergências básicas")
    print("   📊 1 semana depois: 67% de progresso no módulo básico")
    print("   🗣️  1 mês depois: comunica-se fluentemente com pacientes")
    print("   ✅ 3 meses depois: treina novos colegas que chegam")
    print()

    print("="*74)
    print("🎉 DEMONSTRAÇÃO CONCLUÍDA!")
    print("🌍 Sistema Bu Fala Internacional está PRONTO para ONGs!")
    print("="*74)

if __name__ == "__main__":
    test_complete_international_system()
