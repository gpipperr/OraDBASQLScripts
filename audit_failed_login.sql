--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   Query the audit log entries for failed logins in the last 24 hours
--
-- Must be run with dba privileges
--==============================================================================
set linesize 130 pagesize 300 


column username     format a20  heading "DB User|name"
column os_username  format a16  heading "User   |Name"
column userhost     format a20  heading "User   |Host"
column terminal     format a20  heading "User   |Terminal"
column timestamp    format a18  heading "User   |Login at"
column returncode   format 9999 heading "Ora    |Error"

ttitle left  "Failed Logins to this DB in last 24h hours" skip 2

select  os_username
    ,   username
	,   terminal
	,   userhost
	,   returncode
	,   to_char(timestamp,'dd.mm.yyyy hh24:mi') as  timestamp
from dba_audit_trail 
 where ( returncode=1017 OR returncode=28000)
  and timestamp > sysdate-1
order by timestamp
/

prompt -- ----------------------------------

prompt Ora-Error 1017   - Wrong Password
prompt Ora-Error 28000  - Account was locked

prompt -- ----------------------------------

ttitle off