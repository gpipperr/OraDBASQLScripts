--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:  show the local objects
-- Must be run with user privileges
-- 
--==============================================================================


set verify  off
set linesize 130 pagesize 300 

define OBJ_NAME = '&1' 

prompt
prompt Parameter 1 = OBJ Name          => &&OBJ_NAME.
prompt

column object_name format a30
column object_type format a16
column last_ddl_time format a18

select object_name
     , object_type
	 , to_char(last_ddl_time ,'dd.mm.yyyy hh24:mi') as last_ddl_time
from user_objects
where OBJECT_NAME like upper('%&OBJ_NAME.%')
 and object_type not in ('INDEX','LOB','TABLE','VIEW','SEQUENCE')
order by object_type
        ,object_name
/