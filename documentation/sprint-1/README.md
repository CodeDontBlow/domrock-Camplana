# API 6º Semestre ADS — CAMPLANA AI

## Documentação — Sprint 1

## Desafio <a id="desafio"></a>
Chat inteligente voltado à interação com regras de negócio, permitindo sua identificação e interpretação para simulação.

## Backlog da Sprint

<a id="backlog"></a>

| Rank | Prioridade | User Story | Estimativa | Sprint |
| :--: | :--------: | :--- | :--------: | :-----: |
| 1 | Alta | Como Gerente de Vendas, quero falar uma regra em linguagem natural para o sistema interpretar e iniciar uma simulação da regra de negócio. | 20 | 1 |
| 2 | Alta | Como Gerente de Vendas, quero que o agente identifique parâmetros que faltaram no comando inicial para avisar e solicitar os valores, sem assumir valores padrão ou seguir com informações faltando. | 8 | 1 |
| 3 | Alta | Como Gerente de Vendas, quero editar os parâmetros antes de iniciar a simulação para consertar quaisquer erros ou informações que faltaram. | 8 | 2 |
| 4 | Alta | Como Gerente de Vendas, quero rodar a simulação da regra com diferentes cenários de meta para ver o impacto financeiro projetado antes de enviar para aprovação. | 13 | 2 |

## 🏅 DoR — Definition of Ready <a id="dor"></a>

Critérios utilizados para verificar se uma história está suficientemente preparada para entrar em desenvolvimento.

| Critério                       | Descrição                                                                                                                          |
| :----------------------------- | :--------------------------------------------------------------------------------------------------------------------------------- |
| Clareza da descrição           | A User Story apresenta de forma clara a pessoa usuária, a ação desejada e o objetivo a ser alcançado.                              |
| Critérios de aceitação         | A história possui critérios objetivos que definem as condições necessárias para sua conclusão.                                     |
| Cenários de teste              | A história possui pelo menos um cenário de teste estruturado em Dado, Quando e Então.                                              |
| Referência visual              | O protótipo ou material visual necessário para a implementação está disponível, quando aplicável.                                  |
| Escopo técnico definido        | Está especificado se a história envolve frontend, backend, IA ou integração entre esses componentes.                               |
| Regras de negócio definidas    | As regras de comissionamento, entradas, resultados esperados e possíveis exceções estão descritas e compreendidas.                 |
| Estimativa definida            | A história possui uma estimativa de esforço definida e discutida pela equipe.                                                      |


## 🏅 DoD — Definition of Done <a id="dod"></a>

Critérios utilizados para verificar se uma história foi desenvolvida, testada e validada de acordo com o que foi definido. 

| Critério                         | Descrição                                                                                                  |
| :------------------------------- | :--------------------------------------------------------------------------------------------------------- |
| Critérios de aceitação atendidos | Todos os critérios definidos para a história foram implementados e verificados.                            |
| Regras de negócio conferidas     | O comportamento da funcionalidade foi validado com exemplos de entrada, saída e exceções previstas.        |
| Código revisado                  | A implementação passou por revisão de código realizada por outro integrante da equipe.                     |
| Funcionalidade integrada         | A funcionalidade foi integrada à aplicação e testada dentro do fluxo correspondente.                       |
| Documentação atualizada          | As documentações, regras e instruções impactadas pela implementação foram atualizadas.                     |
| Validação funcional pelo PO      | O Product Owner verificou a funcionalidade e confirmou que a história atende ao que foi definido.          |
