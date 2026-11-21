# Backlog — Sprint 3

[← Voltar para a documentação da Sprint 3](README.md) · [Critérios de aceitação (Gherkin)](gherkin.md)

O **ID** de cada história é fixo e é o mesmo usado no Jira (`API-6SEM`). As histórias novas começam no ID 19. A ordem de trabalho é o **Rank** do backlog da sprint.

**Legenda de status:** ✅ entregue · 🔄 na Sprint 3 · *Could* entra se sobrar capacidade

---

## 🗒️ Backlog do Produto <a id="produto"></a>

| ID | Prioridade | User Story | Estimativa | Sprint | Status |
| :-: | :-: | :-- | :-: | :-: | :-: |
| 1 | Alta | Como Gerente de Vendas, quero conversar com o agente por uma interface de chat, para descrever a regra em linguagem natural e receber as respostas dele. | 5 | 1 | ✅ |
| 2 | Alta | Como Gerente de Vendas, quero que o agente interprete meu comando e me mostre os parâmetros extraídos (marcas, cargos, meta, % de comissão, período), para eu confirmar que ele entendeu corretamente. | 13 | 1 | ✅ |
| 3 | Alta | Como Gerente de Vendas, quero revisar e editar os parâmetros interpretados antes de simular, para corrigir erros de interpretação. | 8 | 1 | ✅ |
| 4 | Alta | Como Gerente de Vendas, quero que o agente gere o artefato executável da simulação a partir dos parâmetros confirmados, para que a regra possa ser calculada sobre dados reais. | 13 | 1 | ✅ |
| 5 | Alta | Como Gerente de Vendas, quero executar a simulação de um cenário de atingimento de meta, para ver o valor total de comissionamento resultante. | 8 | 1 | ✅ |
| 6 | Alta | Como Supervisor de Vendas, quero avaliar e aprovar ou reprovar com justificativa as regras de negócio criadas por outros usuários, para garantir que estejam alinhadas ao orçamento e aos objetivos da campanha antes de serem executadas. | 8 | 2 | ✅ |
| 7 | Alta | Como Administrador do Sistema, quero criar, editar e desativar usuários, para gerenciar quem usa o sistema. | 3 | 2 | ✅ |
| 8 | Alta | Como Gerente de Vendas, quero que o sistema disponha da base de vendas, metas e vendedores do período, para que a simulação tenha dados sobre os quais calcular. | 8 | 2 | ✅ |
| 9 | Alta | Como Supervisor de Vendas, quero propor correções pontuais na base cadastral e submetê-las ao mesmo fluxo de aprovação, para manter a base íntegra caso haja necessidade. | 8 | 3 | 🔄 |
| 10 | Média | Como Usuário Autenticado, quero ver o status da minha regra (rascunho, aguardando aprovação, aprovada, reprovada, arquivada), para acompanhar em que etapa ela está. | 5 | 2 | ✅ |
| 15 | Alta | Como Supervisor de Vendas, quero visualizar o passo a passo de como o sistema interpretou o comando e chegou ao resultado da simulação, para entender e confiar na decisão (explicabilidade). | 13 | 2 | ✅ |
| 16 | Média | Como Supervisor de Vendas, quero visualizar as campanhas já realizadas, em andamento e previstas, para gerenciá-las. | 5 | 3 | 🔄 |
| **19** | Alta | Como Auditor, quero consultar, sem poder alterar, as campanhas, versões, conversas e decisões de todos os usuários, para auditar o negócio de ponta a ponta. | 8 | 3 | 🔄 |
| **20** | Alta | Como Auditor, quero ver o SQL e o código gerados pela Lana e resolver os alertas de segurança, para que nenhuma campanha com código suspeito seja aprovada. | 13 | 3 | 🔄 |
| **21** | Alta | Como Gerente de Vendas, quero que a apuração siga todas as regras da especificação e as intercorrências de RH, para que o simulado bata com o que a empresa pagaria. | 13 | 3 | 🔄 |
| **22** | Alta | Como Gerente ou Supervisor de Vendas, quero registrar intercorrências de RH conversando com a Lana, com aprovação de outra pessoa, para que a apuração use a base certa. | 8 | 3 | 🔄 |
| **25** | Média | Como Gerente de Vendas, quero conversar com a Lana sobre comissionamento e sobre o que ela sabe fazer, recebendo uma resposta clara quando o assunto estiver fora do que ela cobre, para usá-la como assistente e não só como formulário. | 8 | 3 | *Could* |

**Perfis:** o **Gerente de Vendas** propõe e simula campanhas e correções. O **Supervisor de Vendas** faz o mesmo e aprova o que **outra pessoa** submeteu. O **Auditor** (novo na Sprint 3) vê tudo e não altera nada; a única ação dele é abrir ou resolver um alerta técnico. O **Administrador** só gerencia usuários.

---

## 🏃 Backlog da Sprint 3 <a id="sprint"></a>

