-- ==============================================================================
-- GPI - Gunther Pippèrr
-- Desc :   Get the audit settings of the database
--
-- Must be run with dba privileges
-- see also for the source of some of the commands 
--   https://oracle-base.com/articles/11g/auditing-enhancements-11gr2#initializing_the_management_infrastructure
-- ==============================================================================

set linesize 130 pagesize 300 

ttitle left  "Audit settings -- init.ora " skip 2

show parameter audit

ttitle left  "Audit Settings -- Parameters " skip 2

column parameter_name  format a30
column parameter_value format a20
column audit_trail     format a20

select  parameter_name
      , parameter_value
	  , audit_trail 
  from dba_audit_mgmt_config_params
order by 1  
/

ttitle left  "Audit Settings -- Audit objects" skip 2

column audit_option format a30
column success format a12
column failure format a12

select  audit_option
      , success,failure 
  from dba_stmt_audit_opts
 order by 1  
/  


----------------
----------------

column PARAMETER_NAME  format a40
column PARAMETER_VALUE format a30
column AUDIT_TRAIL     format a20


ttitle left  "Audit Settings -- Parameter of the normal Auditing" skip 2 

SELECT  PARAMETER_NAME
     ,  PARAMETER_VALUE
     ,  AUDIT_TRAIL
 FROM dba_audit_mgmt_config_params
order by 1
/

ttitle left  "Audit Settings -- Cleanup Jobs" skip 2 



column JOB_NAME                      format a24 heading "JOB|NAME"
column JOB_STATUS                    format a10 heading "JOB|STATUS"
column AUDIT_TRAIL                   format a20 heading "AUDIT|TRAIL"
column JOB_FREQUENCY                 format a30 heading "JOB|FREQUENCY"
column USE_LAST_ARCHIVE_TIMESTAMP    format a10 heading "LAST | TIMESTAMP" 
column JOB_CONTAINER                 format a20 heading "JOB|CONTAINER"

select JOB_NAME
	, JOB_STATUS
	, AUDIT_TRAIL
	, JOB_FREQUENCY
	, USE_LAST_ARCHIVE_TIMESTAMP
	, JOB_CONTAINER
 from DBA_AUDIT_MGMT_CLEANUP_JOBS
/

  
ttitle left  "Audit Settings -- delete older Audits then " skip 2 
  
COLUMN RAC_INSTANCE    format 999 heading "RAC|Inst"  
COLUMN audit_trail     FORMAT A20 heading "Audit|Trail"
COLUMN last_archive_ts FORMAT A40 heading "Last Archive|TS"

SELECT RAC_INSTANCE
     , AUDIT_TRAIL
     , LAST_ARCHIVE_TS
 FROM dba_audit_mgmt_last_arch_ts
order by 1,2
/
 
prompt -- AUDIT_TRAIL_TYPE: The audit trail whose timestamp is to be set (Constants)
prompt -- LAST_ARCHIVE_TIME: Records or files older than this time will be deleted.
prompt -- if empty not set!
prompt -- to set use

DOC
-------------------------------

BEGIN
  DBMS_AUDIT_MGMT.set_last_archive_timestamp(
       audit_trail_type  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD
     , last_archive_time => SYSTIMESTAMP-15);
END;
/

-------------------------------
#

 
ttitle off

set serveroutput on

BEGIN
  DBMS_OUTPUT.put_line(' -------------------------------------------- ');
  DBMS_OUTPUT.put_line('-- Info - Check if the clean job for the audit Log is enabled');
  
  IF DBMS_AUDIT_MGMT.is_cleanup_initialized(DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD) THEN
     DBMS_OUTPUT.put_line('-- Info - Cleaning job is enabled     =>  !!! YES !!!');
  ELSE
     DBMS_OUTPUT.put_line('-- Info - Cleaning job is not enabled => !!!  NO !!!');
  END IF;
  
  DBMS_OUTPUT.put_line(' -------------------------------------------- ');
END;
/

------
DOC 
-------------------------------------------------------------------------------
-- to enable the delete of the logs use:

BEGIN
  DBMS_AUDIT_MGMT.init_cleanup(
      audit_trail_type         => DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL
    , default_cleanup_interval => 24 /* hours */);
END;
/

to disable use

BEGIN
  DBMS_AUDIT_MGMT.deinit_cleanup(
    audit_trail_type         => DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL);
END;
/

-- create Job for this Task
BEGIN
DBMS_AUDIT_MGMT.create_purge_job(
	  audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL
	, audit_trail_purge_interval => 12 /* hours */
	, audit_trail_purge_name     => 'CLEANUP_AUDIT_TRAIL_ALL'
	, use_last_arch_timestamp    => TRUE);
END;
/


-------------------------------------------------------------------------------
#

--DBA_AUDIT_OBJECT


