--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   SQLNet Infos
-- Date:   30.05 2019
--==============================================================================
set verify off
set linesize 140 pagesize 300 



ttitle left  "Get list of sqlnet adapters in use for this connections" skip 2

select sid
     , network_service_banner 
 from V$SESSION_CONNECT_INFO   
 where sid = sys_context('USERENV','SID')
 /
 
 
ttitle left  "Check if this Session is connected via TCP with SSL TCPS or TCP" skip 2

SELECT SYS_CONTEXT('USERENV','NETWORK_PROTOCOL') AS connect_protocol FROM dual;

ttitle off