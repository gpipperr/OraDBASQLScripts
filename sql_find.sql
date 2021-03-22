--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   find the sql statement in the sql cache
-- Date:   September 2013
--
--===============================================================================
set verify off
set linesize 130 pagesize 800 

define SQL_STATEMENT = &1 


prompt
prompt Parameter 1 = SQL_STATEMENT    => &&SQL_STATEMENT.
prompt

ttitle left  "Search SQL from Cursor Cache for this text string :  &SQL_STATEMENT." skip 2

column sql_text           format a35 heading "SQL|Text"
column sql_id             format a13 heading "SQL|ID"
column INST_ID            format 99 heading "In|st"
column parsing_user_name  format a10 heading "Parsing|Schema"
column executions  format 999G999G999 heading "Exec"
column buffer_gets format 999G999G999 heading "Buffer|Gets"
column disk_reads  format 999G999G999 heading "Disks|Reads"
column cpu_time    format 999G999G999 heading "Cpu|Time"
column sorts       format 999G999G999 heading "Sorts"

select  SQL_ID
     ,  INST_ID
	  , (select username from dba_users where user_id=parsing_user_id) as parsing_user_name
	  , sorts
	  , executions
	  , buffer_gets
	  , disk_reads
	  , cpu_time
	  , sql_text
	  , LAST_LOAD_TIME
	  /* GPI SQL Analyse */
 from gv$sqlarea
where upper(sql_text) like upper('%&&SQL_STATEMENT.%') 
  and sql_text not like '%GPI SQL Analyse%'
order by SQL_ID,INST_ID
/

prompt ... to get the execution plan call awr_sql.sql with the sql_id

ttitle off
