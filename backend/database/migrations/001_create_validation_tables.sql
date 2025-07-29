-- Migração para Sistema de Validação Comunitária - Moransa

-- Criar extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabela de usuários com sistema de pontuação
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    
    -- Sistema de pontuação
    points INTEGER DEFAULT 0 NOT NULL,
    level VARCHAR(20) DEFAULT 'Iniciante' NOT NULL,
    badges JSONB DEFAULT '[]'::jsonb,
    
    -- Estatísticas de atividade
    translations_proposed INTEGER DEFAULT 0 NOT NULL,
    translations_validated INTEGER DEFAULT 0 NOT NULL,
    translations_approved INTEGER DEFAULT 0 NOT NULL,
    
    -- Informações do perfil
    native_language VARCHAR(50),
    location VARCHAR(100),
    bio TEXT,
    
    -- Configurações de preferência
    preferred_categories JSONB DEFAULT '[]'::jsonb,
    notification_settings JSONB DEFAULT '{}'::jsonb,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    last_active TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Tabela de frases em português geradas pelo Gemma-3n
CREATE TABLE IF NOT EXISTS phrases_portuguese (
    id SERIAL PRIMARY KEY,
    text TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    difficulty VARCHAR(20) DEFAULT 'básico' NOT NULL,
    
    -- Contexto e metadados
    context TEXT,
    tags JSONB DEFAULT '[]'::jsonb,
    usage_scenario VARCHAR(100),
    
    -- Informações de geração
    generated_by_ai BOOLEAN DEFAULT TRUE NOT NULL,
    ai_model_version VARCHAR(50) DEFAULT 'gemma-3n',
    generation_prompt TEXT,
    
    -- Estatísticas de uso
    translation_attempts INTEGER DEFAULT 0 NOT NULL,
    successful_translations INTEGER DEFAULT 0 NOT NULL,
    avg_validation_score DECIMAL(3,2) DEFAULT 0.0 NOT NULL,
    
    -- Metadados de criação
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    priority_level INTEGER DEFAULT 1 NOT NULL
);

-- Tabela de traduções propostas pela comunidade
CREATE TABLE IF NOT EXISTS proposed_translations (
    id SERIAL PRIMARY KEY,
    phrase_id INTEGER NOT NULL REFERENCES phrases_portuguese(id) ON DELETE CASCADE,
    language VARCHAR(50) NOT NULL,
    translation TEXT NOT NULL,
    
    -- Recursos multimídia
    audio_url VARCHAR(255),
    audio_duration DECIMAL(5,2),
    phonetic_transcription VARCHAR(255),
    
    -- Contexto e notas
    context_notes TEXT,
    usage_examples JSONB DEFAULT '[]'::jsonb,
    regional_variants JSONB DEFAULT '[]'::jsonb,
    
    -- Informações do proponente
    proposed_by INTEGER NOT NULL REFERENCES users(id),
    proposer_confidence INTEGER DEFAULT 5 NOT NULL CHECK (proposer_confidence >= 1 AND proposer_confidence <= 10),
    source_reference VARCHAR(255),
    
    -- Status de validação
    validation_status VARCHAR(20) DEFAULT 'pending' NOT NULL CHECK (validation_status IN ('pending', 'approved', 'rejected')),
    validation_score DECIMAL(3,2) DEFAULT 0.0 NOT NULL,
    total_votes INTEGER DEFAULT 0 NOT NULL,
    approve_votes INTEGER DEFAULT 0 NOT NULL,
    reject_votes INTEGER DEFAULT 0 NOT NULL,
    improve_votes INTEGER DEFAULT 0 NOT NULL,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    validated_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraint para evitar traduções duplicadas
    UNIQUE(phrase_id, language, proposed_by)
);

