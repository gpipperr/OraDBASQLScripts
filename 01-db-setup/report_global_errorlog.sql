--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   HTML Report for the entries in the audit log
-- see :   https://www.pipperr.de/dokuwiki/doku.php?id=dba:oracle_sqlfehler_protokoll
-- Date:   Juni 2019
--
--==============================================================================


col SPOOL_NAME_COL new_val SPOOL_NAME
 
SELECT replace(ora_database_name||'_'||SYS_CONTEXT('USERENV','HOST')||'_'||to_char(sysdate,'dd_mm_yyyy_hh24_mi')||'_sql_error_log.html','\','_') 
--' resolve syntax highlight bug FROM my editer .-(
  AS SPOOL_NAME_COL
FROM dual
/

set verify off

SET linesize 450 pagesize 2000 

column anzahl           format 999G999  heading "Count"
column first_log_entry  format A18      heading "First Entry"
column last_log_entry   format A18      heading "Last Entry"
column LOG_USR          format A20      heading "DB Schema"
column ERR_NR           format 99999    heading "Ora Err | Number"
column mesg             format A100     heading "Ora Err | Message"
column HOUR             format A16      heading "Hour"
column stmt             format A250     heading "SQL Statemment"


spool &&SPOOL_NAME

set markup html on

ttitle left  "SQL Error Total Log Summary" skip 2

SELECT COUNT (*) AS anzahl
        ,to_char(min(log_date),'dd.mm.yyyy hh24:mi') first_log_entry
        ,to_char(max(log_date),'dd.mm.yyyy hh24:mi') last_log_entry		
        ,nvl(LOG_USR,'n/a') AS LOG_USR
        ,ERR_NR
        ,substr(ERR_MSG,1,300) mesg
    FROM SYSTEM.ora_errors
    WHERE nvl(log_usr,'n/a') NOT IN ('SYS','SYSMAN','DBSNMP')
GROUP BY nvl(LOG_USR,'n/a')
        ,ERR_NR
        ,substr(ERR_MSG,1,300)
ORDER BY 2,1 
/


ttitle left  "SQL Error Hour Report" skip 2

 
SELECT   COUNT (*) AS anzahl
        ,TO_CHAR (log_date, 'dd.mm.yyyy hh24')||'h' AS HOUR
        ,nvl(LOG_USR,'n/a') AS LOG_USR
        ,ERR_NR
        ,substr(ERR_MSG,1,300) mesg
    FROM SYSTEM.ora_errors
    WHERE nvl(log_usr,'n/a') NOT IN ('SYS','SYSMAN','DBSNMP')
GROUP BY TO_CHAR (log_date, 'dd.mm.yyyy hh24')||'h'
        ,nvl(LOG_USR,'n/a')
        ,ERR_NR
        ,substr(ERR_MSG,1,300)
ORDER BY 2
/


ttitle left  "SQL Error Log  All Entries " skip 2

set long 64000



with ErrorLog as 
  ( select   stmt
           , log_date
		   , LOG_USR
		   , ERR_NR
		   , substr(ERR_MSG,1,300) mesg
		   , dbms_lob.getlength(STMT) len 
	FROM SYSTEM.ora_errors 
   WHERE nvl(log_usr,'n/a') NOT IN ('SYS','SYSMAN','DBSNMP')
	)
  select
		COUNT (*) AS anzahl
	  , to_char(min(log_date),'dd.mm.yyyy hh24:mi') first_log_entry
	  , to_char(max(log_date),'dd.mm.yyyy hh24:mi') last_log_entry		
	  , LOG_USR
	  , ERR_NR
	  , mesg
	  , dbms_lob.substr(stmt,4000,1) sql_part1
	  , case when len > 4000 then dbms_lob.substr(stmt,4000,4001)    end sql_part2
	  , case when len > 8000 then dbms_lob.substr(stmt,4000,8001)    end sql_part3
	  , case when len > 12000 then dbms_lob.substr(stmt,4000,12001)  end sql_part4
	  , case when len > 16000 then dbms_lob.substr(stmt,4000,165001) end sql_part5
  FROM ErrorLog
 GROUP BY LOG_USR
	  , ERR_NR
	  , mesg
	  , dbms_lob.substr(stmt,4000,1) 
	  , case when len > 4000 then dbms_lob.substr(stmt,4000,4001)    end 
	  , case when len > 8000 then dbms_lob.substr(stmt,4000,8001)    end 
	  , case when len > 12000 then dbms_lob.substr(stmt,4000,12001)  end 
	  , case when len > 16000 then dbms_lob.substr(stmt,4000,165001) end 
ORDER BY 1 
/

set markup html off

spool off
ttitle off

-- works only in a ms windows environment
-- auto start of the result in a browser window
host &&SPOOL_NAME

