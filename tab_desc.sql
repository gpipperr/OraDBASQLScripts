--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   describe a table in the database
--
-- Parameter 1: Owner of the table
-- Parameter 2: Name of the table
--
-- Must be run with dba privileges
-- 
--
--==============================================================================

set verify  off
set linesize 130 pagesize 300 

define OWNER    = '&1' 
define TAB_NAME = '&2' 

prompt
prompt Parameter 1 = Owner Name  => &&OWNER.
prompt Parameter 2 = Tab Name    => &&TAB_NAME.
prompt

column column_name    format a25 heading "Column name" 
column data_type      format a25 heading "Data type" 
column data_default   format a20 heading "Column default"
column nullable       format a3  heading "Null ?"
column char_length    format a4  heading "Char Count"

ttitle left  "Describe the columns of a table" skip 2

select
	  column_name
	  ,data_length
	  ,data_precision
	  ,DATA_SCALE
	, case data_type 
	   when 'VARCHAR2' then 'varchar2('||lpad(data_length,5)||' '|| decode(char_used,'B','Byte','C','Char',char_used)||')'
	   when 'NUMBER'   then 'number  ('||lpad(data_length,5)|| nvl(data_precision,'') ||' '||  nvl(DATA_SCALE,'') ||')'
       when 'DATE'     then  'date'
       else rpad(lower(data_type),8) ||'('||lpad(data_length,5)||nvl(data_precision,'') ||')'
      end as data_type
	, case when char_length > 0 then to_char(char_length)  else '-' end as char_length
	, decode(nullable,'Y','YES','NO') as nullable
	, data_default	
 from all_tab_columns 
 where table_name like upper('&&TAB_NAME.')
   and owner      like upper('&&OWNER.')
order by COLUMN_ID
/

prompt ...

ttitle "Settings for this table &TAB_NAME." SKIP 2

column table_name   format a15        heading "Table|name"
column monitoring   format a10        heading "Monitoring|enabled?"
column num_rows     format 9999999999 heading "Num|Rows"
column degree       format a5         heading "Deg|ree"
column row_movement	format a10        heading "Row|Movement"   
column buffer_pool  format a10        heading "Pool"

select  table_name
      , status
	  , to_char(last_analyzed,'dd.mm.yyyy hh24:mi') as last_analyzed
	  , num_rows
	  , degree
      , row_movement	  
	  , monitoring 
	  , buffer_pool
 from all_tables
where table_name like upper('&TAB_NAME.')
  and owner      like upper('&OWNER.')
/

ttitle off
