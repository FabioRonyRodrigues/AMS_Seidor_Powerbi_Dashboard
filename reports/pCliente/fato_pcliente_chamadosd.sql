    /*
    Finalidade: Esta query tem como finalidade trazer a lista de cabeçalho de chamados e também atua como tabela central
    Responsável: Ezio Abilio
    Data Manutenção: 28/03/2025

    -------
    Documentação

    - UPPER(sd.TipoProjeto) IN ('AMS', 'FAST TRACK', 'INTERNO','MANUTENÇÃO PRODUTO') < Limitar tipo de projeto para os informados;

    - and sd.DataAbertura >= 
        (select min(x.DataAbertura) from prd.stg_chamado_sd x
        WHERE UPPER(x.TipoProjeto) IN ('AMS', 'FAST TRACK', 'INTERNO','MANUTENÇÃO PRODUTO')) > Esta condição limita o escopo de data para limitar a quantidade 
        de chamados a serem lidos.

    - sd.Cliente not like '%Seidor%' > Limitando trazer somente chamados que não sejam cliente seidor.
    - Os cases são auto intuítivos.
    */


SELECT 
       sd.Id,
	sd.exid,
	trim(upper(sd.Descricao)) Descricao,
	trim(upper(sd.Tipo)) Tipo,
	trim(upper(sd.Modulo)) Modulo,
	trim(upper(sd.Usuario)) Usuario,
	trim(upper(sd.sigla)) Sigla,
	sd.DataAbertura,
	CASE 
        WHEN 
            sd.DataEncerramento IS NULL then sd.DataAtualizacao
                else sd.DataEncerramento
    end DataEncerramento,
	trim(upper(sd.Status)) Status,
	trim(upper(sd.Situacao)) Situacao,
	CASE
		WHEN
			sd.Atendente is null then 'Aguardando atendimento'
			else trim(upper(sd.atendente))
	end Atendente,
	trim(upper(sd.AtendentePrivativo)) AtendentePrivativo,
	trim(upper(sd.Cliente)) Cliente,
	trim(upper(sd.Prioridade)) Prioridade,
	sd.DataAtualizacao,
	sd.DataAtualizacaoPrivativo,
	trim(upper(sd.ResponsavelAtualizacao)) ResponsavelAtualizacao,
	sd.HorasGastas,
	trim(upper(sd.TipoProjeto)) TipoProjeto,
	sd.OI,
	sd.Baseline,
	trim(upper(sd.Empresa)) Empresa,
	trim(upper(sd.EmpresaAtendente)) EmpresaAtendente,
	trim(upper(sd.EmpresaAtendentePrivativo)) EmpresaAtendentePrivativo,
	sd.Iteracoes,
    sd.`GrupoProblema - Segmento` ,
	sd.SGRT_PROJETO_id,
	sd.idCliente,
	-- Correção de nome de alguns gestores, incluindo caracteres especiais.
    CASE
        WHEN SD.GESTOR = 'MARCELA LUANA DE OLIVEIRA' THEN '(DESLIGADO) MARCELA LUANA DE OLIVEIRA'
        WHEN SD.GESTOR = 'LUCIANE MARINHO PEREIRA' THEN '(DESLIGADO) LUCIANE MARINHO PEREIRA'
        WHEN SD.GESTOR = 'FABIO CAMPOS LIMA' THEN '(DESLIGADO) FABIO CAMPOS LIMA'
        WHEN SD.GESTOR = 'FABIO DE CARVALHO COTRIM' THEN '(DESLIGADO) FABIO DE CARVALHO COTRIM'
        WHEN SD.GESTOR = 'EDUARDO MARINHO DE MELLO' THEN '(DESLIGADO) EDUARDO MARINHO DE MELLO'
        WHEN SD.GESTOR = 'LUIS GUILHERME MACHADO CAMARGO' THEN '(DESLIGADO) LUIS GUILHERME MACHADO CAMARGO'
        WHEN SD.GESTOR = 'SERGIO MARTINS' THEN '(DESLIGADO) SERGIO MARTINS'
        WHEN SD.GESTOR = 'ALEX JORDAO DE OLIVEIRA' THEN 'ALEX JORDÃO DE OLIVEIRA (BH)'
        WHEN SD.GESTOR = 'ERICO AUGUSTO PERES CHICONELI' THEN 'ÉRICO AUGUSTO PERES CHICONELI'
        WHEN SD.GESTOR = 'GIOVANA PINHEIRO DE MORAES SILVA' THEN 'GIOVANA PINHEIRO DE MORAES DA SILVA'
        WHEN SD.GESTOR = 'HELIO AUGUSTO POSSEBON' THEN 'HÉLIO AUGUSTO POSSEBON'
        WHEN SD.GESTOR = 'LUCIA KAZUKO SHIMABUKURO' THEN 'LÚCIA KAZUKO SHIMABUKURO'
        WHEN SD.GESTOR = 'MARCUS VINICIUS MAGALHAES DE CAMPOS' THEN 'MARCUS VINICIUS MAGALHÃES DE CAMPOS'
        WHEN SD.GESTOR = 'RAFAEL VINICIUS DO CARMO DE OLIVEIRA' THEN 'RAFAEL VINÍCIUS DO CARMO DE OLIVEIRA'
        WHEN SD.GESTOR = 'RENATO RELLO PENNA' THEN 'RENATO RÊLLO PENNA'
        WHEN SD.GESTOR = 'SALOMAO ALVES LOPES' THEN 'SALOMÃO ALVES LOPES'
        ELSE UPPER(TRIM(SD.GESTOR))
    END AS Gestor,
    -- Trazendo a informação se está ou não em atraso.
	CASE 
	    WHEN DATEDIFF(CURDATE(), SD.DATAATUALIZACAO) <= 3 
	         AND SD.STATUS NOT IN ('AGUARDANDO APROVAÇÃO ESCOPO/ESTIMATIVA', 'JÁ EM PRD - EM MONITORAMENTO') 
	    THEN 'EM TEMPO'
	    ELSE 'EM ATRASO'
	END AS 'EM ATRASO',
	-- Informação pra trazer se está com o cliente ou a seidor.
    CASE
        WHEN SD.STATUS IN (
            'AGUARDANDO RETORNO SOLICITANTE',
            'DISPONÍVEL PARA TESTES DO SOLICITANTE',
            'PLANEJADO',
            'AGUARDANDO APROVAÇÃO ESCOPO/ESTIMATIVA',
            'JÁ EM PRD - EM MONITORAMENTO',
            'APROVADO PARA TRANSPORTE EM PRD',
            'AGUARDANDO AÇÃO DO CLIENTE',
            'PARALISADO',
            'SOLUÇÃO PROPOSTA'
        ) THEN 'CLIENTE'
        ELSE
            CASE 
                WHEN SD.STATUS IN (
                    'ENCAMINHADO PARA TERCEIRA PARTE',
                    'ANULADO',
                    'REPROVADO'
                ) THEN 'PARADO'
                ELSE 'SEIDOR'
            END
    END AS 'SEIDOR/CLIENTE',
    ## Definição de status pra Solucionado, em aceitação ou 'Outros'
    CASE
        WHEN SD.STATUS IN (
            'ENCAMINHADO PARA ENCERRAMENTO PELO ATENDENTE',
            'ENCAMINHADO PARA ENCERRAMENTO PELO SOLICITANTE',
            'ENCERRADO COM SATISFAÇÃO VERIFICADA',
            'FINALIZADO'
        ) THEN 'SOLUCIONADO'
        ELSE
            CASE 
                WHEN SD.STATUS IN (
                    'JÁ EM PRD - EM MONITORAMENTO',
                    'DISPONÍVEL PARA TESTES DO SOLICITANTE',
                    'APROVADO PARA TRANSPORTE EM PRD'
                ) THEN 'EM ACEITAÇÃO PELO CLIENTE'
                ELSE 'OUTROS'
            END
    END AS 'STATUS_FINAL',
	CASE
 		WHEN  
 			sd.Status IN ('Encaminhado para encerramento pelo atendente', 'Encaminhado para encerramento pelo solicitante', 'Finalizado')
 			AND YEAR(sd.DataEncerramento) = YEAR(sd.DataAbertura)
 			AND MONTH(sd.DataEncerramento) = MONTH(sd.DataAbertura)
 		THEN 'Aderente'
 		ELSE 'Não aderente'
 	END AS `Aderência`
FROM prd.stg_chamado_sd sd
WHERE 
sd.Cliente not like '%Seidor%'
and UPPER(sd.TipoProjeto) IN ('AMS', 'FAST TRACK', 'INTERNO','MANUTENÇÃO PRODUTO')
and sd.DataAbertura >= 
(select min(x.DataAbertura) from prd.stg_chamado_sd x
WHERE UPPER(x.TipoProjeto) IN ('AMS', 'FAST TRACK', 'INTERNO','MANUTENÇÃO PRODUTO'))