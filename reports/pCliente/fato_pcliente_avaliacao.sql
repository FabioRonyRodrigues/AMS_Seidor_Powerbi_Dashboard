    /*
    Finalidade: Esta query tem como finalidade trazer as avaliações realizadas nos chamados, pendente de manutenção devido a remoção das colunas atuais e inclusão de uma única.
    Responsável: Ezio Abilio
    Data Manutenção: 28/03/2025

    -------
    Documentação
    -     where 
    Chamado in 
    (select EXID from prd.stg_chamado_sd scs
    where UPPER(scs.TipoProjeto) in ('AMS', 'FAST TRACK','MANUTENÇÃO PRODUTO')
    and Cliente not like '%SEIDOR%'
    )
    Esta condição where, tem finalidade limitar os chamados para trazer somente alguns especificos que apareçam na tabela de cabeçalhos de chamado, 
    Pode ocorrer de um chamado possuir ou não SLA, porém não pode ocorrer de um chamado possuir apontamento e não possuir chamado.
    */    
    
    select 
    exid,
    OI,
    NomeRecurso Atendente,
    AtendimentoOperacional,
    AtendimentoGerencial,
    AtendimentoGeral,
    Comentario
    from prd.stg_avaliacao sa 
    where 
    sa.exid in (select scs.exid from prd.stg_chamado_sd scs where upper(scs.tipoprojeto) in ('AMS','FAST TRACK','INTERNO','MANUTENÇÃO PRODUTO'))