--==============================================================================
-- GPI -  Gunther Pippèrr 
-- Desc:  get the RMan settings
-- Date:  September 2013
--==============================================================================
-- Source:  http://docs.oracle.com/cd/E11882_01/backup.112/e10643/rcviews001.htm
--==============================================================================
set linesize 130 pagesize 300 

ttitle  "RMan non default settings"  SKIP 2

column conf# format 9999
column name  format a30 heading "Name"
column value format a70 heading "Value"

select conf#
    ,  name
    ,  value
 from  v$rman_configuration
order by conf#
/ 

ttitle "Check Block Change Tracking" SKIP 2

column filename format a60


select filename
     , status
	  , bytes
   from   v$block_change_tracking
/

ttitle "Check Usage of the Change Tracking" SKIP 2

select round(sum(nvl(BLOCKS_READ,0))/ ( sum(nvl(DATAFILE_BLOCKS,0))/100 ) ,3) as PERCENT_INCREMENT   
 from v$backup_datafile 
where USED_CHANGE_TRACKING = 'YES'
/

ttitle "Overview over the last backups of the system tables space" SKIP 2

select completion_time
     , datafile_blocks
     , blocks_read
	 , blocks 
	 , USED_CHANGE_TRACKING 
  from v$backup_datafile w
where USED_CHANGE_TRACKING = 'YES'  
 and file# = 1 
order by 1
/

ttitle "Overview over the last backups of all datafiles" SKIP 2

select min(completion_time) First_time
    , max(completion_time)  last_time
    , count(*)              total
    , sum(decode(USED_CHANGE_TRACKING,'YES',1,0)) as  USED_CHANGE_TRACKING
	, sum(decode(USED_CHANGE_TRACKING,'NO',1,0))  as  NO_CHANGE_TRACKING
  from v$backup_datafile w
where USED_CHANGE_TRACKING = 'YES'  
order by 1
/


ttitle  "RMan last Backups Sets of the last 3 days"  SKIP 2

column set_stamp            format 9999999999 heading "Set Number"
column start_time           format a16        heading "Start Date"
column end_time   		    format a16        heading "End Date"
column backup_type   		format a3         heading "Type"
column incremental_level	format 99          heading "I"
column backup_byte_mb   	format 999G999G999D999  heading "Backup |Volume"
column backup_duration   	format 999G999G999    heading "Backup|Times s"
column tag                  format a35        heading "Backup|Tag"
column handle               format a35        heading "Backup|Directory"

select to_char(    s.start_time      ,'dd.mm.yyyy hh24:mi') as start_time
    , to_char(max(pd.completion_time),'dd.mm.yyyy hh24:mi') as end_time
	, round(sum(p.bytes)/1024/1024,3) as backup_byte_mb
	, sum(p.elapsed_seconds)          as backup_duration
	, sd.incremental_level
	, pd.tag
 from v$backup_set   s
    , v$backup_piece p	
	, v$backup_piece_details pd
	, v$backup_set_details   sd
where s.completion_time > sysdate - 5
  and p.set_stamp = s.set_stamp
  and sd.SET_STAMP=s.set_stamp
  and pd.SET_STAMP=p.set_stamp 
group by to_char(s.start_time    ,'dd.mm.yyyy hh24:mi')
     , to_char(s.completion_time ,'dd.mm.yyyy hh24:mi') 
	 , s.backup_type
	 , sd.incremental_level    
   	 , pd.tag	
order by to_char(s.completion_time ,'dd.mm.yyyy hh24:mi') desc
/

ttitle  "RMan last Backups Jobs of the last 3 days"  SKIP 2
--
-- http://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_2142.htm#REFRN30391
--

column backup_read_byte_mb format 999G999G999D999 heading "Backup Read|Volume"
column backup_byte_mb      format 999G999G999D999 heading "Backup Write|Volume"
column STATUS              format a20  heading "Backup Status"
column backup_type         format a10  heading "Backup type"
	
select 
       to_char(d.start_time ,'dd.mm.yyyy hh24:mi') as start_time
     , to_char(d.end_time   ,'dd.mm.yyyy hh24:mi') as end_time
	 , round((d.input_bytes)/1024/1024,3) as backup_read_byte_mb
	 , round((d.output_bytes)/1024/1024,3) as backup_byte_mb
	 , d.input_type                      as backup_type
	 , d.status
 from v$rman_backup_job_details d
where end_time > sysdate - 5
order by d.start_time desc
/

----- to get more details ----------------------------------------

-- ttitle  "RMan last Backups jobs details"  SKIP 2

-- select output 
--   from gv$rman_output
--  where session_recid in (select session_recid from v$rman_backup_job_details where session_recid in (select max(i.session_recid) from v$rman_backup_job_details i))  
--    and session_stamp in (select session_stamp from v$rman_backup_job_details where session_recid in (select max(i.session_recid) from v$rman_backup_job_details i))  
--  order by recid;
-- /

-- column handle             format a30   heading "Backup File"
-- column elapsed_seconds    format 99999 heading "Seconds"
-- column size_bytes_display format a10   heading "Size"
-- column piece#             format 99    heading "PC"
-- 
-- select  to_char(p.start_time ,'dd.mm.yyyy hh24:mi') as start_time
--        ,pd.piece# 
--        ,pd.tag
--        ,pd.elapsed_seconds
--        ,pd.handle
--        ,pd.size_bytes_display
--  from  v$backup_piece p   
--   ,  v$backup_piece_details pd 
-- where  pd.set_stamp=p.set_stamp 
--   and  pd.stamp=p.stamp 
--   and  p.start_time > sysdate -1
-- order by  p.start_time desc,pd.piece# asc
-- /
-- 

-----------------------------------------------------------------

ttitle off

