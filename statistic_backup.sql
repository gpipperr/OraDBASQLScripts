--==============================================================================
-- backup the DB statistics
--==============================================================================
set verify off
set linesize 130 pagesize 300 

set heading on
set feedback on
set echo off
set trimspool on
set trimout on
set serveroutput on

-------------------
-- create spool name
column SPOOL_NAME_VAR new_val SPOOL_NAME

select replace (
             ora_database_name
          || '_'
          || sys_context ('USERENV', 'HOST')
          || '_'
          || to_char (sysdate, 'dd_mm_yyyy_hh24_mi')
          || '_backup_statistics..sql'
        ,  '\'
        ,  '_')
          --' resolve syntax highlight bug FROM my editor .-(
          as SPOOL_NAME_VAR
  from dual
/

column AKTDATE new_value LOG_DATE

select to_char (sysdate, 'yyyymmdd_hh24mi') as AKTDATE from dual;

define STATID_SUFFIX = &&LOG_DATE
define STAT_TAB      = EXP_STATS_TABLE
define STAT_TBLSPACE = SYSAUX
define SYSSTAT_TAB   = BAK_SYSSTAT_&&STATID_SUFFIX
define IOSTAT_TAB    = BAK_IOSTAT_&&STATID_SUFFIX

------------

define STAT_OWN      = &STAT_OWNER

-----------

spool &&SPOOL_NAME

column my_sid format a15
column my_instance format a13
column my_instance_name format a20
column username format a15

select sys_context ('USERENV', 'SID') as my_sid
     ,  sys_context ('USERENV', 'INSTANCE') as my_instance
     ,  sys_context ('USERENV', 'INSTANCE_NAME') as my_instance_name
     ,  sys_context ('USERENV', 'CURRENT_USER') as username
  from dual;

select to_char (sysdate, 'dd.mm.yyyy hh24:mi') from dual;

show user

select * from global_name;

set timing on
set time on
set serveroutput on
set linesize 256
set pagesize 200
set echo off
set serveroutput on
set feedback off

-- create statistic backup table
prompt
prompt ... creating stats table &&STAT_OWN..&&STAT_TAB. in tablespace &&STAT_TBLSPACE ...

declare
   v_count   pls_integer := 0;
begin
   select count (*)
     into v_count
     from dba_tables
    where     owner = '&&STAT_OWN.'
          and table_name like '&&STAT_TAB.';

   if v_count < 1
   then
      dbms_stats.create_stat_table (ownname => '&&STAT_OWN.', stattab => '&&STAT_TAB.', tblspace => '&&STAT_TBLSPACE.');
   else
      dbms_output.put_line ('-- Info : stats table &&STAT_OWN..&&STAT_TAB. in tablespace &&STAT_TBLSPACE still exists');
   end if;
end;
/

comment on table &&STAT_OWN..&&STAT_TAB. is 'statistics backup table. do not delete';


-- backup database statistics
prompt
prompt ... backing up database stats to &&STAT_OWN..&&STAT_TAB. with statid: DB_STAT_&&STATID_SUFFIX ...

begin
   dbms_stats.EXPORT_DATABASE_STATS (stattab     => '&&STAT_TAB.'
                                   ,  statid      => 'DB_STAT_&&STATID_SUFFIX.'
                                   ,  statown     => '&&STAT_OWN.'
                                   ,  stat_category => 'OBJECT_STATS,SYNOPSES');
end;
/

-- backup dictionary statistics
prompt
prompt ... backing up dictionary stats to &&STAT_OWN..&&STAT_TAB. with statid: DICT_STATS_&&STATID_SUFFIX ...

begin
   dbms_stats.EXPORT_DICTIONARY_STATS (stattab     => '&&STAT_TAB.'
                                     ,  statid      => 'DICT_STATS_&&STATID_SUFFIX.'
                                     ,  STAT_OWN    => '&&STAT_OWN.'
                                     ,  stat_category => 'OBJECT_STATS,SYNOPSES');
end;
/


-- backup fixed object statistics
prompt
prompt ... backing up fixed object stats to &&STAT_OWN..&&STAT_TAB. with statid: FIXED_OBJ_STATS_&&STATID_SUFFIX ...

begin
   dbms_stats.EXPORT_FIXED_OBJECTS_STATS (stattab     => '&&STAT_TAB.'
                                        ,  statid      => 'FIXED_OBJ_STATS_&&STATID_SUFFIX'
                                        ,  statown     => '&&STAT_OWN.');
end;
/



-- backup system/workload statistics
prompt
prompt ... backing up system/workload stats to &&STAT_OWN..&&STAT_TAB. with statid: system_stats_&&STATID_SUFFIX ...

begin
   dbms_stats.EXPORT_SYSTEM_STATS (stattab => '&&STAT_TAB.', statid => 'SYSTEM_STATS_&&STATID_SUFFIX', statown => '&&STAT_OWN.');
end;
/

prompt
prompt  Summary over the stat table

column STATID format a20
column type   format a3
column counts format 99999999

  select STATID, type, count (*) as counts
    from &&STAT_OWN..&&STAT_TAB.
group by STATID, type
/


prompt
prompt ... creating backup &&STAT_OWN..&&SYSSTAT_TAB. of system/workload stats table sys.aux_stats$ ...

