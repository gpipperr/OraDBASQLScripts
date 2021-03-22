--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: get all open incidents
--==============================================================================
set verify off
set linesize 130 pagesize 300 recsep off

set serveroutput on size 1000000


define METRIK_SUM='&1'

prompt
prompt Parameter 1 = METRIK_SUM     => &&METRIK_SUM.
prompt


column  target_name format a20  heading "Target|Name"
column  target_type format a12  heading "Target|Type"
column  msg         format a30  heading "Message" WORD_WRAPPED
column  event_name  format a28  heading "Event|Name"
column  reported_date format a18 heading "Reported|Date"
column  severity      format a8  heading "Severtiy" 
column  open_status   format 99  heading "OP|ST" 

ttitle left  "Incidents in the Environment" skip 2


select t.target_name
      ,t.target_type
      ,e.msg
      ,e.event_name
      ,to_char(e.reported_date,'dd.mm.yyyy hh24:mi') as  reported_date
      ,e.severity
      ,e.open_status
  from sysman.mgmt$incidents i
      ,sysman.MGMT$TARGET    t
      ,sysman.mgmt$events    e
 where t.target_guid = i.target_guid
   and i.severity != 'Clear'
   and e.incident_id = i.incident_id
   and e.severity != 'Clear'
   and upper(i.summary_msg) like upper('%&&METRIK_SUM.%')  
   --   and e.event_class = 'metric_alert' 
 order by t.target_name,e.event_class   
/		 




column  target_name format a40   heading "Target|Name"
column  target_type format a18   heading "Target|Type"
column  severity    format a8    heading "Severtiy"
column status_count format 99999 heading "Status|Count" 


ttitle left  "Summary over the Incidents in the Environment" skip 2
select t.target_name
      ,t.target_type
      ,e.severity
      ,count(*) as status_count
  from sysman.mgmt$incidents i
      ,sysman.MGMT$TARGET    t
      ,sysman.mgmt$events    e
 where t.target_guid = i.target_guid
   and i.severity != 'Clear'
   and e.incident_id = i.incident_id
   and e.severity != 'Clear'
   and upper(i.summary_msg) like upper('%&&METRIK_SUM.%')  
   --   and e.event_class = 'metric_alert' 
group by  t.target_name
         ,t.target_type
         ,e.severity	
 order by t.target_name
/		 

/* 
internal OEM Base Tables for a incident over the e.event_id

Event
select rowid,e.* from em_event_raw e where e.event_instance_id=?

Incident
select rowid,e.* from  em_issues_internal e where e.issue_id=?


to fix a not closeable incident on each table:
=> severity to 0
=> open status to 0
=> closed_date to actual date
!!! Not supported !!!!

*/

ttitle off
