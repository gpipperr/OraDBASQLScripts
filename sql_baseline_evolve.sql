--==============================================================================
--
-- Test all execution Plans of a baseline and try to find the best plan
--==============================================================================
-- 
-- https://blogs.oracle.com/optimizer/entry/sql_plan_management_part_3_of_4_evolving_sql_plan_baselines_1
-- 
-- Non-accepted plans can be verified by executing the evolve_sql_plan_baseline function. 
-- This function will execute the non-accepted plan and compare its performance to the best accepted plan. 
-- The execution is performed using the conditions (e.g., bind values, parameters, etc.) in effect at the time the non-accepted plan was added to the plan history. 
-- If the non-accepted plan's performance is better, the function will make it accepted, thus adding it to the SQL plan baseline. 
--
--==============================================================================
set verify off
set linesize 130 pagesize 300 

set long 10000

define SQL_HANDEL=&1

prompt
prompt Parameter 1 = SQL_HANDEL   => &&SQL_HANDEL.
prompt

select dbms_spm.evolve_sql_plan_baseline(sql_handle => '&&SQL_HANDEL.') 
  from dual
/

