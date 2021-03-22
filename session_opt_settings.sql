--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   show the  optimizer settings of user sessions
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define USER_NAME = &1

prompt
prompt Parameter 1 = User  Name          => &&USER_NAME.
prompt


column stat_name     format a36    heading "OptFeature|Name"
column sql_feature   format a20    heading "SQL|Feature"
column isdefault     format a4     heading "DEF|AULT"
column value         format a15   heading "Session|Value"
column sid           format 9999   heading "My|SID"
column session_count format 9999   heading "Ses|Cnt"
column inst_id       format 99     heading "Inst|ID"
column username      format a14    heading "DB User|name"
column sid           format 99999  heading "SID"
column serial#       format 99999  heading "Serial"
column inst_value    format a15    heading "Instance|Value"
column is_session_changed format a2 heading "ch"

break on stat_name;

  select o.name as stat_name
       ,  o.sql_feature
       ,  o.isdefault
       ,  decode (upper (o.value), upper (pv.value), '-', '>>') as is_session_changed
       ,  o.value
       ,  pv.value as inst_value
       ,  s.inst_id
       ,  s.username
       ,  count (*) as session_count
    from gv$ses_optimizer_env o, gv$session s, gv$parameter pv
   where     s.sid = o.sid
         and s.inst_id = o.inst_id
         and s.inst_id = pv.inst_id(+)
         and upper (o.name) = upper (pv.name)
         and s.username like upper ('&&USER_NAME.%')
group by s.inst_id
       ,  s.username
       ,  o.NAME
       ,  o.SQL_FEATURE
       ,  o.ISDEFAULT
       ,  decode (upper (o.value), upper (pv.value), '-', '>>')
       ,  o.value
       ,  pv.value
order by o.isdefault
       ,  o.NAME
       ,  s.inst_id
       ,  s.username
/

clear break

