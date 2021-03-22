--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   analyse chained rows in the database
--
-- Must be run with dba privileges
-- 
--
--==============================================================================
-- http://docs.oracle.com/cd/B28359_01/server.111/b28286/statements_4005.htm#SQLRF01105
-- http://blog.tanelpoder.com/2009/11/04/detect-chained-and-migrated-rows-in-oracle/
--==============================================================================
set verify off
set linesize 130 pagesize 1000 

define USER_NAME ='GPI'
define TABLE_NAME ='COL_T'
define TABLE_SPACE='USERS'

set serveroutput on

----------------------
-- alternative use the utlchain.sql script in oracle_home/rdbms/admin
declare
v_count pls_integer;
begin
	select count(*) into v_count 
	  from DBA_TABLES 
	 where owner=upper('&&USER_NAME.') 
	   and table_name ='CHAINED_ROWS';
	if v_count < 1 then
		 dbms_output.put_line('-- Info : create chained row table');
		 execute immediate 'create table &&USER_NAME..CHAINED_ROWS (
			owner_name         varchar2(30),
			table_name         varchar2(30),
			cluster_name       varchar2(30),
			partition_name     varchar2(30),
			subpartition_name  varchar2(30),
			head_rowid         rowid,
			analyze_timestamp  date
		) tablespace &&TABLE_SPACE.
		';
	else
	 dbms_output.put_line('-- Info : use existing chained row table');
	end if; 
end;
/

select to_char(sysdate,'dd.mm.yyyy hh24:mi') as start_time from dual
/

declare
 cursor c_tab is 
  select table_name,owner
    from dba_tables 
   where owner=upper('&&USER_NAME.') 
	   and table_name  like '&&TABLE_NAME.%';

	v_count pls_integer;
	v_start number:=dbms_utility.get_time;
 
begin 
	for rec in c_tab
	 loop
	 	dbms_output.put_line('-- Info --------------------------------');
	   dbms_output.put_line('-- Info : start to analyse the table '||rec.owner||'.'||rec.table_name||' at ::'||to_char(sysdate,'dd.mm.yyyy hh24:mi'));
		--execute immediate 'analyse table '||rec.owner||'.'||rec.table_name||' list chained rows into '||rec.owner||'.chained_rows';
		dbms_output.put_line('-- Info : finish to analyse the table '||rec.owner||'.'||rec.table_name||' at ::'||to_char(sysdate,'dd.mm.yyyy hh24:mi'));		
		v_count:=v_count+1;
	end loop;
	dbms_output.put_line('-- Info --------------------------------');
	dbms_output.put_line('-- Info : finish to analyse '||v_count||' tables after '||to_char(dbms_utility.get_time-v_start)||'ms');
end;
/

select to_char(sysdate,'dd.mm.yyyy hh24:mi') as end_time from dual
/


select count(*),c.table_name
  from &&USER_NAME..CHAINED_ROWS c
 group by c.table_name
/

set verify on

