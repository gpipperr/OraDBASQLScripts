--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   extract the real SQL from a query over a view
--
-- Parameter 2: Owner of the table/object
-- Parameter 1: Name of the table/object
--
-- Must be run with dba privileges
-- Source : https://oracle-base.com/articles/12c/expand-sql-text-12cr1
--==============================================================================
set verify off
set linesize 130 pagesize 3000 

define OWNER    = '&1' 
define VIEW_NAME = '&2' 

prompt
prompt Parameter 1 = Owner Name => &&OWNER.
prompt Parameter 2 = Tab Name   => &&VIEW_NAME.
prompt


SET SERVEROUTPUT ON 

DECLARE
  l_clob CLOB;
BEGIN
  DBMS_UTILITY.expand_sql_text (
    input_sql_text  => 'select count(*) from &&OWNER..&&VIEW_NAME.',
    output_sql_text => l_clob
  );

  DBMS_OUTPUT.put_line(l_clob);
END;
/


