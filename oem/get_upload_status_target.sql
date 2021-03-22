--==============================================================================
-- GPI - Gunther Pippèrr
-- get the upload status of the target on a host
--==============================================================================
set verify off
set linesize 130 pagesize 300 recsep off


define HOST_NAME  = '&1' 

prompt
prompt Parameter 1 =  Host Name => &&HOST_NAME.
prompt 

set verify off

set long 100


column target_name   format a50 heading "Target|Name"
column host_name     format a30 heading "Host|Name"
column target_type   format a15 heading "Target|Type"
column last_metric_load_time format a18 heading "Last|Metric Load"
column last_collection       format a18 heading "Last|Collection"
column diff                  format 99999 heading "Diff| Time"

select target_name
	, target_type
	, host_name
	, to_char(last_metric_load_time,'dd.mm.yyyy hh24:mi') as last_metric_load_time
	, to_char(last_collection,'dd.mm.yyyy hh24:mi') as last_collection
	, last_collection-last_metric_load_time as diff
from (
	select t.target_name
		  , t.target_type
		  , t.host_name
		  , last_metric_load_time
		  , (select max(mmc.collection_timestamp) from sysman.mgmt$metric_current mmc where mmc.target_guid=t.target_guid) last_collection 
	 from sysman.mgmt$target t 
	where lower(t.host_name) like lower('&&HOST_NAME.%') 
)
order by last_collection
/