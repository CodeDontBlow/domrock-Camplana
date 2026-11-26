-- Seed de solicitações de alteração e intercorrências para demonstração da Sprint 3.
-- Idempotente: limpa apenas os registros com chat_id LIKE 'demo-chat-solicitacao-%'.
-- Sem BEGIN/COMMIT no arquivo: o start-demo.sh executa com psql -v ON_ERROR_STOP=1 --single-transaction.

DELETE FROM solicitacao_alteracao WHERE chat_id LIKE 'demo-chat-solicitacao-%';
DELETE FROM mensagem_chat WHERE chat_id LIKE 'demo-chat-solicitacao-%';

DO $body$
DECLARE
  v_gabriela_id INT;
  v_sergio_id   INT;
BEGIN
  SELECT id INTO v_gabriela_id FROM usuario WHERE email = 'gabriela@camplana.com.br';
  SELECT id INTO v_sergio_id   FROM usuario WHERE email = 'sergio@camplana.com.br';

  IF v_gabriela_id IS NULL OR v_sergio_id IS NULL THEN
    RAISE EXCEPTION 'Usuários gabriela@camplana.com.br ou sergio@camplana.com.br não encontrados';
  END IF;

  --------------------------------------------------------------------------
  -- 1. PENDENTE, origem LANA, TRANSFERENCIA_LOJA, MATRIC-33, 2025-10
  -- Gabriela pediu a transferência da loja 76 para a loja 75.
  --------------------------------------------------------------------------
  INSERT INTO mensagem_chat (chat_id, usuario_id, papel, tipo, simulacao_id, texto, ficha, trilha, criada_em)
  VALUES ('demo-chat-solicitacao-transf', v_gabriela_id, 'usuario', NULL, NULL,
          'A funcionária MATRIC-33 foi transferida da loja 76 para a loja 75 em outubro de 2025; foi transferência a pedido da regional.',
          NULL, NULL, '2026-10-25 14:30:00+00');

  INSERT INTO mensagem_chat (chat_id, usuario_id, papel, tipo, simulacao_id, texto, ficha, trilha, criada_em)
  VALUES ('demo-chat-solicitacao-transf', v_gabriela_id, 'lana', NULL, NULL,
          'Localizei o cadastro da MATRIC-33 na loja 76 na competência 10/2025. Preparei o cartão de transferência de loja para a loja 75. Confira os dados e clique em Confirmar para registrar a solicitação.',
          NULL, NULL, '2026-10-25 14:30:05+00');

  INSERT INTO solicitacao_alteracao (
    tipo, matricula, competencia, valor_antes, valor_depois, motivo, autor_id, origem, chat_id, status, criada_em
  ) VALUES (
    'TRANSFERENCIA_LOJA',
    'MATRIC-33',
    '2025-10-01',
    '"76"'::jsonb,
    '"75"'::jsonb,
    'Transferida para a loja 75 em outubro',
    v_gabriela_id,
    'LANA',
    'demo-chat-solicitacao-transf',
    'PENDENTE',
    '2026-10-25 14:30:10'
  );

  --------------------------------------------------------------------------
  -- 2. PENDENTE, origem LANA, AFASTAMENTO, MATRIC-10, 2025-12
  -- Gabriela pediu o afastamento por atestado médico de 5 dias.
  --------------------------------------------------------------------------
  INSERT INTO mensagem_chat (chat_id, usuario_id, papel, tipo, simulacao_id, texto, ficha, trilha, criada_em)
  VALUES ('demo-chat-solicitacao-afast', v_gabriela_id, 'usuario', NULL, NULL,
          'A MATRIC-10 apresentou atestado médico de 5 dias, com afastamento de 08/12/2025 a 12/12/2025.',
          NULL, NULL, '2026-10-25 15:00:00+00');

  INSERT INTO mensagem_chat (chat_id, usuario_id, papel, tipo, simulacao_id, texto, ficha, trilha, criada_em)
  VALUES ('demo-chat-solicitacao-afast', v_gabriela_id, 'lana', NULL, NULL,
          'Entendido. Registrei o cartão da intercorrência de afastamento médico de 08/12/2025 a 12/12/2025 para a colaboradora MATRIC-10. Por favor, confira e confirme para submeter à supervisão.',
          NULL, NULL, '2026-10-25 15:00:05+00');

  INSERT INTO solicitacao_alteracao (
    tipo, matricula, competencia, valor_antes, valor_depois, motivo, autor_id, origem, chat_id, status, criada_em
  ) VALUES (
    'AFASTAMENTO',
    'MATRIC-10',
    '2025-12-01',
    'null'::jsonb,
    '{"data_inicio": "2025-12-08", "data_fim": "2025-12-12", "cod_loja": null}'::jsonb,
    'Atestado médico de 5 dias',
    v_gabriela_id,
    'LANA',
    'demo-chat-solicitacao-afast',
    'PENDENTE',
    '2026-10-25 15:00:10'
  );

  --------------------------------------------------------------------------
  -- 3. REPROVADA por Sérgio, origem USUARIO, TROCA_CARGO, MATRIC-101, 2025-10
  -- Gabriela abriu pelo painel troca de 200 (VENDEDOR BALCAO) para 100 (VENDEDOR LOJA)
  -- Sérgio reprovou com justificativa.
  --------------------------------------------------------------------------
  INSERT INTO solicitacao_alteracao (
    tipo, matricula, competencia, valor_antes, valor_depois, motivo, autor_id, origem, chat_id, status, decisor_id, decidida_em, justificativa, criada_em
  ) VALUES (
    'TROCA_CARGO',
    'MATRIC-101',
    '2025-10-01',
    '"200"'::jsonb,
    '"100"'::jsonb,
    'Promoção para Vendedor Loja',
    v_gabriela_id,
    'USUARIO',
    'demo-chat-solicitacao-cargo',
    'REPROVADA',
    v_sergio_id,
    '2026-10-25 16:30:00',
    'O cargo novo não vale para outubro; abra para novembro.',
    '2026-10-25 16:00:00'
  );

END $body$;
