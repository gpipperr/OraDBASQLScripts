-- ======================================
-- GPI - Gunther Pippèrr
-- set all server based metrics to empty values
-- =======================================
set verify off
set linesize 130 pagesize 300 recsep off

define INSTANCE_NAME = '&1'

prompt
prompt Parameter 1 = Instance Name         => &&INSTANCE_NAME.
prompt


set serveroutput on size 1000000

declare
   type metrics_idTab is table of varchar2 (2000)
                            index by binary_integer;

   cursor c_metrics (p_instance_name varchar2)
   is
      select metrics_id
           ,  object_type
           ,  object_name
           ,  instance_name
        from table (dbms_server_alert.view_thresholds)
       where instance_name = p_instance_name;

   v_instance                  varchar2 (32) := '&&INSTANCE_NAME.';
   v_warning_operator          binary_integer;
   v_warning_operator_text     varchar2 (32);
   v_warning_value             varchar2 (32);
   v_critical_operator         binary_integer;
   v_critical_operator_text    varchar2 (32);
   v_critical_value            varchar2 (32);
   v_observation_period        binary_integer;
   v_consecutive_occurrences   binary_integer;

   v_mid                       metrics_idTab;
begin




 -- create ta with all metric id's  
 -- if you are a lucky sys user you can use  X$KEWMDSM for this stupid typing!!
 --

   v_mid(DBMS_SERVER_ALERT.SQL_SRV_RESPONSE_TIME   ):='Service Response (for each execution) Seconds                                    ';
	v_mid(DBMS_SERVER_ALERT.BUFFER_CACHE_HIT        ):='Buffer Cache Hit (%) % of cache accesses                                         ';
--	v_mid(DBMS_SERVER_ALERT.LIBRARY_CACHE_HIT       ):='Library Cache Hit (%) % of cache accesses                                        ';
--	v_mid(DBMS_SERVER_ALERT.LIBRARY_CACHE_MISS      ):='Library Cache Miss (%) % of cache accesses                                       ';
	v_mid(DBMS_SERVER_ALERT.MEMORY_SORTS_PCT        ):='Sorts in Memory (%) % of sorts                                                   ';
	v_mid(DBMS_SERVER_ALERT.REDO_ALLOCATION_HIT     ):='Redo Log Allocation Hit % of redo allocations                                    ';
