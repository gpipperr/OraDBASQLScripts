--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   show all jobs create over dbms_job in the database
-- Date:   01.September 2012
--==============================================================================
set linesize 130 pagesize 300 

ttitle left  "Job Infos -- Oracle JOB Table " skip 2

column job          format 9999999 heading "Job|Name"
column last_date    format a14     heading "Last|date"
column this_date    format a14     heading "This|date"
column next_date    format a14     heading "Next|date"
column interval     format a30     heading "Interval"       word_wrapped
column broken       format a3      heading "Is|Brocken"
column schema_user  format a11     heading "Schema|User"
column owner        format a11     heading "Owner"
column failures     format 99      heading "Fail|Cnt"
column what         format a10     heading "What|is called" word_wrapped
column instance     format 9999    heading "Inst|ID"


ttitle left  "Job Infos -- Oracle JOB defined with dbms_job" skip 2

  select job
       ,  schema_user
       ,  substr (what, 1, 20) as what
       ,  to_char (last_date, 'dd.mm.yy hh24:mi') as last_date
       ,  to_char (this_date, 'dd.mm.yy hh24:mi') as this_date
       ,  to_char (next_date, 'dd.mm.yy hh24:mi') as next_date
       ,  interval
       ,  failures
       ,  broken
       ,  instance
    from dba_jobs
order by schema_user, job
/


ttitle left  "Job Infos -- job calls what?" skip 2

column what         format a110 heading "What|is called" word_wrapped

  select job, WHAT as what
    from dba_jobs
order by job
/

ttitle left  "Job Infos -- Oracle JOB Table Jobs with failures " skip 2

column what         format a10     heading "What|is called" word_wrapped

select job
     ,  schema_user
     ,  substr (what, 1, 20) as what
     ,  to_char (last_date, 'dd.mm.yy hh24:mi') as last_date
     ,  to_char (this_date, 'dd.mm.yy hh24:mi') as this_date
     ,  to_char (next_date, 'dd.mm.yy hh24:mi') as next_date
     ,  interval
     ,  failures
     ,  broken
  from dba_jobs
 where (failures > 0 or broken = 'Y')
order by schema_user, job
/

ttitle off

prompt
prompt -- *****************************************************
prompt