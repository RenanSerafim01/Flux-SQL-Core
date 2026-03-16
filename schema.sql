-- ==========================================
-- SISTEMA DE CONTROLE DE GASTOS - SUPABASE
-- Arquitetura construída no PostgreSQL
-- ==========================================

-- 1. Criação do Tipo Customizado (ENUM)
CREATE TYPE tipo_pagamento AS ENUM ('CREDITO', 'DEBITO', 'PIX', 'DINHEIRO');

-- 2. Tabela de Categorias
CREATE TABLE ref_expense_category (
    id SERIAL PRIMARY KEY,
    category_name TEXT NOT NULL
);

-- 3. Tabela de Despesas Recorrentes (Moldes / Assinaturas)
CREATE TABLE cfg_recurring_expense (
    id SERIAL PRIMARY KEY,
    id_ref_expense_category INT REFERENCES ref_expense_category(id),
    description TEXT NOT NULL,
    amount_cents INT NOT NULL,
    due_day INT NOT NULL,
    payment_method tipo_pagamento NOT NULL,
    is_active BOOLEAN DEFAULT true
);

-- 4. Tabela Principal de Transações (A base de gastos)
CREATE TABLE trx_expense (
    id SERIAL PRIMARY KEY,
    id_ref_expense_category INT REFERENCES ref_expense_category(id),
    expense_description TEXT NOT NULL,
    expense_amount INT NOT NULL,
    expense_date TIMESTAMPTZ NOT NULL,
    payment_method tipo_pagamento NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Tabela de Auditoria (Câmera de Segurança com JSONB)
CREATE TABLE log_expense_audit (
    id SERIAL PRIMARY KEY,
    action TEXT NOT NULL,
    old_record JSONB,
    new_record JSONB,
    changed_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. O Robô: Função para Gerar Gastos Recorrentes
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
    id_ref_expense_category,
    expense_description,
    expense_amount, 
    expense_date,
    payment_method
  )
  SELECT 
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

-- 7. Views de Relatórios (Com Segurança Invoker Ativada)
CREATE OR REPLACE VIEW vw_resumo_mes_orcamento WITH (security_invoker = true) AS
SELECT 
    c.category_name,
    SUM(t.expense_amount) / 100.0 AS total_gasto_reais
FROM trx_expense t
JOIN ref_expense_category c ON t.id_ref_expense_category = c.id
GROUP BY c.category_name;
