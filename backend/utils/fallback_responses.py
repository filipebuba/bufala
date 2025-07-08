"""
Gerador de respostas fallback para quando o modelo Gemma-3n não está disponível
"""

import random
from datetime import datetime

class FallbackResponseGenerator:
    """Gerador de respostas de fallback por domínio"""
    
    def __init__(self):
        self.responses = {
            'medical': [
                "Para questões de saúde, sempre consulte um profissional médico qualificado.",
                "Mantenha uma dieta equilibrada, pratique exercícios e durma bem.",
                "Em caso de emergência médica, procure atendimento imediato.",
                "Consulte seu médico para orientações personalizadas sobre sua saúde."
            ],
            'education': [
                "O aprendizado é um processo contínuo. Continue estudando e praticando.",
                "Use diferentes métodos de estudo para melhor compreensão.",
                "Faça pausas regulares durante os estudos para melhor retenção.",
                "Procure recursos educacionais confiáveis para aprofundar seus conhecimentos."
            ],
            'agriculture': [
                "Consulte um engenheiro agrônomo para orientações específicas.",
                "Mantenha o solo bem drenado e com nutrientes adequados.",
                "Monitore suas plantas regularmente para detectar problemas cedo.",
                "Use práticas sustentáveis de agricultura para proteger o meio ambiente."
            ],
            'wellness': [
                "Pratique mindfulness e técnicas de respiração para reduzir o estresse.",
                "Mantenha uma rotina de exercícios adequada ao seu nível.",
                "Cuide da sua saúde mental tanto quanto da física.",
                "Estabeleça limites saudáveis entre trabalho e vida pessoal."
            ],
            'translate': [
                "Para traduções precisas, consulte um tradutor profissional.",
                "Use dicionários confiáveis para verificar traduções.",
                "Considere o contexto cultural ao traduzir expressões.",
                "Pratique idiomas regularmente para melhorar sua fluência."
            ],
            'environmental': [
                "Reduza, reutilize e recicle para proteger o meio ambiente.",
                "Use transporte sustentável sempre que possível.",
                "Economize água e energia em suas atividades diárias.",
                "Apoie práticas e empresas ambientalmente responsáveis."
            ],
            'general': [
                "Obrigado por usar o Bu Fala. Estamos aqui para ajudar!",
                "Continue explorando e aprendendo coisas novas.",
                "Se precisar de ajuda específica, consulte um profissional da área.",
                "Mantenha-se curioso e sempre busque conhecimento confiável."
            ]
        }
    
    def generate_response(self, prompt, language='pt-BR', subject='general'):
        """Gerar resposta de fallback baseada no assunto"""
        try:
            # Selecionar categoria de respostas
            category_responses = self.responses.get(subject, self.responses['general'])
            
            # Escolher resposta aleatória
            base_response = random.choice(category_responses)
            
            # Adicionar contexto se o prompt for específico
            if prompt and len(prompt.strip()) > 0:
                if 'como' in prompt.lower():
                    base_response = f"Para sua pergunta sobre '{prompt[:50]}...': {base_response}"
                elif '?' in prompt:
                    base_response = f"Sobre sua pergunta: {base_response}"
            
            # Adicionar timestamp e indicação de fallback
            timestamp = datetime.now().strftime("%H:%M:%S")
            
            return f"{base_response}\n\n[Resposta de emergência às {timestamp} - Gemma-3n temporariamente indisponível]"
            
        except Exception as e:
            # Fallback do fallback
            timestamp = datetime.now().strftime("%H:%M:%S")
            return f"Serviço temporariamente indisponível. Tente novamente em alguns momentos.\n\n[Sistema de emergência às {timestamp}]"
    
    def generate_wellness_recommendations(self, session_type, user_data=None):
        """Gerar recomendações de wellness"""
        recommendations = {
            'stress_relief': [
                "Pratique respiração profunda por 5 minutos",
                "Faça uma caminhada ao ar livre",
                "Ouça música relaxante",
                "Medite por alguns minutos"
            ],
            'motivation': [
                "Defina metas pequenas e alcançáveis",
                "Celebre suas conquistas diárias",
                "Mantenha um diário de gratidão",
                "Conecte-se com pessoas positivas"
            ],
            'energy_boost': [
                "Faça alongamentos leves",
                "Beba mais água",
                "Tome um banho energizante",
                "Escute música animada"
            ],
            'sleep_improvement': [
                "Evite telas 1 hora antes de dormir",
                "Mantenha o quarto escuro e fresco",
                "Pratique relaxamento antes de deitar",
                "Estabeleça uma rotina de sono regular"
            ]
        }
        
        session_recommendations = recommendations.get(session_type, recommendations['motivation'])
        return random.sample(session_recommendations, min(3, len(session_recommendations)))
    
    def calculate_progress_score(self, user_data=None):
        """Calcular score de progresso simulado"""
        if user_data and isinstance(user_data, dict):
            # Simular cálculo baseado em dados do usuário
            base_score = 75
            if user_data.get('mood_rating', 5) > 6:
                base_score += 10
            if user_data.get('exercise_frequency', 0) > 3:
                base_score += 10
            return min(100, base_score)
        
        # Score padrão se não há dados
        return random.randint(70, 85)
    
    def generate_voice_analysis_fallback(self):
        """Gerar análise de voz simulada"""
        return {
            'mood_detected': 'neutro',
            'stress_level': random.choice(['baixo', 'moderado']),
            'energy_level': random.choice(['normal', 'elevado']),
            'confidence': 0.75,
            'analysis': 'Análise baseada em padrões gerais de voz. Para avaliação precisa, use o modelo completo.',
            'status': 'fallback'
        }
    
    def generate_metrics_analysis_fallback(self, metrics):
        """Gerar análise de métricas simulada"""
        return {
            'overall_wellness': 'em progresso',
            'key_insights': [
                'Mantenha a consistência em suas práticas',
                'Pequenos passos levam a grandes mudanças',
                'Celebrate suas conquistas diárias'
            ],
            'improvement_areas': ['Consistência', 'Autocuidado'],
            'status': 'fallback'
        }
