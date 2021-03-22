--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   show all jobs in the database with an error
--===============================================================================
set linesize 130 pagesize 300 

------------------------------------------------------------

ttitle left  "Job Infos -- Oracle Failed JOBs " skip 2

column job          format 9999999
column what         format a15
column last_date    format a13
column this_date    format a13
column next_date    format a13
column interval     format a20
column broken       format a2
column schema_user  format a10

column owner        format a10

  select job
       ,  schema_user
       ,  substr (what, 1, 20) as what
       ,  to_char (last_date, 'dd.mm hh24:mi') as last_date
       ,  to_char (this_date, 'dd.mm hh24:mi') as this_date
       ,  to_char (next_date, 'dd.mm hh24:mi') as next_date
       ,  interval
       ,  failures
       ,  broken
     from dba_jobs
 where (failures > 0 or broken = 'Y')
order by schema_user, job
/

column what format a100

  select job, WHAT as what
    from dba_jobs
 where (failures > 0 or broken = 'Y')
order by schema_user, job
/



------------------------------------------------------------
-- What scheduled tasks failed during execution, and why?

ttitle 'Scheduled Tasks That Failed' skip 2
prompt  Scheduled Tasks That Failed:

column log_date            format a32    heading 'Log Date'
column owner               format a06    heading 'Owner'
column job_name            format a26    heading 'Job'
column status              format a10    heading 'Status'
column actual_start_date   format a32    heading 'Actual|Start|Date'
column error#              format 999999 heading 'Error|Nbr'

  select log_id
       ,  log_date
       ,  owner
       ,  job_name
       ,  status
       ,  substr (actual_start_date, 1, 18) || ' ...' as actual_start_date
       ,  error#
    from dba_scheduler_job_run_details
   where     nvl (status, '-') <> 'SUCCEEDED'
         and log_date > (  sysdate - 7)
order by log_id desc
/

------------------------------------------------------------

ttitle 'Scheduled Tasks with out a status' skip 2
prompt  Scheduled Tasks with out a status:

  select log_id
       ,  log_date
       ,  owner
       ,  job_name
       ,  status
       ,  OPERATION
    from dba_scheduler_job_log
   where     nvl (status, '-') <> 'SUCCEEDED'
         and log_date > (  sysdate
                         - 7)
order by log_id desc
/


------------------------------------------------------------
ttitle 'Auto Task with an error' skip 2

column client_name       format a25 heading "Job|Name"
column job_status        format a10 heading "Job|status"
column job_info          format a25 heading "Job|Info"
column JOB_START_TIME    format a18 heading "Last|Start"
column window_name       format a18 heading "Window|Name"

  select client_name
       ,  window_name
       ,  job_status
       ,  job_info
       ,  JOB_START_TIME
    from dba_autotask_job_history
   where (   job_status <> 'SUCCEEDED'
          or job_status is null)
order by 1, 2
/

prompt
prompt
ttitle off