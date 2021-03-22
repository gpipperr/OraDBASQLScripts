--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   redo
--==============================================================================
set linesize 130 pagesize 300 

ttitle  "Report Redo Log Configuration "  skip 1  -
left "Sizes in MB" skip 2

column member format a50
column THREAD# format 99
column  GROUP# format 99
column value format 999G999G999

ttitle  "Redolog  Size of each group"  skip 1  -
left "Sizes in MB" skip 2

select count (*)
       ,  thread#
       ,  to_char (round (  BYTES  / 1024  / 1024 ,  2))|| 'M'  as REDOLOG_SIZE
    from v$log
group by thread#, BYTES
/

prompt

ttitle  "Redolog  Status of each group"  skip 1  -
left "Sizes in MB" skip 2

select THREAD#
       ,  group#
       ,  status
       ,  to_char (round (  BYTES / 1024 / 1024,  2))|| 'M' as REDOLOG_SIZE
    from v$log
order by 1, 2
/

prompt

ttitle  "Redolog Member  of the groups"  skip 1  -
left "Sizes in MB" skip 2

  select group#
       ,  member
       ,  status
       ,  type
    from v$logfile
order by 1, 2
/

ttitle  "Redolog Switch frequency "  skip 2

--select to_char(FIRST_TIME,'dd.mm.yyyy hh24:mi:ss') as first_time_log
--      , RECID
--      , THREAD#
--      , SEQUENCE#
--  from (select * from v$log_history order by recid desc)
--where rownum <=20
--order by first_time_log asc
--/
set linesize 130

column T01 format a3 heading "01" justify center
column T02 format a3 heading "02" justify center
column T03 format a3 heading "03" justify center
column T04 format a3 heading "04" justify center
column T05 format a3 heading "05" justify center
column T06 format a3 heading "06" justify center
column T07 format a3 heading "07" justify center
column T08 format a3 heading "08" justify center
column T09 format a3 heading "09" justify center
column T10 format a3 heading "10" justify center
column T11 format a3 heading "11" justify center
column T12 format a3 heading "12" justify center
column T13 format a3 heading "13" justify center
column T14 format a3 heading "14" justify center
column T15 format a3 heading "15" justify center
column T16 format a3 heading "16" justify center
column T17 format a3 heading "17" justify center
column T18 format a3 heading "18" justify center
column T19 format a3 heading "19" justify center
column T20 format a3 heading "20" justify center
column T21 format a3 heading "21" justify center
column T22 format a3 heading "22" justify center
column T23 format a3 heading "23" justify center
column T24 format a3 heading "00" justify center
column slday format a5 heading "Day"  justify left

select to_char (to_date (to_char (slday), 'yyyymmdd'), 'DD.MM') as slday
     ,  decode (nvl (T01, 0), 0, '-', to_char (T01)) T01
     ,  decode (nvl (T02, 0), 0, '-', to_char (T02)) T02
     ,  decode (nvl (T03, 0), 0, '-', to_char (T03)) T03
     ,  decode (nvl (T04, 0), 0, '-', to_char (T04)) T04
     ,  decode (nvl (T05, 0), 0, '-', to_char (T05)) T05
     ,  decode (nvl (T06, 0), 0, '-', to_char (T06)) T06
     ,  decode (nvl (T07, 0), 0, '-', to_char (T07)) T07
     ,  decode (nvl (T08, 0), 0, '-', to_char (T08)) T08
     ,  decode (nvl (T09, 0), 0, '-', to_char (T09)) T09
     ,  decode (nvl (T10, 0), 0, '-', to_char (T10)) T10
     ,  decode (nvl (T11, 0), 0, '-', to_char (T11)) T11
     ,  decode (nvl (T12, 0), 0, '-', to_char (T12)) T12
     ,  decode (nvl (T13, 0), 0, '-', to_char (T13)) T13
     ,  decode (nvl (T14, 0), 0, '-', to_char (T14)) T14
     ,  decode (nvl (T15, 0), 0, '-', to_char (T15)) T15
     ,  decode (nvl (T16, 0), 0, '-', to_char (T16)) T16
     ,  decode (nvl (T17, 0), 0, '-', to_char (T17)) T17
     ,  decode (nvl (T18, 0), 0, '-', to_char (T18)) T18
     ,  decode (nvl (T19, 0), 0, '-', to_char (T19)) T19
     ,  decode (nvl (T20, 0), 0, '-', to_char (T20)) T20
     ,  decode (nvl (T21, 0), 0, '-', to_char (T21)) T21
     ,  decode (nvl (T22, 0), 0, '-', to_char (T22)) T22
     ,  decode (nvl (T23, 0), 0, '-', to_char (T23)) T23
  --,  decode(nvl(T24,0),0,'-',to_char(T24))  T24
  from (  select sum (decode (nvl (to_char (lh.FIRST_TIME, 'yyyymmddhh24'), 0), 0, 0, 1)) as slog, dr.dr as slday, dr.dh as slhour
            --, to_char(lh.FIRST_TIME,'yyyymmddhh24')
            from v$log_history lh
               ,  (select td.dr || th.hr as dg, th.hr as dh, td.dr as dr
                     from (select ltrim (to_char (rownum, '09')) as hr
                             from all_objects
                            where rownum < 25) th
                        ,  (select ltrim (to_char (  sysdate
                                                   - (  rownum
                                                      - 1)
                                                 ,  'yyyymmdd'))
                                      as dr
                              from all_objects
                             where rownum < 20) td) dr
           where dr.dg = to_char (lh.FIRST_TIME(+), 'yyyymmddhh24')
        group by to_char (lh.FIRST_TIME, 'yyyymmddhh24')
               ,  dr.dg
               ,  dr.dh
               ,  dr.dr) pivot (sum (slog)
                         for slhour
                         in  ('01' as T01
                           ,  '02' as T02
                           ,  '03' as T03
                           ,  '04' as T04
                           ,  '05' as T05
                           ,  '06' as T06
                           ,  '07' as T07
                           ,  '08' as T08
                           ,  '09' as T09
                           ,  '10' as T10
                           ,  '11' as T11
                           ,  '12' as T12
                           ,  '13' as T13
                           ,  '14' as T14
                           ,  '15' as T15
                           ,  '16' as T16
                           ,  '17' as T17
                           ,  '18' as T18
                           ,  '19' as T19
                           ,  '20' as T20
                           ,  '21' as T21
                           ,  '22' as T22
                           ,  '23' as T23
                           ,  '24' as T24))
