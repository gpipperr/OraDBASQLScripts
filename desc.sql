--==============================================================================
-- GPI - Gunther Pippèrr
-- replacement for the desc command to search after some columns
--==============================================================================
set verify  off
set linesize 130 pagesize 4000 

define TAB_NAME    = '&1' 
define COL_NAME    = '&2' 

prompt
prompt Parameter 1 = TAB_NAME   => &&TAB_NAME.
prompt Parameter 2 = COL Name   => &&COL_NAME.
prompt

column owner          format a10 heading "Owner" 
column table_name     format a18 heading "Table|Name"
column COLUMN_NAME    format a30 heading "Column|Name"
column comments       format a25 heading "Comment on |this column"
column data_type      format a23 heading "Data type" 
column data_default   format a10 heading "Column default"
column nullable       format a4  heading "Null ?"
column char_length    format a4  heading "Char Count"

select  t.OWNER
      , t.TABLE_NAME
      , t.COLUMN_NAME
      , decode(nullable,'Y','YES','NO') as nullable
      , case t.data_type 
         when 'VARCHAR2' then 'varchar2('||lpad(data_length,4)||' '|| decode(t.char_used,'B','Byte','C','Char',t.char_used)||')'
         when 'NUMBER'   then 'number  ('|| nvl(t.data_precision,'') ||' - '||  nvl(t.DATA_SCALE,'') ||')'
         when 'DATE'     then  'date'
             when 'LONG' then 'long'
         else rpad(lower(t.data_type),8) ||'('||lpad(t.data_length,4)||nvl(t.data_precision,'') ||')'
       end as data_type
    --, case when char_length > 0 then to_char(t.char_length)  else '-' end as char_length
    --, data_default
      , c.comments
 from dba_tab_columns t
    , DBA_COL_COMMENTS c
where t.COLUMN_NAME like upper('%&&COL_NAME.%')
  and t.TABLE_NAME like replace(upper('&&TAB_NAME.'),'V$','V_$')
  and t.OWNER=c.OWNER (+)
  and t.TABLE_NAME = c.TABLE_NAME (+)
  and t.COLUMN_NAME = c.COLUMN_NAME (+)
order by OWNER,TABLE_NAME,COLUMN_NAME
/

