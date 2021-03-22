--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   HTML Report over all tables of a database, 
--         for example to discuss with development which tables can be deleted
-- Date:   September 2015
--
--==============================================================================

col SPOOL_NAME_COL new_val SPOOL_NAME
 
SELECT replace(ora_database_name||'_'||SYS_CONTEXT('USERENV','HOST')||'_'||to_char(sysdate,'dd_mm_yyyy_hh24_mi')||'_table_overview.html','\','_') 
--' resolve syntax highlight bug FROM my editer .-(
  AS SPOOL_NAME_COL
FROM dual
/

set verify off
SET linesize 250 pagesize 2000 

spool &&SPOOL_NAME

set markup html on

ttitle left  "Table Overview of this database" skip 2

select   t.owner
       , t.table_name
       , o.OBJECT_TYPE
       , nvl(o.SUBOBJECT_NAME,'-') as SUBOBJECT_NAME
       , 'IN USE' as IN_USE_OR_ARCHIVE
       , round( s.bytes /1024/1024 , 3) as size_MB
       , t.num_rows
       , t.LAST_ANALYZED
       , o.LAST_DDL_TIME
       , o.CREATED
       , t.partitioned
       , t.compression
       , nvl (c.comments, 'n/a') as comments
       -- plsql dependencies
       , (select   count(*) as results from dba_dependencies dep where dep.REFERENCED_OWNER=t.owner and dep.REFERENCED_NAME=t.table_name) as depObjCount
       , (select   substr(rtrim ( xmlagg (xmlelement (c, dep.type||':'||dep.name || ',') order by dep.name).extract ('//text()'), ',' ),1,3999) as results from dba_dependencies dep where dep.REFERENCED_OWNER=t.owner and dep.REFERENCED_NAME=t.table_name) as depObjList
    from dba_tables t
       , dba_tab_comments c
       , dba_objects o
       , dba_segments s       
   where 1=1 
     --
     and c.table_name(+) = t.table_name
     and c.owner(+) = t.owner
     and c.table_type(+) = 'TABLE'
     --
     and o.object_name = t.table_name
     and o.owner      = t.owner
     --
     and s.segment_name = o.object_name
     and s.owner        = o.owner
     and nvl(s.partition_name,'n/a')=nvl(o.subobject_name,'n/a')      
     --
     --and t.owner = 'GPI'
     --
     and t.owner not in
          ('SYS', 'MDSYS', 'SI_INFORMTN_SCHEMA', 'ORDPLUGINS', 'ORDDATA', 'ORDSYS', 'EXFSYS', 'XS$NULL', 'XDB', 'CTXSYS', 'WMSYS'
         , 'APPQOSSYS', 'DBSNMP', 'ORACLE_OCM', 'DIP', 'OUTLN', 'SYSTEM', 'FLOWS_FILES', 'SYSMAN', 'OLAPSYS', 'OWBSYS'
         , 'OWBSYS_AUDIT')     
     --
order by t.owner
       , t.table_name
/

set markup html off

spool off
ttitle off

-- works only in a ms windows environment
-- auto start of the result in a browser window
host &&SPOOL_NAME
