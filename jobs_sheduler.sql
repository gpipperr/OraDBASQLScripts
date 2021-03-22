--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   show all jobs create over dbms_sheduler in the database
--==============================================================================
set linesize 130 pagesize 800 

ttitle "Job Scheduler Information -- Oracle scheduler table " skip 2

column log_id          format 9999999  heading "Log|id"
column log_date        format a13      heading "Log|date"
column job_name        format a15      heading "Job|name"
column status          format a10      heading "Job|status"
column cpu_used        format a10      heading "Cpu|used"
column program_name    format a10      heading "Program|name"
column last_start_date format a11      heading "Last|start date"
column failure_count   format 999      heading "Fail|cnt"
column next_run_date   format a11      heading "Next|start date"
column job             format 9999999  heading "Job|Name"
column last_date       format a11      heading "Last|date"
column this_date       format a11      heading "This|date"
column next_date       format a11      heading "Next|date"
column interval        format a30      heading "Interval"       word_wrapped
column broken          format a3       heading "Is|Brocken"
column schema_user     format a11      heading "Schema|User"
column owner           format a11      heading "Owner"
column failures        format 99       heading "Fail|Cnt"
column what            format a10      heading "What|is called" word_wrapped
column state           format a4      heading "Sta|te"
column job_action      format a13      heading "Job|Action" word_wrapped
column run_count       format 99G999G999 heading "Run|cnt"
column CREATED         format a17      heading "Job|Created"
column job_class       format a17      heading "Job|Class"
column job_class_name           format a28      heading "Job|Class Name"
column resource_consumer_group  format a25  heading "Consumer|Group"
column service                  format a18 heading "Service"
column logging_level            format a18 heading "Log|Level"
column log_history              format 99999999 heading "Log|Hist"
column comments                 format a20 heading "Comments"  word_wrapped


ttitle  "Job Scheduler -- Oracle scheduler table" skip 2


  select js.owner
       ,  js.job_name
       ,  decode (js.state,  'SCHEDULED', 'SHUD',  'DISABLED', 'DIS',  'RUNNING', 'RUN',  js.state) as state
       ,  js.JOB_CLASS
       ,  js.program_name
       ,  js.job_action
       ,  to_char (o.CREATED, 'dd.mm.yyyy hh24:mi') as CREATED
       --, JOB_STYLE
       ,  js.run_count
       ,  js.failure_count
       ,  to_char (js.last_start_date, 'dd.mm hh24:mi') as last_start_date
       ,  to_char (js.next_run_date, 'dd.mm hh24:mi') as next_run_date
    from dba_scheduler_jobs js, dba_objects o
   where     js.owner = o.owner(+)
         and js.job_name = o.OBJECT_NAME(+)
order by owner, job_name
/


ttitle  "Job Scheduler Classes" skip 2

  select job_class_name
       ,  resource_consumer_group
       ,  service
       ,  logging_level
       ,  log_history
       ,  comments
    from dba_scheduler_job_classes
order by job_class_name
/


ttitle  "Job Scheduler History -- Oracle scheduler table of the last day - only the last 20" skip 2


column job_name        format a30      heading "Job|name"

select *
  from (  select log_id
               ,  to_char (log_date, 'dd.mm hh24:mi') as log_date
               ,  owner
               ,  job_name
               ,  status
            from dba_scheduler_job_log
           where log_date > (  sysdate
                             - 1)
        order by log_date, owner)
 where rownum < 20
/

ttitle  "Job Scheduler History -- Summary of the last 24 hours" skip 2

  select owner
       ,  job_name
       ,  nvl (status, '-') as status
       ,  count (*)
    from dba_scheduler_job_log
   where log_date > (  sysdate
                     - 1)
group by owner, job_name, nvl (status, '-')
order by owner, job_name
/

ttitle 'Scheduled Tasks duration histroy of the last day - only the first 40'

select *
  from (  select l.job_name
               ,  sum (  extract (second from d.cpu_used)
                       + (  extract (minute from d.cpu_used)
                          * 60)
                       + (  extract (hour from d.cpu_used)
                          * 60
                          * 60))
                     as timeused
               ,  l.log_id
               ,  l.job_class
            from dba_scheduler_job_log l, dba_scheduler_job_run_details d
           where     d.log_id = l.log_id
                 and d.log_date > (  sysdate
                                   - 1)
        group by l.job_name, l.log_id, l.job_class
        order by l.log_id)
 where rownum < 40
/

-- What scheduled tasks failed during execution, and why?

ttitle 'Scheduled Tasks That Failed'
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
         and log_date > (  sysdate
                         - 1)
order by log_id desc
/


ttitle 'Scheduled Tasks without a Status - may be failed'
prompt  Scheduled Tasks That Failed:

  select log_id
       ,  log_date
       ,  owner
       ,  job_name
       ,  status
       ,  OPERATION
    from dba_scheduler_job_log
   where     nvl (status, '-') <> 'SUCCEEDED'
         and log_date > (  sysdate
                         - 1)
order by log_id desc
/

ttitle left  "Job Scheduler Window Settings " skip 2

prompt
prompt check if the window is not activ in the past!
prompt

column check_active format a10    heading 'Check|if ok'

  select window_name
       ,  to_char (last_start_date, 'DD.MM.YYYY HH24:MI') as last_start_date
       ,  enabled
       ,  active
       ,  decode (active, 'TRUE', '<==CHECK IF POSSIBLE', '-') as check_active
    from dba_scheduler_windows
order by last_start_date
/



ttitle 'Auto Tasks:'
prompt  Auto Task  overview:

column client_name       format a35 heading "Job|Name"
column status            format a10 heading "Job|status"
column mean_job_duration format a10 heading "Mean|duration"
column mdl7              format a10 heading "Max|duration"
column next_start_date   format a18 heading "Next|run"
column window_group_name format a18 heading "Window|group"

  select c.client_name
       ,  c.status
       ,  w.window_group_name
       ,  w.next_start_date
       ,  c.mean_job_duration
       ,  c.max_duration_last_7_days as mdl7
    from dba_autotask_client c, dba_scheduler_window_groups w
   where w.window_group_name = c.window_group
order by 1
/

ttitle off

prompt
prompt -- *****************************************************
prompt