-- Tabela de traduções validadas e aprovadas
CREATE TABLE IF NOT EXISTS validated_translations (
    id SERIAL PRIMARY KEY,
    phrase_id INTEGER NOT NULL REFERENCES phrases_portuguese(id) ON DELETE CASCADE,
    language VARCHAR(50) NOT NULL,
    translation TEXT NOT NULL,
    
    -- Recursos multimídia validados
    audio_url VARCHAR(255),
    audio_duration DECIMAL(5,2),
    phonetic_transcription VARCHAR(255),
    
    -- Contexto validado
    context_notes TEXT,
    usage_examples JSONB DEFAULT '[]'::jsonb,
    regional_variants JSONB DEFAULT '[]'::jsonb,
    
    -- Informações de validação
    original_proposer INTEGER NOT NULL REFERENCES users(id),
    validation_score DECIMAL(3,2) NOT NULL,
    total_votes INTEGER NOT NULL,
    consensus_level VARCHAR(20) DEFAULT 'high' NOT NULL CHECK (consensus_level IN ('high', 'medium', 'low')),
    
    -- Qualidade e confiabilidade
    quality_score DECIMAL(3,2) DEFAULT 0.0 NOT NULL,
    reliability_index DECIMAL(3,2) DEFAULT 0.0 NOT NULL,
    community_rating DECIMAL(3,2) DEFAULT 0.0 NOT NULL,
    
    -- Metadados de uso
    usage_count INTEGER DEFAULT 0 NOT NULL,
    last_used TIMESTAMP WITH TIME ZONE,
    effectiveness_rating DECIMAL(3,2) DEFAULT 0.0 NOT NULL,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    validated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    is_featured BOOLEAN DEFAULT FALSE NOT NULL,
    
    -- Constraint para evitar traduções validadas duplicadas
    UNIQUE(phrase_id, language)
);

-- Tabela de votos de validação
CREATE TABLE IF NOT EXISTS validation_votes (
    id SERIAL PRIMARY KEY,
    translation_id INTEGER NOT NULL REFERENCES proposed_translations(id) ON DELETE CASCADE,
    voted_by INTEGER NOT NULL REFERENCES users(id),
    
    -- Tipo de voto
    vote VARCHAR(20) NOT NULL CHECK (vote IN ('approve', 'reject', 'improve')),
    confidence INTEGER DEFAULT 5 NOT NULL CHECK (confidence >= 1 AND confidence <= 10),
    
    -- Feedback detalhado
    feedback TEXT,
    improvement_suggestion TEXT,
    specific_issues JSONB DEFAULT '[]'::jsonb,
    
    -- Categorias de avaliação
    accuracy_score INTEGER DEFAULT 5 NOT NULL CHECK (accuracy_score >= 1 AND accuracy_score <= 10),
    cultural_appropriateness INTEGER DEFAULT 5 NOT NULL CHECK (cultural_appropriateness >= 1 AND cultural_appropriateness <= 10),
    pronunciation_quality INTEGER DEFAULT 5 NOT NULL CHECK (pronunciation_quality >= 1 AND pronunciation_quality <= 10),
    context_relevance INTEGER DEFAULT 5 NOT NULL CHECK (context_relevance >= 1 AND context_relevance <= 10),
    
    -- Metadados do voto
    vote_weight DECIMAL(3,2) DEFAULT 1.0 NOT NULL,
    is_expert_vote BOOLEAN DEFAULT FALSE NOT NULL,
    voting_time_seconds INTEGER,
    
    -- Informações contextuais
    voter_native_language VARCHAR(50),
    voter_location VARCHAR(100),
    device_type VARCHAR(50),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    -- Constraint para evitar votos duplicados
    UNIQUE(translation_id, voted_by)
);

