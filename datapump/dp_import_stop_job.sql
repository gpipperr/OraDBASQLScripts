CREATE OR REPLACE PROCEDURE dp_import_stop_job(p_job_name varchar2)
is					  
--- +----------------------------------
--
-- testcall exec db_import_stop_job(p_job_name => 'MY_JOB')
--
-- +----------------------------------										  
  v_dp_handle   NUMBER;
  
  cursor c_act_jobs is 
  
  select job_name
		 ,  operation
		 ,  job_mode
		 ,  state
		 ,  attached_sessions
	from user_datapump_jobs
	where job_name not like 'BIN$%'
		order by 1,2
  ;
  
 
  v_job_exits boolean:=false;
  v_job_mode varchar2(32);
  v_job_state varchar2(32);
  v_real_job_name varchar2(32);
  v_count pls_integer;
  
  v_sts ku$_Status;
  v_job_run_state varchar2(2000);
  
BEGIN

  dbms_output.put_line(' -- Stop the Job  Parameter ------------' );
  dbms_output.put_line(' -- p_job_name      :: '|| p_job_name  );
  
  -- query all actual jobs
  -- to show a list of candidates if job_name is wrong
  --
  for rec in  c_act_jobs 
  loop  
	if rec.job_name = upper(p_job_name) then
		v_job_exits:=true;
		v_real_job_name:=rec.job_name;
		v_job_mode:=rec.job_mode;
		v_job_state:=rec.state;
	else
		v_job_exits:=false;
   end if;
    dbms_output.put_line('--- Found this Job :: ' ||rec.job_name );
    dbms_output.put_line('+-- Operation      :: ' ||rec.operation );
	dbms_output.put_line('+-- Mode           :: ' ||rec.job_mode );
	dbms_output.put_line('+-- State          :: ' ||rec.state );
	dbms_output.put_line('+-- Sessions       :: ' ||rec.attached_sessions );
  end loop;  

   if v_job_exits then 
   
    
	 begin
	 		-- Create Data Pump Handle - "ATTACH" in this case
			v_dp_handle := DBMS_DATAPUMP.ATTACH(
					 job_name    => v_real_job_name
					,job_owner   => user); 

	  exception 
		when DBMS_DATAPUMP.NO_SUCH_JOB then
		  -- check if the old job table exits
		  select count(*) into v_count from user_tables where upper(table_name) = upper(v_real_job_name);
		  if v_count > 0 then
			execute immediate 'drop table '||user||'."'||v_real_job_name||'"';
		  end if;
		  
		  RAISE_APPLICATION_ERROR (-20003, '-- Error :: Job Not running anymore, check for other errors - no mastertable  for '||p_job_name || ' get Error '||SQLERRM);
		  
	    when others then
	       RAISE_APPLICATION_ERROR (-20002, '-- Error :: Not possible to attach to the job - Error :: '||SQLERRM);
	  end;
	   
	   
		if  v_job_state in ('DEFINING') then
		
			-- check if the job is in the defining state!
			-- abnormal situation, normal stop not possible
			-- use DBMS_DATAPUMP.START_JOB to restart the job
		
			DBMS_DATAPUMP.START_JOB  ( 	handle    => v_dp_handle );
		
		
		end if;	  
		
		-- print the status
		
		 dbms_datapump.get_status (handle => v_dp_handle
		                    , mask       => dbms_datapump.KU$_STATUS_WIP
                            , timeout    => 0
                            , job_state  => v_job_run_state
                            , status     => v_sts
							);
         
		dbms_output.put_line('+-- Akt State       :: ' ||v_job_run_state );		

 
		-- Stop the job
		DBMS_DATAPUMP.STOP_JOB (
			handle    => v_dp_handle
			, immediate   => 1 			-- stop now
			, keep_master => null  		-- delete Master table
			, delay       => 5          -- wait 5 seconds before kill for other sessions
		);  		
	
	else
      RAISE_APPLICATION_ERROR (-20000, '-- Error :: This job name not found::'||p_job_name);
	end if;	  

end dp_import_stop_job;

/ 
   