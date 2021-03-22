--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: Show all IOT's in the database
--==============================================================================
set verify off
set linesize 130 pagesize 300 
         

ttitle left  "IOT Name and Table space for Overflow Segments" skip 2

column owner            format a16 heading "Owner"
column overflow_table   format a20 heading "OverFlow Table|Name"
column IOT_TYPE         format a14  heading "IOT|Type"
column IOT_NAME         format a20 heading "IOT|Name"
column tablespace_name  format a12 heading "IDX|TBS Name"
column overFlowTabspace format a12 heading "OverFlow|TBS Name"
column index_name       format a24 heading "IOT Index|Name"
column iot_name_table   format a22 heading "IOT Tab|Name"

select i.owner 
     , i.table_name as iot_name_table
     , nvl(t.table_name,'-') as overflow_table
     , nvl(i.index_name,'-') as index_name
     , nvl(t.IOT_TYPE,'-') as IOT_TYPE
     , i.tablespace_name 
     , t.tablespace_name as overFlowTabspace   
 from dba_tables  t
    , dba_indexes i            
where t.IOT_NAME = i.table_name (+)
  and t.owner     = i.owner
  and t.IOT_TYPE like 'IOT%'
order by i.owner,t.table_name            
/  

ttitle off