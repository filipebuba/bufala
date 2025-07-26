-- smartWaiter Database Initialization
-- Sistema de Self-Ordering para Pequenos Restaurantes
-- Criado em: 2025-01-15

-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "btree_gin";

-- Schema principal
CREATE SCHEMA IF NOT EXISTS smartwaiter;
SET search_path TO smartwaiter, public;

-- =============================================
-- TABELAS DE CONFIGURAÇÃO E USUÁRIOS
-- =============================================

-- Restaurantes
CREATE TABLE restaurants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(255),
    logo_url TEXT,
    timezone VARCHAR(50) DEFAULT 'Africa/Bissau',
    currency VARCHAR(3) DEFAULT 'XOF',
    language VARCHAR(5) DEFAULT 'pt-GW',
    settings JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Usuários do sistema (funcionários)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'manager', 'waiter', 'kitchen', 'cashier')),
    permissions JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- TABELAS DE CARDÁPIO E PRODUTOS
-- =============================================

-- Categorias de produtos
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Produtos/Pratos
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2), -- Custo para cálculo de margem
    image_url TEXT,
    preparation_time INTEGER DEFAULT 15, -- em minutos
    calories INTEGER,
    allergens TEXT[], -- Array de alérgenos
    ingredients TEXT[],
    is_available BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    stock_quantity INTEGER,
    min_stock_alert INTEGER DEFAULT 5,
    sort_order INTEGER DEFAULT 0,
    metadata JSONB DEFAULT '{}', -- Dados extras (vegano, sem glúten, etc.)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Variações de produtos (tamanhos, sabores, etc.)
CREATE TABLE product_variants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    price_modifier DECIMAL(10,2) DEFAULT 0, -- Valor a adicionar/subtrair
    is_default BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- TABELAS DE MESAS E PEDIDOS
-- =============================================

-- Mesas do restaurante
CREATE TABLE tables (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
    number VARCHAR(10) NOT NULL,
    name VARCHAR(255),
    capacity INTEGER NOT NULL DEFAULT 4,
    qr_code TEXT UNIQUE NOT NULL,
    location VARCHAR(100), -- Área do restaurante
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(restaurant_id, number)
);

-- Sessões de mesa (quando clientes se sentam)
CREATE TABLE table_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_id UUID REFERENCES tables(id) ON DELETE CASCADE,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    customer_count INTEGER DEFAULT 1,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ended_at TIMESTAMP WITH TIME ZONE,
    total_amount DECIMAL(10,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'ordering', 'eating', 'paying', 'closed')),
    metadata JSONB DEFAULT '{}'
);

-- Pedidos
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
    table_session_id UUID REFERENCES table_sessions(id) ON DELETE CASCADE,
    order_number VARCHAR(20) UNIQUE NOT NULL,
    customer_name VARCHAR(255),
    customer_phone VARCHAR(20),
    subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'preparing', 'ready', 'served', 'cancelled')),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'partial', 'refunded')),
    payment_method VARCHAR(20), -- pix, card, cash, split
    special_instructions TEXT,
    estimated_ready_time TIMESTAMP WITH TIME ZONE,
    confirmed_at TIMESTAMP WITH TIME ZONE,
    ready_at TIMESTAMP WITH TIME ZONE,
    served_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Itens do pedido
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE RESTRICT,
    variant_id UUID REFERENCES product_variants(id) ON DELETE SET NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    special_instructions TEXT,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'preparing', 'ready', 'served', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- TABELAS DE ANALYTICS E ML
-- =============================================

-- Histórico de vendas para ML
CREATE TABLE sales_analytics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    hour INTEGER NOT NULL CHECK (hour >= 0 AND hour <= 23),
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    quantity_sold INTEGER NOT NULL DEFAULT 0,
    revenue DECIMAL(10,2) NOT NULL DEFAULT 0,
    weather_condition VARCHAR(50),
    temperature DECIMAL(5,2),
    is_holiday BOOLEAN DEFAULT false,
    special_event VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(restaurant_id, date, hour, product_id)
);

-- Previsões de demanda
CREATE TABLE demand_predictions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    prediction_date DATE NOT NULL,
    predicted_quantity INTEGER NOT NULL,
    confidence_score DECIMAL(5,4), -- 0.0 a 1.0
    model_version VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(restaurant_id, product_id, prediction_date)
);

-- Recomendações de produtos
CREATE TABLE product_recommendations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
    base_product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    recommended_product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    confidence_score DECIMAL(5,4) NOT NULL,
    recommendation_type VARCHAR(50) NOT NULL, -- 'upsell', 'cross_sell', 'substitute'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(restaurant_id, base_product_id, recommended_product_id)
);

-- =============================================
-- TABELAS DE SISTEMA
-- =============================================

-- Logs de atividades
CREATE TABLE activity_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id UUID,
    details JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Configurações do sistema
CREATE TABLE system_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
    key VARCHAR(100) NOT NULL,
    value JSONB NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(restaurant_id, key)
);