| Rank | ID | Jira | MoSCoW | User Story (resumo) | Estimativa | Frentes | Depende de |
| :-: | :-: | :-: | :-: | :-- | :-: | :-- | :-- |
| 1 | 19 | A6-94 | Must | Auditor: visão de negócio, só leitura | 8 | Back, Front | — |
| 2 | 20 | A6-95 | Must | Auditor: visão técnica e alertas que travam a aprovação | 13 | Back, Front, Lana | 19 |
| 3 | 21 | A6-96 | Must | Apuração completa (regras 5a a 5g e intercorrências) | 13 | Lana, Back | 22 (só para o cenário de intercorrência registrada pela Lana) |
| 4 | 9 | A6-48 | Should | Correção da base pela Lana | 8 | Back, Lana, Front | T5 (migration do PR da A6-80) |
| 5 | 22 | A6-97 | Should | Intercorrências de RH pela Lana | 8 | Lana, Back, Front | 9 (mesmo fluxo de aprovação) |
| 6 | 16 | A6-98 | Should | Campanhas realizadas, em andamento e previstas | 5 | Front, Back | — |
| — | 25 | A6-101 | Could | Lana conversável com grounding e guardrail | 8 | Lana, Back | T1 |

**Must: 34 pontos · Should: 21 pontos · Could: 8 pontos.**

### Tarefas técnicas (sem pontos de história, com capacidade reservada)

| ID | Jira | Tarefa | Frente | Por quê |
| :-: | :-: | :-- | :-- | :-- |
| T1 | A6-117 | **Spike de RAG** (prazo fixo de 3 dias): banco vetorial com os assuntos que a Lana cobre, limiar de distância e resposta de fallback do servidor sem chamar a LLM. Medir acurácia, latência e custo; comparar pgvector no Postgres atual com um banco vetorial separado. | Lana | O PO quer a Lana conversável (história 25), mas a abordagem precisa ser avaliada antes |
| T2 | A6-106 | Filtrar o SQL e o código gerado por perfil **no backend** | Back | Hoje só o front esconde (por `localStorage`); o Auditor exige que a API filtre |
| T3 | A6-118 | Sandbox dedicado para o código gerado (A6-85): confirmar o que foi feito; se não existir, rodar em container sem rede, só leitura e sem privilégios | Lana, Infra | O card está "Feito", mas a develop ainda usa o subprocesso da Sprint 1 |
| T4 | A6-119 | Dividir a ferramenta de simulação da Lana em partes menores | Lana | Facilita a apuração completa (21) e os testes |
| T5 | A6-110 | Renumerar a migration do PR da correção da base (V9 → V11) antes do merge | Back | A develop já tem `V9__add_versao_na_simulacao` e `V10` |
| T6 | A6-120 | Cores verde e laranja para mensagens rápidas de sucesso, mantendo-as como temas selecionáveis (talvez um segundo tom de laranja no tema laranja) | Front | Ajuste visual pedido pelo time (Could) |
| T7 | A6-121 | Manual de Instalação, Manual do Usuário e vídeo tutorial finais | Docs | Requisitos da Fatec e do parceiro para a entrega final |
| T8 | A6-123 | **Correção de bug:** a barra lateral marca "Nova Campanha" como ativo em Vigente, Relatórios, Importar base e Configurações quando a página é aberta pelo endereço ou recarregada (F5) | Front | O `watch` da rota em `Sidebar.vue` só trata `/campanha`, `/admin` e `/` |

---

## 🧭 Priorização MoSCoW <a id="moscow"></a>

| Categoria | Itens | Por quê |
| :-- | :-- | :-- |
| **Must have** | 19, 20, 21 | O cliente pediu um perfil de auditoria com visão de negócio e técnica, e alertas antes de a campanha entrar em vigor. A apuração completa fecha a regra de negócio da especificação, que ficou pendente na Sprint 2. Sem esses três, a entrega final não responde à review. |
| **Should have** | 9, 22, 16, T1 a T5, T8 | Fecham o processo que o cliente elogiou (correções da base e intercorrências entram pela Lana e não por script, campanhas por período). A 9 vem da Sprint 2, onde não foi concluída. O spike T1 decide se a história 25 entra. |
| **Could have** | 25, T6 | A Lana conversável é o diferencial que o PO quer, mas depende do spike T1. As cores de mensagem de sucesso são ajuste visual. |
| **Won't have (neste projeto)** | Relatório com gráficos e insights automáticos; notificação de submissão; comissão fora da média; perfil e troca de senha; custo na meta e campanha futura; cancelar campanha aprovada; eventos das ações no chat; navegação por perfil; logs no Grafana; entrada por voz | Ficam fora para caber na última sprint. O relatório foi decisão do PO, e a fila de aprovações já mostra o que está pendente. Grafana e voz são diferenciais de outra equipe que o cliente não pediu. |

---

## 🔁 Pedido da review → item do backlog <a id="rastreabilidade"></a>

| O que o cliente pediu na review da Sprint 2 | Onde entra |
| :-- | :-- |
| Perfil de auditoria com visão irrestrita e só leitura | História 19 |
| Auditoria de negócio: parâmetros, impacto financeiro, justificativas | História 19 |
| Auditoria técnica: rastro do SQL e do código gerados | História 20 e tarefa T2 |
| Alertas de vulnerabilidade (injeção de prompt e de SQL) antes de a campanha entrar em vigor | História 20 (alerta aberto trava a aprovação) e tarefa T3 |
| Manter a validação humana obrigatória | Histórias 19 e 20 mantêm a aprovação por outra pessoa; o Auditor não aprova |
| Logs consolidados e explicabilidade dos caminhos do agente | Histórias 19 e 20 reúnem conversa, trilha e decisões numa tela por campanha |
