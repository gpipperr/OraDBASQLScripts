--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   HTML Report for the dependencies in the database
-- Date:   September 2015
--
--==============================================================================

col SPOOL_NAME_COL new_val SPOOL_NAME
 
SELECT replace(ora_database_name||'_'||SYS_CONTEXT('USERENV','HOST')||'_'||to_char(sysdate,'dd_mm_yyyy_hh24_mi')||'_dependencies.html','\','_') 
--' resolve syntax highlight bug FROM my editer .-(
  AS SPOOL_NAME_COL
FROM dual
/

set verify off
SET linesize 250 pagesize 2000 

spool &&SPOOL_NAME


set markup html on

ttitle left  "Schema Referenzes over grants " skip 2


select grantee ,'=',PRIVILEGE,'>' ,owner ,count(*) as cnt
  from DBA_TAB_PRIVS
 where GRANTOR not in ('SYS','MDSYS','SI_INFORMTN_SCHEMA','ORDPLUGINS','ORDDATA','ORDSYS','EXFSYS','XS$NULL','XDB','CTXSYS','WMSYS','APPQOSSYS','DBSNMP','ORACLE_OCM','DIP','OUTLN','SYSTEM','FLOWS_FILES','SYSMAN','OLAPSYS','OWBSYS','OWBSYS_AUDIT')
  and table_name not like 'BIN$%'
  and PRIVILEGE in ('UPDATE','INSERT')
 group by owner ,'=>',PRIVILEGE,'>', grantee
order by grantee,PRIVILEGE
/


ttitle left  "Schema Referenzes over Object Rights  - insert or update" skip 2

select dep.owner ,' => Use Object from'
    , dep.referenced_owner as Referenz 
    , count(*) as total_obj_cnt
    , sum(decode(dep.referenced_type,'INDEX',1,0)) as idx_cnt
    , sum(decode(dep.referenced_type,'TABLE',1,0)) as tab_cnt
    , sum(decode(dep.referenced_type,'VIEW',1,0)) as  view_cnt
    , sum(decode(dep.referenced_type,'PACKAGE BODY',1,decode(dep.referenced_type,'PACKAGE',1,0))) as  package_cnt
  from dba_dependencies dep
 where dep.owner not in ('SYS','MDSYS','SI_INFORMTN_SCHEMA','ORDPLUGINS','ORDDATA','ORDSYS','EXFSYS','XS$NULL','XDB','CTXSYS','WMSYS','APPQOSSYS','DBSNMP','ORACLE_OCM','DIP','OUTLN','SYSTEM','FLOWS_FILES','SYSMAN','OLAPSYS','OWBSYS','OWBSYS_AUDIT')
   and dep.referenced_owner != 'PUBLIC'
   and dep.referenced_owner !=  dep.owner
group by dep.owner ,'=>', dep.referenced_owner
order by 1
/


ttitle left  "Schema Referenzes over Object Rights - select " skip 2

select grantee ,'=',PRIVILEGE,'>' ,owner ,count(*) as cnt
  from DBA_TAB_PRIVS
 where GRANTOR not in ('SYS','MDSYS','SI_INFORMTN_SCHEMA','ORDPLUGINS','ORDDATA','ORDSYS','EXFSYS','XS$NULL','XDB','CTXSYS','WMSYS','APPQOSSYS','DBSNMP','ORACLE_OCM','DIP','OUTLN','SYSTEM','FLOWS_FILES','SYSMAN','OLAPSYS','OWBSYS','OWBSYS_AUDIT')
  and table_name not like 'BIN$%'
  and PRIVILEGE in ('SELECT')
 group by owner ,'=>',PRIVILEGE,'>', grantee
order by grantee,PRIVILEGE
/


set markup html off

spool off
ttitle off

-- works only in a ms windows environment
-- auto start of the result in a browser window
host &&SPOOL_NAME



