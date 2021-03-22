--==============================================================================
-- GPI - Gunther Pippèrr
-- get my user connection
--==============================================================================
set linesize 130 pagesize 300 

column MY_USER_AND_SERVICE format a100 heading "My Connection is"

select  'Instance :: '||SYS_CONTEXT('USERENV', 'INSTANCE_NAME')||' ++ Service :: '||SYS_CONTEXT('USERENV', 'SERVICE_NAME') || ' ++ User :: '||user ||' ++ SID :: '||sys_context('userenv','SID')||' + Inst ID :: '||sys_context('userenv','INSTANCE') as MY_USER_AND_SERVICE
  from dual
/

select dbms_debug_jdwp.current_session_id sid
     , dbms_debug_jdwp.current_session_serial serial
from dual
/

prompt


prompt ... will show you are privileges on the database.

select * from session_privs
/

select * from session_roles
/


prompt INHERIT PRIVILEGES for this user



select grantee
     , table_name
	 , privilege
   from user_tab_privs
  where privilege = 'INHERIT PRIVILEGES'
 /
 
