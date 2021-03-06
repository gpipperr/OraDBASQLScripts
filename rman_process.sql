--==============================================================================
-- GPI -  Gunther Pipp?rr 
-- Desc:  Process List of RMAN Oracle sessions
-- Date:  01.September 2013
--==============================================================================
set verify off
set linesize 130 pagesize 300 

ttitle left  "Process List of the RMAN Sessions" skip 2

column process_id format a8     heading "Process|ID"
column inst_id    format 99     heading "Inst|ID"
column username   format a8     heading "DB User|name"
column osusername   format a8   heading "OS User|name"
column sid        format 99999  heading "SID"
column serial#    format 99999  heading "Serial"
column machine    format a14    heading "Remote|pc/server"
column terminal   format a14    heading "Remote|terminal"
column program    format a17    heading "Remote|program"
column module     format a15    heading "Remote|module"
column client_info format a15   heading "Client|info"
column pname       format a8    heading "Process|name"
column tracefile   format a20   heading "Trace|File"
column LOGON_TIME  format a5    heading "Logon|time"

select p.inst_id  
    , to_char(p.spid) as process_id
	, vs.sid
	, vs.serial#
    , nvl(vs.username,'n/a') as username
	, p.username as osusername
	--, p.pname		
	,to_char(vs.logon_time,'hh24:mi') as  LOGON_TIME
	, vs.machine
	--, p.terminal
	, vs.module
    , vs.program
	, vs.client_info 	
	--, substr(p.tracefile,length(p.tracefile)-REGEXP_INSTR(reverse(p.tracefile),'[\/|\]')+2,1000) as tracefile
	--, p.tracefile
from gv$session vs
   , gv$process p
where vs.paddr=p.addr
  and vs.inst_id=p.inst_id
  and vs.program like '%rman%'
order by vs.logon_time
		 , p.inst_id
/  

ttitle left  "Trace File Locations" skip 2
column full_trace_file_loc  format a100  heading "Trace|File"
select p.inst_id  
    , to_char(p.spid) as process_id
    , p.tracefile as full_trace_file_loc
from gv$session vs
   , gv$process p
where vs.paddr=p.addr
  and vs.inst_id=p.inst_id
  and vs.program like '%rman%'
order by vs.logon_time
		 , p.inst_id
/  


prompt
prompt ... to enable trace use "oradebug  SETOSPID <Process ID>"
prompt
prompt ... to kill session     "ALTER SYSTEM KILL SESSION 'sid,serial#,@inst_id';"
prompt ... to end  session     "ALTER SYSTEM DISCONNECT SESSION 'sid,serial#' IMMEDIATE;"
prompt

ttitle off
