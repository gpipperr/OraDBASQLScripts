--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   set the sqlplus prompt
--         try to find out the os of sqlplus and set the title bar of the sql*Plus window if windows
-- 
--
--==============================================================================
set termout off

-- get the host name

col x new_value y
define y=?
-- use only the first part of the host name to avoid error with value to long

select decode (substr (sys_context ('USERENV', 'SERVER_HOST')
                     ,  1
                     ,    instr (sys_context ('USERENV', 'SERVER_HOST'), '.')
                        - 1)
             ,  '', sys_context ('USERENV', 'SERVER_HOST')
             ,  substr (sys_context ('USERENV', 'SERVER_HOST')
                      ,  1
                      ,    instr (sys_context ('USERENV', 'SERVER_HOST'), '.')
                         - 1))
          x
  from dual
/

-- get the data for the window title

col u new_value z
define z=?

select    sys_context ('USERENV', 'INSTANCE_NAME')
       || ' ++ Service :: '
       || sys_context ('USERENV', 'SERVICE_NAME')
       || ' ++ User :: '
       || user
          u
  from dual
/

-- the the operation System to set the title bar of the sqlplus window
-- the problem is the the detection of the operation system of sqlplus
-- to call the right os command to set the title window

-- try to the the os from a return code
-- not working, error out is bad....
-- if command uptime exits we guess linux
--
-- WHENEVER OSERROR continue
--
-- --host set
-- var HR varchar2(5)
--
-- set verify off
-- get the return code from host
-- begin
--  :HR := '&_RC';
-- end;
-- /
-- set verify on

--------

var OS varchar2(5)

declare
   v_oracle_home   varchar2 (512);
   v_module        varchar2 (512);
   v_os_user       varchar2 (512);
   v_host          varchar2 (512);
begin
   :OS := 'XX';

   -- try to get the OS from the Oracle Home Path
   -- only possible if you have DBA rights
   if (sys_context ('USERENV', 'ISDBA') != 'FALSE')
   then
      -- dbms_system is only valid if you are dba
      -- must be called there for dynamic!
      -- but this is not the client environment ...
      -- execute immediate 'begin dbms_system.get_env(''ORACLE_HOME'',:1); end;' using out v_oracle_home;
      -- if instr(v_oracle_home,'/') > 0 then
      --

      -- if you are dba you will see sqlplus.exe
      -- use the .exe to detect windows

      v_module := sys_context ('USERENV', 'MODULE');

      if instr (v_module, '.exe') > 0
      then
         :OS := 'WIN';
      else
         :OS := 'LINUX';
      end if;
   else
      -- try to check if sqlplus was started from a windows environment
      -- the windows login name is host\user
      -- try to detect the \

      v_os_user := sys_context ('USERENV', 'OS_USER');
      v_host := sys_context ('USERENV', 'HOST');

      if instr (v_os_user, '\') > 0
      then
         -- ' needed for syntax highlightning of my editor ...
         :OS := 'WIN';
      else
         --  check  again the with the host
         if instr (v_host, '\') > 0
         then
            -- ' needed for syntax highlightning of my editor ...
            :OS := 'WIN';
         else
            :OS := 'LINUX';
         end if;
      end if;
   end if;
end;
/

--- define  this variable to avoid error with nolog logins
define SCRIPTPART_CALL='set_no_titel.sql'

col SCRIPTPART_COL new_val SCRIPTPART_CALL

select decode (:OS, 'LINUX', 'set_linux_title.sql', 'set_windows_title.sql') as SCRIPTPART_COL from dual
/

undefine OS

-- call the os script for the title setting
--
@@&&SCRIPTPART_CALL "&z" "&y"

set sqlprompt "_USER'@'_CONNECT_IDENTIFIER-&y>"


-- set the session information

begin
   dbms_application_info.set_module ('DBA Connection', 'DBA');
   dbms_application_info.set_client_info ('DBA');
   dbms_session.set_identifier ('DBA');
end;
/

--- global Settings
set trimspool on
set serveroutput on
set pagesize 300
set linesize 130
set 
-- suppress scientific notation
set numwidth  12
--
-- set your personal prefer time format
alter session set nls_date_format='dd.mm.rr hh24:mi';
--
--

--
set verify off
column SQLPLUS_VERSION format a20
select decode(substr('&&_SQLPLUS_RELEASE',0,1), '0','SQLCL','SQLPLUS') as SQLPLUS_VERSION from dual;
set verify on

set termout on
