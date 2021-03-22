--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: On which objects this pl/sql code depends
--==============================================================================
set verify  off
set linesize 130 pagesize 300 
set trimspool on

define OWNER        = '&1' 
define PACKAGE_NAME = '&2' 

prompt
prompt Parameter 1 = Owner   Name   => &&OWNER.
prompt Parameter 2 = Package Name   => &&PACKAGE_NAME.
prompt

column referenced_name  format a28
column referenced_owner format a20
column status           format a10 heading "Status"

select  d.referenced_owner
     ,  d.referenced_name
     ,  d.referenced_type
	  ,  o.last_ddl_time
	  ,  o.status
 from  dba_dependencies d
     , dba_objects o
where d.name  = upper('&&PACKAGE_NAME.') 
  and d.owner = upper('&&OWNER.')
  and o.owner=d.referenced_owner
  and o.object_type=d.referenced_type
  and o.object_name=d.referenced_name  
order by 
   d.referenced_owner
 , d.referenced_name
 , d.referenced_type
/


--
--column hirachie format a40
--
--SELECT RPAD (' ', 3*(LEVEL-1)) || d.referenced_name || ' (' || d.type || ') ' as hirachie
--  FROM dba_dependencies d
--CONNECT BY  PRIOR RTRIM( d.name || d.owner) =  RTRIM(d.referenced_name || d.referenced_owner)
--  START WITH name =  upper('&&PACKAGE_NAME.')  AND owner = upper('&&OWNER.')
--/		
--
