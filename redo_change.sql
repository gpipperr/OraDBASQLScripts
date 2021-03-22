--==============================================================================
-- Desc:   who create how much redo per day last 7 in the database
-- Date:   November 2013
--==============================================================================
-- Src:    http://www.mydbspace.com/?p=173
--==============================================================================
prompt
prompt !!!!You need the Tuning Pack for this feature!!!!
prompt
set linesize 130 pagesize 300 

column mb_day_total   format 999G999G999G999D999
column change_percent format 999D99
column mb_per_user_change    format 999G999G999D99

column write_percent        format 999D99
column mb_per_user_write    format 999G999G999D99
column mb_per_user          format 999G999G999D99

column owner          format a20
column days           format a10


define USER_NAME='&1'

prompt
prompt Parameter 1 = User Name          => &&USER_NAME.
prompt

ttitle  "Percent Overview % for this user &&USER_NAME"  skip 1

with actions
     as (  select so.owner as owner
                ,  sum (ss.db_block_changes_delta) changes
                ,  sum (ss.PHYSICAL_WRITES_DELTA) writes
                ,  trunc (begin_interval_time) as days
             from dba_hist_seg_stat ss, dba_hist_seg_stat_obj so, dba_hist_snapshot sp
            where     sp.snap_id = ss.snap_id
                  and sp.instance_number = ss.instance_number
                  and ss.obj# = so.obj#
                  and ss.dataobj# = so.dataobj#
                  and begin_interval_time > trunc (  sysdate
                                                   - 7)
         group by so.owner, trunc (begin_interval_time))
  select to_char (a.days, 'dd.mm.yyyy') as days
       ,  r.size_mb mb_day_total
       --, round((a.changes / (t.changes_total / 100)), 2) change_percent
       --, round(r.size_mb * (a.changes / (t.changes_total / 1000)), 2) mb_per_user_change
       --, round((a.writes / (t.writes_total / 100)), 2) write_percent
       --, round(r.size_mb * (a.writes / (t.writes_total / 1000)), 2) mb_per_user_write
       ,  round (  (  (  a.writes
                       + a.changes)
                    * 100)
                 / (  t.writes_total
                    + t.changes_total)
               ,  2)
             write_change_percent
       ,  round (  r.size_mb
                 * (  (  (  (  a.writes
                             + a.changes)
                          * 100)
                       / (  t.writes_total
                          + t.changes_total))
                    / 100)
               ,  2)
             mb_per_user
       ,  a.owner
    from (  select trunc (completion_time) days
                 ,  round (  sum (  blocks
                                  * block_size)
                           / 1024
                           / 1024
                         ,  3)
                       size_mb
                 ,  DEST_ID
              from v$archived_log
             where completion_time > trunc (  sysdate
                                            - 7)
          group by (DEST_ID, trunc (completion_time))) r
       ,  actions a
       ,  (  select sum (ss.db_block_changes_delta) changes_total
                  ,  sum (ss.PHYSICAL_WRITES_DELTA) writes_total
                  ,  trunc (begin_interval_time) as days
               from dba_hist_seg_stat ss, dba_hist_seg_stat_obj so, dba_hist_snapshot sp
              where     sp.snap_id = ss.snap_id
                    and sp.instance_number = ss.instance_number
                    and ss.obj# = so.obj#
                    and ss.dataobj# = so.dataobj#
                    and begin_interval_time > trunc (  sysdate
                                                     - 7)
           group by trunc (begin_interval_time)) t
   where     r.days = a.days
         and t.days = r.days
         and a.owner like upper (nvl ('&&USER_NAME', '%'))
order by a.days, a.owner
/


ttitle  "Detail Segments Overview for this user &&USER_NAME"  skip 1

select *
  from (  select so.owner as owner
               ,  sum (ss.db_block_changes_delta) changes
               ,  sum (ss.PHYSICAL_WRITES_DELTA) writes
               ,  trunc (begin_interval_time) as days
               ,  so.OBJECT_NAME
            from dba_hist_seg_stat ss, dba_hist_seg_stat_obj so, dba_hist_snapshot sp
           where     sp.snap_id = ss.snap_id
                 and sp.instance_number = ss.instance_number
                 and ss.obj# = so.obj#
                 and ss.dataobj# = so.dataobj#
                 and begin_interval_time > trunc (  sysdate
                                                  - 7)
                 and so.owner like upper (nvl ('&&USER_NAME', '%'))
        group by so.owner, OBJECT_NAME, trunc (begin_interval_time)
        order by sum (ss.db_block_changes_delta) desc)
 where rownum < 30
/


ttitle off