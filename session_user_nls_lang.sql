--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: show all enviroments settings with SYS_CONTEXT
--
--
--==============================================================================
set linesize 130 pagesize 300 
set serveroutput on 

set serveroutput on

DECLARE
   v_tns   VARCHAR2 (100);
BEGIN
   
	SYS.DBMS_SYSTEM.get_env ('TNS_ADMIN', v_tns);
   DBMS_OUTPUT.put_line ( RPAD('TNS_ADMIN',20,' ')||' :: '||v_tns);
	
	SYS.DBMS_SYSTEM.get_env ('ORACLE_HOME', v_tns);
   DBMS_OUTPUT.put_line ( RPAD('ORACLE_HOME',20,' ')||' :: '||v_tns);
	
	SYS.DBMS_SYSTEM.get_env ('ORACLE_BASE', v_tns);
   DBMS_OUTPUT.put_line ( RPAD('ORACLE_BASE',20,' ')||' :: '||v_tns);

	SYS.DBMS_SYSTEM.get_env ('NLS_LANG', v_tns);
   DBMS_OUTPUT.put_line ( RPAD('NLS_LANG',20,' ')||' :: '||v_tns);

	SYS.DBMS_SYSTEM.get_env ('TEMP', v_tns);
   DBMS_OUTPUT.put_line ( RPAD('TEMP',20,' ')||' :: '||v_tns);
	
	SYS.DBMS_SYSTEM.get_env ('OS', v_tns);
   DBMS_OUTPUT.put_line ( RPAD('OS',20,' ')||' :: '||v_tns);
	
END;
/