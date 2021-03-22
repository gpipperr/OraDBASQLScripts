--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   show informations about directories in the database
-- Date:   08.08.2013
--
--==============================================================================
set linesize 130 pagesize 300 
 
ttitle  "Directories in the database"  SKIP 1 

column owner          format a15
column directory_name format a25
column directory_path format a60
column grantee        format a25
column grantor        format a18
column privilege      format a10
column privilege_list format a30

select  owner
      , directory_name
      , directory_path
  from dba_directories
 order by 1
         ,2
/

ttitle  "Grants to this directories"  SKIP 1 
       
select t.table_name as directory_name
	 , t.grantor
     , t.grantee
	 --, listagg(t.privilege,':') WITHIN GROUP (ORDER BY t.privilege )  AS privilege_list      
  from dba_tab_privs t
     , dba_directories  d
 where t.table_name = d.directory_name
  group by t.table_name 
	, t.grantor
    , t.grantee
order by t.table_name 
       , t.grantee
/

prompt ...
prompt To grant use : grant read,write on directory xxxx to yyyyyy;
prompt ...

ttitle off
