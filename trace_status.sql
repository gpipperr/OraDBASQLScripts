--==============================================================================
-- GPI-  Gunther Pippèrr
-- Desc: show the trace status of the DB
--==============================================================================
-- see also Tracing Enhancements Using DBMS_MONITOR (In 10g, 11g and Above) (Doc ID 293661.1)
--
--==============================================================================

set verify off
set linesize 130 pagesize 300 


column trace_type      format a15
column primary_id      format a15
column qualifier_id1   format a15
column qualifier_id2   format a15
column waits           format a5
column binds           format a5
column plan_stats      format a15
column instance_name   format a20


ttitle left  "DB Trace status for Using DBMS_MONITOR only" skip 2

-- https://docs.oracle.com/cd/E11882_01/server.112/e40402/statviews_3167.htm

select trace_type
	  , primary_id
	  , qualifier_id1
	  , qualifier_id2
	  , waits
	  , binds
	  , plan_stats
	  , instance_name
 from dba_enabled_traces
order by instance_name
/


ttitle left  "DB Trace status for all user sessions" skip 2

column inst_id     format 99        heading "Inst|ID"
column username    format a20       heading "DB User|name"
column sid         format 99999     heading "SID"
column serial#     format 99999     heading "Serial"
column program     format a16       heading "Remote|program"
column module      format a16       heading "Remote|module"
column client_info format a15       heading "Client|info"
column client_identifier format A15 heading "Client|identifier"
column action      format a30
column tracefile   format a80       heading "Trace|File"  FOLD_BEFORE
column sep FOLD_BEFORE

select  vs.inst_id 
     , vs.sid
	 , vs.serial#
	 , vs.username
	 , vs.module
	 , vs.ACTION
	 , to_char(vs.LOGON_TIME,'dd.mm hh24:mi') as LOGON_TIME
     , vs.client_identifier
	 , vs.client_info
     , substr(p.tracefile,length(p.tracefile)-REGEXP_INSTR(reverse(p.tracefile),'[\/|\]')+2,1000) as tracefile
     , p.tracefile
     , rpad('+',80,'=') as sep
from gv$session vs
   , gv$process p
where vs.SQL_TRACE != 'DISABLED'
  and vs.paddr=p.addr
  and vs.inst_id=p.inst_id
order by inst_id
/

ttitle off