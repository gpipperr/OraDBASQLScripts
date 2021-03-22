--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   Status of the login instance
-- Date:   01.September 2013
--==============================================================================
set linesize 130 pagesize 300 

ttitle left  "Status of this instances" skip 2

column status    format A8  heading "Status"
column name      format A8  heading "Instance|Name"
column startzeit format A15 heading "Start|Time"
column host_name format A35 heading "Server|Name"

select  status
      , instance_name as name
      , to_char(STARTUP_TIME, 'dd.mm.YY hh24:mi') as startzeit
	  , host_name 
  from v$instance
 order by 1
/

ttitle left  "The instance is running under this OS User:" skip 2

column osuser    format A20  heading "OS User"

select osuser 
  from v$session 
 where program like '%PMON%'
/

ttitle off
