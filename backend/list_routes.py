#!/usr/bin/env python3
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app

print("=== LISTANDO ROTAS DA APLICAÇÃO REAL ===")

try:
    app = create_app()
    
    print("\nRotas registradas na aplicação:")
    with app.app_context():
        all_routes = []
        for rule in app.url_map.iter_rules():
            all_routes.append({
                'rule': rule.rule,
                'methods': list(rule.methods),
                'endpoint': rule.endpoint
            })
        
        # Ordenar por URL
        all_routes.sort(key=lambda x: x['rule'])
        
        print(f"\nTotal de rotas: {len(all_routes)}")
        
        # Mostrar apenas rotas ambientais
        env_routes = [r for r in all_routes if '/environmental/' in r['rule']]
        print(f"\nRotas ambientais ({len(env_routes)}):")
        for route in env_routes:
            print(f"  {route['rule']} - {route['methods']} - {route['endpoint']}")
        
        # Verificar se a rota específica existe
        target_route = '/api/environmental/education'
        found = any(r['rule'] == target_route for r in all_routes)
        print(f"\nRota '{target_route}' encontrada: {found}")
        
        if not found:
            print("\nRotas similares encontradas:")
            similar = [r for r in all_routes if 'education' in r['rule']]
            for route in similar:
                print(f"  {route['rule']} - {route['methods']} - {route['endpoint']}")
        
except Exception as e:
    print(f"❌ Erro: {e}")
    import traceback
    traceback.print_exc()

print("\n=== FIM ===")