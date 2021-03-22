--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   get the user rights and grants
-- Date:   September 2012
--
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define USER_NAME = &1 


column grantee      format a25
column GRANTOR      format a25
column PRIVILEGE    format a25  heading "Priv"
column table_name   format a20  heading "Table|Name"
column ADMIN_OPTION format a3   heading "Adm|OPT"
column COMMON       format a3   heading "Com"
column INHERITED    format a7   heading "Inherit"


column table_name   format a26  heading "User|Name"


ttitle left  "INHERIT PRIVILEGES for &&USER_NAME" skip 2

select grantee, table_name, privilege
   from dba_tab_privs
  where privilege = 'INHERIT PRIVILEGES'
    and grantee like upper('&&USER_NAME.')
 /
 

ttitle left  "INHERIT PRIVILEGES from to other User" skip 2
 
select GRANTEE
	,  PRIVILEGE
	,  ADMIN_OPTION
	,  COMMON
	,  INHERITED
  from dba_sys_privs
  where privilege like '%INHERIT%'
    and grantee like upper('&&USER_NAME.')
/

ttitle OFF

column table_name   format a20  heading "table_name"

--------------
