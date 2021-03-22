--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   index recreate script
-- Date:   2008 - 2014
--==============================================================================
set pagesize 1000
set linesize 130
set verify off

define USER_NAME='&1'

-----------------------------
-- How many parallel jobs?
define PARALLEL_EXEC=4

-----------------------------
-- use instance default = default
-- to be on the save side use 1
define DEF_DEGREE='1'

-----------------------------
-- define the mode
-- 
-- define REBUILD_MODE='PARALLEL &&PARALLEL_EXEC. NOLOGGING'
define REBUILD_MODE='online NOLOGGING'

prompt
prompt Parameter 1 = User Name => &&USER_NAME.
prompt
prompt Setting PARALLEL_EXEC   => &&PARALLEL_EXEC.
prompt Setting DEF_DEGREE		 => &&DEF_DEGREE.
prompt Setting REBUILD_MODE    => &&REBUILD_MODE.
prompt

--------------------------
-- get sum of database

ttitle "MegaByte DB Objects in use" SKIP 2

set heading  on
set feedback on

column mb_obj     format 999G999G999D90 heading "MegaByte DB Objects of the user &&USER_NAME."
column mb_obj_idx format 999G999G999D90 heading "MegaByte Indexes of the user &&USER_NAME."
column mb_obj_part format 999G999G999D90 heading "MegaByte Part Indexes of the user &&USER_NAME."

select round(sum(bytes)/1024/1024,3) as mb_obj ,'MB - ALL Segments of the user' as info
  from dba_segments
 where  owner = upper('&&USER_NAME.') 
/

select round(sum(s.bytes)/1024/1024,3) as mb_obj_idx ,'MB - ALL NOT PART INDEXES' as info
 from  dba_indexes i, dba_segments s
 where i.owner = upper('&&USER_NAME.')
   and i.index_type = 'NORMAL'
   and s.owner = i.owner
   and s.segment_name = i.index_name   
   and i.index_name not in (select ip.index_name from DBA_IND_PARTITIONS ip  where ip.INDEX_OWNER=i.owner)
/

select round(sum(s.bytes)/1024/1024,3) as mb_obj_part ,'MB - ALL PART INDEXES' as info
  from dba_indexes i , DBA_IND_PARTITIONS p, dba_segments s
 where i.OWNER = upper('&&USER_NAME.')
   and s.owner = i.OWNER
   and s.PARTITION_NAME = p.PARTITION_NAME   	
   and s.SEGMENT_NAME=i.index_name
   and p.INDEX_OWNER=i.OWNER
   and p.index_name=i.index_name
/

ttitle off

set heading off
set feedback off

-------------------
-- create spool name
col SPOOL_NAME_COL new_val SPOOL_NAME
 
