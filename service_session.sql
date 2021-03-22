--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: sessions per service over all instances
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define USER_NAME    = '&1'

prompt
prompt Parameter 1 = USER_NAME Name => &&USER_NAME.
prompt

column inst_id       format 99 heading "SI"
column user_inst_id  format 99 heading "UI"
column username      format a14 heading "User|Name"
column machine       format a20 heading "Machine"
column service_name  format a18 heading "Service|Name"
column osuser        format a16 heading "OS|User"
column RESOURCE_CONSUMER_GROUP format a15   heading "Resource|Manager"
column session_count           format 9G999 heading "Sess|Cnt"
column status                  format a15   heading "Status"

break on inst_id skip 2
compute sum of session_count on inst_id

  select sv.inst_id
       ,  sv.name as service_name
       ,  s.inst_id as user_inst_id
       ,  s.username
       ,  s.machine
       ,  s.osuser
       ,  s.RESOURCE_CONSUMER_GROUP
       ,  status
       ,  count (*) as session_count
    from gv$session s, gv$active_services sv
   where --s.service_name like 'S\_%' escape '\'
         -- and
         sv.name = s.service_name(+)
         --and s.username not in ('SYS', 'DBSNMP')
         and upper (s.username) like upper('&&USER_NAME')
group by s.username
       ,  s.machine
       ,  s.inst_id
       ,  sv.name
       ,  s.osuser
       ,  s.RESOURCE_CONSUMER_GROUP
       ,  sv.inst_id
       ,  status
order by inst_id
       ,  service_name
       ,  username
       ,  status
/

clear break
clear computes
