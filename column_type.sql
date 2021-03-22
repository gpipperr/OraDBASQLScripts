--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   search all columns with this type in the database
-- Parameter 1: Type of the column
--
-- Must be run with dba privileges
-- 
--
--==============================================================================
set verify  off
set linesize 130 pagesize 300 

define OWNER    = '&1'
define COL_TYPE = '&2'

prompt
prompt Parameter 1 = Owner Name   => &&OWNER.
prompt Parameter 2 = Column Type  => &&COL_TYPE.
prompt

column owner       format a15 heading "Qwner"
column table_name  format a25 heading "Table|Name"
column column_name format a20 heading "Column|Name"
column comments    format a50 heading "Comment on this table/view"

select t.OWNER
       ,  t.TABLE_NAME
       ,  t.COLUMN_NAME
       ,  c.comments
    from dba_tab_columns t
	   , dba_col_comments c
   where DATA_TYPE like upper ('&&COL_TYPE.')
     and t.OWNER = c.OWNER(+)
     and t.TABLE_NAME = c.TABLE_NAME(+)
     and t.COLUMN_NAME = c.COLUMN_NAME(+)
     and t.owner = upper ('&&OWNER.')
order by OWNER, TABLE_NAME, COLUMN_NAME
/
