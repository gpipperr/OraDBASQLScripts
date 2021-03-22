--==============================================================================
-- GPI - Gunther Pippèrr
-- get the plan of a plan in a baseline
--
--==============================================================================
set verify off
set linesize 130 pagesize 300 

set long 10000

define SQL_BASELINE_PLAN=&1

prompt
prompt Parameter 1 = SQL_BASELINE_PLAN   => &&SQL_BASELINE_PLAN.
prompt
--
--select *
--  from table(dbms_xplan.display_sql_plan_baseline( plan_name=>'&&SQL_BASELINE_PLAN.'
--                                                  ,format   =>'BASIC ROWS BYTES COST')
--			   )
--/
--

select *
  from table(dbms_xplan.display_sql_plan_baseline( plan_name=>'&&SQL_BASELINE_PLAN.'
                                                  ,format   =>'outline')
			   )
/
