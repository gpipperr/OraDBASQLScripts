 --==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc:   Create SQL Script to set all datafiles of a tablespae to defined size
-- Date:   04.2016
--==============================================================================

set verify off
set linesize 130 pagesize 300 


define TABLESPACE = "&1"

define SIZE_MB    = "&2"

prompt
prompt Parameter 1 = Tablespace Name  => '&TABLESPACE' 
prompt Parameter 2 = New Size         => '&SIZE_MB' 
prompt

ttitle left  "Create the DDL to set all Files of the tablespace :: &&TABLESPACE" skip 2


select  'alter database datafile '''||  file_name||''' resize &&SIZE_MB.M;'
 from  dba_data_files dbf
     , dba_tablespaces et
where dbf.TABLESPACE_NAME = et.TABLESPACE_NAME
  and et.TABLESPACE_NAME in upper('&&TABLESPACE.')
/

  
ttitle off
 