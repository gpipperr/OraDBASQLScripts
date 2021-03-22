--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   SQL Script Locks overview
-- Date:   2012
--
--==============================================================================
set verify off
set linesize 130 pagesize 300 
set echo off

ttitle left "Lock Overview in the database" skip 2

column obj_name       format a16 heading "Locked|Object"

column orauser        format a14 heading "Oracle|Username"
column os_user_name   format a14 heading "O/S|Username"

column ss       format a12 heading "SID:Ser#"
column time     format a16 heading "Logon|Date/Time" 
column procid   format a10 heading "Process|ID"
column machine  format a15 heading "PC Name|User"
column logMod   format 9   heading "=> 6|blocker!"


select owner || '.' || object_name as obj_name
       ,  oracle_username || ' (' || s.status || ')' as orauser
       ,  os_user_name
       ,  machine
       ,  l.process as procid
       ,  lc.inst_id
       ,  s.sid || ',' || s.serial# as ss
       ,  to_char (s.logon_time, 'dd.mm.yyyy hh24:mi') time
       --,l.LOCKED_MODE as logMod
       ,  lc.lmode logMod
    from gv$locked_object l
       ,  dba_objects o
       ,  gv$session s
       ,  gv$transaction t
       ,  gv$lock lc
   where     l.object_id = o.object_id
         and s.sid = l.session_id
         and s.inst_id = l.inst_id
         and s.taddr = t.addr(+)
         and s.inst_id = t.inst_id(+)
         and s.sid = lc.sid
         and lc.type = 'TX'
         and s.inst_id = lc.inst_id
order by oracle_username
       ,  ss
       ,  obj_name
       ,  s.logon_time
/

ttitle off

/* Query OMS Metrik 
with blocked_resources
     as (  select id1
                ,  id2
                ,  sum (ctime) as blocked_secs
                ,  max (request) as max_request
                ,  count (1) as blocked_count
             from v$lock
            where request > 0
         group by id1, id2)
   ,  blockers
     as (select l.*, br.blocked_secs, br.blocked_count
           from v$lock l, blocked_resources br
          where     br.id1 = l.id1
                and br.id2 = l.id2
                and l.lmode > 0
                and l.block <> 0)
select b.id1 || '_' || b.id2 || '_' || s.sid || '_' || s.serial# as id
     ,     'SID,SERIAL:'
        || s.sid
        || ','
        || s.serial#
        || ',LOCK_TYPE:'
        || b.type
        || ',PROGRAM:'
        || s.program
        || ',MODULE:'
        || s.module
        || ',ACTION:'
        || s.action
        || ',MACHINE:'
        || s.machine
        || ',OSUSER:'
        || s.osuser
        || ',USERNAME:'
        || s.username
           as info
     ,  b.blocked_secs
     ,  b.blocked_count
  from v$session s, blockers b
 where b.sid = s.sid
*/
