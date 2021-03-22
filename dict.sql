--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   search data dictionary views
-- Date:   September 2012
--
--==============================================================================

-- FIX IT
-- umbauen auf REGEXP_SUBSTR(table_name,'_+,') um dba_,all_,user_ 
--

set linesize 130 pagesize 300 

set  verify off

column table_name format a30
column comments   format a85

select table_name,comments
  from dict
 where lower(comments) like lower('%&1.%')
   and table_name like 'DBA%'
/

set  verify on
