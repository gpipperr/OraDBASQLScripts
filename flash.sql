--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   show flash features
--
-- Must be run with dba privileges
-- Source 
--  http://docs.oracle.com/cd/E11882_01/appdev.112/e40758/d_flashb.htm#ARPLS142
--==============================================================================

set linesize 130 pagesize 300 

ttitle  "Report Flashback Feature of the Database"  skip 2 -

column  FLASHBACK_ON format A20

select FLASHBACK_ON from V$DATABASE
/

column  INST_ID format A4
column  RETENTION_TARGET format A20
column  FLASH_SIZE format A20
column  ESTIMATED_SIZE format A20

ttitle  "Report Flashback Size of the Database"  skip 2 -


select to_char (INST_ID) as inst_id
     ,  RETENTION_TARGET || ' Minuten' RETENTION_TARGET
     ,     round (  (FLASHBACK_SIZE)
                  / 1024
                  / 1024)
        || ' MB'
           FLASH_SIZE
     ,     round (  (ESTIMATED_FLASHBACK_SIZE)
                  / 1024
                  / 1024)
        || ' MB'
           ESTIMATED_SIZE
  from GV$FLASHBACK_DATABASE_LOG
/


ttitle  "Report Flashback Logs of the Database"  skip 2 -

column  last_first_time format A20
column  maxsize format A10

  select to_char (INST_ID) as inst_id
       ,  max (LOG#) as last_logid
       ,  to_char (max (FIRST_TIME), 'dd.mm.yyyy hh24:mi') as last_first_time
       ,     round (  max (BYTES)
                    / 1024
                    / 1024)
          || ' MB'
             as maxsize
    from GV$FLASHBACK_DATABASE_LOGFILE
group by inst_id
/

ttitle " Flashback Restore Points"
column scn format 99999999999999999
column RESTORE_POINT_TIME format a18 heading "RS P Time"
column time format a18 heading "Time"
column name format a30 heading "Name"
column GUARANTEE_FLASHBACK_DATABASE format a6 heading "Garant."

select scn
     ,  to_char (RESTORE_POINT_TIME, 'dd.mm.yyyy hh24:mi') as RESTORE_POINT_TIME
     ,  to_char (TIME, 'dd.mm.yyyy hh24:mi') as TIME
     ,  NAME
     ,  GUARANTEE_FLASHBACK_DATABASE
  from V$RESTORE_POINT;

ttitle  "Oldest possible time to flashback"  skip 2 -

select to_char (oldest_flashback_time, 'dd-mon-yyyy hh24:mi:ss') as "Oldest possible time" from v$flashback_database_log
/

ttitle  "Oldest possible SCN to flashback"  skip 2 -

column oldest_flashback_scn format 99999999999999999999999999 heading   "Oldest possible SCN"

select oldest_flashback_scn from v$flashback_database_log
/


ttitle  "Report Flashback Logs Buffer"  skip 2 -

column  name format A40

select *
  from v$sgastat
 where name like 'flashback%';


prompt .... check if there are some tablespaces with flashback disabled!

select NAME, FLASHBACK_ON
  from v$tablespace
 where FLASHBACK_ON = 'NO'
/

prompt .... no row should be visible to avoid error!
prompt

ttitle off