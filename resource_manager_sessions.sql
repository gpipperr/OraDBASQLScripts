--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: Show the resource manager settings of the running sessions
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define USER_NAME   =  &1

prompt
prompt Parameter 1 = Username          => &&USER_NAME.
prompt

column inst_id    format 99     heading "Inst|ID"
column username   format a14     heading "DB User|name"
column sid        format 99999  heading "SID"
column serial#    format 99999  heading "Serial"
column machine    format a30    heading "Remote|pc/server"
column terminal   format a13    heading "Remote|terminal"
column program    format a16    heading "Remote|program"
column module     format a16    heading "Remote|module"
column state      format a10 heading "State"
column OSUSER     format a13 heading "OS|User"
column LOGON_TIME format a12 heading "Logon|Time"
column status     format a8  heading "Status"
column action     format a15 heading "Action"
column group_name format a15 heading "Res|Group Name"
column service_name          format a20 heading "Service|Name"
column client_info           format a10   heading "Client|info"
column cpu_wait_time         format 999999 heading "CPU|Wait"
column degree_of_parallelism format 999999 heading "Degree|parallel"
column client_identifier     format A10 heading "Client|identifier"

ttitle left  "All User Sessions with resource manager information" skip 2

select s.inst_id
       ,  s.username
       --    ,s.osuser
       --    ,s.program
       ,  s.module
       ,  s.action
       ,  co.name group_name
       ,  s.service_name
       ,  se.state
       ,  se.consumed_cpu_time cpu_time
       ,  se.cpu_wait_time
       ,  se.dop / 2  degree_of_parallelism
    from gv$rsrc_session_info se, gv$rsrc_consumer_group co, gv$session s
   where     se.current_consumer_group_id = co.id
         and s.sid = se.sid
         and s.inst_id = se.inst_id
         and co.name not in ('_ORACLE_BACKGROUND_GROUP_')
         and s.username like upper ('%&&USER_NAME.%')
order by s.inst_id, s.username
/

ttitle off