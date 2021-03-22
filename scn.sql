--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   Get the Redo Log scn information
-- Date:   01.November 2013
--==============================================================================
set linesize 130 pagesize 300 

set serveroutput on size 1000000

prompt

declare
   v_scn   number;
begin
   v_scn := dbms_flashback.GET_SYSTEM_CHANGE_NUMBER;
   dbms_output.PUT_LINE ('current SCN: ' || v_scn);
end;
/


ttitle  "Report Redo Log SCN History per Day"  skip 1  -

column min_scn format 999999999999999
column max_scn format 999999999999999

  select trunc (FIRST_TIME) as days
       ,  thread#
       ,  min (FIRST_CHANGE#) as min_scn
       ,  max (FIRST_CHANGE#) as max_scn
       ,  count (*) as archive_count
    from V$LOG_HISTORY
   where FIRST_TIME > trunc (  sysdate
                             - 14)
group by trunc (FIRST_TIME), thread#
order by 1, 2
/

ttitle off

ttitle  "Report LOGS with this SCN"  skip 1  -


accept SCN prompt "search for SCN:"

column NAME      format a40    heading "Archivelog|Name"
column THREAD_NR format a2     heading "I"
column SEQUENCE# format 999999 heading "Arch|seq"

set numwidth  14

  select to_char (THREAD#) as THREAD_NR
       ,  SEQUENCE#
       ,  NAME
       ,  to_char (FIRST_TIME, 'dd.mm hh24:mi') as first_time
       ,  NEXT_TIME
       ,  FIRST_CHANGE#
       ,  NEXT_CHANGE#
    from v$archived_log
   where to_number ('&&SCN.') between FIRST_CHANGE# and NEXT_CHANGE#
order by THREAD#, SEQUENCE#
/

undefine SCN