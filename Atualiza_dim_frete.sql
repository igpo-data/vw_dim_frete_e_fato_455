CREATE OR REPLACE PROCEDURE public.atualizar_dim_frete (IN qtddias integer) LANGUAGE plpgsql AS $procedure$
declare
  c_01 cursor (p_data date) for
    select "Serie/Numero CTRC"
        ,"Data de Autorizacao"
        ,"Data de Emissao"
        ,max("Data Atualização") as data_atualizacao
      from ssw_op455
      where "Data de Emissao" = p_data
      group by "Serie/Numero CTRC"
        ,"Data de Autorizacao"
        ,"Data de Emissao";
  c_02 cursor (p_serie varchar, p_autorizacao date, p_emissao date) for
    select ssw."Serie/Numero CTRC",
        ssw."Data de Autorizacao",
        ssw."Data de Emissao",
        ssw."Login",
        ssw."Placa de Coleta",
        ssw."Tipo de Baixa",
        ssw."Tipo do Documento",
        ssw."Tipo do Frete",
        ssw."Tipo de Calculo",
        ssw."Unidade Emissora",
        ssw."Unidade Receptora",
        ssw."Praca Comercial Origem",
        ssw."Praca Comercial Destino",
        ssw."Cidade de Entrega",
        ssw."UF de Entrega",
        ssw."CNPJ Remetente",
        ssw."Cliente Remetente",
        cast(split_part(ssw."Mercadoria", '-', 1) as numeric) as cod_mercadoria,
        split_part(ssw."Mercadoria", '-', 2) as descricao_mercadoria,
        case
          when left(ssw."Tipo do Documento", 6) = 'SUBC E' then 'T'
          when left(ssw."Tipo do Documento", 6) = 'SUBC R' then 'T'
          when ssw."CNPJ Remetente" = ssw."CNPJ Pagador" and ssw."CNPJ Remetente" = ssw."CNPJ Destinatario" then left(ssw."Tipo do Frete", 1)
          when ssw."CNPJ Pagador" = ssw."CNPJ Remetente" then 'C'
          when ssw."CNPJ Pagador" = ssw."CNPJ Destinatario" then 'F'
          else 'T'
        end as tipo_c_f_t,
        case
          when ssw."Unidade Emissora" = 'CAB' then 'CGB'
          when ssw."Unidade Emissora" = 'VIX' then 'RIO'
          when ssw."Unidade Emissora" = 'RJ1' then 'RIO'
          when ssw."Unidade Emissora" = 'RON' then 'ROO'
          when ssw."Unidade Emissora" = 'CAS' then 'CVL'
          when ssw."Unidade Emissora" = 'JIP' AND LEFT(CAST(ssw."CNPJ Pagador" AS TEXT), 8) = '10989834' AND ssw."Data de Autorizacao" >= DATE '2023-08-01' THEN 'CBA' -- Alterado Ivo 26.09.24
          else ssw."Unidade Emissora"
        end as und_expedida,
        split_part(ssw."Tipo de Calculo", '-', 2) as assistente,
        case
          when ssw."Unidade Receptora" = 'CAB' then 'CGB'
          when ssw."Unidade Receptora" = 'PXT' then 'PEX'
          when ssw."Unidade Receptora" = 'RON' then 'ROO'
          when ssw."Unidade Receptora" = 'RJ1' then 'RIO'
          when ssw."Unidade Receptora" = 'VIX' then 'RIO'
          else ssw."Unidade Receptora"
        end as unid_repectora,
        case
          when left(regexp_replace(ssw."CNPJ Pagador"::text, '[^0-9]', '', 'g'), 8) = '51172680' then 'TABELADO'
          when cast(split_part(ssw."Mercadoria", '-', 1) AS NUMERIC) IN (323, 324, 321, 333, 350) then 'TABELADO'
          when ssw."Unidade Emissora" = 'MLV' then 'MERCADO LIVRE'
          when ssw."Unidade Emissora" = 'AMZ' then 'AMAZON'
          when ssw."Unidade Emissora" = 'NAT' then 'NATURA'
          when ssw."Unidade Emissora" = 'AVO' then 'AVON' --Inlcusao dia 26.04.24 feita pelo Ivo.
          when ssw."Unidade Emissora" = 'EXT' then 'PRIVALIA' --Inlcusao dia 26.04.24 feita pelo Ivo.
          when ssw."Unidade Emissora" = 'ECO' then 'DAFITI' --Inlcusao dia 26.04.24 feita pelo Ivo.
          when ssw."Tipo de Calculo" = 'PROMOCIONAL' then 'PROMOCIONAL'
          when ssw."Tipo de Calculo" = 'SUBSTITUICAO' then 'INFORMADO' --alterado por Ivo 04.07.24 solicitado pela Lidi.
          when ssw."Tipo de Calculo" = 'INFORMADO' then 'INFORMADO'
          when ssw."Tipo de Calculo" = 'GENERICA' then 'GENERICA'
          when ssw."Tipo de Calculo" = 'ANULACAO' then 'ANULAÇÃO'
          when ssw."Tipo de Calculo" = 'COMPLEMENTAR DE FRETE' then 'COMPLEMENTAR DE FRETE'
          when ssw."Tipo de Calculo" = 'DEVOLUCAO' then 'DEVOLUÇÃO'
          when ssw."Tipo de Calculo" = 'REENTREGA' then 'REENTREGA'
          when LEFT(ssw."Tipo de Calculo", 7) = 'COTACAO' then 'COTAÇÃO'
          when ssw."Tipo de Calculo" = 'TARIFA' then 'TABELADO'
          else 'TABELADO'
        end AS tp_calculo_rel_comercial,
        REPLACE(sswcpl."Primeiro Manifesto", ' ', '') AS "Primeiro Manifesto",
        REPLACE(sswcpl."Ultimo Manifesto", ' ', '') AS "Ultimo Manifesto",
        sswcpl."Unidade Destino do Ultimo Manifesto",
        sswcpl."Ultimo Romaneio",
        sswcpl."Codigo da Ultima Ocorrencia",
        sswcpl."Descricao da Ultima Ocorrencia",
        sswcpl."Placa de Entrega",
        sswcpl."Numero da Fatura",
        sswcpl."Tipo de Baixa Fatura",
        sswcpl."Vendedor",
        sswcpl."Unidade Origem do Primeiro Manifesto",
        CASE
            WHEN sswcpl."Unidade Origem do Primeiro Manifesto" = 'TSE' AND so."DEST_MANIF" = 'CNP' OR sswcpl."Unidade Origem do Primeiro Manifesto" = 'SPZ' AND so."DEST_MANIF" = 'CNP' AND ssw."Unidade Receptora" NOT IN ('DIA', 'JAR', 'BRA') OR sswcpl."Unidade Origem do Primeiro Manifesto" IN ('TSE', 'CNP') AND so."DEST_MANIF" IN ('SIN', 'SOL', 'LRV', 'NVT') OR sswcpl."Unidade Origem do Primeiro Manifesto" IN ('SIN', 'SOL', 'LRV', 'NVT') AND so."DEST_MANIF" IN ('CNP', 'TSE') OR sswcpl."Unidade Origem do Primeiro Manifesto" IN ('SIN', 'SOL', 'LRV', 'NVT') AND so."DEST_MANIF" = 'CNP' AND ssw."Unidade Receptora" = 'SPZ' THEN 'Rota Agro'
            WHEN sswcpl."Unidade Origem do Primeiro Manifesto" in ('ROO', 'PVL') AND "DEST_MANIF" in ('PVL', 'BGA', 'NXV', 'BOA') THEN 'OrigenROO'
            WHEN sswcpl."Unidade Origem do Primeiro Manifesto" in ('PVL', 'BGA', 'NXV', 'BOA') AND "DEST_MANIF" in ('ROO', 'PVL') THEN 'RetornoROO'
        END AS operacao_agro,
        case
            when TO_CHAR (ssw."Data de Autorizacao" , 'YYYYMM') is null then TO_CHAR (ssw."Data de Emissao", 'YYYYMM')
            else  TO_CHAR (ssw."Data de Autorizacao" , 'YYYYMM')
        end as anomes,
        CASE
           WHEN CAST(SPLIT_PART(ssw."Mercadoria", '-', 1) AS numeric) = 250 AND ssw."Unidade Emissora"  in ( 'LRV','NVT','BBR', 'TSE','CPV','PVL','JAC', 'ROO','NBR','DIA','SOL', 'CAC','MDT'  ) AND ssw."Unidade Receptora"  = 'CGB' THEN 'Operação Cuiabá - Retorno'
           WHEN CAST(SPLIT_PART(ssw."Mercadoria", '-', 1) AS numeric) = 250 AND ssw."Unidade Emissora" = 'CGB' AND ssw."Unidade Receptora"  in ( 'LRV','NVT','BBR', 'TSE','CPV','PVL','JAC', 'ROO','NBR','DIA','SOL', 'CAC','MDT'  ) THEN 'Operação Cuiabá'
           WHEN sswcpl."Unidade Origem do Primeiro Manifesto"  = 'SIN' AND TO_CHAR("HORA_SAIDA_MANIF", 'HH24:MI:SS') BETWEEN '11:00:00' and '13:30:00' THEN 'OrigemSIN'
           WHEN sswcpl."Unidade Origem do Primeiro Manifesto"  = 'LRV' AND TO_CHAR("HORA_SAIDA_MANIF", 'HH24:MI:SS') BETWEEN '13:00:00' and '15:30:00' AND so."DEST_MANIF" = 'NVT' THEN 'OrigemLRV'
           when sswcpl."Unidade Origem do Primeiro Manifesto"  = 'SOL' and  TO_CHAR(so."HORA_SAIDA_MANIF", 'HH24:MI:SS') BETWEEN '12:00:00' and '13:30:00' and so."DEST_MANIF" in ('NVT', 'LRV') THEN 'OrigemSOL'
           WHEN sswcpl."Unidade Origem do Primeiro Manifesto"  = 'LRV' and TO_CHAR("HORA_SAIDA_MANIF", 'HH24:MI:SS') BETWEEN '19:00:00' and '21:30:00' and so."DEST_MANIF"  in ('SOL', 'SIN') then 'RetornoLRV'
           WHEN sswcpl."Unidade Origem do Primeiro Manifesto"  = 'SOL' AND TO_CHAR("HORA_SAIDA_MANIF", 'HH24:MI:SS') BETWEEN '21:00:00' and '23:30:00' AND so."DEST_MANIF"  = 'SIN' THEN 'RetornoSOL'
           WHEN CAST(SPLIT_PART(ssw."Mercadoria", '-', 1) AS numeric) = '250' AND ssw."Unidade Emissora" in('SOL','NVT','LRV') AND ssw."Unidade Receptora" in ( 'SIN','SOL','NVT','LRV') THEN 'Operação Sinop'
           WHEN CAST(SPLIT_PART(ssw."Mercadoria", '-', 1) AS numeric) in ('437' ,'438') THEN 'Operação Confecção'
           WHEN CAST(SPLIT_PART(ssw."Mercadoria", '-', 1) AS numeric) in ('244','245') THEN 'Express'
           when sswcpl."Unidade Origem do Primeiro Manifesto" = 'CGR' AND TO_CHAR("HORA_SAIDA_MANIF", 'HH24:MI:SS') BETWEEN '11:00:00' and '14:00:00' AND so."DEST_MANIF" in ('DRD', 'PPA', 'SGO', 'MCJ', 'SDL') THEN 'OrigemCGR'
           WHEN sswcpl."Unidade Origem do Primeiro Manifesto"  in ('DRD', 'PPA', 'SGO', 'MCJ', 'SDL') AND TO_CHAR("HORA_SAIDA_MANIF", 'HH24:MI:SS') BETWEEN '13:00:00' and '21:00:00' AND so."DEST_MANIF" = 'CGR' THEN 'RetornoCGR'
           when ssw."UF origem da prestacao" = ('MT') and ssw."UF de Entrega" = ('MT') and ssw."Unidade Emissora" not in ('CGB', 'CBA', 'CAB') and ssw."Unidade Receptora" not in ('CGB', 'CBA', 'CAB') THEN 'Conexao MT'
        END AS op_cvl_hoje,
        so."DIA_SAIDA_MANIF",
        so."EMIS_MANIF",
        x.sk_dim_frete
      from ssw_op455 ssw
        join ssw_op455_complementar AS sswcpl ON (sswcpl."Serie/Numero CTRC" = ssw."Serie/Numero CTRC" AND sswcpl."Data de Emissao" = ssw."Data de Emissao")
        left join public.ssw_op200 so on (replace (trim(sswcpl."Primeiro Manifesto"),' ','') = so."NUM_MANIF" and so."NUM_MANIF" is not null)
        left join dim_frete x on (x."Serie/Numero CTRC" = ssw."Serie/Numero CTRC" and x."Data de Autorizacao" = ssw."Data de Autorizacao" and x."Data de Emissao" = ssw."Data de Emissao")
      where ssw."Serie/Numero CTRC" = p_serie
        and ssw."Data de Autorizacao" = p_autorizacao
        and ssw."Data de Emissao" = p_emissao;
  r_01 record;
  r_02 record;
  v_inicio date;
  v_termino date;
