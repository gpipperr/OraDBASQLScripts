--==============================================================================
-- GPI - Gunther Pippèrr
-- get a target
--==============================================================================
set verify off
set linesize 130 pagesize 300 recsep off


define TARGET_NAME  = '&1'

prompt
prompt Parameter 1 =  TARGET_NAME => &&TARGET_NAME.
prompt

set verify off

set long 100


column target_name   format a50 heading "Target|Name"
column host_name     format a30 heading "Host|Name"
column target_type   format a15 heading "Target|Type"
column last_metric_load_time format a18 heading "Last|Metric Load"
column last_collection       format a18 heading "Last|Collection"
column first_metadata_load_time format a18 heading "First|Metadata from"
column display_name  format a30 heading "Target Display|Name"

select t.target_name
     ,  t.target_type
     ,  t.display_name
     --,tt.type_display_name
     ,  t.host_name
     ,  to_char (tlt.last_load_time, 'dd.mm.yyyy hh24:mi') as last_metric_load_time
     ,  to_char ( (select max (mmc.collection_timestamp)
                     from sysman.mgmt$metric_current mmc
                    where mmc.target_guid = t.target_guid)
               ,  'dd.mm.yyyy hh24:mi')
           as last_collection
  -- , to_char(tlt.first_metadata_load_time,'dd.mm.yyyy hh24:mi') as first_metadata_load_time
  from mgmt_targets t, mgmt_targets_load_times tlt, mgmt_target_types tt
 where     t.target_type = tt.target_type(+)
       and t.target_guid = tlt.target_guid
       and lower (t.target_name) like lower ('&&TARGET_NAME.%')
/

column property_value   format a40 heading "Property|Value"
column property_name format a60 heading "Property|Name"

break on target_name

  select target_name, property_name, property_value
    from mgmt$target_properties
   where lower (target_name) like lower ('&&TARGET_NAME.%')
order by property_name
/

clear break



	
