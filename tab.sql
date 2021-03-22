--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   search the table in the database
-- Parameter 1: Name of the table
--
-- Must be run with dba privileges
-- 
--
--==============================================================================
set verify  off
set linesize 130 pagesize 300 

define TAB_NAME = '&1' 

prompt
prompt Parameter 1 = Tab Name          => &&TAB_NAME.
prompt

column owner      format a15 heading "Owner" 
column table_name format a30 heading "Table/View Name"
column otype      format a5  heading "Type"
column comments   format a30 heading "Comment on this | table/view"
column tablespace_name format a40 heading "Tablespace|Name"

select t.owner
     ,  t.table_name
     ,  'table' as otype
     ,  nvl (c.comments, 'n/a') as comments
	 , t.tablespace_name
  from dba_tables t, dba_tab_comments c
 where     upper (t.table_name) like upper ('%&&tab_name.%')
       and c.table_name(+) = t.table_name
       and c.owner(+) = t.owner
       and c.table_type(+) = 'TABLE'
union
select v.owner
     ,  v.view_name
     ,  'view' as otype
     ,  nvl (c.comments, 'n/a') as comments
	 , 'n/a'
  from dba_views v, dba_tab_comments c
 where     upper (v.view_name) like upper ('%&&tab_name.%')
       and c.table_name(+) = v.view_name
       and c.owner(+) = v.owner
       and c.table_type(+) = 'VIEW'
order by 1, 2
/

