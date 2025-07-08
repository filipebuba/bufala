class AdvancedGemmaFeatures:
    def __init__(self, voice_guide_ai):
        self.ai = voice_guide_ai
        
    def dynamic_model_switching(self, complexity_level):
        """Usa o recurso mix'n'match do Gemma 3n"""
        if complexity_level == "simple":
            # Usa submodelo 2B para respostas rápidas
            return self.ai.model.generate_with_submodel("2B")
        else:
            # Usa modelo completo 4B para análises complexas
            return self.ai.model.generate_with_submodel("4B")
    
    def offline_multilingual_support(self, language="pt"):
        """Suporte multilíngue offline"""
        language_prompts = {
            "pt": "Descreva o ambiente para navegação em português claro",
            "es": "Describe el entorno para navegación en español claro",
            "en": "Describe the environment for navigation in clear English"
        }
        return language_prompts.get(language, language_prompts["en"])
    
    def emergency_mode(self, image):
        """Modo de emergência com processamento prioritário"""
        emergency_prompt = """
        EMERGENCY MODE: Quickly identify immediate dangers or obstacles 
        that could harm a visually impaired person. Prioritize safety warnings.
        """
        
        return self.ai.analyze_environment(image, emergency_prompt)