--	v_mid(DBMS_SERVER_ALERT.TRANSACTION_RATE        ):='Number of Transactions (for each second) Transactions for each Second            ';
	v_mid(DBMS_SERVER_ALERT.PHYSICAL_READS_SEC      ):='Physical Reads (for each second) Reads for each Second                           ';
	v_mid(DBMS_SERVER_ALERT.PHYSICAL_READS_TXN      ):='Physical Reads (for each transaction) Reads for each Transaction                 ';
	v_mid(DBMS_SERVER_ALERT.PHYSICAL_WRITES_SEC     ):='Physical Writes (for each second) Writes for each Second                         ';
	v_mid(DBMS_SERVER_ALERT.PHYSICAL_WRITES_TXN     ):='Physical Writes (for each transaction) Writes for each Transaction               ';
	v_mid(DBMS_SERVER_ALERT.PHYSICAL_READS_DIR_SEC  ):='Direct Physical Reads (for each second) Reads for each Second                    ';
	v_mid(DBMS_SERVER_ALERT.PHYSICAL_READS_DIR_TXN  ):='Direct Physical Reads (for each transaction) Reads for each Transaction          ';
	v_mid(DBMS_SERVER_ALERT.PHYSICAL_WRITES_DIR_SEC ):='Direct Physical Writes (for each second) Writes for each Second                  ';
	v_mid(DBMS_SERVER_ALERT.PHYSICAL_WRITES_DIR_TXN ):='Direct Physical Writes (for each transaction) Writes for each Transaction        ';
	v_mid(DBMS_SERVER_ALERT.PHYSICAL_READS_LOB_SEC  ):='Direct LOB Physical Reads (for each second) Reads for each Second                ';
	v_mid(DBMS_SERVER_ALERT.PHYSICAL_READS_LOB_TXN  ):='Direct LOB Physical Reads (for each transaction) Reads for each Transaction      ';
	v_mid(DBMS_SERVER_ALERT.PHYSICAL_WRITES_LOB_SEC ):='Direct LOB Physical Writes (for each second) Writes for each Second              ';
	v_mid(DBMS_SERVER_ALERT.PHYSICAL_WRITES_LOB_TXN ):='Direct LOB Physical Writes (for each transaction) Writes for each Transaction    ';
	v_mid(DBMS_SERVER_ALERT.REDO_GENERATED_SEC      ):='Redo Generated (for each second) Redo Bytes for each Second                      ';
	v_mid(DBMS_SERVER_ALERT.REDO_GENERATED_TXN      ):='Redo Generated (for each transaction) Redo Bytes for each Transaction            ';
	v_mid(DBMS_SERVER_ALERT.DATABASE_WAIT_TIME      ):='Database Wait Time (%) % of all database time                                    ';
	v_mid(DBMS_SERVER_ALERT.DATABASE_CPU_TIME       ):='Database CPU Time (%) % of all database time                                     ';
	v_mid(DBMS_SERVER_ALERT.LOGONS_SEC              ):='Cumulative Logons (for each second)Logons for each Second                        ';
	v_mid(DBMS_SERVER_ALERT.LOGONS_TXN              ):='Cumulative Logons (for each transaction)Logons for each Transaction              ';
	v_mid(DBMS_SERVER_ALERT.LOGONS_CURRENT          ):='Current Number of Logons Number of Logons                                        ';
	v_mid(DBMS_SERVER_ALERT.OPEN_CURSORS_SEC        ):='Cumulative Open Cursors (for each second) Cursors for each Second                ';
	v_mid(DBMS_SERVER_ALERT.OPEN_CURSORS_TXN        ):='Cumulative Open Cursors (for each transaction) Cursors for each Transaction      ';
	v_mid(DBMS_SERVER_ALERT.OPEN_CURSORS_CURRENT    ):='Current Number of Cursors Number of Cursors                                      ';
	v_mid(DBMS_SERVER_ALERT.USER_COMMITS_SEC        ):='User Commits (for each second) Commits for each Second                           ';
	v_mid(DBMS_SERVER_ALERT.USER_COMMITS_TXN        ):='User Commits (for each transaction) Commits for each Transaction                 ';
	v_mid(DBMS_SERVER_ALERT.USER_ROLLBACKS_SEC      ):='User Rollbacks (for each second) rollbacks for each Second                       ';
	v_mid(DBMS_SERVER_ALERT.USER_ROLLBACKS_TXN      ):='User Rollbacks (for each transaction) Rollbacks for each Transaction             ';
	v_mid(DBMS_SERVER_ALERT.USER_CALLS_SEC          ):='User Calls (for each second) Calls for each Second                               ';
	v_mid(DBMS_SERVER_ALERT.USER_CALLS_TXN          ):='User Calls (for each transaction) Calls for each Transaction                     ';
	v_mid(DBMS_SERVER_ALERT.RECURSIVE_CALLS_SEC     ):='Recursive Calls (for each second) Calls for each Second                          ';
	v_mid(DBMS_SERVER_ALERT.RECURSIVE_CALLS_TXN     ):='Recursive Calls (for each transaction) Calls for each Transaction                ';
	v_mid(DBMS_SERVER_ALERT.SESS_LOGICAL_READS_SEC  ):='Session Logical Reads (for each second) Reads for each Second                    ';
	v_mid(DBMS_SERVER_ALERT.SESS_LOGICAL_READS_TXN  ):='Session Logical Reads (for each transaction) Reads for each Transaction          ';
	v_mid(DBMS_SERVER_ALERT.DBWR_CKPT_SEC           ):='DBWR Checkpoints (for each second) Checkpoints for each Second                   ';
