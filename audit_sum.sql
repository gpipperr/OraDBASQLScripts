--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   Query the audit log entries
--
-- Must be run with dba privileges
--
--==============================================================================
set linesize 130 pagesize 300 

column username    format a20  heading "DB User|name"
column action_name format a25  heading "Action|name"
column first_log   format a25  heading "First|entry"
column last_log    format a25  heading "Last|entry"
column entries     format 999G999G999 heading "Audit|entries"

ttitle left  "Audit Trail from time until time" skip 2

select to_char(min(timestamp),'dd.mm.yyyy hh24:mi:ss') as first_log
	 ,  to_char(max(timestamp),'dd.mm.yyyy hh24:mi:ss') as last_log
	 , count(*) as entries
 from dba_audit_trail
order by 1
/


ttitle left  "Audit Object Log entries " skip 2

select username
     , action_name
	 , count(*) as entries
	 , to_char(min(timestamp),'dd.mm.yyyy hh24:mi:ss') as first_log
	 , to_char(max(timestamp),'dd.mm.yyyy hh24:mi:ss') as last_log
 from dba_audit_object
group by username,action_name
order by 1
/


--------------------- Details ----------------------------

column action_count format 9G999G999 heading "Action|Count"
column os_username  format a16 heading "User|Name"
column username     format a15  heading "DB User|name"
column action_name format a20  heading "Action|name"
column instance_number format 99 heading "In|st"
column user_host  format a11 heading "User|Host"
column first_log   format a15  heading "First|entry"
column last_log    format a15  heading "Last|entry"

break on instance_number
--COMPUTE SUM OF action_count ON first_log


ttitle left  "Audit log summary overview " skip 2

select  count(*) as action_count
     ,  os_username
	 ,  (case  when length(USERHOST) > 10  then '...'||substr(USERHOST,-8,10) else USERHOST end)  as user_host    
	 ,  username
	 ,  instance_number
	 ,  to_char(min(extended_timestamp),'dd.mm hh24:mi') as first_log
	 ,  to_char(max(extended_timestamp),'dd.mm hh24:mi') as last_log
	 ,  action_name 
  from dba_audit_trail 
 where extended_timestamp between sysdate -(1/4) and sysdate
       -- username='GPI'
       -- extended_timestamp between to_date('13.11.2014 12:19','dd.mm.yyyy hh24:mi') and to_date('13.11.2014 12:21','dd.mm.yyyy hh24:mi')		
	   -- and USERHOST='---'
 group by  os_username 
     ,  (case  when length(USERHOST) > 10  then '...'||substr(USERHOST,-8,10) else USERHOST end) 
     ,  username
	 ,  action_name 		 
	 , instance_number
order by  instance_number,username,action_name	 
 /
	 
		 
clear break
clear computes		 

prompt
prompt ... for detail information call:                  "audit_rep.sql"
prompt ... for the space usage of the audit$ table call: "tab_space.sql aud$"
prompt

ttitle off
