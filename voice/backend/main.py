"""
VoiceGuide AI - Aplicação Mobile Especializada
Interface otimizada para navegação assistiva
"""

from kivy.app import App
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.button import Button
from kivy.uix.label import Label
from kivy.uix.popup import Popup
from kivy.clock import Clock
from kivy.core.audio import SoundLoader
import threading
import queue

class VoiceGuideWidget(BoxLayout):
    """Widget principal otimizado para acessibilidade"""
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.orientation = 'vertical'
        self.padding = 30  # Padding maior para facilitar toque
        self.spacing = 20  # Espaçamento maior entre elementos
        
        # Inicializar sistema AI
        self.ai_assistant = None
        self.audio_processor = None
        self.is_navigating = False
        
        # Configurar interface acessível
        self.setup_accessible_ui()
        
        # Inicializar sistema em background
        threading.Thread(target=self.initialize_ai_system, daemon=True).start()
    
    def setup_accessible_ui(self):
        """Configura interface otimizada para acessibilidade"""
        
        # Título com fonte grande
        title = Label(
            text="🌟 VoiceGuide AI",
            font_size='32sp',
            size_hint=(1, 0.15),
            color=(1, 1, 1, 1)  # Branco para alto contraste
        )
        self.add_widget(title)
        
        # Botão principal - INICIAR NAVEGAÇÃO
        self.start_button = Button(
            text="▶️ INICIAR NAVEGAÇÃO\n(Toque ou diga 'Iniciar')",
            font_size='20sp',
            size_hint=(1, 0.25),
            background_color=(0, 0.7, 0, 1),  # Verde
            on_press=self.start_navigation
        )
        self.add_widget(self.start_button)
        
        # Botão de emergência - SEMPRE VISÍVEL
        self.emergency_button = Button(
            text="🚨 EMERGÊNCIA\n(Toque ou diga 'Socorro')",
            font_size='18sp',
            size_hint=(1, 0.2),
            background_color=(1, 0, 0, 1),  # Vermelho
            on_press=self.emergency_mode
        )
        self.add_widget(self.emergency_button)
        
        # Status do sistema
        self.status_label = Label(
            text="Inicializando sistema...",
            font_size='16sp',
            size_hint=(1, 0.15),
            color=(0.8, 0.8, 0.8, 1)
        )
        self.add_widget(self.status_label)
        
        # Botões de configuração
        config_layout = BoxLayout(orientation='horizontal', size_hint=(1, 0.15))
        
        self.settings_button = Button(
            text="⚙️ Configurações",
            font_size='14sp',
            on_press=self.show_settings
        )
        config_layout.add_widget(self.settings_button)
        
        self.help_button = Button(
            text="❓ Ajuda",
            font_size='14sp',
            on_press=self.show_help
        )
        config_layout.add_widget(self.help_button)
        
        self.add_widget(config_layout)
