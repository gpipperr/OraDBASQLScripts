--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   Main statistic information of the database
-- Date:   01.September 2012
--
--==============================================================================

-- 11g: Scheduler Maintenance Tasks or Autotasks [ID 756734.1]
-- Why Auto Optimizer Statistics Collection May Appear to be "Stuck"? (Doc ID 1320246.1)


set linesize 130 pagesize 300 

ttitle left  "Workload Statistic Values" skip 2

column SNAME format a15 heading "Statistic|Name"
column pname format a12 heading "Parameter"
column PVAL1 format a20 heading "Value 1"
column PVAL2 format a20 heading "Value 2"

select sname
      ,pname
      ,to_char(pval1, '999G999G999D99') as pval1
      ,pval2
  from sys.aux_stats$
 order by 1
         ,2
/

prompt .... CPUSPEED	   Workload CPU speed in millions of cycles/second
prompt .... CPUSPEEDNW	Noworkload CPU speed in millions of cycles/second
prompt .... IOSEEKTIM	Seek time + latency time + operating system overhead time in milliseconds
prompt .... IOTFRSPEED	Rate of a single read request in bytes/millisecond
prompt .... MAXTHR	   Maximum throughput that the I/O subsystem can deliver in bytes/second
prompt .... MBRC	      Average multiblock read count sequentially in blocks
prompt .... MREADTIM	   Average time for a multi-block read request in milliseconds
prompt .... SLAVETHR	   Average parallel slave I/O throughput in bytes/second
prompt .... SREADTIM	   Average time for a single-block read request in milliseconds
prompt ....
prompt

ttitle left  "I/O Statistic Values" skip 2

column start_time          format a21    heading "Start|time"			
column end_time 		   format a21    heading "End|time"
column max_iops 		   format 9999999 heading "Block/s|data block" 
column max_mbps 		   format 9999999 heading "MB/s|maximum-sized read" 
column max_pmbps 		   format 9999999 heading "MB/s|largeI/0" 
column latency 			   format 9999999 heading "Latency|data block read" 
column num_physical_disks  format 999     heading "Disk|Cnt"

select to_char(START_TIME,'dd.mm.yyyy hh24:mi') as START_TIME
	,to_char(END_TIME,'dd.mm.yyyy hh24:mi') as END_TIME 			
	,MAX_IOPS 			
	,MAX_MBPS 			
	,MAX_PMBPS 			
	,LATENCY 				
	,NUM_PHYSICAL_DISKS
  from dba_rsrc_io_calibrate
/

prompt .... START_TIME 			Start time of the most recent I/O calibration 
prompt .... END_TIME 			End time of the most recent I/O calibration 
prompt .... MAX_IOPS 			Maximum number of data block read requests that can be sustained per second 
prompt .... MAX_MBPS 			Maximum megabytes per second of maximum-sized read requests that can be sustained 
prompt .... MAX_PMBPS 			Maximum megabytes per second of large I/O requests that can be sustained by a single process 
prompt .... LATENCY 					Latency for data block read requests 
prompt .... NUM_PHYSICAL_DISKS 	Number of physical disks in the storage subsystem (as specified by the user) 
prompt ....
prompt

ttitle left  "Last analysed Tables Overview" skip 2

column last_an   format a18  heading "Last|analysed"
column owner     format a18  heading "Tab|Owner"
column tab_count format 9999 heading "Tab|Count"

select last_an
      ,owner
      ,tab_count
  from (select to_char(last_analyzed, 'dd.mm.yyyy') as last_an
              ,owner
              ,count(*) as tab_count
              ,to_char(last_analyzed, 'yyyymmddhh') as sort
          from dba_tables
         group by owner
                 ,to_char(last_analyzed, 'dd.mm.yyyy')
                 ,to_char(last_analyzed, 'yyyymmddhh'))
 order by sort  asc
         ,owner desc
/

prompt...
prompt... if last analyzed is empty there are some tables witout statistics in this schema
prompt... check especially for none sys user
prompt...


ttitle left  "Stale Statistics overview - Table with more then 10% modifications" skip 2


column owner format a20
column table_name format a30

select t.owner
	,  t.table_name
	,  t.last_analyzed
	,  m.TIMESTAMP as last_accessed
	,  m.deletes + m.updates + m.inserts as changes
	,  round ( (m.deletes + m.updates + m.inserts) / t.num_rows * 100) stale_percent
	,  num_rows
from   dba_tables t
    ,  dba_tab_modifications m
