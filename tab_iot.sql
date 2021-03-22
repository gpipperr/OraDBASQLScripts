--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: show information about a index organized table - parameter - Owner, Table name
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define ENTER_OWNER='&1'
define ENTER_TABLE='&2'

prompt
prompt Parameter 1 = User Name     => &&ENTER_OWNER.
prompt Parameter 2 = Table Name    => &&ENTER_TABLE.
prompt

ttitle left  "Check if the table is a IOT Table" skip 2

select 'This Table is'||decode(nvl(IOT_TYPE,'-'),'IOT',' index organised','heap organised') as TABLE_TYPE
  from dba_tables 
 where upper(table_name) like upper('&ENTER_TABLE.')
   and upper(owner) = upper('&ENTER_OWNER.')
/              

ttitle left  "IOT Name and Table space for Overflow Segments" skip 2

column owner            format a10 heading "Owner"
column overflow_table   format a20 heading "OverFlow Table|Name"
column IOT_TYPE         format a14  heading "IOT|Type"
column IOT_NAME         format a20 heading "IOT|Name"
column tablespace_name  format a12 heading "IDX|TBS Name"
column overFlowTabspace format a12 heading "OverFlow|TBS Name"
column index_name       format a20 heading "IOT Index|Name"
column iot_name_table   format a20 heading "IOT Tab|Name"

select i.owner 
     , i.table_name as iot_name_table
     , nvl(t.table_name,'-') as overflow_table
     , nvl(i.index_name,'-') as index_name
     , nvl(t.IOT_TYPE,'-') as IOT_TYPE
     , i.tablespace_name 
     , t.tablespace_name as overFlowTabspace        
 from dba_tables  t
    , dba_indexes i            
where t.IOT_NAME (+) = i.table_name
  and upper(i.table_name) like upper('&&ENTER_TABLE.')
  and upper(i.owner)       =  upper('&&ENTER_OWNER.')                      
/  

ttitle left  "IOT Table SIZE " skip 2

set heading off

column index_nameMB      fold_after
column IndexSizeMB       fold_after
column overflow_tableMB  fold_after
column OverFlowSizeMB    fold_after
column totalMB           fold_after
column lastana           fold_after
column numrows           fold_after


select rpad('Index Name',30,' ')    ||'::'||lpad(index_name,22,' ')                                                             as index_nameMB
     ,  rpad('Index Size',30,' ')   ||'::'||to_char(round((IndexSize/1024/1024),3),'999G999G999G999D99')                ||' MB' as IndexSizeMB
	 ,  rpad('Overflow Name',30,' ')||'::'||lpad(overflow_table,22,' ')                                                         as overflow_tableMB
	 ,  rpad('Overflow Size',30,' ')||'::'||to_char(round((OverFlowSize/1024/1024),3),'999G999G999G999D99')             ||' MB' as OverFlowSizeMB
	 ,  rpad('Total',30,' ')        ||'::'||to_char(round(((IndexSize+OverFlowSize)/1024/1024),3),'999G999G999G999D99') ||' MB' as totalMB
	 , rpad('Last Analyzed',30,' ') ||'::'||to_char(LAST_ANALYZED,'dd.mm.yyyy hh24:mi')                                 ||' '   as lastana
	 , rpad('Num Rows',30,' ')      ||'::'||NUM_ROWS                                                                    ||' '   as numrows 
  from ( 
	select nvl(i.index_name,'-') as index_name
		, (select sum(bytes) from dba_segments where segment_name=i.index_name and owner=i.owner) as IndexSize
		, nvl(t.table_name,'-') as overflow_table
		, nvl((select sum(bytes) from dba_segments where segment_name=t.table_name and owner=t.owner ),0)   as OverFlowSize       			
      , i.LAST_ANALYZED		
		, i.NUM_ROWS
	from dba_tables  t
		 , dba_indexes i            
	where t.IOT_NAME (+) = i.table_name
	  and upper(i.table_name) like upper('&&ENTER_TABLE.')
	  and upper(i.owner)       =  upper('&&ENTER_OWNER.')  
)  
order by 1
/  

set heading on

ttitle left  "Check if the columns are in the overflow segment of the IOT Table" skip 2

select c.table_name
     , c.column_name
     , case 
         when i.include_column != 0 then  ( case when c.column_id < i.include_column then 'TOP' else 'OVERFLOW' end ) 
       else 'TOP' 
       end as segment
  from dba_tab_columns c
     , dba_indexes     i
where  i.table_name (+) = c.table_name
   and i.owner (+) = c.owner
   and upper(c.table_name) like upper('&enter_table.')
   and upper(c.owner) = upper('&enter_owner.')     
 order by table_name
        , column_id
/

ttitle off

/* test Case 
CREATE TABLE T_IOT1(    ID NUMBER  , wert varchar2(20)  , CONSTRAINT T_IOT1_PK PRIMARY KEY (ID) ENABLE ) ORGANIZATION INDEX;

# mit den ersten Daten füllen:
BEGIN
FOR i IN 1..100 
 loop
   INSERT INTO T_IOT1 VALUES (i,to_char(i)||'er Wert');
END loop;
commit;
END;
/
SELECT * FROM  T_IOT1
/
---- zweiter test mit overflow
CREATE TABLE T_IOT2(    ID NUMBER  , wert varchar2(20)  , CONSTRAINT T_IOT2_PK PRIMARY KEY (ID) ENABLE ) ORGANIZATION INDEX INCLUDING wert OVERFLOW;
BEGIN
FOR i IN 1..100 
 loop
   INSERT INTO T_IOT2 VALUES (i,to_char(i)||'er Wert');
END loop;
commit;
END;
/
*/


