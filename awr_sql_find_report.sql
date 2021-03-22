--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc:   find the sql statement in the awr repository
-- Date:   Oktober 2014
--===============================================================================
prompt
prompt !!!!You need the Tuning Pack for this feature!!!!
prompt


define SQL_STATEMENT = &1 

prompt
prompt Parameter 1 = SQL_STATEMENT    => &&SQL_STATEMENT.
prompt

col SPOOL_NAME_COL new_val SPOOL_NAME
 
SELECT replace(ora_database_name||'_'||SYS_CONTEXT('USERENV','HOST')||'_'||to_char(sysdate,'dd_mm_yyyy_hh24_mi')||'_sql_usage.html','\','_') 
--' resolve syntax highlight bug FROM my editer .-(
  AS SPOOL_NAME_COL
FROM dual
/


SET MARKUP HTML ON SPOOL ON PREFORMAT OFF ENTMAP ON -
HEAD "<TITLE>SQL Usage Report</TITLE>               -
<STYLE type='text/css'>                             -
<!-- BODY {background: #FFFFFF}                     -
     span.findings { color:red } -->                -
</STYLE>"                                           -
TABLE "WIDTH='90%' BORDER='1'"

spool &&SPOOL_NAME

set verify off
SET linesize 180 pagesize 4000 

ttitle left  "Search SQL from AWR Repository this text string :  &SQL_STATEMENT." skip 2

column sql_text            format a150       heading "SQL|Text" WORD_WRAPPED ENTMAP OFF
column sql_id              format a13        heading "SQL|ID"
column parsing_schema_name format a20        heading "Parsing|Schema"
column plan_hash_value     format 9999999999 heading "Plan | Hash"
column first_usage         format a18        heading "First Usage"
column last_usage          format a18        heading "Last Usage"
column count_statements       format 99999999   heading "Count Snapshots"
column EXECUTIONS_TOTAL       format 99999999   heading "SQL Executions Total"
column PX_SERVERS_EXECS_TOTAL format 99999999   heading "Parallel Server Usage Total"


select ss.parsing_schema_name  
	  , t.SQL_ID
	  , ss.plan_hash_value
     , replace( DBMS_LOB.SUBSTR(t.SQL_TEXT,1000,1),'&SQL_STATEMENT.','<span style="color:red;">&SQL_STATEMENT.</span>') as SQL_TEXT
	  , count(t.SQL_ID)                  as count_statements
	  , sum(ss.EXECUTIONS_TOTAL)         as EXECUTIONS_TOTAL
	  , sum(ss.PX_SERVERS_EXECS_TOTAL )  as PX_SERVERS_EXECS_TOTAL
	  , to_char(min(s.begin_interval_time),'dd.mm.yyyy hh24:mi') as first_usage
	  , to_char(max(s.begin_interval_time),'dd.mm.yyyy hh24:mi') as last_usage
     /* GPI SQL Analyse */
 from dba_hist_sqltext t
    , dba_hist_sqlstat ss
    , dba_hist_snapshot s 
where s.snap_id = ss.snap_id 
   and ss.instance_number = s.instance_number
   and ss.sql_id = t.sql_id
   and upper(t.sql_text) like upper('%&&SQL_STATEMENT.%') 
	-- not show internal SQL from statistic process and so on
   and t.sql_text not like '%GPI SQL Analyse%' 
	and t.sql_text not like '%SQL Analyze%'
	and t.sql_text not like '%dynamic_sampling(0) no_sql_tune no_monitoring optimizer_features_enable%'
	and t.sql_text not like '% NO_PARALLEL%'
	and t.sql_text not like '%NOPARALLEL%'
	and ss.PARSING_SCHEMA_NAME not in ('SYS','DBSNMP','SYSTEM')
group by ss.parsing_schema_name  
	    , t.SQL_ID
	    , ss.plan_hash_value
       , DBMS_LOB.SUBSTR(t.SQL_TEXT,1000,1)
order by 1,2
/

set markup html off

spool off
ttitle off

-- works only in a ms windows environment
-- auto start of the result in a browser window
host &&SPOOL_NAME

