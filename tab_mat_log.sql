--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: Information about materialized views Logs
--==============================================================================
set verify off
set linesize 130 pagesize 500 

column log_owner             format a10
column master                format a22
column log_table             format a26
column log_trigger           format a10
column rowids                format a3
column primary_key           format a3
column object_id             format a3
column filter_columns        format a3
column sequence              format a3
column include_new_values    format a3
column purge_asynchronous    format a3
column purge_deferred        format a3
column purge_start           format a18
column purge_interval        format a20
column last_purge_date       format a18
column last_purge_status     format 99999 heading "Purge|Status"
column num_rows_purged       format 999G999 heading "Num|Rows P"
column commit_scn_based      format a3
column size_mb               format 999G990D99

compute sum of NUM_ROWS_PURGED on LOG_OWNER
compute sum of SIZE_MB on LOG_OWNER
break on LOG_OWNER

select ml.LOG_OWNER
       ,  ml.MASTER
       ,  ml.LOG_TABLE
       --  , ml.LOG_TRIGGER
       --  , ml.ROWIDS
       --  , ml.PRIMARY_KEY
       --  , ml.OBJECT_ID
       --  , ml.FILTER_COLUMNS
       --  , ml.SEQUENCE
       --  , ml.INCLUDE_NEW_VALUES
       --  , ml.PURGE_ASYNCHRONOUS
       --  , ml.PURGE_DEFERRED
       --  , ml.PURGE_START
       --  , ml.PURGE_INTERVAL
       ,  to_char (ml.LAST_PURGE_DATE, 'dd.mm.yyyy hh24:mi') as LAST_PURGE_DATE
       ,  ml.LAST_PURGE_STATUS
       ,  ml.NUM_ROWS_PURGED
       --  , ml.COMMIT_SCN_BASED
       ,  round ( (  ds.bytes / 1024/ 1024),  2) as SIZE_MB
    from DBA_MVIEW_LOGS ml, dba_segments ds
   where     ds.OWNER(+) = ml.LOG_OWNER
         and ds.SEGMENT_NAME(+) = ml.LOG_TABLE
order by ml.LOG_OWNER, ml.LOG_TABLE
/


-- LOG_OWNER    VARCHAR2(30)         Owner of the materialized view log
-- MASTER    VARCHAR2(30)             Name of the master table or master materialized view whose changes are logged
-- LOG_TABLE    VARCHAR2(30)         Name of the table where the changes to the master table or master materialized view are logged
-- LOG_TRIGGER    VARCHAR2(30)         Obsolete with Oracle8i and later. Set to NULL. Formerly, this parameter was an after-row trigger on the master which inserted rows into the log.
-- ROWIDS    VARCHAR2(3)                 Indicates whether rowid information is recorded (YES) or not (NO)
-- PRIMARY_KEY    VARCHAR2(3)             Indicates whether primary key information is recorded (YES) or not (NO)
-- OBJECT_ID    VARCHAR2(3)             Indicates whether object identifier information in an object table is recorded (YES) or not (NO)
-- FILTER_COLUMNS    VARCHAR2(3)         Indicates whether filter column information is recorded (YES) or not (NO)
-- SEQUENCE    VARCHAR2(3)                 Indicates whether the sequence value, which provides additional ordering information, is recorded (YES) or not (NO)
-- INCLUDE_NEW_VALUES    VARCHAR2(3)         Indicates whether both old and new values are recorded (YES) or old values are recorded but new values are not recorded (NO)
-- PURGE_ASYNCHRONOUS    VARCHAR2(3)         Indicates whether the materialized view log is purged asynchronously (YES) or not (NO)
-- PURGE_DEFERRED    VARCHAR2(3)                 Indicates whether the materialized view log is purged in a deferred manner (YES) or not (NO)
-- PURGE_START    DATE                             For deferred purge, the purge start date
-- PURGE_INTERVAL    VARCHAR2(200)             For deferred purge, the purge interval
-- LAST_PURGE_DATE    DATE                     Date of the last purge
-- LAST_PURGE_STATUS    NUMBER                 Status of the last purge (error code or 0 for success)
-- NUM_ROWS_PURGED    NUMBER                 Number of rows purged in the last purge
-- COMMIT_SCN_BASED    VARCHAR2(3)             Indicates whether the materialized view log is commit SCN-based (YES) or not (NO)


-- Native:
-- select log, sysdate, youngest, youngest+1/86400,  oldest, oldest_pk, oldest_oid, oldest_new, oldest_seq,  oscn, oscn_pk, oscn_oid, oscn_new, oscn_seq, flag, purge_job  from sys.mlog$
--

clear break