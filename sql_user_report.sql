--==============================================================================
-- Author: Gunther Pippèrr
-- Desc:   :   HTML Report for SQL queries executed by one user
--==============================================================================
define DB_USER_NAME = &1


prompt
prompt Parameter 1 = DB_USER_NAME     => &&DB_USER_NAME.
prompt


col SPOOL_NAME_COL new_val SPOOL_NAME
 
SELECT replace(ora_database_name||'_'||SYS_CONTEXT('USERENV','HOST')||'_'||to_char(sysdate,'dd_mm_yyyy_hh24_mi')||'_user_&&DB_USER_NAME._sql.html','\','_') 
--' resolve syntax highlight bug FROM my editer .-(
  AS SPOOL_NAME_COL
FROM dual
/


set verify off
set linesize 250 pagesize 3000 

column sql_text format a35 heading "SQL|Text"
column sql_id   format a13 heading "SQL|ID"
column parsing_user_name  format a10 heading "Parsing|Schema"
column executions  format 999G999G999G999 heading "Exec"
column buffer_gets format 999G999G999G999 heading "Buffer|Gets"
column disk_reads  format 999G999G999G999 heading "Disks|Reads"
column cpu_time    format 999G999G999G999 heading "CpuTime|microseconds"
column sorts       format 999G999G999G999 heading "Sorts"
column avg_bufferget_per_ex  format 999G999G999D99 heading "AVG Buffer gets|Executions"
column avg_disk_reads_per_ex format 999G999G999D99 heading "AVG Disk reads|Executions"
column avg_sort_per_ex       format 999G999G999D99 heading "AVG Sorts|Executions"
column avg_cpu_per_ex        format 999G99G999G999D99 heading "AVG CPU|Executions"

spool &&SPOOL_NAME


set markup html on

ttitle center "SQL Statements in the SGA Cache for this user on this instance" SKIP 2

select s.SQL_ID
	  , u.username as "Parsing User"
	  , s.executions
	  , s.loads
	  , s.buffer_gets
	  , s.disk_reads
	  , trunc(s.buffer_gets/(s.executions),2) avg_bufferget_per_ex
	  , trunc(s.disk_reads/(s.executions),2)  avg_disk_reads_per_ex
	  , s.FIRST_LOAD_TIME
	  , to_char(s.LAST_LOAD_TIME,'dd.mm.yyyy hh24:mi') LAST_LOAD_TIME
	  , to_char(s.LAST_ACTIVE_TIME,'dd.mm.yyyy hh24:mi') LAST_ACTIVE_TIME
	  , s.sql_text 
 from v$sqlarea s
    , dba_users u
 where  u.user_id=s.parsing_user_id
    and u.username like upper('&&DB_USER_NAME.')
	 --and s.LAST_ACTIVE_TIME between to_date('14.11.2014 08:00','dd.mm.yyyy hh24:mi') and to_date('14.11.2014 09:00','dd.mm.yyyy hh24:mi')		
	and s.executions>1	 
order by s.LAST_ACTIVE_TIME desc
/

set markup html off

spool off
ttitle off

-- works only in a ms windows environment
-- auto start of the result in a browser window
host &&SPOOL_NAME