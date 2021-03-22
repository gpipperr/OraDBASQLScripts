--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: HTML Report over all invalid objects of a database, 
--       for example to discuss with development which objects can be deleted
-- Date: September 2015
--
--==============================================================================

col SPOOL_NAME_COL new_val SPOOL_NAME
 
SELECT replace(ora_database_name||'_'||SYS_CONTEXT('USERENV','HOST')||'_'||to_char(sysdate,'dd_mm_yyyy_hh24_mi')||'_invalid_overview.html','\','_') 
--' resolve syntax highlight bug FROM my editer .-(
  AS SPOOL_NAME_COL
FROM dual
/

set verify off
SET linesize 250 pagesize 2000 

spool &&SPOOL_NAME

set markup html on

ttitle left  "Invalid Object Overview of this database" skip 2

select o.owner
     , o.object_name
     , o.object_type
     , o.status
     , 'IN USE' as IN_USE_OR_ARCHIVE
     , 'n/a'   as comments
	 , 'n/a' as responsible_developer
     , o.created
     , o.LAST_DDL_TIME
        -- dependencies
     , (select   count(*) as results from dba_dependencies dep where dep.REFERENCED_OWNER=o.owner and dep.REFERENCED_NAME=o.object_name) as depObjCount
     , (select   substr(rtrim ( xmlagg (xmlelement (c, dep.type||':'||dep.name || ',') order by dep.name).extract ('//text()'), ',' ),1,3999) as results from dba_dependencies dep where dep.REFERENCED_OWNER=o.owner and dep.REFERENCED_NAME=o.object_name) as depObjList
  from dba_objects o 
where o.status!='VALID'
  and o.object_type!='MATERIALIZED VIEW'
order by owner,object_type
/

set markup html off

spool off
ttitle off

-- works only in a ms windows environment
-- auto start of the result in a browser window

host &&SPOOL_NAME