--	v_mid(DBMS_SERVER_ALERT.LOG_SWITCH_SEC          ):='Background Checkpoints (for each second) Checkpoints for each Second             ';
	v_mid(DBMS_SERVER_ALERT.REDO_WRITES_SEC         ):='Redo Writes (for each second) Writes for each Second                             ';
	v_mid(DBMS_SERVER_ALERT.REDO_WRITES_TXN         ):='Redo Writes (for each transaction) Writes for each Transaction                   ';
	v_mid(DBMS_SERVER_ALERT.LONG_TABLE_SCANS_SEC    ):='Scans on Long Tables (for each second) Scans for each Second                     ';
	v_mid(DBMS_SERVER_ALERT.LONG_TABLE_SCANS_TXN    ):='Scans on Long Tables (for each transaction) Scans for each Transaction           ';
	v_mid(DBMS_SERVER_ALERT.TOTAL_TABLE_SCANS_SEC   ):='Total Table Scans (for each second) Scans for each Second                        ';
	v_mid(DBMS_SERVER_ALERT.TOTAL_TABLE_SCANS_TXN   ):='Total Table Scans (for each transaction) Scans for each Transaction              ';
	v_mid(DBMS_SERVER_ALERT.FULL_INDEX_SCANS_SEC    ):='Fast Full Index Scans (for each second) Scans for each Second                    ';
	v_mid(DBMS_SERVER_ALERT.FULL_INDEX_SCANS_TXN    ):='Fast Full Index Scans (for each transaction) Scans for each Transaction          ';
	v_mid(DBMS_SERVER_ALERT.TOTAL_INDEX_SCANS_SEC   ):='Total Index Scans (for each second) Scans for each Second                        ';
	v_mid(DBMS_SERVER_ALERT.TOTAL_INDEX_SCANS_TXN   ):='Total Index Scans (for each transaction) Scans for each Transaction              ';
	v_mid(DBMS_SERVER_ALERT.TOTAL_PARSES_SEC        ):='Total Parses (for each second)  Parses for each Second                           ';
	v_mid(DBMS_SERVER_ALERT.TOTAL_PARSES_TXN        ):='Total Parses (for each transaction) Parses for each Transaction                  ';
	v_mid(DBMS_SERVER_ALERT.HARD_PARSES_SEC         ):='Hard Parses (for each second) Parses for each Second                             ';
	v_mid(DBMS_SERVER_ALERT.HARD_PARSES_TXN         ):='Hard Parses (for each transaction) Parses for each Transaction                   ';
	v_mid(DBMS_SERVER_ALERT.PARSE_FAILURES_SEC      ):='Parse Failures (for each second) Parses for each Second                          ';
	v_mid(DBMS_SERVER_ALERT.PARSE_FAILURES_TXN      ):='Parse Failures (for each transaction) Parses for each Transaction                ';
	v_mid(DBMS_SERVER_ALERT.DISK_SORT_SEC           ):='Sorts to Disk (for each second) Sorts for each Second                            ';
	v_mid(DBMS_SERVER_ALERT.DISK_SORT_TXN           ):='Sorts to Disk (for each transaction) Sorts for each Transaction                  ';
	v_mid(DBMS_SERVER_ALERT.ROWS_PER_SORT           ):='Rows Processed for each Sort Rows for each Sort                                  ';
	v_mid(DBMS_SERVER_ALERT.EXECUTE_WITHOUT_PARSE   ):='Executes Performed Without Parsing % of all executes                             ';
	v_mid(DBMS_SERVER_ALERT.SOFT_PARSE_PCT          ):='Soft Parse (%) % of all parses                                                   ';
	v_mid(DBMS_SERVER_ALERT.CURSOR_CACHE_HIT        ):='Cursor Cache Hit (%) % of soft parses                                            ';
	v_mid(DBMS_SERVER_ALERT.USER_CALLS_PCT          ):='User Calls (%) % of all calls                                                    ';
--	v_mid(DBMS_SERVER_ALERT.TXN_COMMITTED_PCT       ):='Transactions Committed (%) % of all transactions                                 ';
	v_mid(DBMS_SERVER_ALERT.NETWORK_BYTES_SEC       ):='Network Bytes, for each second Bytes for each Second                             ';
	v_mid(DBMS_SERVER_ALERT.RESPONSE_TXN            ):='Response (for each transaction) Seconds for each Transaction                     ';
