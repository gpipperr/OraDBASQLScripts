--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   get the tables of this user
-- Date:   September 2013
--
--
--==============================================================================
set verify off
set linesize 130 pagesize 300 

ttitle left  "Tables and Views for this akt user" skip 2

column table_name format a30 heading "Table/View Name"
column ttype      format a9  heading "Type"
column comments   format a60 heading "Comment on this table/view"
column tablespace_name format a20 heading "Tablespace Name"

select  t.table_name
      , t.table_type as ttype
	  , nvl(c.comments,'n/a')  as comments
 from cat t
     ,user_tab_comments c
where c.table_name (+) = t.table_name
order by 2,1
/

ttitle off
