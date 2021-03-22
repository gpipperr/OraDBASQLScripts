--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: show all enviroments settings with SYS_CONTEXT
--
--
--==============================================================================
set linesize 130 pagesize 300 
set serveroutput on 

declare

 TYPE settings_tab IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
 v_settings settings_tab;

begin

	v_settings(1):='ACTION';
	v_settings(2):='AUDITED_CURSORID';
	v_settings(3):='AUTHENTICATED_IDENTITY';
	v_settings(4):='AUTHENTICATION_DATA';
	v_settings(5):='AUTHENTICATION_METHOD';
	v_settings(6):='BG_JOB_ID';
	v_settings(7):='CLIENT_IDENTIFIER';
	v_settings(8):='CLIENT_INFO';
	v_settings(9):='CURRENT_BIND';
	v_settings(10):='CURRENT_EDITION_ID';
	v_settings(11):='CURRENT_EDITION_NAME';
	v_settings(12):='CURRENT_SCHEMA';
	v_settings(13):='CURRENT_SCHEMAID';
	v_settings(14):='CURRENT_SQL';
	v_settings(15):='CURRENT_SQL1';
	v_settings(16):='CURRENT_SQL2';
	v_settings(17):='CURRENT_SQL3';
	v_settings(18):='CURRENT_SQL_LENGTH';
	v_settings(19):='CURRENT_USER';
	v_settings(20):='CURRENT_USERID';
	v_settings(21):='DATABASE_ROLE';
	v_settings(22):='DB_DOMAIN';
	v_settings(23):='DB_NAME';
	v_settings(24):='DB_UNIQUE_NAME';
	v_settings(25):='DBLINK_INFO';
	v_settings(26):='ENTRYID';
	v_settings(27):='ENTERPRISE_IDENTITY';
	v_settings(28):='FG_JOB_ID';
	v_settings(29):='GLOBAL_CONTEXT_MEMORY';
	v_settings(30):='GLOBAL_UID';
	v_settings(31):='HOST';
	v_settings(32):='IDENTIFICATION_TYPE';
	v_settings(33):='INSTANCE';
	v_settings(34):='INSTANCE_NAME';
	v_settings(35):='IP_ADDRESS';
	v_settings(36):='ISDBA';
	v_settings(37):='LANG';
	v_settings(38):='LANGUAGE';
	v_settings(39):='MODULE';
	v_settings(40):='NETWORK_PROTOCOL';
	v_settings(41):='NLS_CALENDAR';
	v_settings(42):='NLS_CURRENCY';
	v_settings(43):='NLS_DATE_FORMAT';
	v_settings(44):='NLS_DATE_LANGUAGE';
	v_settings(45):='NLS_SORT';
	v_settings(46):='NLS_TERRITORY';
	v_settings(47):='OS_USER';
	v_settings(48):='POLICY_INVOKER';
	v_settings(49):='PROXY_ENTERPRISE_IDENTITY';
	v_settings(50):='PROXY_USER';
	v_settings(51):='PROXY_USERID';
	v_settings(52):='SERVER_HOST';
	v_settings(53):='SERVICE_NAME';
	v_settings(54):='SESSION_EDITION_ID';
	v_settings(55):='SESSION_EDITION_NAME';
	v_settings(56):='SESSION_USER';
	v_settings(57):='SESSION_USERID';
	v_settings(58):='SESSIONID';
	v_settings(59):='SID';
	v_settings(60):='STATEMENTID';
	v_settings(61):='TERMINAL';	
	
	
	dbms_output.put_line('--');
	dbms_output.put_line('-- Check the Setting for your SYS Context of the USERENV');
	dbms_output.put_line('-- -----------------------------------------------------');
	
	FOR i IN v_settings.FIRST .. v_settings.LAST
		loop
			begin
				dbms_output.put_line('-- Setting for '||rpad(v_settings(i),24)||' is :: '||SYS_CONTEXT ('USERENV',v_settings(i)));
			exception 
				when others then
				dbms_output.put_line('-- Setting for '||rpad(v_settings(i),24)||' ERROR :: '||SQLERRM);
			end;
	end loop;
	dbms_output.put_line('-- -----------------------------------------------------');
end;
/