--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   History of usage of a service in the last half day
--==============================================================================

set verify off
set linesize 130 pagesize 300 


ttitle 'Past service-level metrics|(from gv$servicemetric)'


--break on service_name noduplicates

column service_name    format a15          heading 'service|name' wrap
column inst_id         format 9999         heading 'inst|id'
column beg_hist        format a10          heading 'start time' wrap
column end_hist        format a10          heading 'end time' wrap
column intsize_csec    format 9999         heading 'intvl|size|(cs)'
column goodness        format 999999       heading 'goodness'
column delta           format 999999       heading 'pred-|icted|good-|ness|incr'
column cpupercall      format 99999999     heading 'cpu|time|per|call|(mus)'
column dbtimepercall   format 99999999     heading 'elpsd|time|per|call|(mus)'
column callspersec     format 99999999     heading '# 0f|user|calls|per|second'
column dbtimepersec    format 99999999     heading 'dbtime|per|second'
column flags           format 999999       heading 'flags'

select sm.inst_id    
    , sm.service_name
	, ds.service_id
    , to_char(sm.begin_time,'hh24:mi:ss') beg_hist
    , to_char(sm.end_time,'hh24:mi:ss') end_hist
    , ds.goal
    , sm.dbtimepercall
    , sm.callspersec
    , sm.dbtimepersec
  from gv$servicemetric_history sm
     , dba_services ds
 where sm.service_name=ds.name
   and ds.goal is not null
	and sm.BEGIN_TIME between sysdate-0.5 and sysdate
	and sm.dbtimepercall > 0
 order by sm.service_name,sm.inst_id,sm.begin_time
/

prompt...
prompt... goodness => indicates how attractive a given instance is with respect to processing the workload that is presented to the service. 
prompt... a lower number is better. this number is internally computed based on the goal (long or short) that is specified for the particular service.
prompt...
prompt... predicted goodness incr => the predicted increase in the goodness for every additional session that is routed to this instance
prompt...
prompt... flags 
prompt...      0x01 - service is blocked from accepting new connections
prompt...      0x02 - service is violating the set threshold on some metric
prompt..       0x04 - goodness is unknown

--clear break

ttitle off
