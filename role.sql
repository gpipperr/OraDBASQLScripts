--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   get the rights on a DB role
-- Date:   November 2013
--==============================================================================
set verify  off
set linesize 130 pagesize 300 

define ROLENAME    = '&1' 

prompt
prompt Parameter 1 = Role Name => &&ROLENAME.
prompt

column role format a32
column grantee format a20
column GRANTOR format a20
column PRIVILEGE format a20
column cnt format 9999
column TABLE_NAME format a20

ttitle left  "Role Info" skip 2

select lpad(' ', 2 * level) || granted_role "Role, his roles and privileges"
  from (
        /* THE USERS */
        select null  grantee
               ,role granted_role
          from dba_roles
         where upper(role) like upper('&&ROLENAME.')
        /* THE ROLES TO ROLES RELATIONS */
        union
        select grantee
              ,granted_role
          from dba_role_privs
        /* THE ROLES TO PRIVILEGE RELATIONS */
        union
        select grantee
              ,privilege
          from dba_sys_privs)
 start with grantee is null
connect by grantee = prior granted_role
/


ttitle left  "Object rights on this Role  &&ROLENAME." skip 2

select GRANTOR
      ,grantee
      ,PRIVILEGE
      ,table_name
      ,count(*) as cnt
  from DBA_TAB_PRIVS
 where grantee like upper('&&ROLENAME.')
 group by owner
         ,grantee
         ,GRANTOR
         ,PRIVILEGE
         ,table_name
order by owner,table_name,	PRIVILEGE				
/

ttitle off