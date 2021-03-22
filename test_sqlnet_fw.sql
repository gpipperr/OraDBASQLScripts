----====================================
--  GPI - Gunther Pippèrr
--  Desc:   Test Script to check FW Time-outs in SQL*Net
--
--  Idea:  Select something form the DB - Wait some time in a pl/sql loop - test against -- wait a longer period of time  - test again and so on..
--  Goal: How long can be the connection idle until the communication is dropped by the FW
--
--  edit the Intervals Value to check the test intervals
--  the may spool off should avoid that some messages are not in the log file (Buffer effect! ) !
--====================================
set verify off
set linesize 130 pagesize 300 

set serveroutput on
set feedback off

variable WAITTIME number;
variable INTERVALS number;

begin
   :WAITTIME := 15;
   :INTERVALS := 15;
end;
/

-------------------
-- create spool name
col SPOOL_NAME_COL new_val SPOOL_NAME

select replace (
             ora_database_name
          || '_'
          || sys_context ('USERENV', 'HOST')
          || '_'
          || to_char (sysdate, 'dd_mm_yyyy_hh24_mi')
          || '_fwchek_.sql'
        ,  '\'
        ,  '_')
          --' resolve syntax highlight bug FROM my editer .-(
          as SPOOL_NAME_COL
  from dual
/

spool &&SPOOL_NAME

-------------------

prompt =======================================
prompt START FW TEST
prompt =======================================
@date
@my_user
-- !! not use the first block for copy past the next ones!!
prompt == Start waiting ............

begin
   dbms_lock.sleep (  60
                    * :INTERVALS);
   dbms_output.put_line (
      '== Info Wait time :: ' || to_char (:INTERVALS) || ' Wake up at :: ' || to_char (sysdate, 'dd.mm.yyyy hh24:mi'));
   :WAITTIME :=
        :WAITTIME
      + :INTERVALS;
end;
/

prompt == Finish Waiting , start next try
@date
@my_user

spool off
--
spool &&SPOOL_NAME append

-------------------

prompt == Start waiting ............
-- Use this block for new blocks!

begin
   dbms_lock.sleep (  60
                    * :WAITTIME);
   dbms_output.put_line (
      '== Info Wait time :: ' || to_char (:WAITTIME) || ' Wake up at :: ' || to_char (sysdate, 'dd.mm.yyyy hh24:mi'));
   :WAITTIME :=
        :WAITTIME
      + :INTERVALS;
end;
/

prompt == Finish Waiting , start next try
@date
@my_user

spool off
--
spool &&SPOOL_NAME append

-------------------

prompt == Start waiting ............

begin
   dbms_lock.sleep (  60
                    * :WAITTIME);
   dbms_output.put_line (
      '== Info Wait time :: ' || to_char (:WAITTIME) || ' Wake up at :: ' || to_char (sysdate, 'dd.mm.yyyy hh24:mi'));
   :WAITTIME :=
        :WAITTIME
      + :INTERVALS;
end;
/

prompt == Finish Waiting , start next try
@date
@my_user

spool off
--
spool &&SPOOL_NAME append

-------------------

prompt == Start waiting ............

begin
   dbms_lock.sleep (  60
                    * :WAITTIME);
   dbms_output.put_line (
      '== Info Wait time :: ' || to_char (:WAITTIME) || ' Wake up at :: ' || to_char (sysdate, 'dd.mm.yyyy hh24:mi'));
   :WAITTIME :=
        :WAITTIME
      + :INTERVALS;
end;
/

prompt == Finish Waiting , start next try
@date
@my_user

spool off
--
spool &&SPOOL_NAME append

-------------------

prompt == Start waiting ............

begin
   dbms_lock.sleep (  60
                    * :WAITTIME);
   dbms_output.put_line (
      '== Info Wait time :: ' || to_char (:WAITTIME) || ' Wake up at :: ' || to_char (sysdate, 'dd.mm.yyyy hh24:mi'));
   :WAITTIME :=
        :WAITTIME
      + :INTERVALS;
end;
/

prompt == Finish Waiting , start next try
@date
@my_user

spool off
--
spool &&SPOOL_NAME append

-------------------

prompt == Start waiting ............

begin
   dbms_lock.sleep (  60
                    * :WAITTIME);
   dbms_output.put_line (
      '== Info Wait time :: ' || to_char (:WAITTIME) || ' Wake up at :: ' || to_char (sysdate, 'dd.mm.yyyy hh24:mi'));
   :WAITTIME :=
        :WAITTIME
      + :INTERVALS;
end;
/

prompt == Finish Waiting , start next try
@date
@my_user

spool off
--
spool &&SPOOL_NAME append

-------------------


prompt == Start waiting ............

begin
   dbms_lock.sleep (  60
                    * :WAITTIME);
   dbms_output.put_line (
      '== Info Wait time :: ' || to_char (:WAITTIME) || ' Wake up at :: ' || to_char (sysdate, 'dd.mm.yyyy hh24:mi'));
   :WAITTIME :=
        :WAITTIME
      + :INTERVALS;
end;
/

prompt == Finish Waiting , start next try
@date
@my_user

spool off
--
spool &&SPOOL_NAME append

-------------------


prompt == Start waiting ............

begin
   dbms_lock.sleep (  60
                    * :WAITTIME);
   dbms_output.put_line (
      '== Info Wait time :: ' || to_char (:WAITTIME) || ' Wake up at :: ' || to_char (sysdate, 'dd.mm.yyyy hh24:mi'));
   :WAITTIME :=
        :WAITTIME
      + :INTERVALS;
end;
/

prompt == Finish Waiting
@date
@my_user

spool off
--
spool &&SPOOL_NAME append

-------------------


prompt == Start waiting ............

begin
   dbms_lock.sleep (  60
                    * :WAITTIME);
   dbms_output.put_line (
      '== Info Wait time :: ' || to_char (:WAITTIME) || ' Wake up at :: ' || to_char (sysdate, 'dd.mm.yyyy hh24:mi'));
   :WAITTIME :=
        :WAITTIME
      + :INTERVALS;
end;
/

prompt == Finish Waiting , start next try
@date
@my_user

prompt =======================================
prompt FINISH FW TEST
prompt =======================================

spool off