--	v_mid(DBMS_SERVER_ALERT.DATA_DICT_HIT           ):='Data Dictionary Hit (%) % of dictionary accesses                                 ';
--	v_mid(DBMS_SERVER_ALERT.DATA_DICT_MISS          ):='Data Dictionary Miss (%) % of dictionary accesses                                ';
	v_mid(DBMS_SERVER_ALERT.SHARED_POOL_FREE_PCT    ):='Shared Pool Free(%) % of shared pool                                             ';
--	v_mid(DBMS_SERVER_ALERT.AVERAGE_FILE_READ_TIME  ):='Average File Read Time Microseconds                                              ';
--	v_mid(DBMS_SERVER_ALERT.AVERAGE_FILE_WRITE_TIME ):='Average File Write Time Microseconds                                             ';
--	v_mid(DBMS_SERVER_ALERT.DISK_IO                 ):='Disk I/O Milliseconds                                                            ';
	v_mid(DBMS_SERVER_ALERT.PROCESS_LIMIT_PCT       ):='Process Limit Usage (%) % of maximum value                                       ';
	v_mid(DBMS_SERVER_ALERT.SESSION_LIMIT_PCT       ):='Session Limit Usage (%) % of maximum value                                       ';
	v_mid(DBMS_SERVER_ALERT.USER_LIMIT_PCT          ):='User Limit Usage (%) % of maximum value                                          ';
	v_mid(DBMS_SERVER_ALERT.AVG_USERS_WAITING       ):='Average Number of Users Waiting on a Class of Wait Events Count of sessions      ';
	v_mid(DBMS_SERVER_ALERT.DB_TIME_WAITING         ):='Percent of Database Time Spent Waiting on a Class of Wait Events % of Database Time';
