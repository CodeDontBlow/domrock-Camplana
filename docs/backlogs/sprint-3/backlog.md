# Backlog — Sprint 3

[← Voltar para a documentação da Sprint 3](README.md) · [Critérios de aceitação (Gherkin)](gherkin.md)

Revisado em 04/11/2026, depois da Sprint Review da Sprint 2 com a Dom Rock. O **ID** de cada história é fixo e é o mesmo usado no Jira (`API-6SEM`). As histórias novas começam no ID 19. A ordem de trabalho é o **Rank** do backlog da sprint.

**Legenda de status:** ✅ entregue · 🔄 na Sprint 3 · *Could* entra se sobrar capacidade

**Revisão de 04/11/2026:** o backlog foi enxugado para o que cabe até a entrega final, ficando com 19 histórias, das quais 11 já foram entregues. Saíram a 11 (notificação de submissão), 12 (relatório com gráficos), 13 (comissão fora da média), 14 (logs de edição, coberta pelo Auditor na 19), 17 (perfil e senha), 18 (insights automáticos) e as propostas de custo na meta e de campanha futura. Os IDs das histórias que ficaram não mudam.

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
| 9 | Alta | Como Supervisor de Vendas, quero propor correções pontuais na base cadastral e submetê-las ao mesmo fluxo de aprovação, para manter a base íntegra caso haja necessidade. | 8 | 2 | ✅ ¹ |
| 10 | Média | Como Usuário Autenticado, quero ver o status da minha regra (rascunho, aguardando aprovação, aprovada, reprovada, arquivada), para acompanhar em que etapa ela está. | 5 | 2 | ✅ |
| 15 | Alta | Como Supervisor de Vendas, quero visualizar o passo a passo de como o sistema interpretou o comando e chegou ao resultado da simulação, para entender e confiar na decisão (explicabilidade). | 13 | 2 | ✅ ² |
| 16 | Média | Como Supervisor de Vendas, quero visualizar as campanhas já realizadas, em andamento e previstas, para gerenciá-las. | 5 | 3 | 🔄 |
| **19** | Alta | Como Auditor, quero consultar, sem poder alterar, as campanhas, versões, conversas e decisões de todos os usuários, para auditar o negócio de ponta a ponta. | 8 | 3 | 🔄 |
| **20** | Alta | Como Auditor, quero ver o SQL e o código gerados pela Lana e resolver os alertas de segurança, para que nenhuma campanha com código suspeito seja aprovada. | 13 | 3 | 🔄 |
| **21** | Alta | Como Gerente de Vendas, quero que a apuração siga todas as regras da especificação e as intercorrências de RH, para que o simulado bata com o que a empresa pagaria. | 13 | 3 | 🔄 |
| **22** | Alta | Como Gerente ou Supervisor de Vendas, quero registrar intercorrências de RH e correções da base por uma tela, com aprovação de outra pessoa, para que a apuração use a base certa. | 8 | 3 | 🔄 |
| **23** | Média | Como Gerente de Vendas, quero ver no chat o histórico das minhas ações e ter o nome e o compartilhar da campanha acima da conversa, para acompanhar a campanha sem sair do chat. | 5 | 3 | 🔄 |
| **24** | Média | Como Gerente, Supervisor ou Auditor, quero uma navegação de acordo com o meu perfil, para encontrar o que preciso sem me perder. | 5 | 3 | 🔄 |
| **25** | Média | Como Gerente de Vendas, quero conversar com a Lana sobre comissionamento e sobre o que ela sabe fazer, recebendo uma resposta clara quando o assunto estiver fora do que ela cobre, para usá-la como assistente e não só como formulário. | 8 | 3 | *Could* ³ |

¹ O backend e a Lana da correção da base foram entregues (A6-80 e A6-81). A tela fica na história 22.
² Antecipada para a Sprint 2: trilha de onde veio cada número (A6-70) e SQL visível ao Supervisor (A6-71).
³ Depende do spike de RAG (tarefa T1). Só entra se o spike aprovar a abordagem.

**Perfis:** o **Gerente de Vendas** propõe e simula campanhas e correções. O **Supervisor de Vendas** faz o mesmo e aprova o que **outra pessoa** submeteu. O **Auditor** (novo na Sprint 3) vê tudo e não altera nada; a única ação dele é abrir ou resolver um alerta técnico. O **Administrador** só gerencia usuários.

---

## 🏃 Backlog da Sprint 3 <a id="sprint"></a>

| Rank | ID | Jira | MoSCoW | User Story (resumo) | Estimativa | Frentes | Depende de |
| :-: | :-: | :-: | :-: | :-- | :-: | :-- | :-- |
| 1 | 19 | A6-94 | Must | Auditor: visão de negócio, só leitura | 8 | Back, Front | — |
| 2 | 20 | A6-95 | Must | Auditor: visão técnica e alertas que travam a aprovação | 13 | Back, Front, Lana | 19 |
| 3 | 21 | A6-96 | Must | Apuração completa (regras 5a a 5g e intercorrências) | 13 | Lana, Back | 22 (só para o cenário de intercorrência registrada pela tela) |
| 4 | 22 | A6-97 | Should | Tela de intercorrências e correções da base | 8 | Front, Back | A6-80 (PR do backend) |
| 5 | 16 | A6-98 | Should | Campanhas realizadas, em andamento e previstas | 5 | Front, Back | — |
| 6 | 23 | A6-99 | Should | Eventos das ações no chat e barra com nome e compartilhar | 5 | Front, Back | — |
| 7 | 24 | A6-100 | Should | Navegação por perfil | 5 | Front | 19 (itens do Auditor) |
| — | 25 | A6-101 | Could | Lana conversável com grounding e guardrail | 8 | Lana, Back | T1 |

