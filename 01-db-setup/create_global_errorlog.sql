set serveroutput on size 1000000

prompt

DOC
-------------------------------------------------------------------------------
    
    Creating Error Log Tab for SQL Errors over the complete DB
    
-------------------------------------------------------------------------------
#

prompt


DOC
-------------------------------------------------------------------------------

    Errorlog Table / Sequence and Trigger will be created
    
-------------------------------------------------------------------------------
#

prompt
prompt '-------------------------------------------------------------------------------'
prompt

set serveroutput on size 1000000

exec DBMS_OUTPUT.put_line('start create_global_errorlog.sql');

prompt "Create Table SYSTEM.ora_errors  and SEQUENCE SYSTEM.ora_errors_seq"

CREATE TABLE SYSTEM.ora_errors
(
  id         NUMBER
 ,log_date   DATE
 ,log_usr    VARCHAR2 (30)
 ,terminal   VARCHAR2 (50)
 ,err_nr     NUMBER (10)
 ,err_msg    VARCHAR2 (4000)
 ,stmt       CLOB
 ,inst_id    number(2)
) tablespace sysaux
/

create unique index system.idx_ora_errors_pk on system.ora_errors(id) tablespace sysaux;
alter table system.ora_errors add constraint pk_ora_errpr primary key (id) enable validate;

create index system.idx_ora_errors_date on system.ora_errors(log_date) tablespace sysaux; 
  
grant select on system.ora_errors to public;
grant delete on system.ora_errors to public;


-----------

CREATE SEQUENCE SYSTEM.ora_errors_seq
/

-----------

prompt "Create the trigger log_error"

CREATE OR REPLACE TRIGGER log_error
  AFTER SERVERERROR
  ON DATABASE
DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;

  v_id         NUMBER;
  v_sql_text   ORA_NAME_LIST_T;
  v_stmt       CLOB;
  v_count      NUMBER;
BEGIN
  v_count := ora_sql_txt (v_sql_text);

  IF v_count >= 1
  THEN
    FOR i IN 1 .. v_count
    LOOP
      v_stmt := v_stmt || v_sql_text (i);
    END LOOP;
  END IF;

  FOR n IN 1 .. ora_server_error_depth
  LOOP
    IF ora_login_user in ('SYS','DBSNMP','SYSMAN')
    THEN
      -- do nothing
      NULL;
    ELSE
      SELECT SYSTEM.ora_errors_seq.NEXTVAL INTO v_id FROM DUAL;

      INSERT INTO SYSTEM.ora_errors (id
                                   ,log_date
                                   ,log_usr
                                   ,terminal
                                   ,err_nr
                                   ,err_msg
                                   ,stmt
								   ,inst_id)
           VALUES (v_id
                  ,SYSDATE
                  ,ora_login_user
                  ,ora_client_ip_address
                  ,ora_server_error (n)
                  ,ora_server_error_msg (n)
                  ,v_stmt
				  ,ora_instance_num);
    END IF;

    COMMIT;
  END LOOP;
END log_error;
/

------ Clean procedure

CREATE or REPLACE PROCEDURE system.deleteOraErrorTrigTab (p_keepdays NUMBER)
IS
BEGIN
   DELETE FROM SYSTEM.ora_errors WHERE log_date+p_keepdays < sysdate;
   COMMIT;
END;
/
show errors


------ Clean procedure job over DBMS Job ---
/*
DECLARE
  X NUMBER;
BEGIN
  SYS.DBMS_JOB.SUBMIT
    (
      job        => X
	 ,what       => 'begin system.deleteOraErrorTrigTab (p_keepdays => 15); end;'
     ,next_date  => sysdate
     ,interval   => 'to_date(to_char(sysdate+1,''mm/dd/yyyy'')||'' 04:00:00'',''mm/dd/yyyy hh24:mi:ss'')'
     ,no_parse   => FALSE
     ,instance  => 0
     ,force     => TRUE
    );
END;
/
commit;
*/

------ Clean procedure job over DBMS Scheduler ---

-------------------------------------------------------------------------
-- Create Oracle Scheduler Program
BEGIN
  DBMS_SCHEDULER.create_program (
      program_name        => 'CLEAN_SQL_ERROR_LOG_TABLE_PROG'
    , program_type        => 'STORED_PROCEDURE'
    , program_action      => 'system.deleteOraErrorTrigTab'
    , number_of_arguments => 1
    , enabled             => FALSE
    , comments            => 'Prog to clean all from SYSTEM.ora_errors ( Error Log Table in the system schema) older then xx days');
END;
/

BEGIN
  DBMS_SCHEDULER.define_program_argument (
      program_name      => 'CLEAN_SQL_ERROR_LOG_TABLE_PROG'
    , argument_name     => 'p_keepdays'
    , argument_position => 1
    , argument_type     => 'NUMBER'
    , default_value     => '15');
END;
/
BEGIN
  DBMS_SCHEDULER.enable (name => 'CLEAN_SQL_ERROR_LOG_TABLE_PROG');
END;
/
-------------------------------------------------------------------------
-- Create Oracle Scheduler Time Plan
BEGIN
  DBMS_SCHEDULER.create_schedule (
     schedule_name   => 'CLEAN_SQL_ERLOGTAB_TIMEPLAN'
    , start_date      => SYSTIMESTAMP
    , repeat_interval => 'freq=daily; byhour=13; byminute=0'
    , end_date        => NULL
    , comments        => 'Job time plan to delete the  SYSTEM.ora_errors ( Error Log Table in the system schema)');
END;
/
-------------------------------------------------------------------------
-- Create Scheduler Job
BEGIN
  DBMS_SCHEDULER.create_job (
     job_name         => 'CLEAN_SQL_ERROR_LOG_TABLE'
    , program_name    => 'CLEAN_SQL_ERROR_LOG_TABLE_PROG'
    , schedule_name   => 'CLEAN_SQL_ERLOGTAB_TIMEPLAN'   
    , comments        =>  'Job to clean all from SYSTEM.ora_errors ( Error Log Table in the system schema) older then xx days'
	 , enabled         => true);
END;
/ 

--
column job_name FORMAT a40
select owner, job_name, enabled 
  from  dba_scheduler_jobs
 where job_name ='CLEAN_SQL_ERROR_LOG_TABLE'
/
 

------ Analyse example:

column anzahl   format 9999999999
column hour     format A9
column LOG_USR  format A10
column ERR_NR   format 999999999
column mesg     format A30

SELECT COUNT (*) as anzahl
        ,TO_CHAR (log_date, 'dd/mm hh24')||'h' as hour
        ,nvl(LOG_USR,'n/a') as LOG_USR
        ,ERR_NR
        ,substr(ERR_MSG,1,200) mesg
    FROM SYSTEM.ora_errors
    where nvl(log_usr,'n/a') not in ('SYS','SYSMAN','DBSNMP')
GROUP BY TO_CHAR (log_date, 'dd/mm hh24')||'h'
        ,nvl(LOG_USR,'n/a')
        ,ERR_NR
        ,substr(ERR_MSG,1,200)
order by 2,1 
;
------------------------------------------------------

prompt
exec DBMS_OUTPUT.put_line('end create_global_errorlog.sql');
prompt

