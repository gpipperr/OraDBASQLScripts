--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc:   show open transactions in the database
-- Date:   September 2013
--
--==============================================================================
set linesize 130 pagesize 300 

ttitle  "Report DB transactions longer open "  SKIP 1
      
column sessionid    format a8 heading "DB|Session"
column inst_id      format 99 heading "In|id"
column username     format a14 heading "DB|user"
column osuser       format a9 heading "OS|Benutzer"
column machine      format a16 heading "OS|Maschine"
column program      format a10 heading "OS|Programm"
column action       format a10 heading "Action"
column status       format a6 heading "Status"
column logon_time   format a18 heading "Login|Time"
column start_time   format a14 heading "Start|Time"
column last_call_et format 999G999G999 heading "Last Sql|Time s"
column xid          format a15 heading "Transaction|id"
column name         format a15

select n.inst_id
     , n.sid
	 , n.serial#
     , n.username
     , n.osuser
	 , n.machine
	 , n.program
	 , n.action
	 , to_char(n.logon_time,'dd.mm.yyyy hh24:mi') as logon_time
	 , n.last_call_et
	 , n.status
	 --, t.name
	 , t.xidusn||'.'||t.xidslot||'.'||t.xidsqn as xid
  from gv$session n
     , gv$transaction t
where  n.taddr = t.addr
   and n.INST_ID = t.INST_ID
  and to_date(t.start_time, 'MM/DD/YY HH24:MI:SS') < sysdate - (2 / 24)
  and sysdate - (n.last_call_et / (60 * 60 * 24)) < sysdate - (2 / 24)
  and n.status != 'ACTIVE'
/	

ttitle off
