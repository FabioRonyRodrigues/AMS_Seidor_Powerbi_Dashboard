    /*
    Finalidade: Esta query tem como finalidade trazer os valores de horas do Orbit.
    Responsável: Ezio Abilio
    Data Manutenção: 28/03/2025

    -------
    Documentação
	- join prd.stg_ctr_contract scc on sthm.contract_id = scc.id < Este join é somente para fazer a condição where.

	-
    where scc.code in
    (select OI from prd.stg_chamado_sd scs where upper(scs.TipoProjeto) in ('AMS','FAST TRACK','INTERNO','MANUTENÇÃO PRODUTO')) < Limitando projetos para os tipos informados.

    */ 
    select 
    sthm.employee_name,
    sthm.value_sales,
    sthm.value_cost,
    sthm.hours_worked,
    sthm.report_month,
    concat('01/', sthm.report_month) date,
    scc.code as OI
    from prd.stg_timesheets_horas_mensal sthm 
    join prd.stg_ctr_contract scc on sthm.contract_id = scc.id
    where scc.code in
    (select OI from prd.stg_chamado_sd scs where upper(scs.TipoProjeto) in ('AMS','FAST TRACK','INTERNO','MANUTENÇÃO PRODUTO'))