--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   Get buffer cache information
-- Date:   September 2013
--==============================================================================
set linesize 130 pagesize 300 

ttitle  "Buffer Cache Information"  SKIP 1 

@select v$buffer_pool

ttitle  "Buffer Cache Block Count"  SKIP 2 

select count(*) as "Total Count of Blocks"
 from v$bh
/
 
ttitle  "Buffer Cache Block Status"  SKIP 2

SELECT status
     , dirty
     , COUNT(*) 
FROM v$bh 
GROUP BY STATUS
       , dirty
/
prompt
prompt *****************************************************
prompt dirty => N     :: Block can be overwitten
prompt *****************************************************
prompt status => free :: The block is free and was never used
prompt status => xcur :: Exclusive
prompt status => scur :: Shared current
prompt status => cr   :: Consistent read
prompt status => read :: Being read from disk
prompt status => mrec :: In media recovery mode
prompt status => irec :: In instance recovery mode
prompt *****************************************************
prompt

ttitle "Get the 10 top blocks in the cache" SKIP 2

column tch          format 999G999G999 heading "Touch|Count"
column segment_name format a30 heading "Segment|Name"
column owner        format a20 heading "Owner"
column tch_rank     format 999999 heading "R"

select tch_rank
	 , b.tch
	 , o.owner
	 , o.segment_name	 
 from (select tch
            , file#
			, dbablk
			, rank() over (order by tch desc) as tch_rank  
	    from x$bh order by tch
       ) b
	 , dba_extents o
 where b.tch_rank <= 25
   and o.file_id   = b.file#
   and o.block_id  = b.dbablk
   --and o.owner not in ('SYS','SYSTEM')
 order by b.tch_rank asc  
/

prompt

ttitle "LRU Status  " SKIP 2

select lru_flag 
     , count(*)
 from sys.x$bh 
group by lru_flag
/

prompt ***********************************
prompt 0 = flag not set
prompt 2 = buffer moved to tail of LRU
prompt 4 = buffer on auxiliary list
prompt 8 = buffer moved to MRU
prompt ***********************************
prompt

ttitle "Cache Usage - Hot Block Candidates " SKIP 2

column buffer format 999999
column avg_to format 999999
column object_name format a30 heading "Object|Name"

select nvl(o.owner,'-')        as owner
     , nvl(o.object_name,'-') as object_name
     , count(1)   buffer
     , avg(x.tch) avg_to
  from sys.x$bh x
     , dba_objects o
 where x.lru_flag = 8
   and x.obj = o.object_id (+)
 group by nvl(o.owner,'-')       
        , nvl(o.object_name,'-') 
having avg(x.tch) > 5 and count(1) > 20
/

ttitle "Cache Usage " SKIP 2

select  obj object
	 ,  count(1) buffers
  	 ,  round(100*(count(1)/totsize),3) pct_cache
 from sys.x$bh
     , (select BLOCK_SIZE totsize from v$buffer_pool)
 where tch= 1
    or ( tch= 0 and lru_flag < 8 )
 group by obj
     , totsize
having 100*(count(1)/totsize) > 5
/


ttitle off
