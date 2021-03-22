--====== ========================================================================
-- GPI - Gunther Pippèrr
-- Desc:   Query the audit log entries for LOGOFF BY CLEANUP events
--
-- Must be run with dba privileges
--==============================================================================
set linesize 130 pagesize 300 


column username     format a20  heading "DB User|name"
column action_name  format a25  heading "Action|name"
column first_log    format a25  heading "First|entry"
column last_log     format a25  heading "Last|entry"
column entries      format 999G999G999 heading "Audit|entries"
column action_count format 999G9999 heading "Action|Count"
column os_username  format a16 heading "User|Name"
column userhost     format a20 heading "User |Host"
column timestamp    format a23  heading "Time"
column  CLIENT_ID   format a18  heading "DB User|Client Id"


ttitle left  "Audit log Clean Up Entries order by time desc" skip 2

  select                                                                               
         to_char (extended_timestamp, 'dd.mm hh24:mi:ss') as timestamp
       , instance_number     
       , username
       , action_name
       , userhost
       , CLIENT_ID
    from dba_audit_trail
   where     extended_timestamp between   sysdate - (  1 / 4) and sysdate
         and action_name like 'LOGOFF BY CLEANUP'
order by extended_timestamp desc
/



prompt
prompt

ttitle off

