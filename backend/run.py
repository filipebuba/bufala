#!/usr/bin/env python3
"""
Script principal para iniciar o Bu Fala Backend modularizado
"""

import sys
import os

# Adicionar o diretório backend ao Python path
backend_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, backend_dir)

from app import main

if __name__ == "__main__":
    main()