**Must: 34 pontos · Should: 23 pontos · Could: 8 pontos.**

### Tarefas técnicas (sem pontos de história, com capacidade reservada)

| ID | Jira | Tarefa | Frente | Por quê |
| :-: | :-: | :-- | :-- | :-- |
| T1 | A6-117 | **Spike de RAG** (prazo fixo de 3 dias): banco vetorial com os assuntos que a Lana cobre, limiar de distância e resposta de fallback do servidor sem chamar a LLM. Medir acurácia, latência e custo; comparar pgvector no Postgres atual com um banco vetorial separado. | Lana | O PO quer a Lana conversável (história 25), mas a abordagem precisa ser avaliada antes |
| T2 | A6-106 | Filtrar o SQL e o código gerado por perfil **no backend** | Back | Hoje só o front esconde (por `localStorage`); o Auditor exige que a API filtre |
| T3 | A6-118 | Sandbox dedicado para o código gerado (A6-85): confirmar o que foi feito; se não existir, rodar em container sem rede, só leitura e sem privilégios | Lana, Infra | O card está "Feito", mas a develop ainda usa o subprocesso da Sprint 1 |
| T4 | A6-119 | Dividir a ferramenta de simulação da Lana em partes menores | Lana | Facilita a apuração completa (21) e os testes |
| T5 | A6-110 | Renumerar a migration do PR da correção da base (V9 → V11) antes do merge | Back | A develop já tem `V9__add_versao_na_simulacao` e `V10` |
| T6 | A6-120 | Cores verde e laranja para mensagens rápidas de sucesso, mantendo-as como temas selecionáveis (talvez um segundo tom de laranja no tema laranja) | Front | Notas do time (Could) |
| T7 | A6-121 | Manual de Instalação, Manual do Usuário e vídeo tutorial finais | Docs | Requisitos da Fatec e do parceiro para a entrega final |

---

## 🧭 Priorização MoSCoW <a id="moscow"></a>

| Categoria | Itens | Por quê |
| :-- | :-- | :-- |
| **Must have** | 19, 20, 21 | O cliente pediu um perfil de auditoria com visão de negócio e técnica, e alertas antes de a campanha entrar em vigor. A apuração completa fecha a regra de negócio da especificação, que ficou pendente na Sprint 2. Sem esses três, a entrega final não responde à review. |
| **Should have** | 22, 16, 23, 24, T1 a T5 | Fecham o processo que o cliente elogiou (intercorrências entram pela tela e não por script, campanhas por período, histórico de ações no chat) e corrigem problemas de navegação vistos na demo. O spike T1 decide se a história 25 entra. |
| **Could have** | 25, T6 | A Lana conversável é o diferencial que o PO quer, mas depende do spike T1. As cores de mensagem de sucesso são ajuste visual. |
| **Won't have (neste projeto)** | Relatório com gráficos e insights automáticos; notificação de submissão; comissão fora da média; perfil e troca de senha; custo na meta e campanha futura; cancelar campanha aprovada; logs no Grafana; entrada por voz | Saíram na revisão de 04/11/2026 para caber na última sprint. O relatório foi decisão do PO, e a fila de aprovações já mostra o que está pendente. Grafana e voz são diferenciais de outra equipe que o cliente não pediu. |

---

## 🔁 Pedido da review → item do backlog <a id="rastreabilidade"></a>

| O que o cliente pediu na review da Sprint 2 | Onde entra |
| :-- | :-- |
| Perfil de auditoria com visão irrestrita e só leitura | História 19 e o perfil Auditor em todas as telas (24) |
| Auditoria de negócio: parâmetros, impacto financeiro, justificativas | História 19 |
| Auditoria técnica: rastro do SQL e do código gerados | História 20 e tarefa T2 |
| Alertas de vulnerabilidade (injeção de prompt e de SQL) antes de a campanha entrar em vigor | História 20 (alerta aberto trava a aprovação) e tarefa T3 |
| Manter a validação humana obrigatória | Histórias 19 e 20 mantêm a aprovação por outra pessoa; o Auditor não aprova |
| Logs consolidados e explicabilidade dos caminhos do agente | Histórias 19 e 20 reúnem conversa, trilha e decisões numa tela por campanha |

## 📝 Notas do time (Leo e Rafa, 04/11/2026) → item do backlog <a id="notas"></a>

| Nota | Onde entra |
| :-- | :-- |
| Grounding com RAG: comparar o prompt com os assuntos que a Lana cobre | T1 e história 25 |
| Guardrail: fallback do servidor quando a distância passa do limiar, sem gastar token | T1 e história 25 |
| Cores verde e laranja para mensagens rápidas de sucesso | T6 |
| "Minhas campanhas" do Gerente vira "Suas campanhas" na barra lateral; Supervisor mantém "Campanhas" | História 24 |
| Nome da campanha e compartilhar numa barra acima do chat | História 23 |
| Eventos das ações do usuário no histórico do chat | História 23 |
| Supervisor sem "novo chat" e com tela inicial própria | História 24 |
| "Novo chat" limpa o estado da rota | História 24 |
| Item ativo da barra lateral de acordo com a rota (também depois de recarregar) | História 24 |
| SQL gerado só para o Supervisor | Mantido; o Auditor também vê (20) e o backend passa a filtrar (T2) |
| Dividir a ferramenta de simulação | T4 |
| Tela de intercorrências | História 22 |
| Tela de campanhas vigentes e agendadas | História 16 |
| Tela de submissão de intercorrências e de alterações na base | História 22 |
| Tela de relatórios de campanhas | Fora (*Won't*) |
| Tela de versões da campanha (talvez no chat) | História 19 para o Auditor; para o Gerente, a decidir no refinamento da 23 |
| Tela de configurações e perfil | Fora (*Won't*) |
