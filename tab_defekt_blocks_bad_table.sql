--==============================================================================
-- GPI - Gunther Pippèrr
-- create a table with all ids and rowid's for a not full readable oracle table with lobs
--==============================================================================
set verify off
set linesize 130 pagesize 300 

set concat off
set serveroutput on


define OWNER         = 'GPI' 
define TABLE_NAME    = 'LOBTAB' 
define TEST_COL      = 'dbms_lob.getlength(DATA)'
define TABLESPACE    = 'USERS'

prompt
prompt Parameter 1 = Owner  Name    => &&OWNER.
prompt Parameter 2 = Table  Name    => &&TABLE_NAME.
prompt Parameter 3 = TEST Col Name  => &&TEST_COL.
prompt Parameter 4 = TEST Col Name  => &&TABLESPACE.
prompt 

---------------------------------
-- create the bad_rowid table
---------------------------------

declare
 v_count number:=0;
begin
  select count(*) into v_count from dba_tables where table_name = 'BAD_BLOCK_ROWS';
  
  if v_count > 0 then
     execute immediate 'drop table bad_block_rows';
	  dbms_output.put_line('Info -- drop Table  bad_block_rows');
  end if;
  
  execute immediate 'create table bad_block_rows (row_id ROWID ,oracle_error_code number) tablespace &&TABLESPACE';
  dbms_output.put_line('Info -- create Table  bad_block_rows');
  
end;
/

---------------------------------
-- Read all data from the table 
-- remember all defect rowids
---------------------------------

declare
  v_row rowid;
  v_error_code number;
  v_bad_rows number := 0;
  v_good_rows number :=0;
  
  e_ora1578 EXCEPTION;
  e_ora600 EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_ora1578, -1578);
  PRAGMA EXCEPTION_INIT(e_ora600, -600);
  
begin
   for rec in (select rowid rid, &&TEST_COL from &&OWNER.&TABLE_NAME ) -- where rownum < 10
	loop
   begin
     -- read the rowid
	  v_row:=rec.rid;
	  v_good_rows:=v_good_rows+1;
	  
	exception
    when e_ora1578 then
     v_bad_rows := v_bad_rows + 1;
     insert into bad_block_rows(row_id,oracle_error_code) values(rec.rid,1578);
     commit;
    when e_ora600 then
     v_bad_rows := v_bad_rows + 1;
     insert into bad_block_rows(row_id,oracle_error_code) values(rec.rid,600);
     commit;
    when others then
     v_error_code:=SQLCODE;
     v_bad_rows := v_bad_rows + 1;
     insert into bad_block_rows(row_id,oracle_error_code) values(rec.rid,v_error_code);
     commit;   
   end;
  end loop;
  dbms_output.put_line('Info -- Total Rows identified with errors in LOB column: '||v_bad_rows);
end;
/
