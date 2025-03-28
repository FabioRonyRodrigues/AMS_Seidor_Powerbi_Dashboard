    /*
    Finalidade: Esta query tem como finalidade trazer as horas por contrato(baseline), a data de início do contrato e também o valor de hora contratado.
    - Pendente manutenção para remover cliente SEIDOR.
    Responsável: Ezio Abilio
    Data Manutenção: 28/03/2025

    -------
    Documentação

    */ 
    
    select 
        OI,
        InicioHorasContrato,
        HorasContrato,
        ValorHoraContratado
        from prd.stg_configuracao_projeto_orbit scpo 