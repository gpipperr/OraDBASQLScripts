--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   show invalid objects in the database
-- Date:   01.September 2012
--
--==============================================================================
set linesize 130 pagesize 300 
set verify off

ttitle center "Invalid Objects in the database" skip 2

define IGNORE_SCHEMA='''GPI'''

column owner format a15
column object_type format a18

break on report
compute sum of anzahl on report

  select owner, object_type, count (*) as anzahl
    from dba_objects
   where status != 'VALID'
     and object_type!='MATERIALIZED VIEW'
   --and owner not in (&IGNORE_SCHEMA)
--group by rollup(owner, object_type)
group by owner, object_type
order by owner
/


ttitle "count of invalid materialized view" skip 2
select owner
    , count (*) as anzahl 
	, compile_state
	, staleness
 from dba_mviews
where compile_state != 'VALID' or staleness !='FRESH'
 --and owner not in (&IGNORE_SCHEMA)
group by owner,compile_state,staleness
order by owner,compile_state
/

ttitle "Count of not validated or invalid constraints" skip 2

select owner,count(*) as anzahl,validated,status
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
group by validated,status,owner
order by owner
/
prompt ... 
prompt ... for more details use invalid_constraints.sql
prompt ... 

clear breaks




ttitle "List of invalid indexes" skip 2

select owner
     ,  index_name
     ,  status
     ,  'no partition'
  from dba_indexes  
 where status not in ('VALID', 'N/A')
union
select index_owner
     ,  index_name
     ,  status
     ,  partition_name
  from dba_ind_partitions
 where status not in ('VALID', 'N/A', 'USABLE')
order by owner 
/



ttitle "List of invalid Objects" skip 2
break on owner skip 2
column owner noprint

  select object_type || '-> ' || decode (owner, 'PUBLIC', '', owner || '.') || object_name as Overview, owner
    from dba_objects
   where status != 'VALID'
    and owner not in (&IGNORE_SCHEMA)
    and object_type!='MATERIALIZED VIEW'   
order by owner,object_type
/

clear breaks
column owner print

ttitle "-- Command to touch the  Objects" skip 2
set pagesize 4000 

spool desc_invalid.log

select 'desc ' || decode (owner, 'PUBLIC', '', owner || '.') || object_name as "-- TOUCH_ME"
  from dba_objects
 where status != 'VALID' 
   and owner not in (&IGNORE_SCHEMA)
   and object_type!='MATERIALIZED VIEW'
order by owner,object_type  
/

spool off

prompt ... 
prompt ... to describe all invalid objects call desc_invalid.log
prompt ... 

set pagesize 300

ttitle off