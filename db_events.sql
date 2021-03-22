--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   Event settings in the database, must be called as SYS
-- Date:   01.2014
--==============================================================================
set linesize 130 pagesize 300 

set feedback off
set serveroutput on

declare
   v_level         number;
   v_dbname        varchar2 (30);
   v_event_count   pls_integer := 0;
begin
   dbms_output.put_line (rpad ('-', 30, '-'));

   select name into v_dbname from v$database;

   for v_event in 10000 .. 999999
   loop
      dbms_system.read_ev (v_event, v_level);

      if v_level > 0
      then
         dbms_output.put_line (
            ' -- database:: ' || v_dbname || ' >> event ' || to_char (v_event) || ' is set at level ' || to_char (v_level));
         v_event_count := v_event_count+ 1;
      end if;
   end loop;

   if v_event_count = 0
   then
      dbms_output.put_line (' -- No Events are set in this database :: ' || v_dbname);
   else
      dbms_output.put_line (' -- Found ' || to_char (v_event_count) || ' Events are set in this database :: ' || v_dbname);
   end if;

   dbms_output.put_line (rpad ('-', 30, '-'));
end;
/

set feedback on
