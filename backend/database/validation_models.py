#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Modelos de Banco de Dados para Sistema de Validação Comunitária - Moransa


Tabelas implementadas:
- users: Usuários do sistema com pontuação
- phrases_portuguese: Frases em português geradas pelo Gemma-3n
- proposed_translations: Traduções propostas pela comunidade
- validated_translations: Traduções validadas e aprovadas
- validation_votes: Votos de validação da comunidade
"""

from sqlalchemy import Column, Integer, String, Text, DateTime, Boolean, Float, ForeignKey, JSON
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from datetime import datetime

Base = declarative_base()

class User(Base):
    """
    Tabela de usuários com sistema de pontuação gamificado.
    """
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True, nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    
    # Sistema de pontuação
    points = Column(Integer, default=0, nullable=False)
    level = Column(String(20), default="Iniciante", nullable=False)
    badges = Column(JSON, default=list)  # Lista de badges conquistadas
    
    # Estatísticas de atividade
    translations_proposed = Column(Integer, default=0, nullable=False)
    translations_validated = Column(Integer, default=0, nullable=False)
    translations_approved = Column(Integer, default=0, nullable=False)
    
    # Informações do perfil
    native_language = Column(String(50), nullable=True)
    location = Column(String(100), nullable=True)
    bio = Column(Text, nullable=True)
    
    # Configurações de preferência
    preferred_categories = Column(JSON, default=list)  # Categorias preferidas
    notification_settings = Column(JSON, default=dict)  # Configurações de notificação
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    last_active = Column(DateTime, default=datetime.utcnow, nullable=False)
    
    # Relacionamentos
    proposed_translations = relationship("ProposedTranslation", back_populates="proposer")
    validation_votes = relationship("ValidationVote", back_populates="voter")
    validated_translations = relationship("ValidatedTranslation", back_populates="original_proposer_user")
    created_phrases = relationship("PhrasesPortuguese", back_populates="creator")

class PhrasesPortuguese(Base):
    """
    Tabela de frases em português geradas pelo Gemma-3n.
    Estas são as "sementes" para os desafios de tradução.
    """
    __tablename__ = "phrases_portuguese"
    
    id = Column(Integer, primary_key=True, index=True)
    text = Column(Text, nullable=False, index=True)
    category = Column(String(50), nullable=False, index=True)  # educação, saúde, agricultura
    difficulty = Column(String(20), default="básico", nullable=False)  # básico, intermediário, avançado
    
    # Contexto e metadados
    context = Column(Text, nullable=True)  # Contexto de uso da frase
    tags = Column(JSON, default=list)  # Tags para categorização
    usage_scenario = Column(String(100), nullable=True)  # Cenário de uso específico
    
    # Informações de geração
    generated_by_ai = Column(Boolean, default=True, nullable=False)
    ai_model_version = Column(String(50), default="gemma-3n", nullable=True)
    generation_prompt = Column(Text, nullable=True)  # Prompt usado para gerar
    
    # Estatísticas de uso
    translation_attempts = Column(Integer, default=0, nullable=False)
    successful_translations = Column(Integer, default=0, nullable=False)
    avg_validation_score = Column(Float, default=0.0, nullable=False)
    
    # Metadados de criação
    created_by = Column(Integer, ForeignKey("users.id"), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Status
    is_active = Column(Boolean, default=True, nullable=False)
    priority_level = Column(Integer, default=1, nullable=False)  # 1=baixa, 5=alta
    
    # Relacionamentos
    creator = relationship("User", back_populates="created_phrases")
    proposed_translations = relationship("ProposedTranslation", back_populates="phrase")
    validated_translations = relationship("ValidatedTranslation", back_populates="phrase")

class ProposedTranslation(Base):
    """
    Tabela de traduções propostas pela comunidade.
    Estas ficam na "fila de validação" até serem aprovadas.
    """
    __tablename__ = "proposed_translations"
    
    id = Column(Integer, primary_key=True, index=True)
    phrase_id = Column(Integer, ForeignKey("phrases_portuguese.id"), nullable=False, index=True)
    language = Column(String(50), nullable=False, index=True)  # crioulo, balanta, fula, etc.
    translation = Column(Text, nullable=False)
    
    # Recursos multimídia
    audio_url = Column(String(255), nullable=True)  # URL do áudio da pronúncia
    audio_duration = Column(Float, nullable=True)  # Duração em segundos
    phonetic_transcription = Column(String(255), nullable=True)  # Transcrição fonética
    
    # Contexto e notas
    context_notes = Column(Text, nullable=True)  # Notas sobre contexto cultural
    usage_examples = Column(JSON, default=list)  # Exemplos de uso
    regional_variants = Column(JSON, default=list)  # Variantes regionais
    
    # Informações do proponente
    proposed_by = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    proposer_confidence = Column(Integer, default=5, nullable=False)  # 1-10
    source_reference = Column(String(255), nullable=True)  # Referência da fonte
    
    # Status de validação
    validation_status = Column(String(20), default="pending", nullable=False)  # pending, approved, rejected
    validation_score = Column(Float, default=0.0, nullable=False)  # Score de validação
    total_votes = Column(Integer, default=0, nullable=False)
    approve_votes = Column(Integer, default=0, nullable=False)
    reject_votes = Column(Integer, default=0, nullable=False)
    improve_votes = Column(Integer, default=0, nullable=False)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    validated_at = Column(DateTime, nullable=True)
    
    # Relacionamentos
    phrase = relationship("PhrasesPortuguese", back_populates="proposed_translations")
    proposer = relationship("User", back_populates="proposed_translations")
    validation_votes = relationship("ValidationVote", back_populates="translation")

class ValidatedTranslation(Base):
    """
    Tabela de traduções validadas e aprovadas pela comunidade.
    Este é o "corpus validado" usado pelo Modo Socorrista.
    """
    __tablename__ = "validated_translations"
    
    id = Column(Integer, primary_key=True, index=True)
    phrase_id = Column(Integer, ForeignKey("phrases_portuguese.id"), nullable=False, index=True)
    language = Column(String(50), nullable=False, index=True)
    translation = Column(Text, nullable=False)
    
    # Recursos multimídia validados
    audio_url = Column(String(255), nullable=True)
    audio_duration = Column(Float, nullable=True)
    phonetic_transcription = Column(String(255), nullable=True)
    
    # Contexto validado
    context_notes = Column(Text, nullable=True)
    usage_examples = Column(JSON, default=list)
    regional_variants = Column(JSON, default=list)
    
    # Informações de validação
    original_proposer = Column(Integer, ForeignKey("users.id"), nullable=False)
    validation_score = Column(Float, nullable=False)  # Score final de validação
    total_votes = Column(Integer, nullable=False)  # Total de votos recebidos
    consensus_level = Column(String(20), default="high", nullable=False)  # high, medium, low
    
    # Qualidade e confiabilidade
    quality_score = Column(Float, default=0.0, nullable=False)  # Score de qualidade
    reliability_index = Column(Float, default=0.0, nullable=False)  # Índice de confiabilidade
    community_rating = Column(Float, default=0.0, nullable=False)  # Avaliação da comunidade
    
    # Metadados de uso
    usage_count = Column(Integer, default=0, nullable=False)  # Quantas vezes foi usada
    last_used = Column(DateTime, nullable=True)  # Última vez que foi usada
    effectiveness_rating = Column(Float, default=0.0, nullable=False)  # Efetividade no uso
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    validated_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    
    # Status
    is_active = Column(Boolean, default=True, nullable=False)
    is_featured = Column(Boolean, default=False, nullable=False)  # Tradução em destaque
    
    # Relacionamentos
    phrase = relationship("PhrasesPortuguese", back_populates="validated_translations")
    original_proposer_user = relationship("User", back_populates="validated_translations")

class ValidationVote(Base):
    """
    Tabela de votos de validação da comunidade.
    Implementa o "Jogo da Validação" gamificado.
    """
    __tablename__ = "validation_votes"
    
    id = Column(Integer, primary_key=True, index=True)
    translation_id = Column(Integer, ForeignKey("proposed_translations.id"), nullable=False, index=True)
    voted_by = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    
    # Tipo de voto
    vote = Column(String(20), nullable=False)  # approve, reject, improve
    confidence = Column(Integer, default=5, nullable=False)  # 1-10
    
    # Feedback detalhado
    feedback = Column(Text, nullable=True)  # Feedback textual
    improvement_suggestion = Column(Text, nullable=True)  # Sugestão de melhoria
    specific_issues = Column(JSON, default=list)  # Problemas específicos identificados
    
    # Categorias de avaliação
    accuracy_score = Column(Integer, default=5, nullable=False)  # 1-10
    cultural_appropriateness = Column(Integer, default=5, nullable=False)  # 1-10
    pronunciation_quality = Column(Integer, default=5, nullable=False)  # 1-10 (se houver áudio)
    context_relevance = Column(Integer, default=5, nullable=False)  # 1-10
    
    # Metadados do voto
    vote_weight = Column(Float, default=1.0, nullable=False)  # Peso do voto baseado na reputação
    is_expert_vote = Column(Boolean, default=False, nullable=False)  # Voto de especialista
    voting_time_seconds = Column(Integer, nullable=True)  # Tempo gasto votando
    
    # Informações contextuais
    voter_native_language = Column(String(50), nullable=True)
    voter_location = Column(String(100), nullable=True)
    device_type = Column(String(50), nullable=True)  # mobile, desktop, tablet
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Relacionamentos
    translation = relationship("ProposedTranslation", back_populates="validation_votes")
    voter = relationship("User", back_populates="validation_votes")

class CommunityChallenge(Base):
    """
    Tabela de desafios especiais da comunidade.
    Implementa eventos e competições de tradução.
    """
    __tablename__ = "community_challenges"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=False)
    
    # Configurações do desafio
    challenge_type = Column(String(50), nullable=False)  # translation_sprint, quality_focus, etc.
    target_language = Column(String(50), nullable=True)
    target_category = Column(String(50), nullable=True)
    difficulty_level = Column(String(20), nullable=False)
    
    # Recompensas
    points_multiplier = Column(Float, default=1.0, nullable=False)
    special_badges = Column(JSON, default=list)
    winner_rewards = Column(JSON, default=dict)
    
    # Métricas de participação
    participants_count = Column(Integer, default=0, nullable=False)
    translations_submitted = Column(Integer, default=0, nullable=False)
    validations_completed = Column(Integer, default=0, nullable=False)
    
    # Período do desafio
    start_date = Column(DateTime, nullable=False)
    end_date = Column(DateTime, nullable=False)
    
    # Status
    is_active = Column(Boolean, default=True, nullable=False)
    is_featured = Column(Boolean, default=False, nullable=False)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

class TranslationQualityMetric(Base):
    """
    Tabela de métricas de qualidade das traduções.
    Usado para análise e melhoria contínua do sistema.
    """
    __tablename__ = "translation_quality_metrics"
    
    id = Column(Integer, primary_key=True, index=True)
    translation_id = Column(Integer, ForeignKey("validated_translations.id"), nullable=False)
    
    # Métricas automáticas
    character_length_ratio = Column(Float, nullable=True)  # Razão de comprimento
    word_count_ratio = Column(Float, nullable=True)  # Razão de palavras
    complexity_score = Column(Float, nullable=True)  # Score de complexidade
    
    # Métricas da comunidade
    community_satisfaction = Column(Float, default=0.0, nullable=False)  # 0-10
    usage_effectiveness = Column(Float, default=0.0, nullable=False)  # 0-10
    cultural_accuracy = Column(Float, default=0.0, nullable=False)  # 0-10
    
    # Métricas de performance
    validation_speed = Column(Float, nullable=True)  # Tempo médio para validação
    consensus_speed = Column(Float, nullable=True)  # Tempo para atingir consenso
    revision_count = Column(Integer, default=0, nullable=False)  # Número de revisões
    
    # Timestamps
    calculated_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

# Índices adicionais para performance
from sqlalchemy import Index

# Índices compostos para consultas frequentes
Index('idx_proposed_translations_status_language', ProposedTranslation.validation_status, ProposedTranslation.language)
Index('idx_validated_translations_language_category', ValidatedTranslation.language, ValidatedTranslation.phrase_id)
Index('idx_phrases_category_difficulty', PhrasesPortuguese.category, PhrasesPortuguese.difficulty)
Index('idx_validation_votes_translation_voter', ValidationVote.translation_id, ValidationVote.voted_by)
Index('idx_users_points_active', User.points, User.last_active)