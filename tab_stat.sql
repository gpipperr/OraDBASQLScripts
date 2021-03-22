--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   Get the statistic settings of the table
-- Parameter 1: Name of the table
--
-- Must be run with dba privileges
--
--
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define USER_NAME  = &1
define TABLE_NAME = &2

prompt
prompt Parameter 1 = Owner Name => &&USER_NAME.
prompt Parameter 2 = Tab Name   => &&TABLE_NAME.
prompt

create or replace function show_rawvalue (p_rawval raw, p_dtype varchar2)
   return varchar2
is
   -- different datatypes
   v_cn       number;
   v_cv       varchar2 (32);
   v_cd       date;
   v_cnv      nvarchar2 (32);
   v_cr       rowid;
   v_cc       char (32);
   v_cbf      binary_float;
   v_cbd      binary_double;
   -- return value
   v_return   varchar2 (4000);
begin
   case p_dtype
      when 'VARCHAR2'
      then
         dbms_stats.convert_raw_value (p_rawval, v_cv);
         v_return := to_char (v_cv);
      when 'DATE'
      then
         dbms_stats.convert_raw_value (p_rawval, v_cd);
         v_return := to_char (v_cd, 'DD.MM.YYYY HH24:MI:SS');
      when 'NUMBER'
      then
         dbms_stats.convert_raw_value (p_rawval, v_cn);
         v_return := to_char (v_cn);
      when 'BINARY_FLOAT'
      then
         dbms_stats.convert_raw_value (p_rawval, v_cbf);
         v_return := to_char (v_cbf);
      when 'BINARY_DOUBLE'
      then
         dbms_stats.convert_raw_value (p_rawval, v_cbd);
         v_return := to_char (v_cbd);
      when 'NVARCHAR2'
      then
         dbms_stats.convert_raw_value_nvarchar (p_rawval, v_cnv);
         v_return := to_char (v_cnv);
      when 'ROWID'
      then
         dbms_stats.convert_raw_value_rowid (p_rawval, v_cr);
         v_return := to_char (v_cr);
      when 'CHAR'
      then
         dbms_stats.convert_raw_value (p_rawval, v_cc);
         v_return := to_char (v_cc);
      else
         v_return := 'UNKNOWN DATATYPE';
   end case;

   return v_return;
end;
/


set linesize 150 pagesize 200 

ttitle "Read Statistic Values for this table &TABLE_NAME." skip 2

column table_name  format a15
column PARTITION_NAME format a20
colum locked format a5 heading "Stat|Lock"

  select t.table_name
       ,  ts.PARTITION_NAME
       ,  t.status
       ,  to_char (ts.LAST_ANALYZED, 'dd.mm.yyyy hh24:mi') as LAST_ANALYZED
       ,  ts.NUM_ROWS
       ,  ts.AVG_SPACE
       ,  ts.CHAIN_CNT
       ,  ts.AVG_ROW_LEN
       ,  ts.stattype_locked as locked
    from dba_tables t, dba_tab_statistics ts
   where     ts.table_name = t.table_name
         and ts.owner = t.owner
         and t.table_name like '&TABLE_NAME.'
         and t.owner like '&USER_NAME.'
order by ts.PARTITION_NAME
/

prompt ... to anaylse the space Usage use tab.sql
prompt ... to refresh statistic use  EXEC DBMS_STATS.GATHER_TABLE_STATS ('&USER_NAME.', '&TABLE_NAME.');

ttitle center "Read Statistic Values of the columns of this table " skip 2


column column_name format a18
column low_value   format a35
column high_value  format a35
column data_type   format a10
column histogram   format a15

set serveroutput on

  select b.table_name
       ,  b.column_name
       ,  show_rawvalue (a.low_value, b.data_type) as low_value
       ,  show_rawvalue (a.high_value, b.data_type) as high_value
       ,  b.data_type
       ,  a.histogram
    from dba_tab_col_statistics a, dba_tab_cols b
   where     b.table_name like '&TABLE_NAME.'
         and b.owner like '&USER_NAME.'
         and a.table_name(+) = b.table_name
         and a.owner(+) = b.owner
         and a.column_name(+) = b.column_name
order by 1, 2
/

ttitle left  "Overview histogram statistic usage for this table" skip 2

  select table_name, column_name, count (*) as count_hist_buckets
    from DBA_TAB_HISTOGRAMS
   where     table_name like '&TABLE_NAME.'
         and owner like '&USER_NAME.'
group by table_name, column_name
order by column_name
/


ttitle left  "Overview of the last 10 statistics on this table" skip 2

  select h.TABLE_NAME, h.PARTITION_NAME, to_char (h.STATS_UPDATE_TIME, 'dd.mm.yyyy hh24:mi') as STATS_UPDATE_TIME
    from dba_tab_stats_history h
   where     h.table_name like upper ('&TABLE_NAME.')
         and h.owner like upper ('&USER_NAME.')
         and rownum < 10
order by STATS_UPDATE_TIME
/

-- Details Analyse
-- column endpoint_number format 99999  heading "End|Nr."
-- column endpoint_value   heading "Value"
-- column endpoint_actual_value format a30 heading "Act|Value"
--
--
-- select  table_name
--       , column_name
--       , endpoint_number
--       , endpoint_value
--       , endpoint_actual_value
--  from DBA_TAB_HISTOGRAMS
-- where table_name like '&TABLE_NAME.%'
--  and  owner      like '&USER_NAME.%'
-- order by column_name,ENDPOINT_NUMBER
-- /



ttitle off

drop function show_rawvalue
/