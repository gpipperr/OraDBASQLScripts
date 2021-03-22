--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   List tables 
-- Date:   01.September 2013
--
--==============================================================================
set verify off

set linesize 130 pagesize 300

ttitle left  "List of Tables" skip 2


column table_name   format a30     heading "Table|name"
column num_rows     format 999G999G999  heading "Num|rows"
column size_MB      format 999G990D000  heading "Size|MB"
column table_size   format 999G990D000  heading "Size Table|MB"
column index_size   format 999G990D000  heading "Size Index|MB"

 select  t.table_name
       , t.num_rows
	   , round(s.bytes/1024/1024,3) as size_MB 
  from user_tables t
     , user_segments s
  where t.table_name = s.segment_name(+)
order by t.table_name
/ 
prompt
prompt ... num rows are from the db table statistic!
prompt

ttitle left  "Space usage of all tables and indexes"

select   round(table_size/1024/1024,3) as table_size
       , round(index_size/1024/1024,3) as index_size	
from (	   
 select  sum(decode(s.segment_type,'TABLE',s.bytes,0)) as table_size
       , sum(decode(s.segment_type,'INDEX',s.bytes,0)) as index_size	
  from user_segments s
 where s.segment_name not in ( select object_name from recyclebin )
)
/ 

ttitle left  "Space usage of the recycle user bin"
select   round(table_size/1024/1024,3) as table_size
       , round(index_size/1024/1024,3) as index_size	
from (	   
 select  sum(decode(s.segment_type,'TABLE',s.bytes,0)) as table_size
       , sum(decode(s.segment_type,'INDEX',s.bytes,0)) as index_size	
  from user_segments s
 where s.segment_name in ( select object_name from recyclebin )
)
/ 
prompt
prompt ... to clean the recycle Bin :  purge recyclebin;
prompt

ttitle off