-- Tabela de desafios especiais da comunidade
CREATE TABLE IF NOT EXISTS community_challenges (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    
    -- Configurações do desafio
    challenge_type VARCHAR(50) NOT NULL,
    target_language VARCHAR(50),
    target_category VARCHAR(50),
    difficulty_level VARCHAR(20) NOT NULL,
    
    -- Recompensas
    points_multiplier DECIMAL(3,2) DEFAULT 1.0 NOT NULL,
    special_badges JSONB DEFAULT '[]'::jsonb,
    winner_rewards JSONB DEFAULT '{}'::jsonb,
    
    -- Métricas de participação
    participants_count INTEGER DEFAULT 0 NOT NULL,
    translations_submitted INTEGER DEFAULT 0 NOT NULL,
    validations_completed INTEGER DEFAULT 0 NOT NULL,
    
    -- Período do desafio
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    is_featured BOOLEAN DEFAULT FALSE NOT NULL,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Tabela de métricas de qualidade
CREATE TABLE IF NOT EXISTS translation_quality_metrics (
    id SERIAL PRIMARY KEY,
    translation_id INTEGER NOT NULL REFERENCES validated_translations(id) ON DELETE CASCADE,
    
    -- Métricas automáticas
    character_length_ratio DECIMAL(5,2),
    word_count_ratio DECIMAL(5,2),
    complexity_score DECIMAL(3,2),
    
    -- Métricas da comunidade
    community_satisfaction DECIMAL(3,2) DEFAULT 0.0 NOT NULL,
    usage_effectiveness DECIMAL(3,2) DEFAULT 0.0 NOT NULL,
    cultural_accuracy DECIMAL(3,2) DEFAULT 0.0 NOT NULL,
    
    -- Métricas de performance
    validation_speed DECIMAL(8,2),
    consensus_speed DECIMAL(8,2),
    revision_count INTEGER DEFAULT 0 NOT NULL,
    
    -- Timestamps
    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_users_points ON users(points DESC);
CREATE INDEX IF NOT EXISTS idx_users_last_active ON users(last_active DESC);
CREATE INDEX IF NOT EXISTS idx_phrases_category ON phrases_portuguese(category);
CREATE INDEX IF NOT EXISTS idx_phrases_difficulty ON phrases_portuguese(difficulty);
CREATE INDEX IF NOT EXISTS idx_phrases_active ON phrases_portuguese(is_active) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_proposed_translations_status ON proposed_translations(validation_status);
CREATE INDEX IF NOT EXISTS idx_proposed_translations_language ON proposed_translations(language);
CREATE INDEX IF NOT EXISTS idx_proposed_translations_phrase ON proposed_translations(phrase_id);
CREATE INDEX IF NOT EXISTS idx_proposed_translations_proposer ON proposed_translations(proposed_by);
CREATE INDEX IF NOT EXISTS idx_validated_translations_language ON validated_translations(language);
CREATE INDEX IF NOT EXISTS idx_validated_translations_phrase ON validated_translations(phrase_id);
CREATE INDEX IF NOT EXISTS idx_validated_translations_active ON validated_translations(is_active) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_validation_votes_translation ON validation_votes(translation_id);
CREATE INDEX IF NOT EXISTS idx_validation_votes_voter ON validation_votes(voted_by);
CREATE INDEX IF NOT EXISTS idx_validation_votes_vote_type ON validation_votes(vote);

-- Índices compostos para consultas frequentes
CREATE INDEX IF NOT EXISTS idx_proposed_translations_status_language ON proposed_translations(validation_status, language);
CREATE INDEX IF NOT EXISTS idx_validated_translations_language_category ON validated_translations(language, phrase_id);
CREATE INDEX IF NOT EXISTS idx_phrases_category_difficulty ON phrases_portuguese(category, difficulty);
CREATE INDEX IF NOT EXISTS idx_validation_votes_translation_voter ON validation_votes(translation_id, voted_by);
CREATE INDEX IF NOT EXISTS idx_users_points_active ON users(points DESC, last_active DESC);

-- Triggers para atualizar timestamps automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_phrases_portuguese_updated_at BEFORE UPDATE ON phrases_portuguese
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_proposed_translations_updated_at BEFORE UPDATE ON proposed_translations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_validated_translations_updated_at BEFORE UPDATE ON validated_translations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_validation_votes_updated_at BEFORE UPDATE ON validation_votes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_community_challenges_updated_at BEFORE UPDATE ON community_challenges
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_translation_quality_metrics_updated_at BEFORE UPDATE ON translation_quality_metrics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Função para atualizar estatísticas do usuário
CREATE OR REPLACE FUNCTION update_user_stats()
RETURNS TRIGGER AS $$
BEGIN
    -- Atualizar estatísticas quando uma tradução é proposta
    IF TG_TABLE_NAME = 'proposed_translations' AND TG_OP = 'INSERT' THEN
        UPDATE users 
        SET translations_proposed = translations_proposed + 1,
            last_active = NOW()
        WHERE id = NEW.proposed_by;
    END IF;
    
    -- Atualizar estatísticas quando um voto é registrado
    IF TG_TABLE_NAME = 'validation_votes' AND TG_OP = 'INSERT' THEN
        UPDATE users 
        SET translations_validated = translations_validated + 1,
            last_active = NOW()
        WHERE id = NEW.voted_by;
    END IF;
    
    -- Atualizar estatísticas quando uma tradução é validada
    IF TG_TABLE_NAME = 'validated_translations' AND TG_OP = 'INSERT' THEN
        UPDATE users 
        SET translations_approved = translations_approved + 1
        WHERE id = NEW.original_proposer;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_stats_on_proposal AFTER INSERT ON proposed_translations
    FOR EACH ROW EXECUTE FUNCTION update_user_stats();

CREATE TRIGGER update_user_stats_on_vote AFTER INSERT ON validation_votes
    FOR EACH ROW EXECUTE FUNCTION update_user_stats();

CREATE TRIGGER update_user_stats_on_validation AFTER INSERT ON validated_translations
    FOR EACH ROW EXECUTE FUNCTION update_user_stats();

-- Função para atualizar contadores de votos
CREATE OR REPLACE FUNCTION update_vote_counters()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE proposed_translations 
        SET 
            total_votes = total_votes + 1,
            approve_votes = approve_votes + CASE WHEN NEW.vote = 'approve' THEN 1 ELSE 0 END,
            reject_votes = reject_votes + CASE WHEN NEW.vote = 'reject' THEN 1 ELSE 0 END,
            improve_votes = improve_votes + CASE WHEN NEW.vote = 'improve' THEN 1 ELSE 0 END,
            validation_score = (
                SELECT 
                    CASE 
                        WHEN COUNT(*) = 0 THEN 0
                        ELSE ROUND(
                            (COUNT(*) FILTER (WHERE vote = 'approve')::DECIMAL / COUNT(*)) * 100, 2
                        )
                    END
                FROM validation_votes 
                WHERE translation_id = NEW.translation_id
            )
        WHERE id = NEW.translation_id;
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_vote_counters_trigger AFTER INSERT ON validation_votes
    FOR EACH ROW EXECUTE FUNCTION update_vote_counters();

-- Inserir dados iniciais de exemplo
INSERT INTO users (username, email, password_hash, native_language, location) VALUES
('admin', 'admin@moransa.gw', '$2b$12$example_hash', 'crioulo', 'Bissau'),
('maria_silva', 'maria@example.gw', '$2b$12$example_hash', 'crioulo', 'Gabú'),
('joão_santos', 'joao@example.gw', '$2b$12$example_hash', 'balanta', 'Bafatá'),
('fatima_djalo', 'fatima@example.gw', '$2b$12$example_hash', 'fula', 'Cacheu')
ON CONFLICT (username) DO NOTHING;

-- Inserir frases de exemplo
INSERT INTO phrases_portuguese (text, category, difficulty, context, tags, created_by) VALUES
('Bom dia a todos.', 'educação', 'básico', 'Saudação para iniciar aula', '["saudação", "aula", "comunidade"]', 1),
('Onde dói?', 'saúde', 'básico', 'Identificar local da dor', '["dor", "diagnóstico", "emergência"]', 1),
('A terra está seca.', 'agricultura', 'básico', 'Observar condição do solo', '["solo", "seca", "observação"]', 1),
('Prestem atenção, por favor.', 'educação', 'básico', 'Chamar atenção dos alunos', '["instrução", "atenção", "aula"]', 1),
('Respire fundo.', 'saúde', 'básico', 'Acalmar paciente', '["respiração", "calma", "instrução"]', 1)
ON CONFLICT DO NOTHING;

-- Comentários finais
COMMENT ON TABLE users IS 'Usuários do sistema com pontuação gamificada';
COMMENT ON TABLE phrases_portuguese IS 'Frases em português geradas pelo Gemma-3n para tradução';
COMMENT ON TABLE proposed_translations IS 'Traduções propostas pela comunidade aguardando validação';
COMMENT ON TABLE validated_translations IS 'Traduções validadas e aprovadas pela comunidade';
COMMENT ON TABLE validation_votes IS 'Votos de validação da comunidade no sistema gamificado';
COMMENT ON TABLE community_challenges IS 'Desafios especiais e competições de tradução';
COMMENT ON TABLE translation_quality_metrics IS 'Métricas de qualidade para análise e melhoria contínua';

-- Verificar se as tabelas foram criadas com sucesso
SELECT 
    schemaname,
    tablename,
    tableowner
FROM pg_tables 
WHERE tablename IN (
    'users', 
    'phrases_portuguese', 
    'proposed_translations', 
    'validated_translations', 
    'validation_votes', 
    'community_challenges', 
    'translation_quality_metrics'
)
ORDER BY tablename;