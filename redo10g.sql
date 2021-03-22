--==============================================================================
-- Author: Gunther Pippèrr ( http://www.pipperr.de )
-- Desc:   get the user rights and grants
-- Date:   01.September 2012
-- Site:   http://orapowershell.codeplex.com
--==============================================================================

SET linesize 130 pagesize 300 

ttitle  "Report Redo Log Configuration "  SKIP 1  - 
left "Sizes in MB" SKIP 2
			 
column member format a50
column THREAD# format 99
column  GROUP# format 99

ttitle  "Redolog  Size of each group"  SKIP 1  - 
left "Sizes in MB" SKIP 2

select count(*)
      ,thread#
      ,to_char(round(BYTES / 1024 / 1024, 2)) || 'M' as REDOLOG_SIZE
  from v$log
 group by thread#
         ,BYTES
/

prompt

ttitle  "Redolog  Status of each group"  SKIP 1  -
left "Sizes in MB" SKIP 2

select THREAD#
      ,group#
      ,status
      ,to_char(round(BYTES / 1024 / 1024, 2)) || 'M' as REDOLOG_SIZE
  from v$log
 order by 1
         ,2
/
prompt

ttitle  "Redolog Member  of the groups"  SKIP 1  -
left "Sizes in MB" SKIP 2

select group#
      ,member
      ,status
  from v$logfile
 order by 1
         ,2
/	

ttitle  "Redolog Switch frequency "  SKIP 1

select to_char(FIRST_TIME,'dd.mm.yyyy hh24:mi:ss') as first_time_log
      , RECID
	  , THREAD#
	  , SEQUENCE#
  from (select * from v$log_history order by recid desc) 
where rownum <=500
order by first_time_log asc
/

ttitle  "Redolog Statistik"  SKIP 1
SELECT SUBSTR(name,1,20) "Name",gets,misses,immediate_gets,immediate_misses
FROM v$latch
WHERE name in ('redo allocation', 'redo copy')
/

prompt MISSES/GETS (must be < 1%)

ttitle  "Redolog Waits"  SKIP 1
SELECT name,value
FROM v$sysstat
WHERE name = 'redo log space requests';


ttitle  "Redolog init ora Settings "  SKIP 1
show parameter log_buffer

ttitle left  "Trace File Locations" skip 2
column full_trace_file_loc  format a100  heading "Trace|File"
select p.inst_id  
    , p.pname	
    , p.tracefile as full_trace_file_loc
from gv$session vs
   , gv$process p
where vs.paddr=p.addr
  and vs.inst_id=p.inst_id
  and vs.username is  null
  and p.pname = 'LGWR'
order by vs.username
       , p.inst_id
/ 

ttitle off

prompt