create table &&STAT_OWN..&&SYSSTAT_TAB.
as
   select * from sys.aux_stats$;

comment on table &&STAT_OWN..&&SYSSTAT_TAB. is 'Backup of system/workload stats table sys.aux_stats$';



-- backup iocalibrate statistics
prompt
prompt ... creating backup &&STAT_OWN..&&IOSTAT_TAB. of iocalibrate stats table sys.RESOURCE_IO_CALIBRATE$ ...

create table &&STAT_OWN..&&IOSTAT_TAB.
as
   select * from sys.RESOURCE_IO_CALIBRATE$;

comment on table &&STAT_OWN..&&IOSTAT_TAB. is 'Backup of iocalibrate stats table sys.RESOURCE_IO_CALIBRATE$';



-- print summary
column last       format a14
column name       format a65
column start_time format a25
column end_time   format a25
column owner format a25

prompt
prompt =======================================================================================
prompt IOCALIBRATE STATS (sys.RESOURCE_IO_CALIBRATE$,GV$IO_CALIBRATION_STATUS)
prompt =======================================================================================


select * from sys.RESOURCE_IO_CALIBRATE$
/

select * from GV$IO_CALIBRATION_STATUS
/

prompt ...
prompt ... Check that all disks are on async IO! (v$datafile, v$iostat_file)
prompt ...

  select count (*), i.asynch_io
    from v$datafile f, v$iostat_file i
   where     f.file# = i.file_no
         and i.filetype_name = 'Data File'
group by i.asynch_io
/



column START_TIME          format a21    heading "Start|time"
column END_TIME                format a21    heading "End|time"
column MAX_IOPS                format 9999999 heading "Block/s|data block"
column MAX_MBPS                format 9999999 heading "MB/s|maximum-sized read"
column MAX_PMBPS                format 9999999 heading "MB/s|largeI/0"
column LATENCY                 format 9999999 heading "Latency|data block read"
column NUM_PHYSICAL_DISKS  format 999     heading "Disk|Cnt"


select to_char (START_TIME, 'dd.mm.yyyy hh24:mi') as START_TIME
     ,  to_char (END_TIME, 'dd.mm.yyyy hh24:mi') as END_TIME
     ,  MAX_IOPS
     ,  MAX_MBPS
     ,  MAX_PMBPS
     ,  LATENCY
     ,  NUM_PHYSICAL_DISKS
  from dba_rsrc_io_calibrate
/


-- START_TIME             Start time of the most recent I/O calibration
-- END_TIME             End time of the most recent I/O calibration
-- MAX_IOPS             Maximum number of data block read requests that can be sustained per second
-- MAX_MBPS             Maximum megabytes per second of maximum-sized read requests that can be sustained
-- MAX_PMBPS             Maximum megabytes per second of large I/O requests that can be sustained by a single process
-- LATENCY                     Latency for data block read requests
-- NUM_PHYSICAL_DISKS     Number of physical disks in the storage subsystem (as specified by the user)


-- select
--      d.name
--    , f.file_no
--    , f.small_read_megabytes
--    , f.small_read_reqs
--    , f.large_read_megabytes
--    , f.large_read_reqs
-- from
--    v$iostat_file f
--    inner join v$datafile d on f.file_no = d.file#
-- /


prompt
prompt =======================================================================================
prompt Workload Stats Summary (sys.aux_stats$)
prompt =======================================================================================

column SNAME format a15 heading "Statistic|Name"
column pname format a12 heading "Parameter"
column PVAL1 format a20 heading "Value 1"
column PVAL2 format a20 heading "Value 2"

  select sname
       ,  pname
       ,  to_char (pval1, '999G999G999D99') as pval1
       ,  pval2
    from sys.aux_stats$
order by 1, 2
/

prompt .... CPUSPEED   Workload CPU speed in millions of cycles/second
prompt .... CPUSPEEDNW Noworkload CPU speed in millions of cycles/second
prompt .... IOSEEKTIM Seek time + latency time + operating system overhead time in milliseconds
prompt .... IOTFRSPEED Rate of a single read request in bytes/millisecond
prompt .... MAXTHR   Maximum throughput that the I/O subsystem can deliver in bytes/second
prompt .... MBRC      Average multiblock read count sequentially in blocks
prompt .... MREADTIM   Average time for a multi-block read request in milliseconds
prompt .... SLAVETHR   Average parallel slave I/O throughput in bytes/second
prompt .... SREADTIM   Average time for a single-block read request in milliseconds


prompt
prompt =======================================================================================
prompt Table Statistics Summary (dba_tables)
prompt =======================================================================================


  select count (*), owner, to_char (LAST_ANALYZED, 'dd.mm.yyyy') as last
    from dba_tables
group by owner, to_char (LAST_ANALYZED, 'dd.mm.yyyy'), to_char (LAST_ANALYZED, 'YYYYDDMM')
order by owner, to_char (LAST_ANALYZED, 'YYYYDDMM') desc
/



undefine STATID_SUFFIX
undefine STAT_OWN
undefine STAT_TAB
undefine STAT_TBLSPACE
undefine SYSSTAT_TAB
undefine IOSTAT_TAB


spool off;
set echo off
set time off
set timing off