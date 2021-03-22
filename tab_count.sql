--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   List tables 
-- Date:   01.September 2013
--==============================================================================
set verify  off
set linesize 130 pagesize 300 

define TAB_NAME = '&1' 

prompt
prompt Parameter 1 = Tab Name          => &&TAB_NAME.
prompt

ttitle left  "Count table entries" skip 2

column table_name   format a30     heading "Table|name"
column num_rows     format 9999999  heading "Num|rows"
column size_MB      format 999G990D000  heading "Size|MB"
column table_size   format 999G990D000  heading "Size Table|MB"
column index_size   format 999G990D000  heading "Size Index|MB"

 select  t.table_name
       , t.num_rows
	   , round(s.bytes/1024/1024,3) as size_MB 
	   , (select count(*) from &&TAB_NAME ) as count_rows
  from all_tables t
     , dba_segments s
  where t.table_name = s.segment_name
   and upper(t.table_name) = upper('&&TAB_NAME')
order by t.table_name
/ 

prompt
prompt ... num rows are from the db table statistic!
prompt ... count rows are the record count in the table
prompt


ttitle off