--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   search the table in the database
-- Parameter 1: Name of the table
--==============================================================================
set verify  off
set linesize 130 pagesize 300 

define COMMENTTXT = '&1' 

prompt
prompt Parameter 1 = Part of Comment   => &&COMMENTTXT.
prompt

column owner      format a15 heading "Qwner" 
column table_name format a30 heading "Table/View Name"
column otype      format a5 heading "Type"
column comments   format a60 heading "Comment on this table/view"

select  t.owner
      , t.table_name
	  , 'table' as otype
	  , nvl(c.comments,'n/a')  as comments
from all_tables t
    ,all_tab_comments c
 where upper(c.comments) like upper('%&&COMMENTTXT.%')
 and c.table_name  = t.table_name
 and c.owner  = t.owner
 and c.table_type = 'TABLE'
union
 select  v.owner
       , v.view_name
	   , 'view'  as otype
	   , nvl(c.comments,'n/a')  as comments
  from all_views v
      ,all_tab_comments c
 where upper(c.comments) like upper('%&&COMMENTTXT.%')
 and c.table_name  = v.view_name
 and c.owner  = v.owner
 and c.table_type = 'VIEW'
order by 1,2
/


