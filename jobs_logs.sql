--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   show the logs of a job
--==============================================================================
set linesize 130 pagesize 300 

------------------------------------------------------------

define JOB_NAME='&1'

prompt
prompt Parameter 1 = JOB_NAME     => &&JOB_NAME.
prompt

------------------------------------------------------------
-- Job Runs

ttitle 'Job Runs over dba_scheduler_job_run_details' skip 2

column log_date            format a32    heading 'Log Date'
column owner               format a06    heading 'Owner'
column job_name            format a26    heading 'Job'
column status              format a10    heading 'Status'
column actual_start_date   format a32    heading 'Actual|Start|Date'
column error#              format 999999 heading 'Error|Nbr'
column instance_id         format 9999    heading "Inst|ID"

  select log_id
       ,  log_date
       ,  owner
       ,  job_name
       ,  status
       ,  substr (actual_start_date, 1, 18) || ' ...' as actual_start_date
       ,  error#
       ,  instance_id
    from dba_scheduler_job_run_details
   where     job_name like upper ('%&&JOB_NAME.%')
         and log_date > (  sysdate - 7)
order by log_id desc
/

ttitle 'Log : dba_scheduler_job_log' skip 2

prompt  Scheduled Tasks with out a status:

  select log_id
       ,  log_date
       ,  owner
       ,  job_name
       ,  status
       ,  OPERATION
    from dba_scheduler_job_log
   where     job_name like upper ('%&&JOB_NAME.%')
         and log_date > (  sysdate - 7)
order by log_id desc
/

ttitle off
