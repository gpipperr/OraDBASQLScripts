define SYSUSER_PWD='&1'
define AUDITLOG_TAB_LOC='&2'

connect "SYS"/"&&SYSUSER_PWD" as SYSDBA
set echo on
spool $SCRIPTS/gpi_setup.log append

--- Move Audit log tablespace

CREATE SMALLFILE TABLESPACE "AUDITLOG"  LOGGING DATAFILE '&&AUDITLOG_TAB_LOC' 
	   SIZE 100M AUTOEXTEND ON NEXT 120M MAXSIZE 32000M EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT  AUTO
/		 

BEGIN
DBMS_AUDIT_MGMT.SET_AUDIT_TRAIL_LOCATION(
       audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_DB_STD,
       audit_trail_location_value =>  'AUDITLOG');
END;
/

--- recompile invalid objects --------------

@?/rdbms/admin/utlrp.sql

-- Auditlog init ---------------------------

-- see https://www.pipperr.de/dokuwiki/doku.php?id=dba:oracle_clean_audit_log_entries

BEGIN
  DBMS_AUDIT_MGMT.INIT_CLEANUP(
      audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL,
      default_cleanup_interval => 24 /* hours */);
END;
/

--  Delete all after 180 Days

BEGIN
-- Standard database audit records in the SYS.AUD$ table
  DBMS_AUDIT_MGMT.set_last_archive_timestamp(
       audit_trail_type  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD
     , last_archive_time => SYSTIMESTAMP-180);
 
--  Unified audit trail. In unified auditing, all audit records are written to the unified audit trail and are made --  available through the unified audit trail views, such as UNIFIED_AUDIT_TRAIL.
 DBMS_AUDIT_MGMT.set_last_archive_timestamp(
       audit_trail_type  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED
     , last_archive_time => SYSTIMESTAMP-180);
 
-- Operating system audit trail. This refers to the audit records stored in operating system files.
  DBMS_AUDIT_MGMT.set_last_archive_timestamp(
       audit_trail_type  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS
     , last_archive_time => SYSTIMESTAMP-180);
 
END;
/

-- create the job to move the timeframe each day
BEGIN
 
  DBMS_SCHEDULER.CREATE_JOB (
    job_name   => 'AUDIT_ARCHIVE_BEFORE_TIMESTAMP',
    job_type   => 'PLSQL_BLOCK',
    job_action => 'begin 
  DBMS_AUDIT_MGMT.set_last_archive_timestamp(
       audit_trail_type  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD
     , last_archive_time => SYSTIMESTAMP-180);
  DBMS_AUDIT_MGMT.set_last_archive_timestamp(
       audit_trail_type  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED
     , last_archive_time => SYSTIMESTAMP-180);
  DBMS_AUDIT_MGMT.set_last_archive_timestamp(
       audit_trail_type  => DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS
     , last_archive_time => SYSTIMESTAMP-180);
   end;',
     start_date      => sysdate,
     repeat_interval => 'FREQ=HOURLY;INTERVAL=24',
     enabled         =>  TRUE,
     comments        => 'Set the point in time before delete all audit log entries'
  );
END;
/


-- Create Auditlog purge Job ------------------
BEGIN
  DBMS_AUDIT_MGMT.create_purge_job(
    audit_trail_type           => DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL,
    audit_trail_purge_interval => 24 /* hours */,  
    audit_trail_purge_name     => 'PURGE_ALL_AUDIT_TRAILS',
    use_last_arch_timestamp    => TRUE);
END;
/
