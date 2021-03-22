--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   Informations about buffer block Cache usage in the database
-- Date:   02.2017
--
-- see orignal script => http://www.morganslibrary.org/reference/buffer_pools.html
--
--==============================================================================
set linesize 130 pagesize 300 

column owner       format a15
column object_name format a20
column object_type format a15
column status format a15
column buffer_pool format a15


SELECT b.inst_id
    , do.owner
	, do.object_name
	, do.object_type
	, COUNT(b.block#) as "Cached Blocks"
	, ds.buffer_pool
	, b.status
FROM gv$bh b
   , dba_objects_ae do
   , dba_segments ds
WHERE b.OBJD         = do.data_object_id
  AND do.object_name = ds.segment_name
  AND do.owner not like 'SYS%'
GROUP BY b.inst_id, do.owner, do.object_name, do.object_type, ds.buffer_pool, b.status
ORDER BY 1, 2, 3
/

prompt .... --------------------------
prompt .... 
prompt .... Status 	Description
prompt .... cr 	Consistent read
prompt .... free 	Not currently in use
prompt .... irec 	In instance recovery mode
prompt .... mrec 	In media recovery mode
prompt .... read 	Being read from disk
prompt .... scur 	Shared current
prompt .... xcur 	Exclusive