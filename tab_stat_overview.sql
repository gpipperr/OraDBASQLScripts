--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   Get the statistic settings of all tables of a user
-- Parameter 1: Name of the table
--
-- Must be run with dba privileges
-- 
--
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define USER_NAME  = &1

prompt
prompt Parameter 1 = Owner Name => &&USER_NAME.
prompt

SET linesize 150 pagesize 2000 

ttitle "Read Statistic Values for all tables of this user &USER_NAME." SKIP 2

column table_name  format a32

select  table_name
      , status
	  , to_char(LAST_ANALYZED,'dd.mm.yyyy hh24:mi') as LAST_ANALYZED
	  , NUM_ROWS
	  , AVG_SPACE
	  , CHAIN_CNT
	  , AVG_ROW_LEN
 from dba_tables
where owner   like '&USER_NAME.'
order by nvl(NUM_ROWS,1) asc
/

prompt ... to anaylse the space Usage use tab.sql
prompt ... to refresh statistic use  EXEC DBMS_STATS.GATHER_TABLE_STATS ('&USER_NAME.', 'TABLE_NAME');

ttitle "Read Statistic Values for all tables of this user &USER_NAME." SKIP 2

column col_group format a30
 
select e.extension col_group
     , t.num_distinct
     , t.histogram
 from  dba_stat_extensions e
    ,  dba_tab_col_statistics t
where e.extension_name=t.column_name
  and t.owner like '&USER_NAME.'
/

ttitle off
