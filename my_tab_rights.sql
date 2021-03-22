--==============================================================================
-- GPI - Gunther Pippèrr
--
-- get my table rights on this database
--
--==============================================================================
set linesize 130 pagesize 300 

column table_schema  format a20
column table_name    format  a30
column privilege     format a15


prompt ... will show you all table privileges on the database.

select table_schema
    ,  table_name
	,  privilege
from all_tab_privs
where grantee=user
order by 1,2,3
/

prompt