--	v_mid(DBMS_SERVER_ALERT.APPL_DESGN_WAIT_SCT     ):='Application Design Wait (by session count) Count of sessions                     ';
--	v_mid(DBMS_SERVER_ALERT.APPL_DESGN_WAIT_TIME    ):='Application Design Wait (by time) Microseconds                                   ';
--	v_mid(DBMS_SERVER_ALERT.PHYS_DESGN_WAIT_SCT     ):='Physical Design Wait (by session count) Count of sessions                        ';
--	v_mid(DBMS_SERVER_ALERT.PHYS_DESGN_WAIT_TIME    ):='Physical Design Wait (by time) Microseconds                                      ';
--	v_mid(DBMS_SERVER_ALERT.CONTENTION_WAIT_SCT     ):='Internal Contention Wait (by session count) Count of sessions                    ';
--	v_mid(DBMS_SERVER_ALERT.CONTENTION_WAIT_TIME    ):='Internal Contention Wait (by time) Microseconds                                  ';
--	v_mid(DBMS_SERVER_ALERT.PSERVICE_WAIT_SCT       ):='Process Service Wait (by session count) Count of sessions                        ';
--	v_mid(DBMS_SERVER_ALERT.PSERVICE_WAIT_TIME      ):='Process Service Wait (by time) Microseconds                                      ';
--	v_mid(DBMS_SERVER_ALERT.NETWORK_MSG_WAIT_SCT    ):='Network Message Wait (by session count) Count of sessions                        ';
--	v_mid(DBMS_SERVER_ALERT.NETWORK_MSG_WAIT_TIME   ):='Network Message Wait (by time) Microseconds                                      ';
--	v_mid(DBMS_SERVER_ALERT.DISK_IO_WAIT_SCT        ):='Disk I/O Wait (by session count) Count of sessions                               ';
--	v_mid(DBMS_SERVER_ALERT.OS_SERVICE_WAIT_SCT     ):='Operating System Service Wait (by session count) Count of sessions               ';
--	v_mid(DBMS_SERVER_ALERT.OS_SERVICE_WAIT_TIME    ):='Operating System Service Wait (by time) Microseconds                             ';
--	v_mid(DBMS_SERVER_ALERT.DBR_IO_LIMIT_WAIT_SCT   ):='Resource Mgr I/O Limit Wait (by session count) Count of sessions                 ';
--	v_mid(DBMS_SERVER_ALERT.DBR_IO_LIMIT_WAIT_TIME  ):='Resource Mgr I/O Limit Wait (by time) Microseconds                               ';
--	v_mid(DBMS_SERVER_ALERT.DBR_CPU_LIMIT_WAIT_SCT  ):='Resource Mgr CPU Limit Wait (by session count) Count of sessions                 ';
--	v_mid(DBMS_SERVER_ALERT.DBR_CPU_LIMIT_WAIT_TIME ):='Resource Mgr CPU Limit Wait (by time) Microseconds                               ';
--	v_mid(DBMS_SERVER_ALERT.DBR_USR_LIMIT_WAIT_SCT  ):='Resource Mgr User Limit Wait (by session count) Count of sessions                ';
--	v_mid(DBMS_SERVER_ALERT.DBR_USR_LIMIT_WAIT_TIME ):='Resource Mgr User Limit Wait (by time) Microseconds                              ';
--	v_mid(DBMS_SERVER_ALERT.OS_SCHED_CPU_WAIT_SCT   ):='Operating System Scheduler CPU Wait (by session count) Count of sessions         ';
--	v_mid(DBMS_SERVER_ALERT.OS_SCHED_CPU__WAIT_TIME ):='Operating System Scheduler CPU Wait (by time) Microseconds                       ';
--	v_mid(DBMS_SERVER_ALERT.CLUSTER_MSG_WAIT_SCT    ):='Cluster Messaging Wait (by session count) Count of sessions                      ';
--	v_mid(DBMS_SERVER_ALERT.CLUSTER_MSG_WAIT_TIME   ):='Cluster Messaging Wait (by time) Microseconds                                    ';
--	v_mid(DBMS_SERVER_ALERT.OTHER_WAIT_SCT          ):='Other Waits (by session count) Count of sessions                                 ';
--	v_mid(DBMS_SERVER_ALERT.OTHER_WAIT_TIME         ):='Other Waits (by time) Microseconds                                               ';
	v_mid(DBMS_SERVER_ALERT.ENQUEUE_TIMEOUTS_SEC    ):='Enqueue Timeouts (for each second) Timeouts for each Second                      ';
	v_mid(DBMS_SERVER_ALERT.ENQUEUE_TIMEOUTS_TXN    ):='Enqueue Timeouts (for each transaction) Timeouts for each Transaction            ';
	v_mid(DBMS_SERVER_ALERT.ENQUEUE_WAITS_SEC       ):='Enqueue Waits (for each second) Waits for each Second                            ';
	v_mid(DBMS_SERVER_ALERT.ENQUEUE_WAITS_TXN       ):='Enqueue Waits (for each transaction) Waits for each Transaction                  ';
	v_mid(DBMS_SERVER_ALERT.ENQUEUE_DEADLOCKS_SEC   ):='Enqueue Deadlocks (for each second) Deadlocks for each Second                    ';
	v_mid(DBMS_SERVER_ALERT.ENQUEUE_DEADLOCKS_TXN   ):='Enqueue Deadlocks (for each transaction) Deadlocks for each Transaction          ';
	v_mid(DBMS_SERVER_ALERT.ENQUEUE_REQUESTS_SEC    ):='Enqueue Requests (for each second) Requests for each Second                      ';
	v_mid(DBMS_SERVER_ALERT.ENQUEUE_REQUESTS_TXN    ):='Enqueue Requests (for each transaction) Requests for each Transaction            ';
	v_mid(DBMS_SERVER_ALERT.DB_BLKGETS_SEC          ):='DB Block Gets (for each second) Gets for each Second                             ';
	v_mid(DBMS_SERVER_ALERT.DB_BLKGETS_TXN          ):='DB Block Gets (for each transaction)  Gets for each Transaction                  ';
	v_mid(DBMS_SERVER_ALERT.CONSISTENT_GETS_SEC     ):='Consistent Gets (for each second) Gets for each Second                           ';
	v_mid(DBMS_SERVER_ALERT.CONSISTENT_GETS_TXN     ):='Consistent Gets (for each transaction) Gets for each Transaction                 ';
	v_mid(DBMS_SERVER_ALERT.DB_BLKCHANGES_SEC       ):='DB Block Changes (for each second) Changes for each Second                       ';
	v_mid(DBMS_SERVER_ALERT.DB_BLKCHANGES_TXN       ):='DB Block Changes (for each transaction) Changes for each Transaction             ';
	v_mid(DBMS_SERVER_ALERT.CONSISTENT_CHANGES_SEC  ):='Consistent Changes (for each second) Changes for each Second                     ';
	v_mid(DBMS_SERVER_ALERT.CONSISTENT_CHANGES_TXN  ):='Consistent Changes (for each transaction) Changes for each Transaction           ';
	v_mid(DBMS_SERVER_ALERT.SESSION_CPU_SEC         ):='Database CPU (for each second) Microseconds for each Second                      ';
	v_mid(DBMS_SERVER_ALERT.SESSION_CPU_TXN         ):='Database CPU (for each transaction) Microseconds for each Transaction            ';
	v_mid(DBMS_SERVER_ALERT.CR_BLOCKS_CREATED_SEC   ):='CR Blocks Created (for each second) Blocks for each Second                       ';
	v_mid(DBMS_SERVER_ALERT.CR_BLOCKS_CREATED_TXN   ):='CR Blocks Created (for each transaction) Blocks for each Transaction             ';
	v_mid(DBMS_SERVER_ALERT.CR_RECORDS_APPLIED_SEC  ):='CR Undo Records Applied (for each second) Records for each Second                ';
	v_mid(DBMS_SERVER_ALERT.CR_RECORDS_APPLIED_TXN  ):='CR Undo Records Applied (for each transaction) Records for each Transaction      ';
	v_mid(DBMS_SERVER_ALERT.RB_RECORDS_APPLIED_SEC  ):='Rollback Undo Records Applied (for each second) Records for each Second          ';
	v_mid(DBMS_SERVER_ALERT.RB_RECORDS_APPLIED_TXN  ):='Rollback Undo Records Applied (for each transactionRecords for each Transaction  ';
	v_mid(DBMS_SERVER_ALERT.LEAF_NODE_SPLITS_SEC    ):='Leaf Node Splits (for each secondSplits for each Second                          ';
	v_mid(DBMS_SERVER_ALERT.LEAF_NODE_SPLITS_TXN    ):='Leaf Node Splits (for each transaction) Splits for each Transaction              ';
	v_mid(DBMS_SERVER_ALERT.BRANCH_NODE_SPLITS_SEC  ):='Branch Node Splits (for each second) Splits for each Second                      ';
	v_mid(DBMS_SERVER_ALERT.BRANCH_NODE_SPLITS_TXN  ):='Branch Node Splits (for each transaction) Splits for each Transaction            ';
	v_mid(DBMS_SERVER_ALERT.GC_BLOCKS_CORRUPT       ):='Global Cache Blocks Corrupt Blocks                                               ';
	v_mid(DBMS_SERVER_ALERT.GC_BLOCKS_LOST          ):='Global Cache Blocks Lost Blocks                                                  ';
	v_mid(DBMS_SERVER_ALERT.GC_AVG_CR_GET_TIME      ):='Global Cache CR Request Milliseconds                                             ';
	v_mid(DBMS_SERVER_ALERT.GC_AVG_CUR_GET_TIME     ):='Global Cache Current Request  Milliseconds                                       ';
