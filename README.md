# 📊 Flux Engine - Arquitetura de Banco de Dados SaaS

Um sistema robusto de gestão de despesas e finanças pessoais construído puramente no nível do Banco de Dados (PostgreSQL / Supabase). Este projeto foca em integridade referencial, arquitetura Multi-tenant, segurança de dados e automação de regras de negócio direto no back-end.

## 🚀 Visão Geral do Projeto

Este repositório contém a modelagem e a lógica de banco de dados para um aplicativo de controle de gastos (SaaS). A arquitetura foi desenhada para garantir que nenhuma regra de negócio seja burlada pelo front-end, utilizando recursos avançados do PostgreSQL para blindar os dados, isolar as contas de diferentes usuários e automatizar processos repetitivos.

## 🛠️ Tecnologias e Conceitos Aplicados

* **Arquitetura Multi-tenant (SaaS):** Modelagem focada no isolamento de dados, onde todas as transações, rendas e contas são amarradas de forma segura ao UUID de um usuário mestre (`id_master_user`), permitindo que múltiplos usuários utilizem o sistema simultaneamente sem vazamento de dados.
* **Integridade e Constraints:** Uso agressivo de chaves estrangeiras com `ON DELETE CASCADE` para evitar registros órfãos, e travas de unicidade (`UNIQUE`) para blindar o sistema contra duplicações acidentais (ex: duplo clique no front-end).
* **Tipagem Forte & ENUMs:** Criação de tipos customizados (ex: `tipo_pagamento`) para restringir e padronizar entradas (Lixo entra, Lixo sai - resolvido).
* **Automação com Functions (PL/pgSQL):** Desenvolvimento de um "Motor de Gastos Recorrentes" inteligente que processa assinaturas mensais, identifica o usuário dono da assinatura, calcula datas de vencimento e gera recibos dinâmicos em formato de tabela (`RETURNS TABLE`).
* **Views Seguras (Security Invoker):** Painéis de consolidação financeira configurados para respeitar o contexto de segurança, preparando o terreno para relatórios complexos.

## 📂 Estrutura do Repositório

* `schema.sql`: O esqueleto do sistema. Contém a DDL completa (criação de tabelas, relacionamentos, constraints, ENUMs, views e a função de automação).
* `seed.sql`: Script de população de banco (mock data) otimizado para testes em ambiente de desenvolvimento, incluindo a criação de um "Usuário de Teste" e suas transações simuladas.

## ⚙️ Como Executar

Para testar esta arquitetura em seu próprio ambiente (como o Supabase ou qualquer instância PostgreSQL local):

1.  Execute o arquivo `schema.sql` no seu SQL Editor para construir as tabelas e a lógica.
2.  Execute o arquivo `seed.sql` para inserir as categorias globais, o usuário de teste e suas despesas/rendas iniciais.
3.  Faça a chamada da função de automação rodando: `SELECT * FROM gerar_gastos_recorrentes_do_mes();` para ver o motor processando as assinaturas do usuário simulado.

## 👨‍💻 Autor

**Renan Serafim**
Estudante de Sistemas de Informação na FIAP.
Aprofundando conhecimentos em Engenharia de Software, com foco no ecossistema Java, desenvolvimento SQL estruturado para arquiteturas escaláveis e integrações avançadas com IA.
