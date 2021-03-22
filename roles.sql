--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   get DB roles
-- Date:   November 2013
--==============================================================================
set verify  off
set linesize 130 pagesize 300 

define ROLENAME    = '&1' 

prompt
prompt Parameter 1 = Role Name => &&ROLENAME.
prompt

column role format a32

select role 
  from dba_roles
where upper(role) like upper('&&ROLENAME.')
order by role asc
/

