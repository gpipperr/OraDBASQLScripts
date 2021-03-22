--==============================================================================
-- GPI - Gunther Pippèrr
-- 
-- Desc:   get Information about my session
--
--==============================================================================

set verify off

set linesize 130 pagesize 300 

ttitle left  "My Oracle session and the process to this session" skip 2

column process_id format a8     heading "Process|ID"
column inst_id    format 99     heading "Inst|ID"
column username   format a8     heading "DB User|name"
column osusername   format a8   heading "OS User|DB Process"
column sid        format 99999  heading "SID"
column serial#    format 99999  heading "Serial"
column machine    format a14    heading "Remote|pc/server"
column terminal   format a14    heading "Remote|terminal"
column program    format a17    heading "Remote|program"
column module     format a15    heading "Remote|module"
column client_info format a15   heading "Client|info"
column pname       format a8    heading "Process|name"
column tracefile   format a20   heading "Trace|File"

  select p.inst_id
       ,  vs.sid
       ,  vs.serial#
       ,  nvl (vs.username, 'n/a') as username
       ,  p.username as osusername
       ,  p.pname
       ,  to_char (p.spid) as process_id
       ,  vs.machine
       --, p.terminal
       ,  vs.module
       ,  vs.program
       ,  vs.client_info
    --, substr(p.tracefile,length(p.tracefile)-REGEXP_INSTR(reverse(p.tracefile),'[\/|\]')+2,1000) as tracefile
    --, p.tracefile
    from gv$session vs, gv$process p
   where     vs.paddr = p.addr
         and vs.inst_id = p.inst_id
         and vs.sid = sys_context ('userenv', 'SID')
         and vs.inst_id = sys_context ('userenv', 'INSTANCE')
order by vs.username, p.inst_id, p.spid
/

ttitle left  "My SID and my Serial over dbms_debug_jdwp" skip 2

SELECT dbms_debug_jdwp.current_session_id sid
     , dbms_debug_jdwp.current_session_serial serial
FROM dual
/

ttitle left  "Trace File Locations" skip 2

column full_trace_file_loc  format a70 heading "Trace|File"

select value as full_trace_file_loc
  from v$diag_info
 where name = 'Default Trace File'
/

--select p.inst_id
--    , to_char(p.spid) as process_id
--    , p.tracefile as full_trace_file_loc
--from gv$session vs
--   , gv$process p
--where vs.paddr=p.addr
--  and vs.inst_id=p.inst_id
--   and vs.sid=sys_context('userenv','SID')
--    and vs.inst_id=sys_context('userenv','INSTANCE')
--order by vs.username
--       , p.inst_id
--/

ttitle left  "Check if this Session is connected via TCP with SSL TCPS or TCP" skip 2


SELECT SYS_CONTEXT('USERENV','NETWORK_PROTOCOL') AS connect_protocol 
  FROM dual
/  


ttitle left  "TAF Setting" skip 2
column inst_id    format 99       heading "Inst|ID"
column username   format a14      heading "DB User|name"
column machine    format a36      heading "Remote|pc/server"
column failover_type   format a6  heading "Fail|type"
column failover_method format a6 heading "Fail|method"
column failed_over     format a6 heading "Fail|over"

select inst_id
     ,  machine
     ,  username
     ,  failover_type
     ,  failover_method
     ,  failed_over
  from gv$session
 where     sid = sys_context ('userenv', 'SID')
       and inst_id = sys_context ('userenv', 'INSTANCE')
/


ttitle left  "Session NLS Lang Values" skip 2

select sys_context ('USERENV', 'LANGUAGE') as NLS_LANG_Parameter from dual;


ttitle left  "Session NLS Values" skip 2

column parameter format a24 heading "NLS Session Parameter"
column value     format a30 heading "Setting"

select PARAMETER, value
    from nls_session_parameters
order by 1
/

---------------
--- Source https://stackoverflow.com/questions/8114453/read-all-parameters-from-sys-context-userenv
-- thanks to beloblotskiy
---------------
column NAME format a30     heading "Sys Context|Parameter" 
column VAL  format a50    heading "Sys Context|Value" 

ttitle left  "Session sys_context  Values" skip 2


