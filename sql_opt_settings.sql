--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: Show the optimizer settings  for this statement 
--       parameter 1 - SQL ID
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define SQL_ID='&1'

prompt
prompt Parameter 1 = SQL ID     => &&SQL_ID.
prompt

break on child_number skip 1

select child_number
     , name
	 , value
  from v$sql_optimizer_env
 where sql_id = '&&SQL_ID.'
order by child_number
       , name
/

clear break