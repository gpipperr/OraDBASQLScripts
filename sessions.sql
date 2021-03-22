--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   actual connections to the database
-- Date:   01.September 2012
--==============================================================================
set verify off
set linesize 140 pagesize 300 

define USER_NAME   =  &1
define ALL_PROCESS = '&2'

prompt
prompt Parameter 1 = Username          => &&USER_NAME.
prompt Parameter 2 = to Show all use Y => &&ALL_PROCESS.
prompt

ttitle left  "All User Sessions on this DB" skip 2

column inst_id    format 99     heading "Inst|ID"
column username   format a12     heading "DB User|name"
column sid        format 99999  heading "SID"
column serial#    format 99999  heading "Serial"
column machine    format a15    heading "Remote|pc/server"
column terminal   format a14    heading "Remote|terminal"
column program    format a15    heading "Remote|program"
column module     format a16    heading "Remote|module"
column client_info format a10   heading "Client|info"
column client_identifier format A10 heading "Client|identifier"
column OSUSER      format a13 heading "OS|User"
column LOGON_TIME  format a12 heading "Logon|Time"
column status      format a8  heading "Status"

  select inst_id
       ,  sid
       ,  serial#
       ,  status
       ,  username
       ,  machine
       --, terminal
       ,  program
       ,  OSUSER
       ,  module
       ,  to_char (LOGON_TIME, 'dd.mm hh24:mi') as LOGON_TIME
       ,  client_identifier
       ,  client_info
    from gv$session
   where (   username like upper ('%&&USER_NAME.%')
          or (    nvl ('&ALL_PROCESS.', 'N') = 'Y'
              and username is null))
order by program, inst_id
/

ttitle left  "User Sessions Summary on this DB" skip 2

column cs format 9999
column program  format A60
column username format A20

column DUMMY noprint;
compute sum of cs on DUMMY
break on DUMMY;

  select null dummy
       ,  count (*) as cs
       ,  username
       ,  program
    from gv$session
   where username is not null
group by username, program
order by username
/

clear break

ttitle off

show parameter processes
show parameter sessions

prompt
prompt ... to kill session     "ALTER SYSTEM KILL SESSION 'sid,serial#,@inst_id';"
prompt ... to end  session     "ALTER SYSTEM DISCONNECT SESSION 'sid,serial#' IMMEDIATE;"
prompt ...
prompt ...  On MS Windows you can use "orakill ORACLE_SID spid" to kill from the OS the session
prompt