SELECT replace(ora_database_name||'_'||SYS_CONTEXT('USERENV','HOST')||'_'||to_char(sysdate,'dd_mm_yyyy_hh24_mi')||'_index_rebuild_&&USER_NAME..sql','\','_') 
--' resolve syntax highlight bug FROM my editer .-(
  AS SPOOL_NAME_COL
FROM dual
/


spool &&SPOOL_NAME

prompt 
prompt spool recreate_&&SPOOL_NAME.log
prompt
prompt
prompt prompt  ============ Start ================
prompt select to_char(sysdate,'dd.mm.yyyy hh24:mi') as start_date from dual
prompt /
prompt prompt  ===================================
prompt 
prompt
prompt set heading  on
prompt set feedback on
prompt 
prompt ttitle "MegaByte DB Index for the change in Use" SKIP 2
prompt
prompt column mb_obj    format 999G999G999D90 heading "MegaByte DB Objects of the user &&USER_NAME."
prompt column mb_obj_idx format 999G999G999D90 heading "MegaByte Indexes of the user &&USER_NAME."
prompt column mb_obj_part format 999G999G999D90 heading "MegaByte Part Indexes of the user &&USER_NAME."
prompt 
prompt select round(sum(bytes)/1024/1024,3) as mb_obj ,'MB - ALL Segments of the user' as info
prompt   from dba_segments
prompt  where  owner = upper('&&USER_NAME.') 
prompt /
prompt 
prompt select round(sum(s.bytes)/1024/1024,3) as mb_obj_idx ,'MB - ALL NOT PART INDEXES' as info
prompt  from  dba_indexes i, dba_segments s
prompt  where i.owner = upper('&&USER_NAME.')
prompt    and i.index_type = 'NORMAL'
prompt    and s.owner = i.owner
prompt    and s.segment_name = i.index_name   
prompt    and i.index_name not in (select ip.index_name from DBA_IND_PARTITIONS ip  where ip.INDEX_OWNER=i.owner)
prompt /
prompt 
prompt select round(sum(s.bytes)/1024/1024,3) as mb_obj_part ,'MB - ALL PART INDEXES' as info
prompt   from dba_indexes i , DBA_IND_PARTITIONS p, dba_segments s
prompt  where i.OWNER = upper('&&USER_NAME.')
prompt    and s.owner = i.OWNER
prompt    and s.PARTITION_NAME = p.PARTITION_NAME   	
prompt    and s.SEGMENT_NAME=i.index_name
prompt    and p.INDEX_OWNER=i.OWNER
prompt    and p.index_name=i.index_name
prompt /
prompt 
prompt ttitle off
prompt 
prompt set echo on
prompt set timing on
prompt alter session set ddl_lock_timeout=10;
prompt 
prompt prompt
prompt prompt =======================
prompt prompt non partitioned indexes
prompt prompt
prompt prompt
--------------------------------
-------- non partitioned indexes

select 'select to_char(sysdate,''hh24:mi'') from dual;'||chr(13)||chr(10)||'prompt rebuild the '||rownum||' index '||iname||' for table '||itabname||' ('||isize ||' MB)'||chr(13)||chr(10)||'alter index &&USER_NAME..' ||iname||' REBUILD &&REBUILD_MODE. ;'||chr(13)||chr(10)||'alter index &&USER_NAME..' ||iname||' LOGGING PARALLEL (DEGREE &&DEF_DEGREE. instances default);'
 from (
 select i.index_name  iname
      , round (s.bytes / 1024 / 1024, 2) isize
      ,i.TABLE_NAME itabname
   from dba_indexes i, dba_segments s
  where i.owner = upper('&&USER_NAME.')
    and i.index_type = 'NORMAL'
    and s.owner = i.owner
    and s.segment_name = i.index_name   
  	 and i.index_name not in (select ip.index_name from DBA_IND_PARTITIONS ip  where ip.INDEX_OWNER=i.owner)
 )
order by itabname desc,isize asc
/
prompt prompt
prompt prompt =======================
prompt prompt partitioned indexes
prompt prompt
prompt prompt
--------------------------------
-------- partitioned indexes

select 'select to_char(sysdate,''hh24:mi'') from dual;'||chr(13)||chr(10)||'prompt rebuild the '||rownum||' index '||iname||' Partition '||PARTITION_NAME ||' for table '||itabname||' ('||isize ||' MB)'||chr(13)||chr(10)||'alter index &&USER_NAME..' ||iname||' REBUILD PARTITION '||PARTITION_NAME||' &&REBUILD_MODE. ;'||chr(13)||chr(10)||'alter index &&USER_NAME..' ||iname||' LOGGING PARALLEL (DEGREE &&DEF_DEGREE. instances default);'
from (
select i.index_name  iname
     , round (s.bytes / 1024 / 1024, 2) isize
     , i.TABLE_NAME itabname
	 , p.PARTITION_NAME   
  from dba_indexes i , DBA_IND_PARTITIONS p, dba_segments s
 where i.OWNER = upper('&&USER_NAME.')
   and s.owner = i.OWNER
   and s.PARTITION_NAME = p.PARTITION_NAME   	
   and s.SEGMENT_NAME=i.index_name
   and p.INDEX_OWNER=i.OWNER
   and p.index_name=i.index_name
)
order by itabname desc,isize asc
/

prompt 
prompt set echo off
prompt set timing off
prompt set heading  on
prompt set feedback on
prompt
prompt ttitle "MegaByte DB Index for the change in Use" SKIP 2
prompt
prompt column mb_obj    format 999G999G999D90 heading "MegaByte DB Objects of the user &&USER_NAME."
prompt column mb_obj_idx format 999G999G999D90 heading "MegaByte Indexes of the user &&USER_NAME."
prompt column mb_obj_idx format 999G999G999D90 heading "MegaByte Part Indexes of the user &&USER_NAME."
prompt 
prompt select round(sum(bytes)/1024/1024,3) as mb_obj ,'MB - ALL Segments of the user' as info
prompt   from dba_segments
prompt  where  owner = upper('&&USER_NAME.') 
prompt /
prompt 
prompt select round(sum(s.bytes)/1024/1024,3) as mb_obj_idx ,'MB - ALL NOT PART INDEXES' as info
prompt  from  dba_indexes i, dba_segments s
prompt  where i.owner = upper('&&USER_NAME.')
prompt    and i.index_type = 'NORMAL'
prompt    and s.owner = i.owner
prompt    and s.segment_name = i.index_name   
prompt    and i.index_name not in (select ip.index_name from DBA_IND_PARTITIONS ip  where ip.INDEX_OWNER=i.owner)
prompt /
prompt 
prompt select round(sum(s.bytes)/1024/1024,3) as mb_obj_part ,'MB - ALL PART INDEXES' as info
prompt   from dba_indexes i , DBA_IND_PARTITIONS p, dba_segments s
prompt  where i.OWNER = upper('&&USER_NAME.')
prompt    and s.owner = i.OWNER
prompt    and s.PARTITION_NAME = p.PARTITION_NAME   	
prompt    and s.SEGMENT_NAME=i.index_name
prompt    and p.INDEX_OWNER=i.OWNER
prompt    and p.index_name=i.index_name
prompt /
prompt 
prompt ttitle off
prompt
prompt prompt recreate statistics if missing after index rebuild at
prompt select to_char(sysdate,'dd.mm.yyyy hh24:mi') as finish_date from dual
prompt /
prompt exec dbms_stats.gather_schema_stats (ownname => upper('&&USER_NAME.'), options => 'GATHER', estimate_percent => DBMS_STATS.auto_sample_size, cascade => TRUE , degree => &&PARALLEL_EXEC. );
prompt 
prompt 
prompt prompt  ============ Finish ================
prompt select to_char(sysdate,'dd.mm.yyyy hh24:mi') as finish_date from dual
prompt /
prompt prompt  ===================================
prompt 
prompt prompt to check the log see recreate_&&SPOOL_NAME.log
prompt

prompt spool off

spool off 

prompt .....
prompt to start he recreate scripts use the script:  &&SPOOL_NAME
prompt .....

set heading on
set feedback on
set verify on
 
