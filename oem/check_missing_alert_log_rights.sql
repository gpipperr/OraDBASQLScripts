--==============================================================================
-- GPI - Gunther Pippèrr
-- check Report to get all DB Instances with missing alert.log
--==============================================================================
set verify off
set linesize 130 pagesize 300 recsep off

column property_value   format a40 heading "Property|Value"
column property_name format a60 heading "Property|Name"

select target_name 	  	 
     , property_name
     , property_value      	   
  from mgmt$target_properties 
 where property_name='alert_log_file' 
  and  property_value='[MISSING_LOG]'
order by property_name
/

