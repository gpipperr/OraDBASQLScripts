 --==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc:   SQL Script to set all datafiles of a tablespae to autoexend unlimited
-- Date:   04.2016
--==============================================================================

set verify off
set linesize 130 pagesize 300 


define TABLESPACE = "&1"

prompt
prompt Parameter 1 = Tablespace Name  => '&TABLESPACE' 
prompt

ttitle left  "Create the DDL to set all Files of the tablespace :: &&TABLESPACE" skip 2


select  'alter database datafile '''||  file_name||''' autoextend on maxsize unlimited;'
 from  dba_data_files dbf
     , dba_tablespaces et
where dbf.TABLESPACE_NAME = et.TABLESPACE_NAME
  and et.TABLESPACE_NAME=upper('&&TABLESPACE')
/

  
ttitle off
 