--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   get Information over the usage of resources of the database
-- Date:   November 2013
--
--==============================================================================
set linesize 130 pagesize 300 

ttitle  "Resource Limit Informations"  SKIP 2

column INST_ID             format 9999   heading "INST|ID"   
column RESOURCE_NAME       format a25    heading "Resource|Name"              
column CURRENT_UTILIZATION format 999G999G999 heading "Act|Usage"   
column MAX_UTILIZATION     format 999G999G999 heading "Max|Usage"   
column INITIAL_ALLOCATION  format a10 heading "Init|Value"            
column LIMIT_VALUE         format 999999 heading "Limit|Value"


select inst_id
	, resource_name
	, current_utilization
	, max_utilization
	, initial_allocation
	, limit_value
 from gv$resource_limit
order by 1,2 desc  
/

ttitle off

