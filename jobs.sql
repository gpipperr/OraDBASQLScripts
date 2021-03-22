--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc : Information about jobs in the database
--==============================================================================
SET linesize 130 pagesize 300 

@jobs_dbms.sql

@jobs_sheduler.sql

prompt
prompt init.ora Settings for the job queue

show parameter job_queue_processes

prompt
prompt
prompt
