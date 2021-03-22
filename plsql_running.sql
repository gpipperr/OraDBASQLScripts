--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   actual running pl/sql in the database
-- Date:   Februar 2018
--==============================================================================
set verify off
set linesize 140 pagesize 300 

ttitle left  "All running PL/SQL at the moment" skip 2

column inst_id    format 99     heading "Inst|ID"
column username   format a12     heading "DB User|name"
column sid        format 99999  heading "SID"
column serial#    format 99999  heading "Serial"
column machine    format a15    heading "Remote|pc/server"
column terminal   format a14    heading "Remote|terminal"
column program    format a15    heading "Remote|program"
column module     format a16    heading "Remote|module"
column client_info format a10   heading "Client|info"
column client_identifier format a10 heading "Client|identifier"
column OSUSER      format a13 heading "OS|User"
column LOGON_TIME  format a12 heading "Logon|Time"
column status      format a8  heading "Status"



select 'Top PL/SQL'
      ,s.username
      ,o.object_name
      ,inst_id
      ,s.sid
      ,s.serial#
      ,s.status
      ,s.osuser
  from dba_objects o inner join gv$session s on (o.object_id = s.plsql_entry_object_id)
union all
select 'Current PL/SQL'    ,s.username
      ,o.object_name
      ,inst_id
      ,s.sid
      ,s.serial#
      ,s.status
      ,s.osuser
  from dba_objects o inner join gv$session s on (o.object_id = s.plsql_object_id)
union all
select 'Top sub programm PL/SQL'    ,s.username
      ,o.object_name
      ,inst_id
      ,s.sid
      ,s.serial#
      ,s.status
      ,s.osuser
  from dba_objects o inner join gv$session s on (o.object_id = s.PLSQL_SUBPROGRAM_ID)
union all
select 'Current sub program PL/SQL'    ,s.username
      ,o.object_name
      ,inst_id
      ,s.sid
      ,s.serial#
      ,s.status
      ,s.osuser
  from dba_objects o inner join gv$session s on (o.object_id = s.PLSQL_ENTRY_SUBPROGRAM_ID)

/

ttitle off

-- PLSQL_ENTRY_OBJECT_ID      -  Object ID of the top-most PL/SQL subprogram on the stack; NULL if there is no PL/SQL subprogram on the stack
-- PLSQL_ENTRY_SUBPROGRAM_ID  -  Subprogram ID of the top-most PL/SQL subprogram on the stack; NULL if there is no PL/SQL subprogram on the stack
-- PLSQL_OBJECT_ID            -  Object ID of the currently executing PL/SQL subprogram; NULL if executing SQL
-- PLSQL_SUBPROGRAM_ID        -  Subprogram ID of the currently executing PL/SQL object; NULL if executing SQL
