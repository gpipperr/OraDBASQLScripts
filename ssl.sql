--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   actual connections to the database
-- Date:   01.September 2012
--==============================================================================
set verify off
set linesize 140 pagesize 300 

define USER_NAME   =  &1

prompt
prompt Parameter 1 = Username          => &&USER_NAME.
prompt


ttitle left  "Check if this Session is connected via TCP with SSL TCPS or TCP" skip 2


SELECT SYS_CONTEXT('USERENV','NETWORK_PROTOCOL') AS connect_protocol FROM dual;


ttitle left  "Check connection information of all sesssions" skip 2

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
column network_service_banner format a100 format "Network|Info"


select   s.inst_id
       , s.sid
       , s.serial#
       , s.status
       , s.username
       , s.machine
       , s.terminal
       , s.program
       , s.OSUSER
       , s.module
       --, s.to_char (LOGON_TIME, 'dd.mm hh24:mi') as LOGON_TIME
       , s.client_identifier
       , s.client_info
       , c.network_service_banner 
	   --, c.client_charset
      -- , c.client_oci_library
       , c.authentication_type
  from gv$session_connect_info c 
     , gv$session s 
 where c.sid = s.sid 
  -- and c.serial#=s.serial# 
   and c.inst_id=s.inst_id
   and s.username is not null
  order by 1
/

ttitle off
