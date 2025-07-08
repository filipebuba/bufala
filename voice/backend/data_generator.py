"""
Gerador de dados sintéticos para treinamento e teste
"""

import numpy as np
from PIL import Image, ImageDraw, ImageFont
import cv2
import os
import json
from typing import List, Dict, Tuple
import random
from loguru import logger

class SyntheticDataGenerator:
    """Gerador de dados sintéticos para treinamento"""
    
    def __init__(self, output_dir: str = "data/synthetic"):
        self.output_dir = output_dir
        os.makedirs(output_dir, exist_ok=True)
        
        # Configurações de geração
        self.image_size = (768, 768)
        self.scenarios = [
            "corridor", "room", "stairs", "elevator", 
            "bathroom", "kitchen", "office", "outdoor"
        ]
        
        # Objetos e obstáculos comuns
        self.objects = {
            "obstacles": ["chair", "table", "box", "person", "pillar"],
            "landmarks": ["door", "window", "sign", "elevator", "stairs"],
            "surfaces": ["wall", "floor", "ceiling", "carpet", "tile"]
        }
        
    def generate_scene_image(self, scenario: str, objects: List[str]) -> Image.Image:
        """
        Gera imagem sintética de uma cena
        
        Args:
            scenario: Tipo de cenário
            objects: Lista de objetos na cena
            
        Returns:
            Imagem PIL gerada
        """
        # Criar imagem base
        img = Image.new('RGB', self.image_size, color='white')
        draw = ImageDraw.Draw(img)
        
        # Desenhar cenário base
        if scenario == "corridor":
            self._draw_corridor(draw)
        elif scenario == "room":
            self._draw_room(draw)
        elif scenario == "stairs":
            self._draw_stairs(draw)
        else:
            self._draw_generic_space(draw)
        
        # Adicionar objetos
        for obj in objects:
            self._draw_object(draw, obj)
        
        return img
    
    def _draw_corridor(self, draw: ImageDraw.Draw):
        """Desenha um corredor"""
        width, height = self.image_size
        
        # Paredes laterais (perspectiva)
        draw.polygon([
            (0, 0), (width//4, height//3), 
            (width//4, 2*height//3), (0, height)
        ], fill='lightgray')
        
        draw.polygon([
            (width, 0), (3*width//4, height//3),
            (3*width//4, 2*height//3), (width, height)
        ], fill='lightgray')
        
        # Chão
        draw.polygon([
            (0, height), (width//4, 2*height//3),
            (3*width//4, 2*height//3), (width, height)
        ], fill='darkgray')
        
        # Teto
        draw.polygon([
            (0, 0), (width//4, height//3),
            (3*width//4, height//3), (width, 0)
        ], fill='white')
    
    def _draw_room(self, draw: ImageDraw.Draw):
        """Desenha uma sala"""
        width, height = self.image_size
        
        # Paredes
        draw.rectangle([0, 0, width, height//3], fill='lightblue')
        draw.rectangle([0, 2*height//3, width, height], fill='brown')
        
    def _draw_stairs(self, draw: ImageDraw.Draw):
        """Desenha escadas"""
        width, height = self.image_size
        
        # Desenhar degraus
        for i in range(10):
            y = height - (i * height//15)
            step_width = width - (i * width//20)
            x_offset = (width - step_width) // 2
            
            draw.rectangle([
                x_offset, y - height//20,
                x_offset + step_width, y
            ], fill='gray', outline='black')
    
    def _draw_generic_space(self, draw: ImageDraw.Draw):
        """Desenha espaço genérico"""
        width, height = self.image_size
        
        # Fundo simples com gradiente
        for y in range(height):
            color_intensity = int(255 * (1 - y / height))
            draw.line([(0, y), (width, y)], fill=(color_intensity, color_intensity, 255))
    
    def _draw_object(self, draw: ImageDraw.Draw, obj_type: str):
        """Desenha objeto específico na cena"""
        width, height = self.image_size
        
        # Posição aleatória
        x = random.randint(width//4, 3*width//4)
        y = random.randint(height//3, 2*height//3)
        
        if obj_type == "chair":
            # Desenhar cadeira simples
            draw.rectangle([x-30, y-40, x+30, y-10], fill='brown')  # Assento
            draw.rectangle([x-25, y-60, x+25, y-40], fill='brown')  # Encosto
            
        elif obj_type == "table":
            # Desenhar mesa
            draw.rectangle([x-50, y-30, x+50, y-20], fill='wood')  # Tampo
            draw.line([(x-40, y-20), (x-40, y+20)], fill='brown', width=5)  # Pernas
            draw.line([(x+40, y-20), (x+40, y+20)], fill='brown', width=5)
            
        elif obj_type == "door":
            # Desenhar porta
            draw.rectangle([x-30, y-80, x+30, y+20], fill='brown', outline='black')
            draw.circle([x+20, y-30], 3, fill='gold')  # Maçaneta
            
        elif obj_type == "person":
            # Desenhar pessoa simples
            draw.circle([x, y-60], 15, fill='peach')  # Cabeça
            draw.rectangle([x-15, y-45, x+15, y], fill='blue')  # Corpo
            draw.line([(x, y), (x-10, y+30)], fill='blue', width=5)  # Perna
            draw.line([(x, y), (x+10, y+30)], fill='blue', width=5)  # Perna
            
        elif obj_type == "box":
            # Desenhar caixa
            draw.rectangle([x-25, y-25, x+25, y+25], fill='cardboard', outline='black')
    
    def generate_navigation_dataset(self, num_samples: int = 1000) -> List[Dict]:
        """
        Gera dataset completo para treinamento de navegação
        
        Args:
            num_samples: Número de amostras a gerar
            
        Returns:
            Lista de amostras com imagem, descrição e instruções
        """
        dataset = []
        
        for i in range(num_samples):
            # Escolher cenário aleatório
            scenario = random.choice(self.scenarios)
            
            # Escolher objetos aleatórios
            num_objects = random.randint(1, 5)
            objects = random.sample(
                self.objects["obstacles"] + self.objects["landmarks"], 
                min(num_objects, len(self.objects["obstacles"] + self.objects["landmarks"]))
            )
            
            # Gerar imagem
            image = self.generate_scene_image(scenario, objects)
            
            # Gerar descrição
            description = self._generate_scene_description(scenario, objects)
            
            # Gerar instruções de navegação
            destination = random.choice(["saída", "banheiro", "elevador", "escada", "sala"])
            instructions = self._generate_navigation_instructions(scenario, objects, destination)
            
            # Salvar imagem
            image_path = os.path.join(self.output_dir, f"scene_{i:04d}.png")
            image.save(image_path)
            
            # Criar entrada do dataset
            sample = {
                "id": i,
                "image_path": image_path,
                "scenario": scenario,
                "objects": objects,
                "description": description,
                "destination": destination,
                "instructions": instructions,
                "safety_level": self._assess_safety_level(objects)
            }
            
            dataset.append(sample)
            
            if i % 100 == 0:
                logger.info(f"Geradas {i}/{num_samples} amostras")
        
        # Salvar metadata do dataset
        metadata_path = os.path.join(self.output_dir, "dataset_metadata.json")
        with open(metadata_path, 'w', encoding='utf-8') as f:
            json.dump(dataset, f, ensure_ascii=False, indent=2)
        
        logger.success(f"Dataset gerado com {num_samples} amostras")
        return dataset
    
    def _generate_scene_description(self, scenario: str, objects: List[str]) -> str:
        """Gera descrição textual da cena"""
        descriptions = {
            "corridor": "Você está em um corredor",
            "room": "Você está em uma sala",
            "stairs": "Há escadas à sua frente",
            "elevator": "Você está próximo ao elevador",
            "bathroom": "Você está próximo ao banheiro",
            "kitchen": "Você está na cozinha",
            "office": "Você está em um escritório",
            "outdoor": "Você está em área externa"
        }
        
        base_desc = descriptions.get(scenario, "Você está em um ambiente interno")
        
        if objects:
            objects_desc = ", ".join(objects)
            return f"{base_desc}. Há {objects_desc} no ambiente."
        
        return f"{base_desc}."
    
    def _generate_navigation_instructions(self, scenario: str, objects: List[str], destination: str) -> str:
        """Gera instruções de navegação"""
        instructions = []
        
        # Instruções baseadas em obstáculos
        if "chair" in objects:
            instructions.append("Cuidado com a cadeira à sua frente")
        if "table" in objects:
            instructions.append("Contorne a mesa pela direita")
        if "person" in objects:
            instructions.append("Há uma pessoa no caminho, aguarde ou peça licença")
        if "box" in objects:
            instructions.append("Há uma caixa no chão, desvie pela esquerda")
        
        # Instruções baseadas no cenário
        if scenario == "corridor":
            instructions.append("Continue em frente pelo corredor")
        elif scenario == "stairs":
            if destination in ["elevador", "térreo"]:
                instructions.append("Desça as escadas com cuidado, segure no corrimão")
            else:
                instructions.append("Suba as escadas devagar, use o corrimão")
        
        # Instrução final para o destino
        destination_instructions = {
            "saída": "A saída está à sua direita no final do corredor",
            "banheiro": "O banheiro está à sua esquerda, procure pela placa em braile",
            "elevador": "O elevador está à frente, ouça o som dos botões",
            "escada": "A escada está à sua direita, sinta o corrimão",
            "sala": "A sala está à sua frente, a porta deve estar aberta"
        }
        
        if destination in destination_instructions:
            instructions.append(destination_instructions[destination])
        
        return ". ".join(instructions) + "."
    
    def _assess_safety_level(self, objects: List[str]) -> str:
        """Avalia nível de segurança da cena"""
        dangerous_objects = ["stairs", "box", "person"]
        danger_count = sum(1 for obj in objects if obj in dangerous_objects)
        
        if danger_count == 0:
            return "safe"
        elif danger_count <= 2:
            return "moderate"
        else:
            return "dangerous"

class AudioDataGenerator:
    """Gerador de dados de áudio sintéticos"""
    
    def __init__(self, output_dir: str = "data/audio"):
        self.output_dir = output_dir
        os.makedirs(output_dir, exist_ok=True)
        
        # Comandos de voz comuns
        self.voice_commands = [
            "parar", "pare", "emergência", "socorro", "ajuda",
            "ir para banheiro", "ir para saída", "ir para elevador",
            "onde estou", "o que há à frente", "repetir instruções",
            "mais devagar", "mais rápido", "volume alto", "volume baixo"
        ]
        
        # Variações de pronúncia
        self.pronunciation_variants = {
            "banheiro": ["banheiro", "toalete", "lavabo"],
            "saída": ["saída", "porta", "exit"],
            "elevador": ["elevador", "ascensor"],
            "escada": ["escada", "escadaria"],
            "ajuda": ["ajuda", "socorro", "help"]
        }
    
    def generate_voice_command_dataset(self, num_samples: int = 500) -> List[Dict]:
        """
        Gera dataset de comandos de voz
        
        Args:
            num_samples: Número de amostras de áudio
            
        Returns:
            Lista de metadados dos comandos gerados
        """
        dataset = []
        
        for i in range(num_samples):
            # Escolher comando aleatório
            base_command = random.choice(self.voice_commands)
            
            # Aplicar variações
            command = self._apply_pronunciation_variants(base_command)
            
            # Gerar características do áudio sintético
            audio_features = self._generate_audio_features()
            
            # Classificar comando
            command_type = self._classify_command(command)
            
            sample = {
                "id": i,
                "command": command,
                "base_command": base_command,
                "command_type": command_type,
                "audio_features": audio_features,
                "priority": self._get_command_priority(command_type)
            }
            
            dataset.append(sample)
        
        # Salvar metadata
        metadata_path = os.path.join(self.output_dir, "voice_commands_metadata.json")
        with open(metadata_path, 'w', encoding='utf-8') as f:
            json.dump(dataset, f, ensure_ascii=False, indent=2)
        
        logger.success(f"Dataset de comandos de voz gerado com {num_samples} amostras")
        return dataset
    
    def _apply_pronunciation_variants(self, command: str) -> str:
        """Aplica variações de pronúncia"""
        for word, variants in self.pronunciation_variants.items():
            if word in command:
                variant = random.choice(variants)
                command = command.replace(word, variant)
        return command
    
    def _generate_audio_features(self) -> Dict:
        """Gera características de áudio sintéticas"""
        return {
            "duration": random.uniform(0.5, 3.0),
            "pitch": random.uniform(80, 300),
            "volume": random.uniform(0.3, 1.0),
            "noise_level": random.uniform(0.0, 0.3),
            "accent": random.choice(["neutral", "regional", "foreign"])
        }
    
    def _classify_command(self, command: str) -> str:
        """Classifica tipo de comando"""
        if any(word in command.lower() for word in ["parar", "pare"]):
            return "stop"
        elif any(word in command.lower() for word in ["emergência", "socorro"]):
            return "emergency"
        elif "ir para" in command.lower():
            return "navigation"
        elif any(word in command.lower() for word in ["ajuda", "help"]):
            return "help"
        elif any(word in command.lower() for word in ["repetir", "repeat"]):
            return "repeat"
        else:
            return "query"
    
    def _get_command_priority(self, command_type: str) -> str:
        """Determina prioridade do comando"""
        priority_map = {
            "emergency": "high",
            "stop": "high", 
            "navigation": "medium",
            "help": "medium",
            "repeat": "low",
            "query": "low"
        }
        return priority_map.get(command_type, "low")

def main():
    """Função principal para geração de dados"""
    logger.info("Iniciando geração de dados sintéticos...")
    
    # Gerar dados de imagem
    image_generator = SyntheticDataGenerator()
    image_dataset = image_generator.generate_navigation_dataset(num_samples=100)
    
    # Gerar dados de áudio
    audio_generator = AudioDataGenerator()
    audio_dataset = audio_generator.generate_voice_command_dataset(num_samples=50)
    
    logger.success("Geração de dados concluída!")
    
    # Estatísticas
    logger.info(f"Imagens geradas: {len(image_dataset)}")
    logger.info(f"Comandos de áudio gerados: {len(audio_dataset)}")
    
    return image_dataset, audio_dataset

if __name__ == "__main__":
    main()
