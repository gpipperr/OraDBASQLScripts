--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   show the errors in the database
-- Must be run with dba privileges
--==============================================================================
set verify  off
set linesize 130 pagesize 300 
set trimspool on

column owner format a30 heading "Owner"
column name  format a30 heading "Object|Name"
column type  format a20 heading "Object|Type"
column line  format 9G999 heading "Line|No."
column text  format a100 heading "Error Message" fold_before WORD_WRAPPED NEWLINE

select owner
     , name
	 , type
	 , line
	 , text 
from dba_errors
order by owner
       , name
	   , line
/
