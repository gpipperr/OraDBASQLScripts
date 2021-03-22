--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   show the last modifications on a table
-- Date:   October 2013
--
-- Source:   http://docs.oracle.com/cd/E11882_01/server.112/e25513/statviews_2107.htm#i1591024
--==============================================================================

set verify off
set linesize 130 pagesize 300 

define OWNER    = '&1' 
define TAB_NAME = '&2' 

prompt
prompt Parameter 1 = Owner Name  => &&OWNER.
prompt Parameter 2 = Tab Name    => &&TAB_NAME.
prompt

set serveroutput on;

prompt ... 
prompt ... if values are empty flash the counter as dba! with to the table: 
prompt ... exec DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO 
prompt ...
prompt ... works only if "monitoring" is enabled on this table!
prompt ...

ttitle "Read Modifications for this table &TAB_NAME." SKIP 2


column TABLE_OWNER        format a12    heading "Table|Owner"
column TABLE_NAME         format a15    heading "Table|Name"
column PARTITION_NAME     format a12    heading "Part|Name"
column SUBPARTITION_NAME  format a12    heading "Subpart|Name"
column INSERTS            format 999G999G999G999 heading "Inserts|Count"
column UPDATES            format 999G999 heading "Updates|Count"
column DELETES            format 999G999G999G999 heading "Deletes|Count"
column TIMESTAMP          format a20    heading "Last|Access"
column TRUNCATED          format a3     heading "Tru|cat"
column DROP_SEGMENTS      format 999 heading "Drop Seg| Count"

select TABLE_OWNER
	 , TABLE_NAME
	 , PARTITION_NAME
	 , SUBPARTITION_NAME
	 , INSERTS
	 , UPDATES
	 , DELETES
	 , to_char(TIMESTAMP,'dd.mm.yyyy hh24:mi') as TIMESTAMP
	 , TRUNCATED
	 , DROP_SEGMENTS
 from DBA_TAB_MODIFICATIONS
where TABLE_OWNER like upper('&&OWNER.') 
  and TABLE_NAME like upper('&&TAB_NAME.')
order by  TIMESTAMP asc  
/



prompt ... Inserts       - Approximate number of inserts since the last time statistics were gathered
prompt ... Updates       - Approximate number of updates since the last time statistics were gathered
prompt ... Deletes       - Approximate number of deletes since the last time statistics were gathered
prompt ... Last Access   - Indicates the last time the table was modified
prompt ... Drop Seg      - Number of partition and subpartition segments dropped since the last analyze
prompt 

ttitle "Last statistic info for this table &TAB_NAME." SKIP 2

column table_name  format a15
column MONITORING  format a10 heading "Monitoring|enabled?"

select  table_name
      , status
	  , to_char(LAST_ANALYZED,'dd.mm.yyyy hh24:mi') as LAST_ANALYZED
	  , NUM_ROWS
	  , AVG_SPACE
	  , CHAIN_CNT
	  , AVG_ROW_LEN
	  , MONITORING 
 from dba_tables
where table_name like upper('&TAB_NAME.%')
  and  owner      like upper('&OWNER.')
/

ttitle off
  