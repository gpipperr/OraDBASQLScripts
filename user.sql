--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   get the user rights and grants
-- Date:   September 2012
--
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define USER_NAME = &1 

set verify off

SET linesize 120 pagesize 500 

ttitle left  "User Account status" skip 2

select username
      , account_status
	  , lock_date
	  , expiry_date
	  , default_tablespace
	  , temporary_tablespace
 from dba_users 
 where username like upper('&&USER_NAME.')
 /

ttitle left  "User Info" skip 2

select lpad(' ', 2 * level) || granted_role "User, his roles and privileges"
  from (
        /* THE USERS */
        select null     grantee
               ,username granted_role
          from dba_users
         where username like upper('&&USER_NAME.')
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

ttitle left  "Object rights from &&USER_NAME. to other User" skip 2

column grantee format a25
column GRANTOR format a25
column PRIVILEGE format a20
column cnt format 9999

select GRANTOR
      ,grantee
      ,PRIVILEGE
      ,table_name
      ,count(*) as cnt
  from DBA_TAB_PRIVS
 where owner like upper('&&USER_NAME.')
-- owner not in ('SYS','MDSYS','SI_INFORMTN_SCHEMA','ORDPLUGINS','ORDDATA','ORDSYS','EXFSYS','XS$NULL','XDB','CTXSYS','WMSYS','APPQOSSYS','DBSNMP','ORACLE_OCM','DIP','OUTLN','SYSTEM','FLOWS_FILES','PUBLIC','SYSMAN','OLAPSYS','OWBSYS','OWBSYS_AUDIT')
 group by owner
         ,grantee
         ,GRANTOR
         ,PRIVILEGE
         ,table_name 
order by owner,table_name,	PRIVILEGE		
/

ttitle left  "Object rights from other user to &&USER_NAME." skip 2



select GRANTOR
      ,grantee
      ,PRIVILEGE
      ,table_name
      ,count(*) as cnt
  from DBA_TAB_PRIVS
 where grantee like upper('&&USER_NAME.')
 group by owner
         ,grantee
         ,GRANTOR
         ,PRIVILEGE
         ,table_name
order by owner,table_name,	PRIVILEGE				
/

ttitle left  "User Quota Settings for the user &&USER_NAME." skip 2

column tablespace_name format a20 heading "Tablespace|Name"
column username        format a20 heading "User|Name"
column m_bytes         format 999G999D99 heading "Bytes"
column max_bytes_mb    format 999G999D99 heading "Max|Bytes"


select tablespace_name
     , username
	  , round(bytes /1024/1024,2) as m_bytes
	  , round(max_bytes /1024/1024,2) as max_bytes_mb
from dba_ts_quotas
where username like upper('&&USER_NAME.')
/

prompt ... max_bytes = -1 => unlimited!
prompt
prompt ... to set the quota 
prompt ...  alter user &&USER_NAME. quota unlimited on xxxxxxx;
prompt ...  alter user &&USER_NAME. quota 50M       on xxxxxxx;
prompt ...  alter user &&USER_NAME. quota 0         on xxxxxxx;
prompt


ttitle left  "Profile Settings for the user &&USER_NAME." skip 2

column PROFILE format a18
column RESOURCE_NAME format a30
column limit format a20

select  p.PROFILE
      , p.RESOURCE_NAME
	   , p.limit
 from    dba_profiles p
      , dba_users u
where u.PROFILE=p.PROFILE
  and u.username like upper('&&USER_NAME.')	
order by p.RESOURCE_NAME
/

ttitle left  "Proxy Settings for the user &&USER_NAME." skip 2

column PROXY                    format a15 heading "Proxy"
column CLIENT                   format a15 heading "Client|User"
column AUTHENTICATION           format a5 heading "Auth"
column AUTHORIZATION_CONSTRAINT format a40 heading "Auth|Const"
column ROLE                     format a15 heading "Role"
column PROXY_AUTHORITY          format a10 heading "Proxy|Auth"

  
select 	proxy
	, client
	, authentication
	, authorization_constraint
	, role
	, proxy_authority
 from dba_proxies
where proxy like upper('&&USER_NAME.%')	
/

--ttitle left  "Password History for the user &&USER_NAME." skip 2
--
--SELECT user$.NAME
--     , user$.PASSWORD
--	 , user$.ptime
--	 , user_history$.password_date
--FROM  SYS.user_history$
--    , SYS.user$
--WHERE user_history$.user# = user$.user#
-- and user$.NAME like upper('&&USER_NAME.%')	
-- /
--
--prompt ... If you have PASSWORD_REUSE_TIME and/or PASSWORD_REUSE_MAX set in a profile assigned to a user account 
--prompt ... then you can reference dictionary table USER_HISTORY$ for when the password was changed for this account.

prompt ...
prompt ... Unlock User         use "alter user xxxx account unlock;" 
prompt ... Expire the password use "alter user xxx password expire;"

ttitle off
