--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   Get the last 5 Objects in a tablespace
-- Date:   Januar 2015
--==============================================================================

set verify off
set linesize 130 pagesize 300 

define TABLESPACE_NAME = '&1' 

prompt
prompt Parameter 1 = Tablespace Name => &&TABLESPACE_NAME.
prompt

ttitle left  "The last 5 Objects inside the tablespace" skip 2

column owner          format a15 heading "Owner"
column segment_name   format a25 heading "Segment|name"
column partition_name format a20 heading "Partition|name"
column segment_type   format a10 heading "Segment|type"  
column file_id        format 99    heading "File|id"
column block_id       format 9999999 heading "Block|id"
	  
prompt -- get the last Object in this tablespace

select e.owner
      ,e.segment_name
	  ,nvl(e.partition_name,'n/a') as partition_name
	  ,e.segment_type
	  ,e.block_id
	  ,e.file_id
 from dba_extents e
where tablespace_name like upper('&TABLESPACE_NAME.')
 and (file_id,block_id) in (select file_id,block_id
		 	  from ( 
				select   file_id
		 			 , block_id		 			
		 			 , rank() over (order by block_id desc) as row_rank
				 from dba_extents	
				where tablespace_name like upper('&TABLESPACE_NAME.')			
		 	    group by file_id,block_id
		 	) 
			where row_rank between 1 and 5 )
order by block_id desc
/

prompt ....
prompt .... to move LOG Segments move the column of the tablespace
prompt .... ALTER TABLE owner.table_name MOVE LOB (column_name) STORE AS (tablespace_name) 

prompt .... to move Tables
prompt .... ALTER TABLE owner.table_name MOVE PARTITION xxxxxx ONLINE TABLESPACE xxxxx UPDATE INDEXES

prompt .... to move INDEXES
prompt .... alter index owner.index_name rebuild 
prompt ....



ttitle off
