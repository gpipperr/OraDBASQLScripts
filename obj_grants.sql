--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: grants to an object in the database
--==============================================================================
--desc DBA_ROLE_PRIVS
--desc DBA_SYS_PRIVS
--desc DBA_TAB_PRIVS
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define OWNER    = '&1'
define TAB_NAME = '&2'

prompt
prompt Parameter 1 = Owner Name => &&OWNER.
prompt Parameter 2 = Tab Name   => &&TAB_NAME.
prompt

ttitle left  "Grants of the object &OWNER..&TAB_NAME." skip 2

column GRANTEE     format a20
column OWNER       format a20
column TABLE_NAME  format a20
column GRANTOR     format a20
column PRIVILEGE   format a20

select OWNER
     ,  TABLE_NAME
     ,  GRANTOR
     ,  GRANTEE
     ,  PRIVILEGE
  --        , GRANTABLE
  --        , HIERARCHY
  from dba_tab_privs
 where     owner = upper ('&OWNER')
       and table_name = upper ('&TAB_NAME')
/

ttitle off


