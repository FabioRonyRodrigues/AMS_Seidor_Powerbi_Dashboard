    /*
    Finalidade: Esta query tem como finalidade trazer os valores para calculo de indicadores de SLA.
    Responsável: Ezio Abilio
    Data Manutenção: 28/03/2025

    -------
    Documentação
	- ADENDO IMPORTANTE, MESMO HAVENDO VÁRIOS CALCULOS DE SQL, FOI FEITO UMA MODIFICAÇÃO DIRETA NA TABELA, PARA QUE AS COLUNAS DE % REACAO E % SOLUCAO, SEJAM VARCHAR,
	CASO CONTRARIO ESSAS NÃO VEM COM VALOR DECIMAL. Ao realizar manutenção nesta query é necessário mudar novamente o tipo de dados para varchar nessas colunas.

	- where upper(sse.ProjectTypeName) in ('AMS', 'FAST TRACK', 'INTERNO','MANUTENÇÃO PRODUTO') < Limitar somente chamados para estes tipos de contrato.

	- where 
	sse.ExternalTicketId in (
	select exid from prd.stg_chamado_sd sd
	where UPPER(sd.TipoProjeto) IN ('AMS', 'FAST TRACK', 'INTERNO','MANUTENÇÃO PRODUTO')
	and sd.Cliente not like '%Seidor%')
		Esta condição where, tem finalidade limitar os chamados para trazer somente alguns especificos que apareçam na tabela de cabeçalhos de chamado, 
		Pode ocorrer de um chamado possuir ou não SLA, porém não pode ocorrer de um chamado possuir apontamento e não possuir chamado.
		Também é incluído que deve somente trazer informações de chamado que o cliente seja diferente de seidor, em vista que os chamados cliente "SEIDOR" são internos.

    */ 

select 
	ProjectCode OI,
	TicketId,
	ExternalTicketId,
	SeidorTime,
	CustomerTime,
	PartnerTime,
	SolutionTime,
	ReactionTime,
	SolutionTimePlanned,
	ReactionTimePlanned,
	CASE 
	    WHEN ReactionTimePlanned = 0 or ReactionTime = 0 THEN 0 
	    ELSE round((ReactionTime / ReactionTimePlanned),2)
	END AS `% Reaction`,
	CASE 
	    WHEN SolutionTimePlanned = 0 or SolutionTime = 0 THEN 0 
	    ELSE round((SolutionTime / SolutionTimePlanned),2)
	END AS `% Solution`,
	CASE 
	    WHEN ReactionTimePlanned = 0 THEN 'S/ Planned'
	    WHEN ReactionTime = ReactionTimePlanned THEN 'Conforme'
	    WHEN ReactionTimePlanned < ReactionTime THEN 'Não conforme'
	    ELSE 'S/ Planned'
	END AS `SLA Reaction`,
	CASE 
	    WHEN SolutionTimePlanned = 0 THEN 'S/ Planned'
	    WHEN SolutionTime = SolutionTimePlanned THEN 'Conforme'
	    WHEN SolutionTimePlanned < SolutionTime THEN 'Não conforme'
	    ELSE 'S/ Planned'
	END AS `SLA Solution`,
	case 
		when ReactionTimePlanned = 0 then 'Ok'
		when (ReactionTime/ReactionTimePlanned) <= 0.5 then 'Ok'
		when (ReactionTime/ReactionTimePlanned) <= 0.99 then 'Verificar'
		when (ReactionTime/ReactionTimePlanned) > 1 then 'Gap'
	end `Moderation Reaction`,
	case 
		when SolutionTimePlanned = 0 then 'Ok'
		when (SolutionTime / SolutionTimePlanned) <= 0.5 then 'Ok'
		when (SolutionTime / SolutionTimePlanned) <= 0.99 then 'Verificar'
		when (SolutionTime / SolutionTimePlanned) > 1 then 'Gap'
	end `Moderation Solution`,
CASE 
    WHEN 
        ((SolutionTime / SolutionTimePlanned) > 0.5) OR
        ((SolutionTime / SolutionTimePlanned) > 0.5) 
    THEN 'Verificar' 
    ELSE 'Não verificar'
END AS Moderar
from prd.stg_sla_exec sse 
where upper(sse.ProjectTypeName) in ('AMS', 'FAST TRACK', 'INTERNO','MANUTENÇÃO PRODUTO')
and sse.ExternalTicketId in (
select exid from prd.stg_chamado_sd sd
where UPPER(sd.TipoProjeto) IN ('AMS', 'FAST TRACK', 'INTERNO','MANUTENÇÃO PRODUTO')
and sd.Cliente not like '%Seidor%')