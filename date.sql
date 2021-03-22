--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   show the actual date of the database
--
--==============================================================================
set linesize 130 pagesize 300 

column DBTIMEZONE      format a15     heading "Database|Time Zone" 
column SESSIONTIMEZONE format a15     heading "Session|Time Zone" 
column db_time         format a18     heading "DB|Time"
column sess_time       format a18     heading "Client|Time"
column diff_time       format 999.999 heading "Time gap|Client <=> DB"	 	  

select  DBTIMEZONE                                   
	  , to_char(sysdate,'dd.mm.yyyy hh24:mi')       as  db_time
	  , SESSIONTIMEZONE
	  , to_char(current_date,'dd.mm.yyyy hh24:mi')  as  sess_time
      , sysdate-current_date                        as  diff_time
from dual
/
