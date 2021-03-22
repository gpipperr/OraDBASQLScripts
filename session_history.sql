--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc:  get information about the last session in the database
--   
--==============================================================================
--  see 
--  http://www.nocoug.org/download/2008-08/a-tour-of-the-awr-tables.nocoug-Aug-21-2008.abercrombie.html
-- 
--==============================================================================
prompt
prompt !!!!You need the Tuning Pack for this feature!!!!
prompt

prompt
prompt ... get the periods with more then 5 active sessions from the database
prompt

select * 
  from (
	select   sample_id
			 , sample_time
			 , inst_id
			 , count(*) as active_sessions
			 , sum(decode(session_state, 'ON CPU', 1, 0))  as cpu
			 , sum(decode(session_state, 'WAITING', 1, 0)) as waiting			          			 
	  from	gv$active_session_history
	 where	sample_time > sysdate - 10 --((1/24))
	 group by sample_id
	        , sample_time
			, inst_id
	 order by sample_id,inst_id
) 
where active_sessions >  32
/


-----

column sample_hour format a17


prompt
prompt ... show the activity of the last sessions
prompt

select to_char(round(sub1.sample_time, 'HH24'), 'MM.DD.YYYY HH24:MI') as sample_hour
		,instance_number
		,round(avg(sub1.on_cpu),1) as cpu_avg
		,round(avg(sub1.waiting),1) as wait_avg
		,round(avg(sub1.active_sessions),1) as act_avg
		,round( (variance(sub1.active_sessions)/avg(sub1.active_sessions)),1) as act_var_mean
from
   ( 
     select sample_id
			  ,sample_time
			  ,sum(decode(session_state, 'ON CPU', 1, 0))  as on_cpu
			  ,sum(decode(session_state, 'WAITING', 1, 0)) as waiting
			  ,count(*) as active_sessions
			  ,INSTANCE_NUMBER
      from dba_hist_active_sess_history
     where sample_time > sysdate - ((1/24))
		  --sample_time between to_date('27.03.2014 14:30','MM.DD.YYYY HH24:MI') and to_date('27.03.2014 14:32','MM.DD.YYYY HH24:MI')
     group by sample_id
	        ,sample_time
			,INSTANCE_NUMBER
   ) sub1
group by round(sub1.sample_time, 'HH24'),instance_number
order by round(sub1.sample_time, 'HH24'),instance_number
/

--------