--	v_mid(DBMS_SERVER_ALERT.PX_DOWNGRADED_SEC       ):='Downgraded Parallel Operations (for each second) Operations for each Second      ';
	v_mid(DBMS_SERVER_ALERT.PX_DOWNGRADED_25_SEC    ):='Downgraded to 25% and more (for each second) Operations for each Second          ';
	v_mid(DBMS_SERVER_ALERT.PX_DOWNGRADED_50_SEC    ):='Downgraded to 50% and more (for each second) Operations for each Second          ';
	v_mid(DBMS_SERVER_ALERT.PX_DOWNGRADED_75_SEC    ):='Downgraded to 75% and more (for each second) Operations for each Second          ';
--	v_mid(DBMS_SERVER_ALERT.PX_DOWNGRADED_SER_SEC   ):='Downgraded to serial (for each second) Operations for each Second                ';
	v_mid(DBMS_SERVER_ALERT.BLOCKED_USERS           ):='Number of Users blocked by some Session Number of Users                          ';
	v_mid(DBMS_SERVER_ALERT.PGA_CACHE_HIT           ):='PGA Cache Hit (%) % bytes processed in PGA                                           ';
	v_mid(DBMS_SERVER_ALERT.ELAPSED_TIME_PER_CALL   ):='Elapsed time for each user call for each service Microseconds for each call      ';
	v_mid(DBMS_SERVER_ALERT.CPU_TIME_PER_CALL       ):='CPU time for each user call for each service Microseconds for each call          ';
	v_mid(DBMS_SERVER_ALERT.TABLESPACE_PCT_FULL     ):='Tablespace space usage% full                                                     ';
	v_mid(DBMS_SERVER_ALERT.TABLESPACE_BYT_FREE     ):='Tablespace bytes space usage Kilobytes free                                      ';

   -- read all metrics for the instance and set to null

   for rec in c_metrics (p_instance_name => upper (v_instance))
   loop
      dbms_output.put_line ('-- Info ' || rpad (' ', 80, '-'));
      dbms_output.put_line ('-- Info - Metric for Instance ::' || rec.instance_name);
      dbms_output.put_line (
         '-- Info - Metric ID (' || rec.metrics_id || ') O. Type(' || rec.object_type || ')  O. Name(' || rec.object_name || ')');

      begin
         dbms_output.put_line ('-- Info - Metrik Name :: ' || v_mid (rec.metrics_id));
      exception
         when others
         then
            dbms_output.put_line ('-- Info - Metrik Name not found for :: ' || rec.metrics_id);
      end;

      dbms_server_alert.get_threshold (metrics_id  => rec.metrics_id
                                     ,  warning_operator => v_warning_operator
                                     ,  warning_value => v_warning_value
                                     ,  critical_operator => v_critical_operator
                                     ,  critical_value => v_critical_value
                                     ,  observation_period => v_observation_period
                                     ,  consecutive_occurrences => v_consecutive_occurrences
                                     ,  instance_name => rec.instance_name
                                     ,  object_type => rec.object_type
                                     ,  object_name => rec.object_name);

      ---
      select decode (v_warning_operator
                   ,  0, 'GT'
                   ,  1, 'EQ'
                   ,  2, 'LT'
                   ,  3, 'LE'
                   ,  4, 'GE'
                   ,  5, 'CONTAINS'
                   ,  6, 'NE'
                   ,  7, 'DO_NOT_CHECK'
                   ,  'NONE')
        into v_warning_operator_text
        from dual;

      ---
      select decode (v_critical_operator
                   ,  0, 'GT'
                   ,  1, 'EQ'
                   ,  2, 'LT'
                   ,  3, 'LE'
                   ,  4, 'GE'
                   ,  5, 'CONTAINS'
                   ,  6, 'NE'
                   ,  7, 'DO NOT CHECK'
                   ,  'NONE')
        into v_critical_operator_text
        from dual;

      ---
      dbms_output.put_line (
            '-- Info - Warning OP          :: '
         || rpad (v_warning_operator_text, 20, ' ')
         || 'Warning Value           :: '
         || v_warning_value);
      dbms_output.put_line (
            '-- Info - Critical OP         :: '
         || rpad (v_critical_operator_text, 20, ' ')
         || 'Critical Value          :: '
         || v_critical_value);
      dbms_output.put_line (
            '-- Info - Observation Period  :: '
         || rpad (v_observation_period, 20, ' ')
         || 'Consecutive Occurrences :: '
         || v_consecutive_occurrences);

      ---

      if v_warning_value is not null
      then
         dbms_output.put_line ('-- Info -');
         dbms_output.put_line ('-- Info - Unset the thresholds for this Metric : ' || rec.metrics_id);

         dbms_server_alert.set_threshold (metrics_id  => rec.metrics_id
                                        ,  warning_operator => null
                                        ,  warning_value => null
                                        ,  critical_operator => null
                                        ,  critical_value => null
                                        ,  observation_period => null
                                        ,  consecutive_occurrences => null
                                        ,  instance_name => rec.instance_name
                                        ,  object_type => rec.object_type
                                        ,  object_name => rec.object_name);
         commit;
      end if;

      dbms_output.put_line ('-- Info ' || rpad (' ', 80, '-'));
   end loop;
end;
/