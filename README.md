# 📊 Sistema de Controle Financeiro - Arquitetura de Banco de Dados

Um sistema robusto de gestão de despesas e finanças pessoais construído puramente no nível do Banco de Dados (PostgreSQL / Supabase). Este projeto foca em integridade referencial, segurança de dados e automação de regras de negócio direto no back-end.

## 🚀 Visão Geral do Projeto

Este repositório contém a modelagem e a lógica de banco de dados para um aplicativo de controle de gastos. A arquitetura foi desenhada para garantir que nenhuma regra de negócio seja burlada pelo front-end, utilizando recursos avançados do PostgreSQL para blindar os dados e automatizar processos repetitivos.

## 🛠️ Tecnologias e Conceitos Aplicados

* **PostgreSQL & Supabase:** Motor principal de banco de dados.
* **Tipagem Forte & ENUMs:** Criação de tipos customizados (ex: `tipo_pagamento`) para restringir e padronizar entradas (Lixo entra, Lixo sai - resolvido).
* **Automação com Functions (PL/pgSQL):** Desenvolvimento de um "Motor de Gastos Recorrentes" que processa assinaturas mensais automaticamente, calcula datas de vencimento e gera recibos em formato de tabela (`RETURNS TABLE`).
* **Views Seguras (Security Invoker):** Painéis de consolidação financeira (resumos mensais) configurados para respeitar o contexto de segurança do usuário logado, prevenindo vazamento de dados.
* **Auditoria com JSONB:** Estrutura pronta para rastreamento de alterações (logs) empacotando o estado anterior e o novo estado das transações em formato JSONB dinâmico.

## 📂 Estrutura do Repositório

* `schema.sql`: O esqueleto do sistema. Contém a DDL completa (criação de tabelas, relacionamentos, constraints, ENUMs, views e a função de automação).
* `seed.sql`: Dados fictícios (mock data) para popular o banco em ambientes de teste, permitindo a validação das queries e visualização dos relatórios.

## ⚙️ Como Executar

Para testar esta arquitetura em seu próprio ambiente (como o Supabase ou qualquer instância PostgreSQL local):

1.  Execute o arquivo `schema.sql` no seu SQL Editor para construir as tabelas e a lógica.
2.  Execute o arquivo `seed.sql` para inserir as categorias e despesas de teste.
3.  Faça a chamada da função de automação rodando: `SELECT * FROM gerar_gastos_recorrentes_do_mes();` para ver o motor processando as assinaturas.

## 👨‍💻 Autor

**Renan Serafim**
Estudante de Sistemas de Informação na FIAP.
Aprofundando conhecimentos em Engenharia de Software, com foco no ecossistema Java, desenvolvimento SQL estruturado e integrações com IA.
