--==============================================================================
--
-- get all Baselines in the database
-- see
--
-- http://oracle-base.com/articles/11g/sql-plan-management-11gr1.php
-- https://blogs.oracle.com/optimizer/entry/what_is_the_different_between
-- https://blogs.oracle.com/optimizer/entry/sql_plan_management_part_1_of_4_creating_sql_plan_baselines
--
--==============================================================================
set verify off
set linesize 130 pagesize 300 

column SQL_TEXT format a23
column SQL_HANDLE format a20
column PARSING_SCHEMA_NAME format a14
column PLAN_NAME format a30
column ORIGIN format a16
column CREATED_TEXT format a18
column ENABLED format a3 heading "Ena|bld"
column ACCEPTED format a3 heading "Ac|ted"


  select SQL_HANDLE
       ,  replace (replace (substr (SQL_TEXT, 1, 20) || ' ..', chr (10), ''), '  ', ' ') as SQL_TEXT
       ,  PARSING_SCHEMA_NAME
       ,  PLAN_NAME
       ,  ORIGIN
       ,  to_char (CREATED, 'dd.mm.yyyy hh24:mi') as CREATED_TEXT
       ,  ENABLED
       ,  ACCEPTED
    from DBA_SQL_PLAN_BASELINES
order by CREATED
/




