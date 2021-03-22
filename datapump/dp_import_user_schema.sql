CREATE OR REPLACE PROCEDURE dp_import_user_schema
IS

--- +----------------------------------
--
-- testcall exec dp_import_user_schema
--
-- +----------------------------------		


  v_dp_handle   NUMBER;
  PRAGMA AUTONOMOUS_TRANSACTION;
  
  v_db_directory varchar2(200):='BACKUP';
  v_db_link varchar2(200):='DP_TRANSFER';
  v_job_name varchar2(256):=user ||'_IMPORT' || TO_CHAR (SYSDATE, 'DD_HH24');
  --v_log_file_name varchar2(256):=user||'_' || TO_CHAR (SYSDATE, 'YYYYMMDD-HH24MISS') || '.log';
  v_log_file_name varchar2(256):='db_import_plsql.log';
  
BEGIN

  dbms_output.put_line(' -- Import Parameter ------------' );
  dbms_output.put_line(' -- DB Link      :: '|| v_db_link  );
  dbms_output.put_line(' -- DB DIRECTORY :: '|| v_db_directory);
  dbms_output.put_line(' -- DP JOB Name  :: '|| v_job_name);
  dbms_output.put_line(' -- DP Log File  :: '|| v_log_file_name);
  
  
  
  -- Create Data Pump Handle - "IMPORT" in this case
  v_dp_handle := DBMS_DATAPUMP.open  (operation => 'IMPORT'
	                  , job_mode    => 'SCHEMA'
					  , job_name    => v_job_name
					  , remote_link => v_db_link);
 
  -- No PARALLEL
  DBMS_DATAPUMP.set_parallel (handle => v_dp_handle, degree => 1);
  
  -- consistent EXPORT
  -- Consistent to the start of the export with the timestamp of systimestamp
  --
  DBMS_DATAPUMP.SET_PARAMETER(
    handle       =>  v_dp_handle
   , name         => 'FLASHBACK_TIME'
   , value        => 'systimestamp'
   );
   
 
  -- impprt the complete schema Filter
  DBMS_DATAPUMP.metadata_filter (handle => v_dp_handle
                                , name => 'SCHEMA_EXPR'
								 , VALUE => 'IN ('''||user||''')');
 
   
  -- Logfile
  DBMS_DATAPUMP.add_file (handle      => v_dp_handle
                         ,filename    => v_log_file_name
                         ,filetype    => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE
                         ,directory   => v_db_directory
                         ,reusefile   => 1   -- overwrite existing files
                         ,filesize    => '10000M');
 
 
  -- Do it!
  DBMS_DATAPUMP.start_job (handle => v_dp_handle);
 
  COMMIT;
   
   
  DBMS_DATAPUMP.detach (handle => v_dp_handle);
  
END dp_import_user_schema;
/