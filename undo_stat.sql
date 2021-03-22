--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   undo  stat
--==============================================================================
-- Source:
-- http://www.dbaref.com/home/dba-routine-tasks/scriptstocheckundotablespacestats
-- http://docs.oracle.com/cd/B28359_01/server.111/b28320/dynviews_3110.htm#REFRN30295
--==============================================================================
set verify  off
set linesize 130 pagesize 300 

prompt Show the Undo init.ora settings

show parameter undo

column "Begin" format a21
column "End" format a21

ttitle "How often and when does -Snapshot too old (ORA-01555) -occur?" skip 2

select Inst_id  
     ,  to_char(begin_time,'YYYY-MM-DD HH24:MI:SS') "Begin"
     ,  to_char(end_time,'YYYY-MM-DD HH24:MI:SS') "End"
                ,  undoblks "UndoBlocks"
                ,  SSOLDERRCNT "ORA-1555"
                ,  MAXQUERYID
from GV$UNDOSTAT
where SSOLDERRCNT > 0
order by 1
/

ttitle "length of the longest query (in seconds and hours)" skip 2

Select max(MAXQUERYLEN), max(MAXQUERYLEN)/60/60 From V$UNDOSTAT;




ttitle "When and how often was the undo-table space too small?" skip 2


select Inst_id 
                  , to_char(begin_time,'YYYY-MM-DD HH24:MI:SS') as "Begin"
                  , to_char(end_time,'YYYY-MM-DD HH24:MI:SS') as "End"
                  , undoblks "UndoBlocks"
                  , nospaceerrcnt "Space Err"
from GV$UNDOSTAT
where nospaceerrcnt > 0
order by 1
/

--This option is disabled by default. see http://docs.oracle.com/cd/B28359_01/server.111/b28310/undo002.htm#ADMIN10180
ttitle "RETENTION policy on the tablespace" skip 2

column tablespace_name     format a25         heading "Tablespace|Name"
column used_space_gb       format 999G990D999 heading "Used Space|GB"
column gb_free             format 999G990D999 heading "Free Space|GB"
column tablespace_size_gb  format 999G990D999 heading "Max Tablespace|Size GB"
column DF_SIZE_GB          format 999G990D999 heading "Size on| Disk GB"
column used_percent        format 90G99       heading "Used |% Max"  
column pct_used_size        format 90G99       heading "Used |% Disk"  
column BLOCK_SIZE          format 99G999      heading "TBS BL|Size"  
column DF_Count            format 9G999       heading "Count|DB Files"  

select dt.tablespace_name
                , dt.RETENTION
                ,  round((dm.tablespace_size * dt.BLOCK_SIZE)/1024/1024/1024,3) as tablespace_size_gb      
                 ,  round( 
                                               (case dt.CONTENTS
                                                               when 'TEMPORARY' then
                                                                              (select sum(df.BLOCKS)*dt.BLOCK_SIZE from dba_temp_files df where df.TABLESPACE_NAME=dt.tablespace_name)
                                                               else
                                                               (select sum(df.BLOCKS)*dt.BLOCK_SIZE from dba_data_files df where df.TABLESPACE_NAME=dt.tablespace_name)
                                  end) /1024/1024/1024,3)  as DF_SIZE_GB
    ,  (case dt.CONTENTS
                                                               when 'TEMPORARY' then
                                                                              (select count(*) from dba_temp_files df where df.TABLESPACE_NAME=dt.tablespace_name)
                                                               else
                                                               (select count(*) from dba_data_files df where df.TABLESPACE_NAME=dt.tablespace_name)
                                  end)  as DF_Count
                ,  round(((dm.used_space * dt.BLOCK_SIZE)/1024/1024/1024),3)      as used_space_gb    
                 ,  round(100*dm.used_percent,2) as used_percent
                ,  dt.BLOCK_SIZE
  from DBA_TABLESPACE_USAGE_METRICS dm
     , dba_tablespaces dt
where dm.tablespace_name=dt.tablespace_name
and dt.tablespace_name like 'UNDO%'
order by dm.tablespace_name
/


prompt ... 
prompt ... if "NOGUARANTEE" the DB will not gurantee the Undo Rention time
prompt ... 


ttitle "Maximal Undo usage (MB) over the last 4 days - but only for this instance!" skip 2

-- http://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_3118.htm#REFRN30295
-- thanks to may be trivadis ? 

