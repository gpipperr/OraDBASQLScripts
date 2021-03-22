--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: Information about the tablespaces
--==============================================================================
set verify off
set linesize 130 pagesize 300 

-- use the default block size as variable
-- 

col BLOCK_SIZE_COL new_val BLOCK_SIZE

column BLOCK_SIZE_COL format a20 heading "Default DB Blocksize"
 
ttitle  "Default DB Blocksize"  SKIP 2

select value as BLOCK_SIZE_COL
  from v$parameter 
 where name = 'db_block_size'
 /

column tablespace_name     format a25         heading "Tablespace|Name"
column used_space_gb       format 999G990D999 heading "Used Space|GB"
column gb_free             format 999G990D999 heading "Free Space|GB"
column tablespace_size_gb  format 999G990D999 heading "Max Tablespace|Size GB"
column DF_SIZE_GB          format 999G990D999 heading "Size on| Disk GB"
column used_percent        format 90G99       heading "Used |% Max"  
column pct_used_size        format 90G99       heading "Used |% Disk"  
column BLOCK_SIZE          format 99G999      heading "TBS BL|Size"  
column DF_Count            format 9G999       heading "Count|DB Files"  


ttitle  "Used Space over  DBA_TABLESPACE_USAGE_METRICS"  SKIP 2

select dt.tablespace_name
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
order by dm.tablespace_name
/


ttitle  "Used Space over dba_data_files and dba_free_space"  SKIP 2

select df.tablespace_name
     , df.gb_max  as tablespace_size_gb
     , df.gb_size as DF_SIZE_GB
	  , fs.gb_free
	  , (df.gb_size - fs.gb_free) as used_space_gb	 
	  , (case gb_max when 0 then 0 else (round((100/df.gb_max*(df.gb_size - fs.gb_free)),3)*100) end)  as used_percent
	  , round((100/df.gb_size*(df.gb_size - fs.gb_free)),3)*100 as pct_used_size
	  , dt.BLOCK_SIZE
from (select tablespace_name
	        , round(sum(bytes/1024/1024/1024),3) as gb_size
			  ,round(sum(MAXBYTES/1024/1024/1024),3) as gb_max 
        from dba_data_files 
		 group by tablespace_name) df,
     (select tablespace_name
	        , round(sum(bytes/1024/1024/1024),3) as gb_free 
		 from dba_free_space group by tablespace_name) fs
		, dba_tablespaces dt 
where df.tablespace_name = fs.tablespace_name
 and  dt.tablespace_name = fs.tablespace_name
order by df.tablespace_name
/  



ttitle  "Get max free extend from the tablespace"  SKIP 2

column max_extend_free_mb format 999G990D999 heading "Max Free Space Extend|MB"
column max_blocks         format 999G990     heading "Max Free Space Extend|Blocks"

SELECT round(max(fs.bytes)/1024/1024,3) as max_extend_free_mb
     , max(fs.bytes)/dt.BLOCK_SIZE as max_blocks
     , fs.tablespace_name
     , dt.EXTENT_MANAGEMENT	  
	  , dt.ALLOCATION_TYPE
 from dba_free_space fs
    , dba_tablespaces dt
where fs.tablespace_name=dt.tablespace_name
group by fs.tablespace_name,dt.BLOCK_SIZE,dt.ALLOCATION_TYPE,dt.EXTENT_MANAGEMENT
order by fs.tablespace_name
/
 
ttitle off

