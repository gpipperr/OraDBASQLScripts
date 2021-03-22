--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   Check for long active sessions longer then one hour
--==============================================================================
set linesize 130 pagesize 300 

column session_info format a20         heading "Session|Info" 
column last_call_et format 999G999G999 heading "Query|Runtime sec"
column inst_id      format 99          heading "In|Id"
column machine      format a13         heading "Remote|pc/server"
column terminal     format a13         heading "Remote|terminal"
column program      format a16         heading "Remote|program"
column module       format a16         heading "Remote|module"
column client_info  format a10         heading "Client|info"
column sql_id       format a14         heading "SQL|id"
column OSUSER       format a15 heading "OS|User"

break on sql_id

select inst_id 
	  , username||'(sid:'||sid||')' as session_info
	  , sql_id
      , machine
     --, terminal
      , program
	  , module
	  --, client_info
	  , osuser
	  , last_call_et  
from gv$session 
where status='ACTIVE' 
  and type='USER' 
  and username not in ('SYS','AQ','STRMADMIN') 
  and last_call_et > (60*60) -- longer then one hour
order by sql_id,inst_id
/

prompt ...
prompt ... use session_longops.sql to see what the session is doing
prompt ...

clear break
