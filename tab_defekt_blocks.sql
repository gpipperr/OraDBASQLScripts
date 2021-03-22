--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: check for block corruption
--==============================================================================
set verify off
set linesize 130 pagesize 300 

column segment_name    format a16 heading "Segment|Name"
column tablespace_name format a16 heading "Tablespace|Name"
column partition_name  format a10 heading "Partition|Name"
column owner           format a14
column relative_fno    format 9999 heading "File|No"
column segment_type    format a0  heading "Segment|Type"
column file#           format 9999 heading "File|Id"
column defekt_range    format a18 heading "defect|range"


prompt Check of the database has detected corrupt blocks

select count(*) from  v$database_block_corruption;

 --file#
 --block#
 --blocks
 --corruption_change#
 --corruption_type
 
prompt ...
prompt Check which tables are affected
prompt

select ext.owner
      , ext.segment_name
	  , ext.segment_type
	  , ext.relative_fno
	  , ext.partition_name
	  , ext.tablespace_name
	  , blc.file# 
	  , blc.block# ||' for '||blc.blocks as defekt_range
 from dba_extents ext
   ,  v$database_block_corruption blc
where ext.file_id = blc.file# 
  and blc.block# between ext.block_id and ext.block_id + ext.blocks - 1
/  



prompt ... to check the whole data file
prompt .... you can use RMAN> VALIDATE DATAFILE 5;

