--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc:   Analyse the SYSAUX Table space and AWR Repository
-- Date:   08.2013
--==============================================================================
prompt
prompt !!!!You need the Tuning Pack for this feature!!!!
prompt


set linesize 130 pagesize 300 

---
@space_tablespace.sql SYSAUX
--


ttitle left  "AWR Snapshots count" skip 2
column snapshot_count format 999999 heading "Snapshot Count"

select count(*) as snapshot_count from sys.wrm$_snapshot
/

ttitle left  "AWR Snapshots time frame" skip 2
column snap_id format 999999 heading "Snap|Id"
column start_time format a21 heading "Start|time"
column end_time   format a21 heading "End|time"


select  snap_id
      , to_char(begin_interval_time,'dd.mm.yyyy hh24:mi:ss') as start_time
	  , to_char(end_interval_time ,'dd.mm.yyyy hh24:mi:ss')  as end_time
 from sys.wrm$_snapshot 
where   ( 
        snap_id = ( select min (snap_id) from sys.wrm$_snapshot) 
    or  snap_id = ( select max(snap_id) from sys.wrm$_snapshot) 
    )
order by snap_id asc
/


ttitle left  "AWR Usage Overview" skip 2

column occupant_name  format a25
column schema_name    format a18
column move_procedure format a40
column space_usage    format 9G999G999 heading "Space | Usage (M)"

select   occupant_name
       , round( space_usage_kbytes/1024) as space_usage  
       , schema_name
       , move_procedure
 from  v$sysaux_occupants  
 where space_usage_kbytes > 1
order by 2 desc    
/


DOC 
-------------------------------------------------------------------------------
 to drop some snapshots from the repostitory you can use this command:
 begin                                                               
  dbms_workload_repository.drop_snapshot_range( low_snap_id  => <min_snap_id>
                                              , high_snap_id => <max_snap_id>);                                         
 end;
 / 
 
 To get more Information you can use also @?/rdbms/admin/awrinfo.sql

-------------------------------------------------------------------------------
#

ttitle off