where  t.owner = m.table_owner
  and  t.table_name = m.table_name
  and t.num_rows > 0 
  and round ( (m.deletes + m.updates + m.inserts) / t.num_rows * 100) >= 10 
  and owner not in ('SYS'
                    ,'SYSTEM'
                    ,'SYSMAN'
                    ,'APEX_030200'
                    ,'XDB'
                    ,'ORDDATA'
                    ,'MDSYS'
                    ,'OLAPSYS'
                    ,'CTXSYS'
                    ,'SYSMAN_MDS'
                    ,'EXFSYS'
                    ,'DBSNMP'
                    ,'ORDSYS'
                    ,'WMSYS'
                    ,'APEX_030200'
                    ,'PEFSTAT')
order by 1,2
/


set serveroutput on

declare
	v_list dbms_stats.objecttab;
	v_owner varchar2(32):='NULL';
begin
	dbms_stats.gather_database_stats( objlist => v_list
									, options => 'LIST STALE');
	dbms_output.put_line('--Info - List of stale Objects with dbms_stats.gather_database_stats'); 									
	for i in v_list.first..v_list.last
	loop
		if v_list(i).ownname != v_owner then
			dbms_output.put_line('--Info '||rpad('-',30,'-'));
		end if;
		if v_list(i).ownname != 'SYS' then
			dbms_output.put_line('--Info Object:: ' || rpad(v_list(i).ownname || '.' || v_list(i).objname,42,' ') ||  rpad(' Type:: ' || v_list(i).objtype ,20,' ')|| ' Partition:: ' || v_list(i).partname);
		end if;			
		v_owner:=v_list(i).ownname;
	end loop;
end;
/

prompt...

 
ttitle left  "Overview histogram statistic usage for none system user in the database" skip 2
 
column table_name   format a25 heading "Table Name"
 
select owner
      ,count(distinct table_name) as count_tables
       --, column_name 
      ,count(*) as count_hist_buckets
  from DBA_TAB_HISTOGRAMS
 where owner not in ('SYS'
                    ,'SYSTEM'
                    ,'SYSMAN'
                    ,'APEX_030200'
                    ,'XDB'
                    ,'ORDDATA'
                    ,'MDSYS'
                    ,'OLAPSYS'
                    ,'CTXSYS'
                    ,'SYSMAN_MDS'
                    ,'EXFSYS'
                    ,'DBSNMP'
                    ,'ORDSYS'
                    ,'WMSYS'
                    ,'APEX_030200'
                    ,'PEFSTAT')
 group by owner --table_name ,column_name
 order by owner
/

---------------------------- Check the Scheduler for the statistic job -------------------------------


column job_name            format a30     heading "Job|Name"
column run_count           format 99999   heading "Run|Count"
column failure_count       format 99999   heading "Failure|Count"
column last_start_date     format a18     heading "Last|run date"
column next_run_date       format a18     heading "Next|run date"
column client_name         format a35     heading "Job|Name"
column status              format a10     heading "Job|status"
column mean_job_duration   format 999G999 heading "Mean|duration"
column mdl7                format 999G999 heading "Max|duration"
column next_start_date     format a38     heading "Next|run"
column window_group_name   format a18     heading "Window|group"
column job_duration        format 999G999 heading "Duration|Minutes"
column job_start_time      format a18     heading "Job|Start time"
column log_date            format a18     heading 'Log Date'
column owner               format a10     heading 'Owner'
column job_name            format a30     heading 'Job'
column status              format a10     heading 'Status'
column actual_start_date   format a32     heading 'Actual|Start|Date'
column error#              format 999999  heading 'Error|Nbr'
column window_start_time   format a18     heading 'Windows|Start'
column job_status          format a10     heading 'Status'
column window_name         format a20     heading 'Windows|Name'
column window_next_time    format a38     heading 'Window|next Time'

ttitle left  "Job Scheduler Information -- Oracle Statistic Auto Job " skip 2

select OWNER
      ,JOB_NAME
      ,RUN_COUNT
      ,FAILURE_COUNT
      ,to_char(LAST_START_DATE, 'DD.MM.YYYY HH24:MI') as LAST_START_DATE
      ,to_char(NEXT_RUN_DATE, 'DD.MM.YYYY HH24:MI') as NEXT_RUN_DATE
  from dba_scheduler_jobs
 where job_name like '%STAT%' 
/
 
prompt ... GATHER_STATS_JOB 10g job should not run in 11g!
prompt ... to delete use as sys user: exec dbms_scheduler.drop_job(job_name => 'SYS.GATHER_STATS_JOB');
prompt

ttitle left  "Job Scheduler BSLN_MAINTAIN_STATS_JOB History " skip 2 


select log_id
      ,to_char(log_date, 'DD.MM.YYYY HH24:MI') as log_date
      ,owner
      ,job_name
      ,status
      ,to_char(actual_start_date, 'DD.MM.YYYY HH24:MI') as actual_start_date
      ,error#
  from dba_scheduler_job_run_details
 where JOB_NAME = 'BSLN_MAINTAIN_STATS_JOB'
 order by actual_start_date
