-- 1. Criar Categorias Globais (do Sistema)
INSERT INTO ref_expense_category (category_name, is_global) VALUES
('Lazer e Entretenimento', true),
('Contas de Casa', true),
('Alimentação', true),
('Transporte', true);

-- 2. Criar um Utilizador de Teste (Mock User) para atrelar os gastos
-- Usei um UUID fixo e repetido (tudo 1) apenas para fins de teste no ambiente de desenvolvimento
INSERT INTO master_user (id, full_name, login, senha) VALUES
('11111111-1111-1111-1111-111111111111', 'Utilizador Teste Seed', 'testeseed@flux.com', 'senha_criptografada_fake');

-- 3. Inserir Gastos Recorrentes para o Utilizador de Teste
INSERT INTO cfg_recurring_expense (id_master_user, id_ref_expense_category, description, amount_cents, due_day, payment_method) VALUES
('11111111-1111-1111-1111-111111111111', 1, 'Assinatura Streaming (Filmes)', 4590, 10, 'CREDITO'),
('11111111-1111-1111-1111-111111111111', 1, 'Fiel Torcedor VIP', 3500, 5, 'CREDITO'),
('11111111-1111-1111-1111-111111111111', 2, 'Conta de Energia Elétrica', 12050, 15, 'DEBITO'),
('11111111-1111-1111-1111-111111111111', 2, 'Condomínio', 55000, 10, 'PIX');

-- 4. Inserir Despesas Avulsas para o Utilizador de Teste
INSERT INTO trx_expense (id_master_user, id_ref_expense_category, expense_description, expense_amount, expense_date, payment_method) VALUES
('11111111-1111-1111-1111-111111111111', 3, 'Compra no Mercado da Esquina', 25000, NOW() - INTERVAL '5 days', 'DEBITO'),
('11111111-1111-1111-1111-111111111111', 4, 'Abastecimento Carro', 15000, NOW() - INTERVAL '2 days', 'CREDITO'),
('11111111-1111-1111-1111-111111111111', 3, 'Pizza de Sexta', 8990, NOW() - INTERVAL '1 day', 'PIX');

-- 5. Rodar a automação para gerar os gastos fixos do mês atual no extrato
SELECT * FROM gerar_gastos_recorrentes_do_mes();
