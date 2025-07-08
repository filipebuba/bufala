"""
Testes para VoiceGuide AI
"""

import pytest
import numpy as np
from PIL import Image
import torch
from unittest.mock import Mock, patch
import sys
import os

# Adicionar src ao path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'src'))

from voice_guide_core import VoiceGuideAI, AdvancedGemmaFeatures
from audio_processor import AudioProcessor, SpatialAudioProcessor

class TestVoiceGuideAI:
    """Testes para a classe principal VoiceGuideAI"""
    
    @pytest.fixture
    def mock_ai(self):
        """Fixture com AI mockada para testes"""
        with patch('voice_guide_core.Gemma3nForConditionalGeneration'):
            with patch('voice_guide_core.AutoProcessor'):
                with patch('voice_guide_core.pipeline'):
                    ai = VoiceGuideAI(model_size="2b")
                    return ai
    
    def test_initialization(self, mock_ai):
        """Testa inicialização do sistema"""
        assert mock_ai.model
