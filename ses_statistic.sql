--==============================================================================
-- in work
-- Desc: get the statistic information of a session
--==============================================================================
set verify off
set linesize 130 pagesize 300 

select n.name
     , s.value
	 , ses.username
	 , ses.program
	 , ses.osuser
	 , ses.machine
from v$statname n
   , v$sesstat s
   , v$session ses
where n.statistic# = s.statistic# 
  and s.sid = ses.sid 
  and s.statistic# not in (13, 14)
order by value desc
/