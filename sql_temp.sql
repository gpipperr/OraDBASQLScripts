--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   check usage of temp tablespace
-- Date:   November 2013
--==============================================================================
set verify off
set linesize 130 pagesize 300 

select s.inst_id
     , s.username
     , u."USER" as user_name
     , u.tablespace
     , u.contents
     , u.extents
     , u.blocks
     , u.segtype     
     , s.client_info
     , sq.sql_text
     , sq.disk_reads
     , sq.buffer_gets
     , sq.fetches
     , sq.executions
from   sys.gv$session s
     , sys.gv$sort_usage u       
     , sys.gv$sql sq
where  s.saddr      = u.session_addr
  and  s.inst_id    = u.inst_id
  and sq.address    = s.sql_address
  and sq.hash_value = s.sql_hash_value
  and sq.inst_id    = s.inst_id
  and  u.sqladdr    = sq.address
  and  u.sqlhash    = sq.hash_value
  and  u.inst_id    = sq.inst_id
order by u.blocks desc
/
