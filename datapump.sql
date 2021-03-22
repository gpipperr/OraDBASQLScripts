--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   Get Information about running data pump jobs
-- Date:   November 2013
--==============================================================================
set linesize 130 pagesize 300 

column owner_name format a10;
column job_name   format a20
column state      format a12

column operation like state
column job_mode like state

ttitle  "Datapump Jobs"  SKIP 2


select owner_name
    ,  job_name
	 ,  operation
	 ,  job_mode
	 ,  state
	 ,	 attached_sessions
from dba_datapump_jobs
where job_name not like 'BIN$%'
order by 1,2
/

ttitle  "Datapump Master Table"  SKIP 2


column status       format a10;
column object_id    format 99999999
column object_type  format a12
column OBJECT_NAME  format a25

select o.status 
     , o.object_id
	 , o.object_type
	 , o.owner||'.'||object_name as OBJECT_NAME
from dba_objects o
   , dba_datapump_jobs j
where o.owner=j.owner_name 
  and o.object_name=j.job_name
  and j.job_name not like 'BIN$%' order by 4,2
/  

ttitle off

prompt ... 
prompt ... check for "NOT RUNNING" Jobs
prompt ... 