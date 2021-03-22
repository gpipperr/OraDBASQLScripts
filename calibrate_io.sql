--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   SQL Script to check io of the database
-- Date:   08.2013
--==============================================================================
-- Doku:   http://www.oracle.com/webfolder/technetwork/de/community/dbadmin/tipps/io_calibration/index.html
--         http://docs.oracle.com/cd/E11882_01/appdev.112/e25788/d_resmgr.htm#CJGHGFEA
--         https://support.oracle.com/epmos/main/downloadattachmentprocessor?attachid=727062.1:CALIBRATEIO&clickstream=yes
--         http://docs.oracle.com/cd/E11882_01/appdev.112/e40758/d_resmgr.htm#ARPLS050
--
-- num_physical_disks  Approximate number of physical disks in the database storage
-- max_latency         Maximum tolerable latency in milliseconds for database-block-sized IO requests
-- max_iops            Maximum number of I/O requests per second that can be sustained. The I/O requests are randomly-distributed, database-block-sized reads.
-- max_mbps            Maximum throughput of I/O that can be sustained, expressed in megabytes per second. The I/O requests are randomly-distributed, 1 megabyte reads.
-- actual_latency      Average latency of database-block-sized I/O requests at max_iops rate, expressed in milliseconds
-- 
--==============================================================================
--
-- Must run as SYS!
--
--
--==============================================================================
set linesize 130 pagesize 300 

column name       format a35
column start_time format a25
column end_time   format a25

select * 
  from  sys.RESOURCE_IO_CALIBRATE$
/

select * 
   from GV$IO_CALIBRATION_STATUS
/

prompt ...
prompt ... Check that all disks are on async IO!
prompt ...

SELECT count(*)
     , i.asynch_io 
  FROM v$datafile f
     , v$iostat_file i
 WHERE f.file#          = i.file_no
   AND i.filetype_name  = 'Data File'
 group by i.asynch_io  
 /
 
prompt ...
prompt ... Check that all disks are on async IO!
prompt ...

 
set serveroutput on
set timing on
set time on

-- set the Count of Disk on the count of luns behind the ASM disks 
--
declare
  lat  integer;
  iops integer;
  mbps integer;
begin
  dbms_resource_manager.calibrate_io (  
		  num_physical_disks    => 36
		, max_latency           => 10
		, max_iops              => iops
		, max_mbps              => mbps
		, actual_latency        => lat
	);
	
  dbms_output.put_line('max_iops = ' || iops);
  dbms_output.put_line('latency  = ' || lat);
  dbms_output.put_line('max_mbps = ' || mbps);
end;
/


set timing off
set time off



column start_time          format a21    heading "Start|time"			
column end_time 		   format a21    heading "End|time"
column max_iops 		   format 9999999 heading "Block/s|data block" 
column max_mbps 		   format 9999999 heading "MB/s|maximum-sized read" 
column max_pmbps 		   format 9999999 heading "MB/s|largeI/0" 
column latency 			   format 9999999 heading "Latency|data block read" 
column num_physical_disks  format 999     heading "Disk|Cnt"

select to_char(START_TIME,'dd.mm.yyyy hh24:mi') as START_TIME
	,to_char(END_TIME,'dd.mm.yyyy hh24:mi') as END_TIME 			
	,MAX_IOPS 			
	,MAX_MBPS 			
	,MAX_PMBPS 			
	,LATENCY 				
	,NUM_PHYSICAL_DISKS
  from dba_rsrc_io_calibrate
/

-- START_TIME 			Start time of the most recent I/O calibration 
-- END_TIME 			End time of the most recent I/O calibration 
-- MAX_IOPS 			Maximum number of data block read requests that can be sustained per second 
-- MAX_MBPS 			Maximum megabytes per second of maximum-sized read requests that can be sustained 
-- MAX_PMBPS 			Maximum megabytes per second of large I/O requests that can be sustained by a single process 
-- LATENCY 					Latency for data block read requests 
-- NUM_PHYSICAL_DISKS 	Number of physical disks in the storage subsystem (as specified by the user) 

select * 
   from GV$IO_CALIBRATION_STATUS
/

prompt ... You should see that your IO Calibrate is READY and therefore Auto DOP is ready.

select
     d.name
   , f.file_no
   , f.small_read_megabytes
   , f.small_read_reqs
   , f.large_read_megabytes
   , f.large_read_reqs
from
   v$iostat_file f
   inner join v$datafile d on f.file_no = d.file#
/
