--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: running transactions in the database
-- Date: September 2012
--==============================================================================
set linesize 130 pagesize 300 

ttitle  "Report active DB transactions"  SKIP 1
      
column sessionid  format a8 heading "DB|Session"
column inst_id    format 99 heading "In|id"
column username   format a9 heading "DB|user"
column osuser     format a9 heading "OS|Benutzer"
column machine    format a9 heading "OS|Maschine"
column program    format a9 heading "OS|Programm"
column xidsqn              heading "Trans.| Nr."
column start_scnb          heading "Start|SCN"

column start_time          heading "Start|Time"
--column used_ublk           heading "Ver.|Blocks"
column status     format a6 heading "Status"
--column xidusn              heading "Nr.|RB Seg."

column logon_time   format a14 heading "Login|Time"
column start_time   format a14 heading "Start|Time"
column last_call_et format a14 heading "Last Sql|Time"


select  s.sid||':'||serial#  as sessionid
      , s.inst_id
      , s.username          
	  , s.osuser
	  , s.machine
	  , s.program
	  , to_char(s.logon_time,'dd.mm hh24:mi') as logon_time
      , t.xidsqn            
      , t.start_scnb        
      , t.start_time   
	  , s.last_call_et 
--      , t.used_ublk         
      , t.status            
--      , t.xidusn            
 from gv$transaction t, gv$session s
 where s.taddr=t.addr
 and s.inst_id = t.inst_id
order by  s.logon_time
/

ttitle off