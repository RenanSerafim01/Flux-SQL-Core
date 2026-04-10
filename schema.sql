-- ==============================================================================
-- 1. TIPOS CUSTOMIZADOS (ENUMS)
-- ==============================================================================
CREATE TYPE tipo_pagamento AS ENUM ('CREDITO', 'DEBITO', 'PIX', 'DINHEIRO');

-- ==============================================================================
-- 2. TABELAS DO SISTEMA (CORE)
-- ==============================================================================

-- Tabela de Usuários (SaaS)
CREATE TABLE master_user (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name TEXT NOT NULL,
    login TEXT UNIQUE NOT NULL, 
    senha TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    created_by UUID
);

-- Tabela de Contas Bancárias / Carteiras (Em Desenvolvimento)
CREATE TABLE cfg_account (
    id SERIAL PRIMARY KEY,
    id_master_user UUID REFERENCES master_user(id) ON DELETE CASCADE,
    account_name TEXT NOT NULL,
    balance_cents INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de Categorias de Despesas
CREATE TABLE ref_expense_category (
    id SERIAL PRIMARY KEY,
    id_master_user UUID REFERENCES master_user(id) ON DELETE CASCADE, -- NULL indica categoria Global/Sistema
    category_name TEXT NOT NULL,
    is_global BOOLEAN DEFAULT false
);

-- ==============================================================================
-- 3. TABELAS DE TRANSAÇÕES E GASTOS
-- ==============================================================================

-- Tabela de Entradas / Rendas
CREATE TABLE trx_income (
    id SERIAL PRIMARY KEY,
    id_master_user UUID REFERENCES master_user(id) ON DELETE CASCADE,
    id_cfg_account INT REFERENCES cfg_account(id), 
    income_description TEXT NOT NULL,
    income_amount_cents INT NOT NULL,
    income_date DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de Configuração de Gastos Recorrentes/Fixos
CREATE TABLE cfg_recurring_expense (
    id SERIAL PRIMARY KEY,
    id_master_user UUID REFERENCES master_user(id) ON DELETE CASCADE,
    id_cfg_account INT REFERENCES cfg_account(id), 
    id_ref_expense_category INT REFERENCES ref_expense_category(id),
    description TEXT NOT NULL,
    amount_cents INT NOT NULL,
    due_day INT NOT NULL,
    payment_method tipo_pagamento NOT NULL,
    is_active BOOLEAN DEFAULT true
);

-- Tabela de Despesas Avulsas e Efetivadas
CREATE TABLE trx_expense (
    id SERIAL PRIMARY KEY,
    id_master_user UUID REFERENCES master_user(id) ON DELETE CASCADE,
    id_cfg_account INT REFERENCES cfg_account(id),
    id_ref_expense_category INT REFERENCES ref_expense_category(id),
    expense_amount INT NOT NULL,
    payment_method tipo_pagamento NOT NULL,
    expense_description TEXT NOT NULL,
    expense_date TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);


-- ==============================================================================
-- 4. TABELAS DE AUDITORIA E LOGS
-- ==============================================================================
CREATE TABLE log_expense_audit (
    id SERIAL PRIMARY KEY,
    action TEXT NOT NULL,
    old_record JSONB,
    new_record JSONB,
    changed_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- 5. FUNÇÕES E PROCEDURES (AUTOMATIZAÇÕES)
-- ==============================================================================

CREATE OR REPLACE FUNCTION gerar_gastos_recorrentes_do_mes()
RETURNS TABLE (
  id_gasto_gerado INT8,
  descricao TEXT, 
  valor_centavos INT4, 
  data_vencimento TIMESTAMPTZ, 
  metodo_pagamento TEXT
)
LANGUAGE plpgsql
SECURITY INVOKER 
AS $$
BEGIN
  RETURN QUERY
  INSERT INTO trx_expense (
    id_master_user,           
    id_cfg_account,          
    id_ref_expense_category,
    expense_description,
    expense_amount, 
    expense_date,
    payment_method
  )
  SELECT 
    id_master_user,
    id_cfg_account,
    id_ref_expense_category, 
    description,
    amount_cents,
    make_date(
      CAST(EXTRACT(YEAR FROM CURRENT_DATE) AS INTEGER), 
      CAST(EXTRACT(MONTH FROM CURRENT_DATE) AS INTEGER), 
      due_day
    ),
    payment_method
  FROM cfg_recurring_expense
  WHERE is_active = true
  RETURNING 
    id, 
    expense_description, 
    expense_amount, 
    expense_date, 
    payment_method::TEXT;
END;
$$;

-- ==============================================================================
-- 6. VIEWS (VISUALIZAÇÕES CONSOLIDADAS)
-- ==============================================================================

CREATE OR REPLACE VIEW vw_resumo_mes_orcamento WITH (security_invoker = true) AS
SELECT 
    t.id_master_user,
    c.category_name,
    SUM(t.expense_amount) / 100.0 AS total_gasto_reais
FROM trx_expense t
JOIN ref_expense_category c ON t.id_ref_expense_category = c.id
GROUP BY t.id_master_user, c.category_name;
