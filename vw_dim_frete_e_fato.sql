CREATE OR REPLACE VIEW "public"."vw_dim_frete_e_fato_455" AS
SELECT
  d.sk_dim_frete,
  d."Serie/Numero CTRC",
  d."Data de Autorizacao",
  d.tipo_c_f_t,
  d."Tipo do Documento",
  d."Tipo de Baixa",
  d."Codigo da Ultima Ocorrencia",
  d.tp_calculo_rel_comercial,
  d.cod_mercadoria,
  d.descricao_mercadoria,
  d.und_expedida,
  d.unid_repectora,
  d."Unidade Emissora",
  d."Unidade Receptora",
  d.operacao_agro,
  d.op_cvl_hoje,
  d."Vendedor",
  d."Tipo de Calculo",
  f.qtd_volumes,
  f.vlr_mercadoria,
  f.vlr_frete2,
  f."Frete Peso",
  f."Frete Valor",
  f."Valor do Frete sem ICMS",
  f."Base de Calculo",
  f."Valor do ICMS",
  f."Pedagio",
  f."TDE",
  f.sk_tempo_autorizacao,
  p."Peso Calculado em Kg",
  p."Valor do Frete",
  p."CNPJ Pagador" AS cnpj_pagador,
  p."Cliente Pagador" AS cliente_pagador,
  p."CNPJ Expedidor" AS cnpj_expedidor,
  p."Cliente Expedidor" AS cliente_expedidor,
  p."CNPJ Destinatario" AS cnpj_dest,
  p."Cliente Destinatario" AS cliente_dest,
  p."Cidade do Remetente",
  p."UF do Remetente",
  p."Cidade do Destinatario",
  p."UF do Destinatario",
  p."Cidade origem da prestacao",
  p."UF origem da prestacao",
  f."Valor do ICMS origem",
  f."Valor da Comissao de Expedicao",
  f."Rel de Comissao de Expedicao",
  f."Valor da Comissao Exp Creditada",
  f."Valor da Comissao de Recepcao",
  f."Rel de Comissao de Recepcao",
  f."Valor da Comissao Rec Creditada",
  d."Login",
  d."Placa de Coleta",
  d."Cidade de Entrega",
  d."UF de Entrega",
  d."CNPJ Remetente",
  d."Cliente Remetente",
  CASE
    WHEN d."Codigo da Ultima Ocorrencia" = ANY (ARRAY[83::numeric, 87::numeric, 97::numeric]) THEN 0
    WHEN d."Tipo de Baixa" = ANY (ARRAY['LIQU OCOR'::text, 'CANCELADO'::text]) THEN 0
    WHEN d."Tipo do Documento" = 'ANULACAO'::text THEN 0
    ELSE 1
  END AS flag_frete_valido,
  CASE
    WHEN d."Unidade Emissora" = 'JD1'::text
    AND (
      d."Unidade Receptora" = ANY (
        ARRAY[
          'BGA'::text,
          'BOA'::text,
          'CHS'::text,
          'CNR'::text,
          'QRA'::text,
          'TAQ'::text
        ]
      )
    ) THEN 'Rota Vale'::text
    WHEN (
      d."Unidade Emissora" = 'CGB'::text
      OR d."Unidade Emissora" = 'JD1'::text
    )
    AND (
      d."Unidade Receptora" = ANY (ARRAY['STM'::text, 'ITB'::text])
    ) THEN 'PA-1'::text
    WHEN d."Unidade Emissora" = 'JD1'::text
    AND (
      d."Unidade Receptora" = ANY (
        ARRAY[
          'MAB'::text,
          'RDC'::text,
          'STA'::text,
          'STM'::text
        ]
      )
    ) THEN 'PA-2'::text
    ELSE NULL::text
  END AS rota_john_deere,
  row_number() OVER (
    PARTITION BY
      d."Data de Autorizacao"
    ORDER BY
      d."Serie/Numero CTRC"
  ) AS id_sequencia_ctrc
FROM
  dim_frete d
  LEFT JOIN ft_455 f ON f.sk_dim_frete = d.sk_dim_frete
  LEFT JOIN ssw_op455 p ON p."Serie/Numero CTRC"::text = d."Serie/Numero CTRC"::text
  AND p."Data de Autorizacao" = d."Data de Autorizacao"
  LEFT JOIN dim_cliente c ON c.cliente = p."Cliente Pagador"
  AND c.cnpj = p."CNPJ Pagador"
  LEFT JOIN dim_cliente e ON e.cliente = p."Cliente Expedidor"
  AND e.cnpj = p."CNPJ Expedidor"
  LEFT JOIN dim_cliente r ON r.cliente = p."Cliente Destinatario"
  AND r.cnpj = p."CNPJ Destinatario"
GROUP BY
  d.sk_dim_frete,
  d."Serie/Numero CTRC",
  d."Data de Autorizacao",
  d.tipo_c_f_t,
  d."Tipo do Documento",
  d."Tipo de Baixa",
  d."Codigo da Ultima Ocorrencia",
  d.und_expedida,
  d.unid_repectora,
  d."Unidade Emissora",
  d."Tipo de Calculo",
  d."Unidade Receptora",
  d.operacao_agro,
  d.op_cvl_hoje,
  f.qtd_volumes,
  f.vlr_mercadoria,
  f.vlr_frete2,
  f."Frete Peso",
  f."Frete Valor",
  f."Valor do Frete sem ICMS",
  f."Base de Calculo",
  f."Valor do ICMS",
  f."Pedagio",
  f."TDE",
  f.sk_tempo_autorizacao,
  d.tp_calculo_rel_comercial,
  d.cod_mercadoria,
  d.descricao_mercadoria,
  p."Peso Calculado em Kg",
  p."Valor do Frete",
  p."CNPJ Pagador",
  p."Cliente Pagador",
  p."CNPJ Expedidor",
  p."Cliente Expedidor",
  p."CNPJ Destinatario",
  p."Cliente Destinatario",
  d."Vendedor",
  f."Valor do ICMS origem",
  f."Valor da Comissao de Expedicao",
  f."Rel de Comissao de Expedicao",
  f."Valor da Comissao Exp Creditada",
  f."Valor da Comissao de Recepcao",
  f."Rel de Comissao de Recepcao",
  f."Valor da Comissao Rec Creditada",
  d."Login",
  d."Placa de Coleta",
  d."Cidade de Entrega",
  d."UF de Entrega",
  p."Cidade do Remetente",
  p."UF do Remetente",
  p."Cidade do Destinatario",
  p."UF do Destinatario",
  p."Cidade origem da prestacao",
  p."UF origem da prestacao",
  d."CNPJ Remetente",
  d."Cliente Remetente";