prompt

DOC
-------------------------------------------------------------------------------
    
    Remove Error Log for SQL Errors over the complete DB
    
-------------------------------------------------------------------------------
#

prompt
set echo on
set serveroutput on

prompt "Info -- delete trigger"
drop TRIGGER log_error;


prompt "Info -- delete Delete Job"
declare

  v_job_id dba_jobs.job%type;
  v_count  pls_integer := 0;

  -- search the DBMS_JOB
  cursor c_del_job is
    select job
          ,what
      from dba_jobs
     where upper(WHAT) like upper('%system.deleteOraErrorTrigTab%');

  -- search the DBMS_SCHEDULER
  cursor c_del_sheduler_job is
    select job_name from dba_scheduler_jobs where job_name = 'CLEAN_SQL_ERROR_LOG_TABLE';

  cursor c_del_sheduler_plan is
    select schedule_name from dba_scheduler_schedules where schedule_name = 'CLEAN_SQL_ERLOGTAB_TIMEPLAN';

  cursor c_del_sheduler_prog is
    select program_name from dba_scheduler_programs where program_name = 'CLEAN_SQL_ERROR_LOG_TABLE_PROG';

begin
  dbms_output.put_line('Info -- start remove the error table delete job');
  for rec in c_del_job
  loop
    dbms_output.put_line('Info -- remove JOB ::' || rec.what || ' with the id::' || to_char(rec.job));
    dbms_job.remove(rec.job);
    commit;
    v_count := v_count + 1;
  end loop;
  dbms_output.put_line('Info -- remove ' || to_char(v_count) || ' Jobs -- finish');
  v_count := 0;
  ---------------- Scheduler -------------------------------------------------
  -- delete job
  dbms_output.put_line('Info -- start remove the error table Scheduler Time Plan');
  for rec in c_del_sheduler_job
  loop
    dbms_output.put_line('Info -- remove Scheduler Time Plan ::' || rec.job_name);
    DBMS_SCHEDULER.drop_job(job_name => rec.job_name);
    commit;
    v_count := v_count + 1;
  end loop;
  dbms_output.put_line('Info -- remove ' || to_char(v_count) || ' Scheduler Time Plan -- finish');
  v_count := 0;
  --
  -- delete time plan
  dbms_output.put_line('Info -- start remove the error table Scheduler Time Plan');
  for rec in c_del_sheduler_plan
  loop
    dbms_output.put_line('Info -- remove Scheduler Time Plan ::' || rec.schedule_name);
    DBMS_SCHEDULER.drop_schedule(schedule_name => rec.schedule_name);
    commit;
    v_count := v_count + 1;
  end loop;
  dbms_output.put_line('Info -- remove ' || to_char(v_count) || ' Scheduler Time Plan -- finish');
  v_count := 0;
  --
  --delete prog
  dbms_output.put_line('Info -- start remove the error table Scheduler delete job');
  for rec in c_del_sheduler_prog
  loop
    dbms_output.put_line('Info -- remove Scheduler Programm ::' || rec.program_name);
    DBMS_SCHEDULER.drop_program(program_name => rec.program_name);
    commit;
    v_count := v_count + 1;
  end loop;
  dbms_output.put_line('Info -- remove ' || to_char(v_count) || ' Scheduler Jobs -- finish');
  --  
end;
/


prompt "Info -- delete Error Table"
drop table  SYSTEM.ora_errors purge;

prompt "Info -- delete Error Sequence"
drop SEQUENCE SYSTEM.ora_errors_seq;

prompt "Info -- delete Error Sequence"
drop  PROCEDURE system.deleteOraErrorTrigTab;



 