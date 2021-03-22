--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   show invalid constraints in the database
-- Date:   10 2015
--
--==============================================================================
set linesize 130 pagesize 300 


ttitle "List of not validated or invalid constraints" skip 2

column owner                format a20
column table_name           format a30
column constraint_name      format a30
column validated            format a20

select owner
       ,  table_name
       ,  constraint_name
       ,  status
       ,  validated
    from dba_constraints
   where     (   validated != 'VALIDATED'
       or status != 'ENABLED')
     and owner not in
         ('SYS'
        ,  'MDSYS'
        ,  'SI_INFORMTN_SCHEMA'
        ,  'ORDPLUGINS'
        ,  'ORDDATA'
        ,  'ORDSYS'
        ,  'EXFSYS'
        ,  'XS$NULL'
        ,  'XDB'
        ,  'CTXSYS'
        ,  'WMSYS'
        ,  'APPQOSSYS'
        ,  'DBSNMP'
        ,  'ORACLE_OCM'
        ,  'DIP'
        ,  'OUTLN'
        ,  'SYSTEM'
        ,  'FLOWS_FILES'
        ,  'PUBLIC'
        ,  'SYSMAN'
        ,  'OLAPSYS'
        ,  'OWBSYS'
        ,  'OWBSYS_AUDIT')
order by owner
/


ttitle off