column days    format a6       heading "day"
column m30    format 999G999    heading "30m"
column m60    format 999G999    heading "1h"
column m120   format 999G999    heading "2h"
column m180   format 999G999    heading "3h"
column m240   format 999G999    heading "4h"
column m300   format 999G999    heading "5h"
column m600   format 999G999    heading "6h"
column m900   format 999G999    heading "15"
column m1440  format 999G999    heading "24h"
column m1800  format 999G999    heading "30h"
column m2400  format 999G999    heading "40h"
column m3000  format 999G999    heading "50h"

select  days
                               , round(b.block_size * a.m30  /(1024*1024)) m30
                               , round(b.block_size * a.m60  /(1024*1024)) m60
                               , round(b.block_size * a.m120 /(1024*1024)) m120
                               , round(b.block_size * a.m180 /(1024*1024)) m180
                               , round(b.block_size * a.m240 /(1024*1024)) m240
                               , round(b.block_size * a.m300 /(1024*1024)) m300
                               , round(b.block_size * a.m600 /(1024*1024)) m600
                               , round(b.block_size * a.m900 /(1024*1024)) m900
                               , round(b.block_size * a.m1440/(1024*1024)) m1440
                               , round(b.block_size * a.m1800/(1024*1024)) m1800
                               , round(b.block_size * a.m2400/(1024*1024)) m2400
                               , round(b.block_size * a.m3000/(1024*1024)) m3000
from
  (select max(sum_blk30)    m30
                                               , max(sum_blk60)   m60
                                               , max(sum_blk120)  m120
                                               , max(sum_blk180)  m180
                                               , max(sum_blk240)  m240
                                               , max(sum_blk300)  m300
                                               , max(sum_blk600)  m600
                                               , max(sum_blk900)  m900
                                               , max(sum_blk1440) m1440
                                               , max(sum_blk1800) m1800
                                               , max(sum_blk2400) m2400
                                               , max(sum_blk3000) m3000                       
                                               , days                                   
                               from
                                               (select  begin_time
                                                                              , undoblks
                                                                              , to_char(begin_time,'dd.mm') as days
                                                                              , sum(undoblks) over (order by begin_time rows between current row and 2 following)   as sum_blk30
                                                                              , sum(undoblks) over (order by begin_time rows between current row and 5 following)   as sum_blk60
                                                                              , sum(undoblks) over (order by begin_time rows between current row and 11 following)  as sum_blk120
                                                                              , sum(undoblks) over (order by begin_time rows between current row and 17 following)  as sum_blk180
                                                                              , sum(undoblks) over (order by begin_time rows between current row and 23 following)  as sum_blk240
                                                                              , sum(undoblks) over (order by begin_time rows between current row and 29 following)  as sum_blk300
                                                                              , sum(undoblks) over (order by begin_time rows between current row and 59 following)  as sum_blk600
                                                                              , sum(undoblks) over (order by begin_time rows between current row and 89 following)  as sum_blk900
                                                                              , sum(undoblks) over (order by begin_time rows between current row and 143 following) as sum_blk1440
                                                                              , sum(undoblks) over (order by begin_time rows between current row and 179 following) as sum_blk1800
                                                                              , sum(undoblks) over (order by begin_time rows between current row and 239 following) as sum_blk2400
                                                                              , sum(undoblks) over (order by begin_time rows between current row and 299 following) as sum_blk3000
                                               from v$undostat
                                               order by begin_time )
                               group by days   
                ) a
, (select block_size  from dba_tablespaces  where contents='UNDO'    and status  ='ONLINE'  ) b 
order by days
/

ttitle "undo per sec in the last 12 hours"  skip 2

select  trunc(end_time,'hh24') as hour
      , round(sum(undoblks)/60,2) as undo_block_pr_min
      , round(((sum(undoblks)/60)*( b.block_size ))/1024/1204,2) as undo_mb_pr_min
  from v$undostat
     , (select block_size  from dba_tablespaces  where contents='undo' and status  ='online'  ) b 
 where end_time > sysdate - ((1/24) * 12)
group by trunc(end_time,'hh24'),b.block_size
order by 1 
/
  
 
ttitle "Dynamic Undo Retention in the last hour"  skip 2
--
-- http://docs.oracle.com/cd/B28359_01/server.111/b28310/undo002.htm#ADMIN11462
--

select to_char(begin_time, 'dd.mm.yyyy HH24:MI') begin_time
     , to_char(end_time, 'dd.mm.yyyy HH24:MI') end_time
                  , tuned_undoretention
from v$undostat 
where end_time > sysdate - (1/24*1)
order by end_time
/

ttitle "Dynamic Undo Retention max - min Value"  skip 2

select min(begin_time)begin_time
     , max(end_time) end_time
                  , min(tuned_undoretention)
                  , max(tuned_undoretention)
from v$undostat 
/


ttitle off