/

ttitle  "Archive log size last 7 days"  skip 1

column SIZE_GB format 999999999 heading "Size GB"
column dest_id format 99 heading "Arch|Dest ID"

  select decode (grouping (trunc (completion_time)), 1, 'Sum:', trunc (completion_time)) days
       ,  round (  sum (  blocks
                        * block_size)
                 / 1024
                 / 1024
                 / 1024
               ,  3)
             size_gb
       ,  DEST_ID
    from v$archived_log
   where completion_time > trunc (  sysdate
                                  - 3)
--where completion_time > to_date('13.01.2014  17:13','dd.mm.yyyy hh24:mi')
--group by DEST_ID
group by cube (DEST_ID, trunc (completion_time))
order by 1, 3
/

prompt .... look at the archive dest id for more then one archive destination
prompt ....

ttitle  "Archive log count on disk days"  skip 1

  select THREAD# as inst_id
       ,  DEST_ID
       ,  trunc (COMPLETION_TIME) as log_day
       ,  substr (name, 1, 10) || '..' as file_name
       ,  count (*) as archvie_count
    from v$archived_log
   where name is not null
group by trunc (COMPLETION_TIME)
       ,  THREAD#
       ,  substr (name, 1, 10) || '..'
       ,  DEST_ID
order by 2, 3, 1
/

ttitle  "Redolog init ora Settings "  skip 1

show parameter log_buffer

ttitle left  "Trace File Locations" skip 2
column full_trace_file_loc  format a100  heading "Trace|File"

select p.inst_id, p.pname, p.tracefile as full_trace_file_loc
    from gv$session vs, gv$process p
   where     vs.paddr = p.addr
         and vs.inst_id = p.inst_id
         and vs.username is null
         and p.pname = 'LGWR'
order by vs.username, p.inst_id
/

ttitle  "Redolog Buffer Contention statistic:"  skip 2

column r format a50 fold_after

set heading off

select rpad ('Name', 20) || ': ' || name as r
     ,  rpad ('Gets', 20) || ': ' || gets as r
     ,  rpad ('Misses', 20) || ': ' || misses as r
     ,     rpad ('Alloc Ratio', 20)
        || ': '
        || round (  (  misses
                     / gets)
                  * 100
                ,  3)
           as r
     ,  rpad ('Immediate Gets', 20) || ': ' || immediate_gets as r
     ,  rpad ('Immediate Misses', 20) || ': ' || immediate_misses as r
     ,     rpad ('Miss Ratio', 20)
        || ': '
        || decode (  immediate_gets
                   + immediate_misses
                 ,  0, 0
                 ,  round (  immediate_misses
                           / (  immediate_gets
                              + immediate_misses)
                         ,  3))
           as r
     ,  '---' || chr (10)
  from v$latch
 where name in ('redo allocation', 'redo copy')
/

set heading on

prompt misses/gets (must be < 1%)

--Redo allocation: (2'534'627 / 277'446'780) * 100 = 0.91 %
--Redo Copy: (27'694 / 33'818) * 100 = 81.8 %
--IMMEDIATE_MISSES/(IMMEDIATE_GETS+IMMEDIATE_MISSES) (must be < 1%)
--Redo Copy: 150'511/(150'511+357'613'861) = 0.04 %


ttitle  "Waits on Redo Log Buffer"  skip 1

column value format 999G999G999

select name, value
  from v$sysstat
 where name = 'redo log space requests'
/

prompt The value of 'redo log space requests' reflects the number of times a user process waits for space in the redo log buffer.
prompt Optimal is if the value is near 0

ttitle  "Size of one Redo Log Buffer in Bytes"  skip 1

select max (l.lebsz) log_block_size
  from sys.x$kccle l
 where l.inst_id = userenv ('Instance')
/

prompt

ttitle off

prompt