begin
  v_termino := current_date;
  v_inicio := v_termino - (qtddias::varchar || ' days')::interval;

  while (v_inicio <= v_termino) loop
    for r_01 in c_01 (v_inicio) loop
      for r_02 in c_02 (r_01."Serie/Numero CTRC", r_01."Data de Autorizacao", r_01."Data de Emissao") loop
        if r_02.sk_dim_frete is null then
          insert into public.dim_frete ("Serie/Numero CTRC", "Data de Autorizacao", "Data de Emissao", "Login", "Placa de Coleta", "Tipo de Baixa", "Tipo do Documento", "Tipo do Frete", "Tipo de Calculo", "Unidade Emissora", "Unidade Receptora", "Praca Comercial Origem", "Praca Comercial Destino", "Cidade de Entrega", "UF de Entrega", "CNPJ Remetente", "Cliente Remetente", cod_mercadoria, descricao_mercadoria, tipo_c_f_t, und_expedida, assistente, unid_repectora, tp_calculo_rel_comercial, "Primeiro Manifesto", "Ultimo Manifesto", "Unidade Destino do Ultimo Manifesto", "Ultimo Romaneio", "Codigo da Ultima Ocorrencia", "Descricao da Ultima Ocorrencia", "Placa de Entrega", "Numero da Fatura", "Tipo de Baixa Fatura", "Vendedor", "Unidade Origem do Primeiro Manifesto", operacao_agro, anomes, op_cvl_hoje, data_saida_manifesto, data_emissao_manifesto)
            values (r_02."Serie/Numero CTRC", r_02."Data de Autorizacao", r_02."Data de Emissao", r_02."Login", r_02."Placa de Coleta", r_02."Tipo de Baixa", r_02."Tipo do Documento", r_02."Tipo do Frete", r_02."Tipo de Calculo", r_02."Unidade Emissora", r_02."Unidade Receptora", r_02."Praca Comercial Origem", r_02."Praca Comercial Destino", r_02."Cidade de Entrega", r_02."UF de Entrega", r_02."CNPJ Remetente", r_02."Cliente Remetente", r_02.cod_mercadoria, r_02.descricao_mercadoria, r_02.tipo_c_f_t, r_02.und_expedida, r_02.assistente, r_02.unid_repectora, r_02.tp_calculo_rel_comercial, r_02."Primeiro Manifesto", r_02."Ultimo Manifesto", r_02."Unidade Destino do Ultimo Manifesto", r_02."Ultimo Romaneio", r_02."Codigo da Ultima Ocorrencia", r_02."Descricao da Ultima Ocorrencia", r_02."Placa de Entrega", r_02."Numero da Fatura", r_02."Tipo de Baixa Fatura", r_02."Vendedor", r_02."Unidade Origem do Primeiro Manifesto", r_02.operacao_agro, r_02.anomes, r_02.op_cvl_hoje, r_02."DIA_SAIDA_MANIF", r_02."EMIS_MANIF");
        else
          update public.dim_frete
              set "Login" = r_02."Login"
                ,"Placa de Coleta" = r_02."Placa de Coleta"
                ,"Tipo de Baixa" = r_02."Tipo de Baixa"
                ,"Tipo do Documento" = r_02."Tipo do Documento"
                ,"Tipo do Frete" = r_02."Tipo do Frete"
                ,"Tipo de Calculo" = r_02."Tipo de Calculo"
                ,"Unidade Emissora" = r_02."Unidade Emissora"
                ,"Unidade Receptora" = r_02."Unidade Receptora"
                ,"Praca Comercial Origem" = r_02."Praca Comercial Origem"
                ,"Praca Comercial Destino" = r_02."Praca Comercial Destino"
                ,"Cidade de Entrega" = r_02."Cidade de Entrega"
                ,"UF de Entrega" = r_02."UF de Entrega"
                ,"CNPJ Remetente" = r_02."CNPJ Remetente"
                ,"Cliente Remetente" = r_02."Cliente Remetente"
                ,cod_mercadoria = r_02.cod_mercadoria
                ,descricao_mercadoria = r_02.descricao_mercadoria
                ,tipo_c_f_t = r_02.tipo_c_f_t
                ,und_expedida = r_02.und_expedida
                ,assistente = r_02.assistente
                ,unid_repectora = r_02.unid_repectora
                ,tp_calculo_rel_comercial = r_02.tp_calculo_rel_comercial
                ,"Primeiro Manifesto" = r_02."Primeiro Manifesto"
                ,"Ultimo Manifesto" = r_02."Ultimo Manifesto"
                ,"Unidade Destino do Ultimo Manifesto" = r_02."Unidade Destino do Ultimo Manifesto"
                ,"Ultimo Romaneio" = r_02."Ultimo Romaneio"
                ,"Codigo da Ultima Ocorrencia" = r_02."Codigo da Ultima Ocorrencia"
                ,"Descricao da Ultima Ocorrencia" = r_02."Descricao da Ultima Ocorrencia"
                ,"Placa de Entrega" = r_02."Placa de Entrega"
                ,"Numero da Fatura" = r_02."Numero da Fatura"
                ,"Tipo de Baixa Fatura" = r_02."Tipo de Baixa Fatura"
                ,"Vendedor" = r_02."Vendedor"
                ,"Unidade Origem do Primeiro Manifesto" = r_02."Unidade Origem do Primeiro Manifesto"
                ,operacao_agro = r_02.operacao_agro
                ,anomes = r_02.anomes
                ,op_cvl_hoje = r_02.op_cvl_hoje
                ,data_saida_manifesto = r_02."DIA_SAIDA_MANIF"
                ,data_emissao_manifesto = r_02."EMIS_MANIF"
              where sk_dim_frete = r_02.sk_dim_frete;
        end if;
      end loop;
    end loop;

    v_inicio := v_inicio + '1 days'::interval;
    commit;
  end loop;
end;
$procedure$