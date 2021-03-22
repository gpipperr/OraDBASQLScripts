--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   show change time of a table
-- Date:   September 2013
--
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define OWNER    = '&1' 
define TAB_NAME = '&2' 

prompt
prompt Parameter 1 = Owner Name  => &&OWNER.
prompt Parameter 2 = Tab Name    => &&TAB_NAME.

define FILTER   = '&3' 
prompt Parameter 3 = Tab Filter   => &&FILTER.
prompt

set serveroutput on;

declare
	
	v_tab_owner varchar2(32):='&&OWNER.';
	v_tab_name  varchar2(32):='&&TAB_NAME.';
	v_filter    varchar2(32):='&&FILTER.';
	v_sql       varchar2(2000);
	v_max_scn   number;
	v_min_scn   number;
	v_count     number;
	
	function getSCNTime(p_scn number)
	return varchar2
	is
	v_return varchar2(20);
	begin
		
		select to_char(FIRST_TIME,'dd.mm.yyyy hh24:mi:ss') into v_return
	      from V$LOG_HISTORY 
		 where p_scn between FIRST_CHANGE# and NEXT_CHANGE#;
		 
	exception 
		when others then	
		
		select to_char(min(FIRST_TIME),'dd.mm.yyyy hh24:mi:ss') into v_return
		  from V$LOG_HISTORY 
		 where FIRST_CHANGE# > p_scn;
		 
		return 'no exact value found but older then :: '||v_return;
		
	end;
begin

	v_sql:=' select max(ora_rowscn),min(ora_rowscn),count(*) from '||upper(v_tab_owner)||'.'||upper(v_tab_name);
	
	if length(v_filter) > 1 then
		v_sql:=v_sql||' where '||v_filter;
	end if;
	
	dbms_output.put_line('Info -- start search of last change date for the table :: '||upper(v_tab_name));
	dbms_output.put_line('Info -- sql    ::'|| v_sql);
    dbms_output.put_line('Info --');
	
	execute immediate v_sql into v_max_scn,v_min_scn,v_count;
	
	dbms_output.put_line('Info -- MAX SCN:: '||to_char(v_max_scn));
	dbms_output.put_line('Info -- MIN SCN:: '||to_char(v_min_scn));
	dbms_output.put_line('Info -- Count  :: '||to_char(v_count));
	dbms_output.put_line('Info --');
	
	if v_count > 0 then
		dbms_output.put_line('Info -- Transform scn to timestamp');
		dbms_output.put_line('Info -- May be the data has this age');
		
		begin
			dbms_output.put_line('Info -- Max time :: ' || SCN_TO_TIMESTAMP(v_max_scn));
		exception
		when others then
			dbms_output.put_line('Info -- For min time the scn is not    valid  :: '||v_max_scn);
			dbms_output.put_line('Info -- Try to read from V$LOG_HISTORY found  :: '||getSCNTime(v_max_scn));
		end;
		dbms_output.put_line('Info --');
		begin
			dbms_output.put_line('Info -- Min time :: ' || SCN_TO_TIMESTAMP(v_min_scn));
		exception
		when others then
			dbms_output.put_line('Info -- For min time the scn is not    valid  :: '||v_min_scn);
			dbms_output.put_line('Info -- Try to read from V$LOG_HISTORY found  :: '||getSCNTime(v_min_scn));
		end;	
	else
		dbms_output.put_line('Info -- No Records found');
	end if;
		
end;
/
