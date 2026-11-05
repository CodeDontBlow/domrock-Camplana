# API 6º Semestre ADS — CAMPLANA AI

## Documentação — Sprint 3

| Documento | Conteúdo |
| :-- | :-- |
| **README.md** (este) | Desafio, meta, capacidade, backlog da sprint, MoSCoW resumido, DoR, DoD, entregas por frente e riscos |
| [backlog.md](backlog.md) | Backlog do produto atualizado, backlog da sprint, tarefas técnicas, MoSCoW completo e rastreabilidade da review |
| [gherkin.md](gherkin.md) | Critérios de aceitação em BDD/Gherkin de todas as histórias da sprint |

**Sumário:** [Desafio](#desafio) · [Meta](#meta) · [Review da Sprint 2](#review) · [Backlog da Sprint](#backlog) · [MoSCoW](#moscow) · [Critérios de aceitação](#bdd) · [DoR](#dor) · [DoD](#dod) · [Entregas por frente](#entregas) · [Riscos](#riscos) · [Documentação](#docs) · [Burndown](#burndown) · [Demonstração](#demo) · [Protótipo](#prototipo)

---

## Desafio <a id="desafio"></a>

A Sprint 3 é a última do projeto. Na review da Sprint 2, a Dom Rock elogiou a governança por perfis, o fluxo de aprovação com status, o cálculo aditivo sobre a % vigente e a trilha do agente. Também apontou o que falta para fechar: **rastreabilidade, explicabilidade e auditoria**. Como a Lana gera e executa SQL e código, existe risco de injeção (de prompt e de SQL). Por isso, o cliente pediu um perfil neutro, que audite o negócio e o código gerado sem poder alterar nada, com a validação humana mantida como etapa obrigatória.

Ao mesmo tempo, a apuração ainda não aplica todas as regras da especificação (admissão, demissão, afastamentos, férias e intercorrências). Sem elas, o valor simulado não bate com o que a empresa pagaria.

## 🎯 Meta da Sprint <a id="meta"></a>

**Entregar uma campanha auditável de ponta a ponta e uma apuração fiel à especificação.**

1. **Auditoria de negócio (US 19):** um perfil Auditor, somente leitura, que vê todas as campanhas, versões, conversas, decisões e correções, com parâmetros, impacto financeiro e justificativas.
2. **Auditoria técnica e alertas (US 20):** o Auditor vê o SQL e o código gerados e o resultado da checagem de segurança. Consulta bloqueada ou código suspeito abre um alerta, e uma versão com alerta aberto não pode ser aprovada.
3. **Apuração completa (US 21):** as regras 5a a 5g da especificação e as intercorrências de RH entram no cálculo, com o detalhamento de quanto cada pessoa recebe.

| Capacidade estimada | Meta da Sprint | Previsão (extras) |
| :--: | :--: | :-- |
| 40 | User stories de rank 1, 2 e 3 (IDs 19, 20 e 21) — 34 pontos | User stories de rank 4 a 7 (IDs 22, 16, 23 e 24) — 23 pontos |

**Período:** 02/11/2026 a 23/11/2026, com 3 semanas, como as Sprints 1 (07/09 a 27/09) e 2 (05/10 a 26/10). A capacidade considera a velocidade das sprints anteriores e reserva tempo para os manuais e o vídeo da entrega final.

## 🔁 O que a review da Sprint 2 pediu <a id="review"></a>

| Pedido do cliente | Como a Sprint 3 responde |
| :-- | :-- |
| Perfil de auditoria com visão irrestrita e só leitura | Novo perfil **Auditor** (US 19) |
| Auditoria de negócio: parâmetros, impacto financeiro, justificativas | Tela de auditoria por campanha (US 19) |
| Auditoria técnica: rastro do SQL e do código gerados | Aba técnica com SQL, código e checagem de segurança (US 20) |
| Alertas de vulnerabilidade antes de a campanha entrar em vigor | Alerta aberto trava a aprovação até o Auditor resolvê-lo (US 20) |
| Validação humana obrigatória | Mantida: a aprovação continua exigindo outra pessoa, e o Auditor não aprova |
| Logs consolidados e explicabilidade | Conversa, trilha, versões e decisões reunidas numa tela por campanha (US 19 e 20) |

O mapa completo, incluindo as notas do time, está em [backlog.md](backlog.md#rastreabilidade).

## Backlog da Sprint <a id="backlog"></a>

| Rank | ID | MoSCoW | User Story | Estimativa |
| :--: | :--: | :--: | :--- | :--: |
| 1 | 19 | Must | Como Auditor, quero consultar, sem poder alterar, as campanhas, versões, conversas e decisões de todos os usuários, para auditar o negócio de ponta a ponta. | 8 |
| 2 | 20 | Must | Como Auditor, quero ver o SQL e o código gerados pela Lana e resolver os alertas de segurança, para que nenhuma campanha com código suspeito seja aprovada. | 13 |
| 3 | 21 | Must | Como Gerente de Vendas, quero que a apuração siga todas as regras da especificação e as intercorrências de RH, para que o simulado bata com o que a empresa pagaria. | 13 |
| 4 | 22 | Should | Como Gerente ou Supervisor de Vendas, quero registrar intercorrências de RH e correções da base por uma tela, com aprovação de outra pessoa, para que a apuração use a base certa. | 8 |
| 5 | 16 | Should | Como Supervisor de Vendas, quero visualizar as campanhas já realizadas, em andamento e previstas, para gerenciá-las. | 5 |
| 6 | 23 | Should | Como Gerente de Vendas, quero ver no chat o histórico das minhas ações e ter o nome e o compartilhar da campanha acima da conversa, para acompanhar a campanha sem sair do chat. | 5 |
| 7 | 24 | Should | Como Gerente, Supervisor ou Auditor, quero uma navegação de acordo com o meu perfil, para encontrar o que preciso sem me perder. | 5 |

Tarefas técnicas da sprint (sem pontos de história): spike de RAG para a Lana conversável (T1), filtro do SQL por perfil no backend (T2), sandbox dedicado (T3), divisão da ferramenta de simulação (T4), renumeração da migration da correção da base (T5) e manuais e vídeo finais (T7). Detalhes em [backlog.md](backlog.md#sprint).

## 🧭 Priorização MoSCoW <a id="moscow"></a>

| Must have | Should have | Could have | Won't have |
| :-- | :-- | :-- | :-- |
| 19 Auditor: negócio<br>20 Auditor: técnica e alertas<br>21 Apuração completa | 22 Intercorrências pela tela<br>16 Campanhas por período<br>23 Eventos no chat<br>24 Navegação por perfil<br>Tarefas T1 a T5 | 25 Lana conversável (RAG)<br>T6 Cores de sucesso | Relatório com gráficos e insights<br>Notificação de submissão<br>Comissão fora da média<br>Perfil e troca de senha<br>Custo na meta e campanha futura<br>Cancelar campanha aprovada<br>Logs no Grafana e entrada por voz |

O porquê de cada categoria está em [backlog.md](backlog.md#moscow). O backlog do produto foi enxugado em 04/11/2026 para 19 histórias, das quais 11 já foram entregues. O relatório com gráficos saiu por decisão do PO: a sprint prioriza a apuração correta e a auditoria.

## 🧪 Critérios de aceitação <a id="bdd"></a>

Todos os cenários estão em [gherkin.md](gherkin.md), escritos com os usuários e as campanhas da demo. Cada história tem caminho feliz, exceções, permissões por perfil e, quando há cálculo, exemplos numéricos tirados da especificação do parceiro.

| História | Cenários | Destaques |
| :-- | :--: | :-- |
| [19 — Auditor: negócio](gherkin.md#us19) | 9 | Só leitura com 403 nas rotas de escrita; versões comparadas; decisão com justificativa |
| [20 — Auditor: técnica e alertas](gherkin.md#us20) | 10 | Injeção de prompt e de SQL bloqueadas e registradas; alerta trava a aprovação |
| [21 — Apuração completa](gherkin.md#us21) | 11 | Uma regra por cenário (5a a 5g) com os exemplos da especificação |
| [22 — Intercorrências pela tela](gherkin.md#us22) | 7 | Cinco tipos de intercorrência; quatro olhos; base alterada desde o pedido (409) |
| [16 — Campanhas por período](gherkin.md#us16) | 4 | Classificação pela data de hoje |
| [23 — Eventos no chat](gherkin.md#us23) | 5 | Eventos ficam na conversa e não gastam token da Lana |
| [24 — Navegação por perfil](gherkin.md#us24) | 5 | Tela inicial por perfil; item ativo depois do F5 |
| [25 — Lana conversável](gherkin.md#us25) | 4 | Fallback sem chamar a LLM; limiar configurável |

## 🏅 DoR — Definition of Ready <a id="dor"></a>

Critérios utilizados para verificar se uma história está suficientemente preparada para entrar em desenvolvimento.

| Critério | Descrição |
| :-- | :-- |
| Clareza da descrição | A User Story apresenta de forma clara a pessoa usuária, a ação desejada e o objetivo a ser alcançado. |
| Critérios de aceitação | A história possui cenários em Gherkin com caminho feliz, exceções e, quando houver regra de acesso, um cenário por perfil afetado. |
| Referência visual | O protótipo ou material visual necessário para a implementação está disponível, quando aplicável. |
| Escopo técnico definido | Está especificado se a história envolve frontend, backend, IA ou integração entre esses componentes. |
| Regras de negócio definidas | As regras de comissionamento, entradas, resultados esperados e possíveis exceções estão descritas e compreendidas, com exemplo numérico quando houver cálculo. |
| Perfis e permissões definidos | Está claro o que cada perfil (Gerente, Supervisor, Auditor, Administrador) pode ver e fazer na história. |
| Dependências identificadas | Histórias, tarefas ou decisões de que a história depende estão listadas e resolvidas ou planejadas. |
| Estimativa definida | A história possui uma estimativa de esforço definida e discutida pela equipe. |

## 🏅 DoD — Definition of Done <a id="dod"></a>

Critérios utilizados para verificar se uma história foi desenvolvida, testada e validada de acordo com o que foi definido.

| Critério | Descrição |
| :-- | :-- |
| Critérios de aceitação atendidos | Todos os cenários definidos para a história foram implementados e verificados. |
| Regras de negócio conferidas | O comportamento da funcionalidade foi validado com exemplos de entrada, saída e exceções previstas. |
| Testes automatizados | Cada regra de cálculo e cada permissão por perfil tem teste automatizado, e as suítes do backend, da Lana e do front passam. |
| Permissões validadas no backend | Toda restrição de perfil é aplicada pela API (resposta 403), e não apenas escondida na tela. |
| Rastro registrado | Ações novas que mudam dados ou decisões ficam registradas com autor e data, e aparecem para o Auditor. |
| Código revisado | A implementação passou por revisão de código realizada por outro integrante da equipe. |
| Funcionalidade integrada | A funcionalidade foi integrada à `develop` e testada dentro do fluxo correspondente. |
| Documentação atualizada | Manual do Usuário, Manual de Instalação e contrato entre front, backend e Lana foram atualizados quando impactados. |
| Validação funcional pelo PO | O Product Owner verificou a funcionalidade e confirmou que a história atende ao que foi definido. |

## 🏗️ Entregas técnicas por frente <a id="entregas"></a>

### Backend (Spring Boot, PostgreSQL, Flyway)
- Perfil `AUDITOR` no cadastro de usuários, nas regras de acesso e no seed da demo (US 19).
- Rotas de leitura para o Auditor e 403 em todas as rotas de escrita (US 19).
- SQL e código gerados devolvidos só para Supervisor e Auditor (T2).
- Alertas técnicos: tabela, rotas de abrir e resolver, e trava na decisão da versão (US 20).
- Intercorrências com o mesmo fluxo de aprovação da correção da base (US 22).
- Campanhas por período e eventos de ação gravados na conversa (US 16 e 23).

### Frontend (Vue 3, Vite, Pinia)
- Tela "Auditoria" com abas de negócio (versões, decisões, conversa) e técnica (SQL, código, alertas) (US 19 e 20).
- Tela de intercorrências e correções da base (US 22).
- Abas realizadas, em andamento e previstas em "Campanhas" (US 16).
- Barra acima do chat com nome e compartilhar, e eventos na conversa (US 23).
- Navegação e tela inicial por perfil, item ativo pela rota e "Novo chat" limpo (US 24).

### Lana (Python, FastAPI, gRPC, LangGraph)
- Consultas bloqueadas pela checagem de SQL gravadas na trilha, com o motivo (US 20).
- Análise do código Python gerado antes de executar (US 20).
- Apuração com as regras 5a a 5g e as intercorrências, com o detalhamento por pessoa (US 21).
- Ferramenta de simulação dividida em partes menores (T4).
- Spike de RAG: banco vetorial, limiar e fallback (T1).

### Documentação
- Manual de Instalação, Manual do Usuário (com o perfil Auditor) e vídeo tutorial final (T7).
- Contrato entre front, backend e Lana atualizado com o Auditor e os alertas.

## ⚠️ Riscos e dependências <a id="riscos"></a>

| Risco | Impacto | Como tratar |
| :-- | :-- | :-- |
| A apuração completa (21) é a história mais pesada e depende de dados de intercorrência | Atraso na meta | Começar pelas regras com exemplo da especificação; intercorrências registradas pela tela (22) entram depois |
| Alertas demais travam a aprovação na demo | Demo emperrada | Só bloqueios reais e código suspeito abrem alerta; o Auditor resolve com justificativa |
| Status do sandbox (A6-85) incerto | Risco de segurança e de pergunta na review | Confirmar no início da sprint (T3) |
| O spike de RAG cresce além do prazo | Tira capacidade das Must | Prazo fixo de 3 dias; a história 25 só entra se o spike aprovar |
| Última sprint, com manuais e vídeo na mesma janela | Falta de tempo no fim | Capacidade de 40 pontos, abaixo do total Must + Should (57) |

## 📚 Documentação do projeto <a id="docs"></a>

| Documento | Onde |
| :-- | :-- |
| Manual de Instalação | [docs/guias/manual-instalacao.md](../../guias/manual-instalacao.md) |
| Manual do Usuário | [docs/guias/manual-usuario.md](../../guias/manual-usuario.md) |
| Contrato entre front, backend e Lana | [docs/contratos-sprint-2.md](../../contratos-sprint-2.md) |
| Backlog do produto e da sprint, MoSCoW | [backlog.md](backlog.md) |
| Critérios de aceitação (Gherkin) | [gherkin.md](gherkin.md) |
| Sprints anteriores | [Sprint 1](../sprint-1/README.md) · [Sprint 2](../sprint-2/README.md) |

## 🏅 Sprint Burndown <a id="burndown"></a>

<!-- Inserir o gráfico de burndown da Sprint 3 ao fim da sprint -->

*A preencher ao fim da sprint: gráfico, período e pontos entregues.*

## 🎥 Demonstração <a id="demo"></a>

### • SPRINT 3

*A preencher com o vídeo da demonstração final.*

## 📋 Protótipo da Aplicação <a id="prototipo"></a>

*A preencher com as telas novas da Sprint 3: Auditoria (negócio e técnica), alertas, intercorrências e campanhas por período.*
