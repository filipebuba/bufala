#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Validação Final da Padronização Bu Fala
Script para validar arquivos criados e gerar relatório final
"""

import os
import json
from datetime import datetime

def validar_arquivo_existe(caminho):
    """Verifica se um arquivo existe"""
    return os.path.exists(caminho)

def contar_linhas_arquivo(caminho):
    """Conta linhas de um arquivo"""
    try:
        with open(caminho, 'r', encoding='utf-8') as f:
            return len(f.readlines())
    except:
        return 0

def verificar_conteudo_arquivo(caminho, palavras_chave):
    """Verifica se arquivo contém palavras-chave específicas"""
    try:
        with open(caminho, 'r', encoding='utf-8') as f:
            conteudo = f.read().lower()
            return {palavra: palavra in conteudo for palavra in palavras_chave}
    except:
        return {palavra: False for palavra in palavras_chave}

def main():
    print("🔍 VALIDAÇÃO FINAL DA PADRONIZAÇÃO BU FALA")
    print("=" * 60)
    
    # Arquivos criados durante a padronização
    arquivos_criados = {
        'Backend Padronizado': 'bufala_backend_padronizado.py',
        'ApiService Flutter': 'api_service_padronizado.dart',
        'Script de Teste': 'teste_endpoints_padronizados.py',
        'Documentação de Padronização': 'PADRONIZACAO_ENDPOINTS.md',
        'Guia de Migração': 'GUIA_MIGRACAO_PADRONIZACAO.md',
        'Backend Teste Simples': 'backend_teste_simples.py'
    }
    
    relatorio = {
        'timestamp': datetime.now().isoformat(),
        'arquivos_validados': {},
        'estrutura_padronizada': {},
        'compatibilidade': {},
        'resumo': {}
    }
    
    print("\n📁 VALIDAÇÃO DE ARQUIVOS CRIADOS:")
    print("-" * 40)
    
    total_arquivos = len(arquivos_criados)
    arquivos_existentes = 0
    
    for nome, arquivo in arquivos_criados.items():
        existe = validar_arquivo_existe(arquivo)
        linhas = contar_linhas_arquivo(arquivo) if existe else 0
        
        status = "✅ EXISTE" if existe else "❌ AUSENTE"
        print(f"{nome:25} | {status:10} | {linhas:4} linhas")
        
        if existe:
            arquivos_existentes += 1
            
        relatorio['arquivos_validados'][nome] = {
            'arquivo': arquivo,
            'existe': existe,
            'linhas': linhas
        }
    
    print(f"\n📊 Arquivos criados: {arquivos_existentes}/{total_arquivos}")
    
    # Validação de estrutura padronizada
    print("\n🔧 VALIDAÇÃO DE ESTRUTURA PADRONIZADA:")
    print("-" * 45)
    
    # Backend padronizado
    if validar_arquivo_existe('bufala_backend_padronizado.py'):
        palavras_backend = ['success', 'data', 'error', 'timestamp', 'metadata']
        resultado_backend = verificar_conteudo_arquivo('bufala_backend_padronizado.py', palavras_backend)
        
        print("Backend Padronizado:")
        for palavra, encontrada in resultado_backend.items():
            status = "✅" if encontrada else "❌"
            print(f"  {status} Campo '{palavra}'")
            
        relatorio['estrutura_padronizada']['backend'] = resultado_backend
    
    # ApiService Flutter
    if validar_arquivo_existe('api_service_padronizado.dart'):
        palavras_flutter = ['success', 'data', 'error', 'timestamp', 'apiresponse']
        resultado_flutter = verificar_conteudo_arquivo('api_service_padronizado.dart', palavras_flutter)
        
        print("\nApiService Flutter:")
        for palavra, encontrada in resultado_flutter.items():
            status = "✅" if encontrada else "❌"
            print(f"  {status} Campo '{palavra}'")
            
        relatorio['estrutura_padronizada']['flutter'] = resultado_flutter
    
    # Validação de compatibilidade
    print("\n🔄 VALIDAÇÃO DE COMPATIBILIDADE:")
    print("-" * 35)
    
    compatibilidade_score = 0
    total_checks = 0
    
    # Verificar se ambos os arquivos principais existem
    backend_existe = validar_arquivo_existe('bufala_backend_padronizado.py')
    flutter_existe = validar_arquivo_existe('api_service_padronizado.dart')
    
    if backend_existe and flutter_existe:
        print("✅ Backend e Flutter criados")
        compatibilidade_score += 1
    else:
        print("❌ Backend ou Flutter ausente")
    total_checks += 1
    
    # Verificar documentação
    doc_existe = validar_arquivo_existe('PADRONIZACAO_ENDPOINTS.md')
    guia_existe = validar_arquivo_existe('GUIA_MIGRACAO_PADRONIZACAO.md')
    
    if doc_existe and guia_existe:
        print("✅ Documentação completa")
        compatibilidade_score += 1
    else:
        print("❌ Documentação incompleta")
    total_checks += 1
    
    # Verificar script de teste
    teste_existe = validar_arquivo_existe('teste_endpoints_padronizados.py')
    if teste_existe:
        print("✅ Script de teste criado")
        compatibilidade_score += 1
    else:
        print("❌ Script de teste ausente")
    total_checks += 1
    
    compatibilidade_percentual = (compatibilidade_score / total_checks) * 100
    
    relatorio['compatibilidade'] = {
        'score': compatibilidade_score,
        'total': total_checks,
        'percentual': compatibilidade_percentual
    }
    
    # Resumo final
    print("\n" + "=" * 60)
    print("📋 RESUMO FINAL DA PADRONIZAÇÃO")
    print("=" * 60)
    
    print(f"📁 Arquivos criados: {arquivos_existentes}/{total_arquivos} ({(arquivos_existentes/total_arquivos)*100:.1f}%)")
    print(f"🔄 Compatibilidade: {compatibilidade_score}/{total_checks} ({compatibilidade_percentual:.1f}%)")
    
    if compatibilidade_percentual >= 80:
        status_geral = "🟢 SUCESSO"
        print(f"\n🎯 STATUS GERAL: {status_geral}")
        print("✅ Padronização implementada com sucesso!")
        print("✅ Arquivos prontos para integração")
        print("✅ Documentação completa disponível")
    elif compatibilidade_percentual >= 60:
        status_geral = "🟡 PARCIAL"
        print(f"\n🎯 STATUS GERAL: {status_geral}")
        print("⚠️ Padronização parcialmente implementada")
        print("⚠️ Alguns ajustes podem ser necessários")
    else:
        status_geral = "🔴 CRÍTICO"
        print(f"\n🎯 STATUS GERAL: {status_geral}")
        print("❌ Padronização incompleta")
        print("❌ Revisão necessária antes da integração")
    
    relatorio['resumo'] = {
        'status_geral': status_geral,
        'arquivos_percentual': (arquivos_existentes/total_arquivos)*100,
        'compatibilidade_percentual': compatibilidade_percentual,
        'recomendacoes': []
    }
    
    # Recomendações
    print("\n💡 RECOMENDAÇÕES:")
    print("-" * 20)
    
    if not backend_existe:
        rec = "Verificar criação do backend padronizado"
        print(f"• {rec}")
        relatorio['resumo']['recomendacoes'].append(rec)
    
    if not flutter_existe:
        rec = "Verificar criação do ApiService Flutter"
        print(f"• {rec}")
        relatorio['resumo']['recomendacoes'].append(rec)
    
    if not teste_existe:
        rec = "Executar script de teste para validação"
        print(f"• {rec}")
        relatorio['resumo']['recomendacoes'].append(rec)
    
    if compatibilidade_percentual >= 80:
        rec = "Proceder com a migração usando o guia criado"
        print(f"• {rec}")
        relatorio['resumo']['recomendacoes'].append(rec)
    
    # Salvar relatório
    with open('relatorio_validacao_final.json', 'w', encoding='utf-8') as f:
        json.dump(relatorio, f, indent=2, ensure_ascii=False)
    
    print(f"\n💾 Relatório salvo em: relatorio_validacao_final.json")
    
    # Próximos passos
    print("\n🚀 PRÓXIMOS PASSOS:")
    print("-" * 20)
    print("1. Revisar o Guia de Migração (GUIA_MIGRACAO_PADRONIZACAO.md)")
    print("2. Implementar backend padronizado no ambiente de produção")
    print("3. Atualizar ApiService no aplicativo Flutter")
    print("4. Executar testes de integração")
    print("5. Validar funcionamento com modelo Gemma-3n real")
    
    print("\n" + "=" * 60)
    print("🎉 VALIDAÇÃO CONCLUÍDA!")
    print("=" * 60)

if __name__ == '__main__':
    main()