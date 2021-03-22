--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   describe a table in the database
--
-- Parameter 1: Owner of the table
-- Parameter 2: Name of the table
--
-- Must be run with dba privileges
-- 
--
--==============================================================================

set verify  off
set linesize 130 pagesize 300 

define OWNER    = '&1' 
define TAB_NAME = '&2' 

prompt
prompt Parameter 1 = Owner Name  => &&OWNER.
prompt Parameter 2 = Tab Name    => &&TAB_NAME.
prompt

column table_name     format a25 heading "Table|name" 
column grantee        format a25 heading "Granted|to" 
column PRIVILEGE      format a20 heading "PRIVILEGE"

ttitle left  "Show all rights on this table &OWNER..&TAB_NAME." skip 2

select table_name,grantee,PRIVILEGE
  from dba_tab_privs
 where table_name like upper('&TAB_NAME.')
  and  owner      like upper('&OWNER.')
 order by 1,2,3
/


ttitle off
