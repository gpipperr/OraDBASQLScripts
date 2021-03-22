--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   OEM SQL Script Overview
-- Show the DB internal Alerting Setting + open Alerts
--==============================================================================
-- docu
-- Database metrics, e.g.Tablespace Full(%), not clearing in Grid Control even though they are no longer present in dba_outstanding_alerts (Doc ID 455222.1)
--==============================================================================


set linesize 130 pagesize 500 

column metrics_name      format a35  heading "Metric|Name"
column instance_name     format a13  heading "Instance|Name"
column object_name       format a15 heading "Object|Name"
column warning_operator  format a8 heading "Warn|OP"       WORD_WRAPPED
column warning_value     format a8 heading "Warn|Value"    WORD_WRAPPED
column critical_operator format a8 heading "Crit|OP"       WORD_WRAPPED
column critical_value    format a8 heading "Crit|Value"    WORD_WRAPPED
column object_type       format a12 heading "Object|Type"  WORD_WRAPPED
column consecutive_occurrences  format 999 heading  "Con|Exec"
column observation_period       format 999 heading  "Ob|Per"

ttitle left "show the metric setting in this database" skip 2

select object_name 
   , object_type
	, metrics_name
	, warning_operator
	, warning_value
	, critical_operator
	, nvl(critical_value,'null') as critical_value
	, observation_period
	, consecutive_occurrences
	, instance_name
 from dba_thresholds
order by object_name
        ,object_type
		  ,instance_name
/

prompt ... null means NULL!!
prompt ... to set the settings use db_alerts_set.sql <metricname>
prompt ...

ttitle left "Check for Metrics from other instances" skip 2

select count(*)
      ,instance_name 
from dba_thresholds 
group by instance_name
/

prompt ...
prompt ... in a clon database you will find OLD values!
prompt ...


ttitle left "Show the outstanding alerts in this database"  skip 2

select count(*) as total_message_count from sys.dba_outstanding_alerts
/

column reason format a40 heading "Reason"
column metric_value format 999G999 heading "Metric|Value"
column message_type format a10     heading "Message|Type"
column creation_time  format a21   heading "Creation|Time"

select reason 
	,  metric_value
	,  message_type 
	,  to_char(creation_time,'dd.mm.yyyy hh24:mi:ss')  as creation_time
	, INSTANCE_NAME
from sys.dba_outstanding_alerts
order by SEQUENCE_ID
/	

prompt
prompt ...
prompt 


ttitle left "Show the Alert Queue of this database" skip 2


column name          format a12
column queue_table   format a15
column waiting       format 999G999G999D99
column ready         format 999G999G999D99
column expired       format 999G999G999D99
--column total_wait    format 999G999G999D99
--column average_wait  format 999G999G999D99
column owner         format a10
column retention     format a10

select /*+ rule */ 
     d.queue_table
	, q.waiting
	, q.ready
	, q.expired
	, q.total_wait
	, q.average_wait
	, d.owner
	, d.retention
 from gv$aq q
    , dba_queues d
where q.qid = d.qid
  and d.name = 'ALERT_QUE'
/

prompt
prompt ...
prompt 


ttitle left "Show the messages in the Alert Queue of this database"  skip 2


column q_name    format a20
column enq_time  format a42 
column deq_time  format a30
column state     format a30
column user_data format a120  heading "User|Data" fold_before WORD_WRAPPED 

select  '+--------- enq_time=> '||to_char(enq_time,'dd.mm.yyyy hh24:mi:ss') as enq_time
	  ,  'deq_time=> '||to_char(deq_time,'dd.mm.yyyy hh24:mi:ss') as deq_time
	  ,  'state   => '|| state
	  , user_data 	  
 from sys.alert_qt 
 order by enq_time
/

prompt
prompt ...
prompt


ttitle off