-- =============================================
-- ÍNDICES PARA PERFORMANCE
-- =============================================

-- Índices para consultas frequentes
CREATE INDEX idx_products_restaurant_category ON products(restaurant_id, category_id);
CREATE INDEX idx_products_available ON products(restaurant_id, is_available);
CREATE INDEX idx_orders_restaurant_status ON orders(restaurant_id, status);
CREATE INDEX idx_orders_table_session ON orders(table_session_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_sales_analytics_date ON sales_analytics(restaurant_id, date);
CREATE INDEX idx_sales_analytics_product ON sales_analytics(product_id, date);
CREATE INDEX idx_table_sessions_active ON table_sessions(table_id, status) WHERE status = 'active';
CREATE INDEX idx_activity_logs_restaurant_date ON activity_logs(restaurant_id, created_at);

-- Índices para busca de texto
CREATE INDEX idx_products_name_search ON products USING gin(name gin_trgm_ops);
CREATE INDEX idx_categories_name_search ON categories USING gin(name gin_trgm_ops);

-- =============================================
-- TRIGGERS PARA AUDITORIA
-- =============================================

-- Função para atualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para updated_at
CREATE TRIGGER update_restaurants_updated_at BEFORE UPDATE ON restaurants FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tables_updated_at BEFORE UPDATE ON tables FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_order_items_updated_at BEFORE UPDATE ON order_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_system_settings_updated_at BEFORE UPDATE ON system_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- DADOS INICIAIS
-- =============================================

-- Restaurante de exemplo
INSERT INTO restaurants (name, slug, description, address, phone, email) VALUES 
('Restaurante Moransa', 'moransa', 'Restaurante tradicional da Guiné-Bissau com pratos locais e internacionais', 'Bissau, Guiné-Bissau', '+245 123 456 789', 'contato@moransa.gw');

-- Usuário administrador padrão (senha: admin123)
INSERT INTO users (restaurant_id, username, email, password_hash, full_name, role) VALUES 
((SELECT id FROM restaurants WHERE slug = 'moransa'), 'admin', 'admin@moransa.gw', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj3L3jzjvQSG', 'Administrador', 'admin');

-- Categorias de exemplo
INSERT INTO categories (restaurant_id, name, description, sort_order) VALUES 
((SELECT id FROM restaurants WHERE slug = 'moransa'), 'Pratos Principais', 'Pratos tradicionais e internacionais', 1),
((SELECT id FROM restaurants WHERE slug = 'moransa'), 'Bebidas', 'Bebidas geladas e quentes', 2),
((SELECT id FROM restaurants WHERE slug = 'moransa'), 'Sobremesas', 'Doces e sobremesas', 3),
((SELECT id FROM restaurants WHERE slug = 'moransa'), 'Entradas', 'Aperitivos e entradas', 0);

-- Produtos de exemplo
INSERT INTO products (restaurant_id, category_id, name, description, price, preparation_time) VALUES 
((SELECT id FROM restaurants WHERE slug = 'moransa'), (SELECT id FROM categories WHERE name = 'Pratos Principais' LIMIT 1), 'Canja de Galinha', 'Prato tradicional da Guiné-Bissau', 1500.00, 25),
((SELECT id FROM restaurants WHERE slug = 'moransa'), (SELECT id FROM categories WHERE name = 'Pratos Principais' LIMIT 1), 'Arroz de Marisco', 'Arroz com frutos do mar frescos', 2500.00, 30),
((SELECT id FROM restaurants WHERE slug = 'moransa'), (SELECT id FROM categories WHERE name = 'Bebidas' LIMIT 1), 'Sumo de Bissap', 'Bebida tradicional de hibisco', 500.00, 5),
((SELECT id FROM restaurants WHERE slug = 'moransa'), (SELECT id FROM categories WHERE name = 'Bebidas' LIMIT 1), 'Água Mineral', 'Água mineral gelada', 300.00, 2);

-- Mesas de exemplo
INSERT INTO tables (restaurant_id, number, name, capacity, qr_code) VALUES 
((SELECT id FROM restaurants WHERE slug = 'moransa'), '01', 'Mesa 1', 4, 'QR_MESA_01_' || extract(epoch from now())),
((SELECT id FROM restaurants WHERE slug = 'moransa'), '02', 'Mesa 2', 2, 'QR_MESA_02_' || extract(epoch from now())),
((SELECT id FROM restaurants WHERE slug = 'moransa'), '03', 'Mesa 3', 6, 'QR_MESA_03_' || extract(epoch from now())),
((SELECT id FROM restaurants WHERE slug = 'moransa'), '04', 'Mesa 4', 4, 'QR_MESA_04_' || extract(epoch from now()));

COMMIT;

-- Mensagem de sucesso
DO $$
BEGIN
    RAISE NOTICE 'smartWaiter database initialized successfully!';
    RAISE NOTICE 'Default admin user: admin@moransa.gw / admin123';
    RAISE NOTICE 'Restaurant: Restaurante Moransa';
END $$;