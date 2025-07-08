#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de Teste - Endpoints Padronizados Bu Fala
Testa a comunicação entre backend padronizado e estrutura esperada pelo Flutter
"""

import requests
import json
import time
from datetime import datetime
from typing import Dict, Any

class TestePadronizacao:
    def __init__(self, base_url: str = "http://127.0.0.1:5000"):
        self.base_url = base_url
        self.resultados = []
        
    def log_resultado(self, teste: str, sucesso: bool, detalhes: str = ""):
        """Registra resultado do teste"""
        resultado = {
            'teste': teste,
            'sucesso': sucesso,
            'detalhes': detalhes,
            'timestamp': datetime.now().isoformat()
        }
        self.resultados.append(resultado)
        status = "✅ PASSOU" if sucesso else "❌ FALHOU"
        print(f"{status} - {teste}")
        if detalhes:
            print(f"   Detalhes: {detalhes}")
        print()
    
    def testar_health(self):
        """Testa endpoint /health"""
        try:
            response = requests.get(f"{self.base_url}/health", timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                
                # Verificar estrutura padronizada
                campos_obrigatorios = ['success', 'data', 'timestamp']
                for campo in campos_obrigatorios:
                    if campo not in data:
                        self.log_resultado(
                            "Health - Estrutura", 
                            False, 
                            f"Campo '{campo}' ausente na resposta"
                        )
                        return
                
                # Verificar dados específicos
                data_section = data.get('data', {})
                campos_data = ['status', 'model_status', 'features', 'backend_version']
                for campo in campos_data:
                    if campo not in data_section:
                        self.log_resultado(
                            "Health - Dados", 
                            False, 
                            f"Campo '{campo}' ausente em data"
                        )
                        return
                
                self.log_resultado(
                    "Health - Endpoint", 
                    True, 
                    f"Status: {data_section['status']}, Features: {len(data_section['features'])}"
                )
            else:
                self.log_resultado(
                    "Health - Endpoint", 
                    False, 
                    f"Status code: {response.status_code}"
                )
                
        except Exception as e:
            self.log_resultado("Health - Endpoint", False, str(e))
    
    def testar_medical(self):
        """Testa endpoint /medical"""
        try:
            payload = {
                "question": "Como tratar uma dor de cabeça?",
                "language": "pt-BR",
                "urgency": "medium"
            }
            
            response = requests.post(
                f"{self.base_url}/medical", 
                json=payload, 
                timeout=30
            )
            
            if response.status_code == 200:
                data = response.json()
                
                # Verificar estrutura padronizada
                if not self._verificar_estrutura_padrao(data, "Medical"):
                    return
                
                # Verificar dados específicos
                data_section = data.get('data', {})
                campos_medical = ['answer', 'question', 'domain', 'language', 'metadata']
                for campo in campos_medical:
                    if campo not in data_section:
                        self.log_resultado(
                            "Medical - Dados", 
                            False, 
                            f"Campo '{campo}' ausente em data"
                        )
                        return
                
                # Verificar metadata
                metadata = data_section.get('metadata', {})
                campos_metadata = ['urgency', 'confidence', 'emergency_detected', 'recommendations']
                for campo in campos_metadata:
                    if campo not in metadata:
                        self.log_resultado(
                            "Medical - Metadata", 
                            False, 
                            f"Campo '{campo}' ausente em metadata"
                        )
                        return
                
                self.log_resultado(
                    "Medical - Endpoint", 
                    True, 
                    f"Domínio: {data_section['domain']}, Confiança: {metadata['confidence']}"
                )
            else:
                self.log_resultado(
                    "Medical - Endpoint", 
                    False, 
                    f"Status code: {response.status_code}"
                )
                
        except Exception as e:
            self.log_resultado("Medical - Endpoint", False, str(e))
    
    def testar_education(self):
        """Testa endpoint /education"""
        try:
            payload = {
                "question": "Como ensinar matemática básica?",
                "language": "pt-BR",
                "subject": "mathematics",
                "level": "elementary"
            }
            
            response = requests.post(
                f"{self.base_url}/education", 
                json=payload, 
                timeout=30
            )
            
            if response.status_code == 200:
                data = response.json()
                
                if not self._verificar_estrutura_padrao(data, "Education"):
                    return
                
                data_section = data.get('data', {})
                metadata = data_section.get('metadata', {})
                
                # Verificar campos específicos da educação
                if 'subject' in metadata and 'level' in metadata:
                    self.log_resultado(
                        "Education - Endpoint", 
                        True, 
                        f"Matéria: {metadata['subject']}, Nível: {metadata['level']}"
                    )
                else:
                    self.log_resultado(
                        "Education - Metadata", 
                        False, 
                        "Campos subject/level ausentes"
                    )
            else:
                self.log_resultado(
                    "Education - Endpoint", 
                    False, 
                    f"Status code: {response.status_code}"
                )
                
        except Exception as e:
            self.log_resultado("Education - Endpoint", False, str(e))
    
    def testar_agriculture(self):
        """Testa endpoint /agriculture"""
        try:
            payload = {
                "question": "Quando plantar arroz?",
                "language": "pt-BR",
                "crop_type": "rice",
                "season": "planting"
            }
            
            response = requests.post(
                f"{self.base_url}/agriculture", 
                json=payload, 
                timeout=30
            )
            
            if response.status_code == 200:
                data = response.json()
                
                if not self._verificar_estrutura_padrao(data, "Agriculture"):
                    return
                
                data_section = data.get('data', {})
                metadata = data_section.get('metadata', {})
                
                # Verificar campos específicos da agricultura
                campos_agri = ['crop_type', 'season', 'best_practices']
                for campo in campos_agri:
                    if campo not in metadata:
                        self.log_resultado(
                            "Agriculture - Metadata", 
                            False, 
                            f"Campo '{campo}' ausente"
                        )
                        return
                
                self.log_resultado(
                    "Agriculture - Endpoint", 
                    True, 
                    f"Cultura: {metadata['crop_type']}, Estação: {metadata['season']}"
                )
            else:
                self.log_resultado(
                    "Agriculture - Endpoint", 
                    False, 
                    f"Status code: {response.status_code}"
                )
                
        except Exception as e:
            self.log_resultado("Agriculture - Endpoint", False, str(e))
    
    def testar_translate(self):
        """Testa endpoint /translate"""
        try:
            payload = {
                "text": "Como você está?",
                "from_language": "pt-BR",
                "to_language": "crioulo-gb"
            }
            
            response = requests.post(
                f"{self.base_url}/translate", 
                json=payload, 
                timeout=30
            )
            
            if response.status_code == 200:
                data = response.json()
                
                if not self._verificar_estrutura_padrao(data, "Translate"):
                    return
                
                data_section = data.get('data', {})
                campos_translate = ['translated', 'original_text', 'from_language', 'to_language']
                for campo in campos_translate:
                    if campo not in data_section:
                        self.log_resultado(
                            "Translate - Dados", 
                            False, 
                            f"Campo '{campo}' ausente"
                        )
                        return
                
                self.log_resultado(
                    "Translate - Endpoint", 
                    True, 
                    f"'{data_section['original_text']}' -> '{data_section['translated']}'"
                )
            else:
                self.log_resultado(
                    "Translate - Endpoint", 
                    False, 
                    f"Status code: {response.status_code}"
                )
                
        except Exception as e:
            self.log_resultado("Translate - Endpoint", False, str(e))
    
    def testar_multimodal(self):
        """Testa endpoint /multimodal"""
        try:
            payload = {
                "text": "Analise esta situação",
                "type": "text_analysis",
                "language": "pt-BR",
                "context": "general"
            }
            
            response = requests.post(
                f"{self.base_url}/multimodal", 
                json=payload, 
                timeout=30
            )
            
            if response.status_code == 200:
                data = response.json()
                
                if not self._verificar_estrutura_padrao(data, "Multimodal"):
                    return
                
                data_section = data.get('data', {})
                metadata = data_section.get('metadata', {})
                
                # Verificar campos específicos multimodal
                campos_multi = ['has_image', 'has_audio', 'has_text', 'confidence']
                for campo in campos_multi:
                    if campo not in metadata:
                        self.log_resultado(
                            "Multimodal - Metadata", 
                            False, 
                            f"Campo '{campo}' ausente"
                        )
                        return
                
                self.log_resultado(
                    "Multimodal - Endpoint", 
                    True, 
                    f"Tipo: {data_section.get('type')}, Confiança: {metadata['confidence']}"
                )
            else:
                self.log_resultado(
                    "Multimodal - Endpoint", 
                    False, 
                    f"Status code: {response.status_code}"
                )
                
        except Exception as e:
            self.log_resultado("Multimodal - Endpoint", False, str(e))
    
    def testar_validacao_erros(self):
        """Testa tratamento de erros padronizado"""
        try:
            # Teste com JSON inválido
            response = requests.post(
                f"{self.base_url}/medical", 
                data="json inválido", 
                headers={'Content-Type': 'application/json'},
                timeout=10
            )
            
            if response.status_code == 400:
                data = response.json()
                
                # Verificar estrutura de erro padronizada
                if 'success' in data and not data['success'] and 'error' in data:
                    error = data['error']
                    campos_erro = ['code', 'message', 'details', 'suggestions']
                    
                    for campo in campos_erro:
                        if campo not in error:
                            self.log_resultado(
                                "Validação - Estrutura Erro", 
                                False, 
                                f"Campo '{campo}' ausente no erro"
                            )
                            return
                    
                    self.log_resultado(
                        "Validação - Tratamento Erro", 
                        True, 
                        f"Código: {error['code']}, Sugestões: {len(error['suggestions'])}"
                    )
                else:
                    self.log_resultado(
                        "Validação - Estrutura Erro", 
                        False, 
                        "Estrutura de erro não padronizada"
                    )
            else:
                self.log_resultado(
                    "Validação - Status Code", 
                    False, 
                    f"Esperado 400, recebido {response.status_code}"
                )
                
        except Exception as e:
            self.log_resultado("Validação - Tratamento Erro", False, str(e))
    
    def _verificar_estrutura_padrao(self, data: Dict[str, Any], endpoint: str) -> bool:
        """Verifica se a resposta segue a estrutura padronizada"""
        campos_obrigatorios = ['success', 'data', 'model', 'timestamp', 'status']
        
        for campo in campos_obrigatorios:
            if campo not in data:
                self.log_resultado(
                    f"{endpoint} - Estrutura", 
                    False, 
                    f"Campo '{campo}' ausente na resposta"
                )
                return False
        
        return True
    
    def executar_todos_testes(self):
        """Executa todos os testes de padronização"""
        print("🧪 INICIANDO TESTES DE PADRONIZAÇÃO DOS ENDPOINTS")
        print("=" * 60)
        print()
        
        # Aguardar servidor estar pronto
        print("⏳ Aguardando servidor estar pronto...")
        time.sleep(2)
        
        # Executar testes
        self.testar_health()
        self.testar_medical()
        self.testar_education()
        self.testar_agriculture()
        self.testar_translate()
        self.testar_multimodal()
        self.testar_validacao_erros()
        
        # Relatório final
        self._gerar_relatorio()
    
    def _gerar_relatorio(self):
        """Gera relatório final dos testes"""
        print("=" * 60)
        print("📊 RELATÓRIO FINAL DOS TESTES")
        print("=" * 60)
        
        total_testes = len(self.resultados)
        testes_passou = sum(1 for r in self.resultados if r['sucesso'])
        testes_falhou = total_testes - testes_passou
        
        taxa_sucesso = (testes_passou / total_testes * 100) if total_testes > 0 else 0
        
        print(f"📈 Total de testes: {total_testes}")
        print(f"✅ Testes que passaram: {testes_passou}")
        print(f"❌ Testes que falharam: {testes_falhou}")
        print(f"📊 Taxa de sucesso: {taxa_sucesso:.1f}%")
        print()
        
        if testes_falhou > 0:
            print("❌ TESTES QUE FALHARAM:")
            for resultado in self.resultados:
                if not resultado['sucesso']:
                    print(f"   • {resultado['teste']}: {resultado['detalhes']}")
            print()
        
        # Status geral
        if taxa_sucesso >= 90:
            status = "🟢 EXCELENTE"
        elif taxa_sucesso >= 70:
            status = "🟡 BOM"
        elif taxa_sucesso >= 50:
            status = "🟠 REGULAR"
        else:
            status = "🔴 CRÍTICO"
        
        print(f"🎯 STATUS GERAL: {status}")
        print()
        
        # Salvar relatório
        relatorio = {
            'timestamp': datetime.now().isoformat(),
            'total_testes': total_testes,
            'testes_passou': testes_passou,
            'testes_falhou': testes_falhou,
            'taxa_sucesso': taxa_sucesso,
            'status': status,
            'resultados': self.resultados
        }
        
        with open('relatorio_padronizacao.json', 'w', encoding='utf-8') as f:
            json.dump(relatorio, f, indent=2, ensure_ascii=False)
        
        print("💾 Relatório salvo em: relatorio_padronizacao.json")
        print()
        
        return taxa_sucesso >= 70

def main():
    """Função principal"""
    print("🚀 Bu Fala - Teste de Padronização de Endpoints")
    print("Verificando compatibilidade Backend ↔ Flutter")
    print()
    
    tester = TestePadronizacao()
    sucesso = tester.executar_todos_testes()
    
    if sucesso:
        print("🎉 PADRONIZAÇÃO CONCLUÍDA COM SUCESSO!")
        print("✅ Backend e Flutter estão compatíveis")
        return 0
    else:
        print("⚠️ PROBLEMAS ENCONTRADOS NA PADRONIZAÇÃO")
        print("❌ Correções necessárias antes da integração")
        return 1

if __name__ == '__main__':
    exit(main())