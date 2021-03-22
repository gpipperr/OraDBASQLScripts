--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: get the DB internal system stat values like workload statistic and i/o calibrate values
--==============================================================================
set linesize 130 pagesize 300 

ttitle left  "Workload Statistic Values" skip 2

column SNAME format a15 heading "Statistic|Name"
column pname format a12 heading "Parameter"
column PVAL1 format a20 heading "Value 1"
column PVAL2 format a20 heading "Value 2"

select sname
      ,pname
      ,to_char(pval1, '999G999G999D99') as pval1
      ,pval2
  from sys.aux_stats$
 order by 1
         ,2
/

prompt .... CPUSPEED    Workload CPU speed in millions of cycles/second
prompt .... CPUSPEEDNW  Noworkload CPU speed in millions of cycles/second
prompt .... IOSEEKTIM   Seek time + latency time + operating system overhead time in milliseconds
prompt .... IOTFRSPEED  Rate of a single read request in bytes/millisecond
prompt .... MAXTHR      Maximum throughput that the I/O subsystem can deliver in bytes/second
prompt .... MBRC        Average multiblock read count sequentially in blocks
prompt .... MREADTIM    Average time for a multi-block read request in milliseconds
prompt .... SLAVETHR    Average parallel slave I/O throughput in bytes/second
prompt .... SREADTIM    Average time for a single-block read request in milliseconds



column START_TIME   format a21     heading "Start|time"   
column END_TIME     format a21    heading "End|time"
column MAX_IOPS     format 9999999 
--heading "Block/s|data block" 
column MAX_MBPS     format 9999999 
--heading "MB/s|maximum-sized read" 
column MAX_PMBPS    format 9999999 
--heading "MB/s|largeI/0" 
column LATENCY      format 9999999 
--heading "Latency|data block read" 
column NUM_PHYSICAL_DISKS  format 999   heading "Disk|Cnt"


ttitle left  "I/O Calibrate Values" skip 2


select to_char(START_TIME,'dd.mm.yyyy hh24:mi') as START_TIME
 ,to_char(END_TIME,'dd.mm.yyyy hh24:mi') as END_TIME    
 ,MAX_IOPS    
 ,MAX_MBPS    
 ,MAX_PMBPS    
 ,LATENCY     
 ,NUM_PHYSICAL_DISKS
  from dba_rsrc_io_calibrate
/


prompt .... START_TIME        Start time of the most recent I/O calibration 
prompt .... END_TIME          End time of the most recent I/O calibration 
prompt .... MAX_IOPS          Maximum number of data block read requests that can be sustained per second 
prompt .... MAX_MBPS          Maximum megabytes per second of maximum-sized read requests that can be sustained 
prompt .... MAX_PMBPS         Maximum megabytes per second of large I/O requests that can be sustained by a single process 
prompt .... LATENCY           Latency for data block read requests 
prompt .... NUM_PHYSICAL_DISKS Number of physical disks in the storage subsystem (as specified by the user) 


column INST_ID          format 999  heading "IN|ID"
column STATUS           format a13  heading "Status"
column CALIBRATION_TIME format a21  heading "Calibration|time" 


ttitle left  "I/O Calibrate Status" skip 2

select INST_ID
 , STATUS
 , to_char(CALIBRATION_TIME,'dd.mm.yyyy hh24:mi') as CALIBRATION_TIME
 from GV$IO_CALIBRATION_STATUS
order by 1 
/

prompt ... You should see that your IO Calibrate is READY and therefore Auto DOP is ready.
prompt

ttitle off

