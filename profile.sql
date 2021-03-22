--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   get the profiles of the database
-- Date:   September 2013
--
--==============================================================================
set linesize 130 pagesize 300 

define USER_NAME = &1 

column PROFILE       format a26 heading "Profil"
column RESOURCE_NAME format a25 heading "Resource Name"
column RESOURCE_TYPE format a10 heading "Resourcen | Type"
column LIMIT         format a20 heading "Limit"

select PROFILE
	,  RESOURCE_NAME
	,  RESOURCE_TYPE
	,  LIMIT
 from dba_profiles
order by PROFILE,RESOURCE_TYPE
/

prompt ...
prompt ... example to change: "ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS 50 PASSWORD_LIFE_TIME UNLIMITED;"
prompt ...

ttitle left  "Which Profile is in user" skip 2

column username   format a24 heading "User Name"
column account_status   format a20 heading "Status"

select username
    ,  profile
	,  account_status 
 from dba_users
order by profile,account_status
/

ttitle off

prompt ... to set the profile of the user: alter user <name> profile <profile>;