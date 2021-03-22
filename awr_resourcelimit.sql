--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: display the OS statistic of the last days  
--==============================================================================
prompt
prompt !!!!You need the Tuning Pack for this feature!!!!
prompt

set linesize 130 pagesize 300 

/*
CURRENT_UTILIZATION	NUMBER	 	Number of (resources, locks, or processes) currently being used
MAX_UTILIZATION	NUMBER	 	Maximum consumption of the resource since the last instance start up
INITIAL_ALLOCATION	VARCHAR2(10)	 	Initial allocation. This will be equal to the value specified for the resource in the initialization parameter file (UNLIMITED for infinite allocation).
LIMIT_VALUE	VARCHAR2(10)	 	Unlimited for resources and locks. This can be greater than the initial allocation value (UNLIMITED for infinite limit).
*/
 
SELECT *
  FROM (
SELECT  ss.instance_number
      , to_char(s.begin_interval_time,'dd.mm.yyyy hh24:mi') AS begin_interval_time
		, ss.RESOURCE_NAME
		, ss.CURRENT_UTILIZATION
		,ss.MAX_UTILIZATION
	 --, ss.INITIAL_ALLOCATION
		, ss.LIMIT_VALUE
FROM  dba_hist_snapshot s 
    , DBA_HIST_RESOURCE_LIMIT ss
WHERE  s.snap_id = ss.snap_id 
  AND ss.instance_number = s.instance_number
  AND  s.snap_id > (SELECT MAX(i.snap_id)-10 FROM dba_hist_snapshot i WHERE i.instance_number=ss.instance_number)   
  AND ss.RESOURCE_NAME IN ('processes','sessions')
  AND  ss.instance_number=3
 )
pivot ( 
     MAX (CURRENT_UTILIZATION) AS CUR_UTL , MAX (MAX_UTILIZATION) AS MAX_UTL, MAX(LIMIT_VALUE) AS MAX_LIMIT
        FOR RESOURCE_NAME
        IN  ( 'processes' AS proc
             ,'sessions'  AS sess       
            )
)
/