select context_values.*
    from (
      select *
      from (
        select
          sys_context ('userenv','ACTION') ACTION,
          sys_context ('userenv','AUDITED_CURSORID') AUDITED_CURSORID,
          sys_context ('userenv','AUTHENTICATED_IDENTITY') AUTHENTICATED_IDENTITY,
          sys_context ('userenv','AUTHENTICATION_DATA') AUTHENTICATION_DATA,
          sys_context ('userenv','AUTHENTICATION_METHOD') AUTHENTICATION_METHOD,
          sys_context ('userenv','BG_JOB_ID') BG_JOB_ID,
          sys_context ('userenv','CLIENT_IDENTIFIER') CLIENT_IDENTIFIER,
          sys_context ('userenv','CLIENT_INFO') CLIENT_INFO,
          sys_context ('userenv','CURRENT_BIND') CURRENT_BIND,
          sys_context ('userenv','CURRENT_EDITION_ID') CURRENT_EDITION_ID,
          sys_context ('userenv','CURRENT_EDITION_NAME') CURRENT_EDITION_NAME,
          sys_context ('userenv','CURRENT_SCHEMA') CURRENT_SCHEMA,
          sys_context ('userenv','CURRENT_SCHEMAID') CURRENT_SCHEMAID,
          sys_context ('userenv','CURRENT_SQL') CURRENT_SQL,
          sys_context ('userenv','CURRENT_SQLn') CURRENT_SQLn,
          sys_context ('userenv','CURRENT_SQL_LENGTH') CURRENT_SQL_LENGTH,
          sys_context ('userenv','CURRENT_USER') CURRENT_USER,
          sys_context ('userenv','CURRENT_USERID') CURRENT_USERID,
          sys_context ('userenv','DATABASE_ROLE') DATABASE_ROLE,
          sys_context ('userenv','DB_DOMAIN') DB_DOMAIN,
          sys_context ('userenv','DB_NAME') DB_NAME,
          sys_context ('userenv','DB_UNIQUE_NAME') DB_UNIQUE_NAME,
          sys_context ('userenv','DBLINK_INFO') DBLINK_INFO,
          sys_context ('userenv','ENTRYID') ENTRYID,
          sys_context ('userenv','ENTERPRISE_IDENTITY') ENTERPRISE_IDENTITY,
          sys_context ('userenv','FG_JOB_ID') FG_JOB_ID,
          sys_context ('userenv','GLOBAL_CONTEXT_MEMORY') GLOBAL_CONTEXT_MEMORY,
          sys_context ('userenv','GLOBAL_UID') GLOBAL_UID,
          sys_context ('userenv','HOST') HOST,
          sys_context ('userenv','IDENTIFICATION_TYPE') IDENTIFICATION_TYPE,
          sys_context ('userenv','INSTANCE') INSTANCE,
          sys_context ('userenv','INSTANCE_NAME') INSTANCE_NAME,
          sys_context ('userenv','IP_ADDRESS') IP_ADDRESS,
          sys_context ('userenv','ISDBA') ISDBA,
          sys_context ('userenv','LANG') LANG,
          sys_context ('userenv','LANGUAGE') LANGUAGE,
          sys_context ('userenv','MODULE') MODULE,
          sys_context ('userenv','NETWORK_PROTOCOL') NETWORK_PROTOCOL,
          sys_context ('userenv','NLS_CALENDAR') NLS_CALENDAR,
          sys_context ('userenv','NLS_CURRENCY') NLS_CURRENCY,
          sys_context ('userenv','NLS_DATE_FORMAT') NLS_DATE_FORMAT,
          sys_context ('userenv','NLS_DATE_LANGUAGE') NLS_DATE_LANGUAGE,
          sys_context ('userenv','NLS_SORT') NLS_SORT,
          sys_context ('userenv','NLS_TERRITORY') NLS_TERRITORY,
          sys_context ('userenv','OS_USER') OS_USER,
          sys_context ('userenv','POLICY_INVOKER') POLICY_INVOKER,
          sys_context ('userenv','PROXY_ENTERPRISE_IDENTITY') PROXY_ENTERPRISE_IDENTITY,
          sys_context ('userenv','PROXY_USER') PROXY_USER,
          sys_context ('userenv','PROXY_USERID') PROXY_USERID,
          sys_context ('userenv','SERVER_HOST') SERVER_HOST,
          sys_context ('userenv','SERVICE_NAME') SERVICE_NAME,
          sys_context ('userenv','SESSION_EDITION_ID') SESSION_EDITION_ID,
          sys_context ('userenv','SESSION_EDITION_NAME') SESSION_EDITION_NAME,
          sys_context ('userenv','SESSION_USER') SESSION_USER,
          sys_context ('userenv','SESSION_USERID') SESSION_USERID,
          sys_context ('userenv','SESSIONID') SESSIONID,
          sys_context ('userenv','SID') SID,
          sys_context ('userenv','STATEMENTID') STATEMENTID,
          sys_context ('userenv','TERMINAL') TERMINAL
        from dual
      )
      unpivot include nulls (
        val for name in (action, audited_cursorid, authenticated_identity, authentication_data, authentication_method, bg_job_id, client_identifier, client_info, current_bind, current_edition_id, current_edition_name, current_schema, current_schemaid, current_sql, current_sqln, current_sql_length, current_user, current_userid, database_role, db_domain, db_name, db_unique_name, dblink_info, entryid, enterprise_identity, fg_job_id, global_context_memory, global_uid, host, identification_type, instance, instance_name, ip_address, isdba, lang, language, module, network_protocol, nls_calendar, nls_currency, nls_date_format, nls_date_language, nls_sort, nls_territory, os_user, policy_invoker, proxy_enterprise_identity, proxy_user, proxy_userid, server_host, service_name, session_edition_id, session_edition_name, session_user, session_userid, sessionid, sid, statementid, terminal)
      )
    ) context_values
/	
	



ttitle off