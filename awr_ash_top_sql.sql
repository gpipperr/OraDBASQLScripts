--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc: get  the statistic information over a the active sessions of a DB user
--  see 
--  http://www.oracle.com/technetwork/database/manageability/ppt-active-session-history-129612.pdf
--==============================================================================
prompt
prompt !!!!You need the Tuning Pack for this feature!!!!
prompt


set linesize 130 pagesize 300 

define MINUTES_SINCE="( 1/24/60 * 120)"

-- top sql
select sql_id
     , count(*)
	 , round(count(*)/sum(count(*)) over (), 2) pctload
 from v$active_session_history
 where sample_time > sysdate - &&MINUTES_SINCE
   and session_type <> 'BACKGROUND'
 group by sql_id
order by count(*) desc
/

-- top io sql

select ash.sql_id
     , count(*)
 from v$active_session_history ash
    , v$event_name evt
where ash.sample_time > sysdate - &&MINUTES_SINCE
  and ash.session_state = 'WAITING'
  and ash.event_id = evt.event_id
  and evt.wait_class = 'User I/O'
group by sql_id
order by count(*) desc
/


-- top cpu sql

select ash.sql_id
     , count(*)
	 ,evt.wait_class
 from v$active_session_history ash
    , v$event_name evt
where ash.sample_time > sysdate - &&MINUTES_SINCE
  --and ash.session_state = 'WAITING'
  and ash.event_id = evt.event_id
  --and evt.wait_class like '%CPU%'
group by sql_id,evt.wait_class
order by count(*) desc
/


