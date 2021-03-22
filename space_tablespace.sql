--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc:   SQL Script to check the size of a table
--         thanks to Christian Gärber for create alter database file statement  
-- Date:   08.2013
--==============================================================================

set verify off
set linesize 130 pagesize 300 


define TABLESPACE = "&1"


prompt
prompt Parameter 1 = Tablespace Name  => '&TABLESPACE' 
prompt


ttitle left  "Space of the the table space" skip 2

-- get the free size in the tablespace
-- 
column tablespace_name format a20   heading "Table space|name"
column SIZE_MB         format 99G999G999D99 heading "Size MB|total"
column max_used_mb     format 99G999G999D99 heading "Size MB|used"
column freeable_mb     format 99G999G999D99 heading "Size MB|freeable" 
column file_id         format 99 heading  "File|id"
column file_name       format a23 heading "File|name"

select sum(freeable_mb)from (
select  s.tablespace_name
      , s.bytes / 1024 / 1024 as SIZE_MB
      , (e.max_data_block_id * et.BLOCK_SIZE / 1024 / 1024) as max_used_mb
      , (s.bytes - e.max_data_block_id * et.BLOCK_SIZE) / 1024 / 1024 as freeable_mb
	  , s.file_id
	  , '..'||substr(s.file_name,length(s.file_name)-20,20) file_name
  from  dba_data_files s
      , (select  file_id
                , max(block_id + blocks) + 1 max_data_block_id
			       , tablespace_name
          from dba_extents
		 where tablespace_name like upper('&TABLESPACE.')
         group by file_id,tablespace_name) e
	 , dba_tablespaces et	 
 where s.FILE_ID = e.file_id
   and s.TABLESPACE_NAME = et.TABLESPACE_NAME
   and e.TABLESPACE_NAME =et.TABLESPACE_NAME
   and et.TABLESPACE_NAME like upper('&TABLESPACE.')   
)   
/

-- to slow .....

--ttitle left  "The last 5 Objects inside the tablespace" skip 2
--
--column owner          format a15 heading "Owner"
--column segment_name   format a25 heading "Segment|name"
--column partition_name format a20 heading "Partition|name"
--column segment_type   format a10 heading "Segment|type"  
--column file_id        format 99    heading "File|id"
--column block_id       format 9999999 heading "Block|id"
--	  
-- get the last Object in this tablespace
--
--select e.owner
--      ,e.segment_name
--	  ,nvl(e.partition_name,'n/a') as partition_name
--	  ,e.segment_type
--	  ,e.block_id
--	  ,e.file_id
-- from dba_extents e
--where tablespace_name like upper('&TABLESPACE.')
-- and (file_id,block_id) in (select file_id,block_id
--		 	  from ( 
--				select   file_id
--		 			 , block_id		 			
--		 			 , rank() over (order by block_id desc) as row_rank
--				 from dba_extents	
--				where tablespace_name like upper('&TABLESPACE.')			
--		 	    group by file_id,block_id
--		 	) 
--			where row_rank between 1 and 5 )
--order by block_id desc
--/


ttitle left  "DLL to shrink the the table space" skip 2
-- create the alter script
--
column command format a100

select 'alter database datafile ''' || s.file_name || ''' resize ' ||round(e.max_data_block_id * et.BLOCK_SIZE / 1024 / 1024 + 1, 0) || 'M;' as command
 from dba_data_files s
      , (select file_id
              ,max(block_id + blocks) + 1 max_data_block_id
			  ,tablespace_name
          from dba_extents
		 where tablespace_name like upper('&TABLESPACE.')
		 group by file_id,tablespace_name) e
	 , dba_tablespaces et	 
 where s.FILE_ID = e.file_id
   and s.TABLESPACE_NAME = et.TABLESPACE_NAME
   and e.TABLESPACE_NAME =et.TABLESPACE_NAME
   and et.TABLESPACE_NAME like upper('&TABLESPACE.')
   and (s.bytes - e.max_data_block_id * et.BLOCK_SIZE) / 1024 / 1024 > 10
/
 
ttitle off

 
 
 
 
 
 