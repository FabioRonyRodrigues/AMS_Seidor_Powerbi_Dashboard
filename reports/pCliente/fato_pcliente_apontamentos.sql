    /*
    Finalidade: Esta query tem como finalidade trazer os apontamentos do LiveOps;
    Responsável: Ezio Abilio
    Data Manutenção: 28/03/2025

    -------
    Documentação

    - case when DataAlocacao is null then Data else DataAlocacao end DataAlocacao, < Esta linha tem finalidade de trazer os apontamentos
    sem data de alocação, exemplo apontamentos de ajuste de horas.

    - left join prd.stg_campo_adicional ca on sa.chamado = ca.exid  < Este join tem finalidade única de trazer a coluna "FormaCobranca", 
    onde há uma função DAX especifica que utiliza esta coluna, mais detalhes no arquivo .pbix

    -     where 
    Chamado in 
    (select EXID from prd.stg_chamado_sd scs
    where UPPER(scs.TipoProjeto) in ('AMS', 'FAST TRACK','MANUTENÇÃO PRODUTO')
    and Cliente not like '%SEIDOR%'
    )
    Esta condição where, tem finalidade limitar os chamados para trazer somente alguns especificos que apareçam na tabela de cabeçalhos de chamado, 
    Pode ocorrer de um chamado possuir ou não SLA, porém não pode ocorrer de um chamado possuir apontamento e não possuir chamado.
    Também é incluído que deve somente trazer informações de chamado que o cliente seja diferente de seidor, em vista que os chamados cliente "SEIDOR" são internos.
    */
    
    select
    Chamado,
    OI,
    upper(trim(Tipo)) TipoProjeto,
    HorasGastas,
    TipoHora,
    Data,
    case when DataAlocacao is null then Data else DataAlocacao end DataAlocacao,
    upper(trim(AreaConsultor)),
    upper(trim(Consultor)) Consultor,
    upper(trim(EmpresaConsultor)) EmpresaConsultor,
    NomeUsuario,
    ca.FormaCobranca
    from prd.stg_apontamentos sa
    left join prd.stg_campo_adicional ca on sa.chamado = ca.exid 
    where 
    Chamado in 
    (select EXID from prd.stg_chamado_sd scs
    where UPPER(scs.TipoProjeto) in ('AMS', 'FAST TRACK','MANUTENÇÃO PRODUTO')
    and Cliente not like '%SEIDOR%'
    )
    order by Chamado