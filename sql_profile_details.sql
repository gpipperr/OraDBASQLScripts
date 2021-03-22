-- ==============================================================================
-- Show the detail hints from 
-- Must be run with dba privileges 
-- see 
--  http://antognini.ch/2008/08/sql-profiles-in-data-dictionary/
--  http://antognini.ch/papers/SQLProfiles_20060622.pdf
--
-- ==============================================================================
set verify  off
set linesize 130 pagesize 300 

define PROF_NAME = '&1' 

prompt
prompt Parameter 1 = Tab Name          => &&PROF_NAME.
prompt

column hint format a120 WORD_WRAPPED

SELECT extractValue(value(h),'.') AS hint
  FROM sys.sqlobj$data od
     , sys.sqlobj$ so
	 , table(xmlsequence(extract(xmltype(od.comp_data),'/outline_data/hint'))) h
 WHERE upper(so.name) like upper('&&PROF_NAME.')
    AND so.signature = od.signature
    AND so.category = od.category
    AND so.obj_type = od.obj_type
    AND so.plan_id = od.plan_id
/	 


/* 10g

select h.attr_val as outline_hints
  from dba_sql_profiles p
      ,sys.sqlprof$attr h
 where p.signature = h.signature
   and p.category = h.category
   and p.name like upper('&&PROF_NAME.')
 order by h.attr#
 /

-- aus AWR
-- muss aber im AWR sein!

SELECT plan_table_output FROM TABLE(dbms_xplan.display_awr('SQL_ID','PLAN_HASH',NULL,'OUTLINE'))

DBMS_SQLTUNE.IMPORT_SQL_PROFILE(
  SQL_TEXT => SQL_FTEXT,
  PROFILE => SQLPROF_ATTR('FULL(@"SEL$1" "OBJECTS"@"SEL$1") FULL(@"SEL$1" "SEGMENTS"@"SEL$1")'),
  NAME => 'PROFILE_gy6fj888vt27y',
  REPLACE => TRUE,
  FORCE_MATCH => TRUE
);

*/