/

ttitle left  "Job Scheduler Window Settings " skip 2 

prompt 
prompt check if the window is not activ in the past!
prompt

column check_active format a10    heading 'Check|if ok'

select window_name
      ,to_char(last_start_date, 'DD.MM.YYYY HH24:MI') as last_start_date
      ,enabled
      ,active
      ,decode(active, 'TRUE', '<==CHECK IF POSSIBLE', '-') as check_active
  from dba_scheduler_windows
 order by last_start_date
/

prompt
prompt  ... if a window is still open in the past, close the window manually
prompt  ... with : EXECUTE DBMS_SCHEDULER.CLOSE_WINDOW ('SATURDAY_WINDOW');
prompt  ..

ttitle left  "Check Window  history" skip 2 
prompt 
prompt check Window history
prompt 

select window_name
      ,optimizer_stats
      ,window_next_time
      ,autotask_status
  from dba_autotask_window_clients

/ 

ttitle left  "Check Auto tasks " skip 2 

prompt 
prompt if autotask is really enabled
prompt

select client_name
      ,status
  from dba_autotask_task
/  

ttitle left  "Check Auto tasks Settings" skip 2 

select c.client_name
      ,c.status
      ,w.window_group_name
      ,w.next_start_date as next_start_date
      ,extract(hour from c.mean_job_duration) * 60 + extract(minute from c.mean_job_duration) as mean_job_duration
      ,extract(hour from c.max_duration_last_7_days) * 60 + extract(minute from c.max_duration_last_7_days) as mdl7
  from dba_autotask_client         c
      ,dba_scheduler_window_groups w
 where w.window_group_name = c.window_group
 order by 1
/

prompt .... if task is disabled
prompt .... exec DBMS_AUTO_TASK_ADMIN.ENABLE( client_name => 'auto optimizer stats collection',operation => NULL,window_name => NULL)
prompt ....
prompt

ttitle left  "Check Auto tasks history" skip 2 

prompt 
prompt if empty no  history!!
prompt

select client_name
      ,window_name
      ,to_char(window_start_time, 'dd.mm.yyyy hh24:mi') as window_start_time
       --, window_duration
       --, job_name
      ,job_status
      ,to_char(job_start_time, 'dd.mm.yyyy hh24:mi') as job_start_time
      ,extract(hour from job_duration) * 60 + extract(minute from job_duration) as job_duration
      ,job_error
      --, job_info 
  from dba_autotask_job_history
 where job_start_time > sysdate - 14
order by job_start_time
/  

---------------------------- Check the Statistic Settings for this database -------------------------------

prompt 
prompt if empty no  history!!
prompt

ttitle left  "How long the DB keeps old statistics" skip 2 

select DBMS_STATS.GET_STATS_HISTORY_RETENTION
  from dual
/  

ttitle left  "Check Global Stat Settings" skip 2 

column parameter format a30
column value format a30

select 'AUTOSTATS_TARGET'  as parameter, DBMS_STATS.GET_PREFS ( 'AUTOSTATS_TARGET','GLOBAL') as value from dual
union
select 'CASCADE'           as parameter, DBMS_STATS.GET_PREFS ( 'CASCADE','GLOBAL') as value from dual
union
select 'DEGREE'            as parameter, DBMS_STATS.GET_PREFS ( 'DEGREE','GLOBAL') as value from dual
union
select 'ESTIMATE_PERCENT'  as parameter, DBMS_STATS.GET_PREFS ( 'ESTIMATE_PERCENT','GLOBAL') as value from dual
union
select 'METHOD_OPT'        as parameter, DBMS_STATS.GET_PREFS ( 'METHOD_OPT','GLOBAL') as value from dual
union
select 'NO_INVALIDATE'     as parameter, DBMS_STATS.GET_PREFS ( 'NO_INVALIDATE','GLOBAL') as value from dual
union
select 'GRANULARITY'      as parameter, DBMS_STATS.GET_PREFS ( 'GRANULARITY','GLOBAL') as value from dual
union
select 'PUBLISH'          as parameter, DBMS_STATS.GET_PREFS ( 'PUBLISH','GLOBAL') as value from dual
union
select 'INCREMENTAL'      as parameter, DBMS_STATS.GET_PREFS ( 'INCREMENTAL','GLOBAL') as value from dual
union
select 'STALE_PERCENT'    as parameter, DBMS_STATS.GET_PREFS ( 'STALE_PERCENT','GLOBAL') as value from dual
/

prompt ... 
prompt ... to set the global preferences use "exec DBMS_STATS.SET_GLOBAL_PREFS ( pname => ' ', pvalue =>' ');"
prompt ... 

ttitle off



 

