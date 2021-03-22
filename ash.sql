--==============================================================================
-- GPI - Gunther Pippèrr 
--==============================================================================
-- see  Metalink Node Active Session History (ASH) Performed An Emergency Flush Messages In The Alert Log (Doc ID 1385872.1)
--==============================================================================
set linesize 130 pagesize 300 

column total_size                format 999G999G999 heading "Total|size"
column OLDEST_SAMPLE_TIME        format a18         heading "Oldest|sample"
column LATEST_SAMPLE_TIME        format a18         heading "Latest|sample"
column SAMPLE_COUNT              format 999G999G999 heading "Sample|count"
column awr_flush_emergency_count format 999         heading "Emergency|flush"

select total_size
     , to_char(OLDEST_SAMPLE_TIME,'dd.mm.yyyy hh24 mi') as OLDEST_SAMPLE_TIME
	 , to_char(LATEST_SAMPLE_TIME,'dd.mm.yyyy hh24 mi') as LATEST_SAMPLE_TIME
	 , SAMPLE_COUNT
     , awr_flush_emergency_count 
 from v$ash_info
/

prompt
@init _ash_size
prompt
prompt .... if you have a high count on awr_flush_emergency_count 
prompt .... Check Metalink Node Doc ID 1385872.1
prompt .... May be you increase the size with 
prompt .... alter system set "_ash_size"=<new_value> scope=both sid='*'; 
prompt
