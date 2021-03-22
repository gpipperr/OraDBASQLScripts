--==============================================================================
-- create the role for the usage of the AWR repository for none DBA user
-- run as sys
--==============================================================================
set echo on

create role call_awr_reports;

grant select on sys.v_$database to call_awr_reports;
grant select on sys.v_$instance to call_awr_reports;
grant execute on sys.dbms_workload_repository to call_awr_reports;
grant select on sys.dba_hist_database_instance to call_awr_reports;
grant select on sys.dba_hist_snapshot to call_awr_reports;

set echo off

