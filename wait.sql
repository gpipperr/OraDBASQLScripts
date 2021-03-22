--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:  show the actual wait of the database 
--==============================================================================
set linesize 130 pagesize 300 

ttitle  "Report waiting Sessions"  skip 2

column snap         format a16
column client_info  format a30
column MODULE       format a20
column username     format a10 heading "User|name"

column program      format a20
column state        format a20
column event        format a15
column last_sql     format a20
column sec          format 99999 heading "Wait|sec"
column inst         format 9     heading "Inst"
column ss       format a10 heading "SID:Ser#"

select                                                                                             /* gpi script lib wait.sql */
         --to_char(sysdate, 'dd.mm.yyyy hh24:mi') as snap
         --,
         sw.inst_id as inst
       ,  s.sid || ',' || s.serial# as ss
       --,s.client_info
       --,s.MODULE
       ,  s.username
       --,s.program
       --,sw.state
       ,  sw.event
       ,  sw.seconds_in_wait sec
       ,  sw.p1
       ,  sw.p2
       ,  sw.p3
       ,  sa.sql_text last_sql
    from gv$session_wait sw, gv$session s, gv$sqlarea sa
   where     sw.event not in
                ('rdbms ipc message'
               ,  'smon timer'
               ,  'pmon timer'
               ,  'SQL*Net message from client'
               ,  'lock manager wait for remote message'
               ,  'ges remote message'
               ,  'client message'
               ,  'pipe get'
               ,  'Null event'
               ,  'PX Idle Wait'
               ,  'single-task message'
               ,  'PX Deq: Execution Msg'
               ,  'KXFQ: kxfqdeq - normal deqeue'
               ,  'listen endpoint status'
               ,  'slave wait'
               ,  'wakeup time manager'
               ,  'jobq slave wait'
               ,  'Space Manager: slave idle wait'
               ,  'Streams AQ: qmn coordinator idle wait'
               ,  'Streams AQ: qmn slave idle wait'
               ,  'Streams AQ: qmn slave idle wait or cleanup tasks'
               ,  'Streams AQ: waiting for time management or cleanup tasks'
               ,  'VKRM Idle'
               ,  'VKTM Logical Idle Wait'
               ,  'DIAG idle wait')
     and sw.seconds_in_wait > 0
     and sw.inst_id = s.inst_id
     and sw.sid = s.sid
     and s.inst_id = sa.inst_id
     and s.sql_address = sa.address
order by sw.seconds_in_wait desc
/

ttitle  "Event Description"  skip 2

column event  format a40
column p1text format a18
column p2text format a18
column p3text format a18

select distinct sw.event
                ,  sw.p1text
                ,  sw.p2text
                ,  sw.p3text
    from gv$session_wait sw, gv$session s
   where     sw.event not in
            ('rdbms ipc message'
           ,  'smon timer'
           ,  'pmon timer'
           ,  'SQL*Net message from client'
           ,  'lock manager wait for remote message'
           ,  'ges remote message'
           ,  'client message'
           ,  'pipe get'
           ,  'Null event'
           ,  'PX Idle Wait'
           ,  'single-task message'
           ,  'PX Deq: Execution Msg'
           ,  'KXFQ: kxfqdeq - normal deqeue'
           ,  'listen endpoint status'
           ,  'slave wait'
           ,  'wakeup time manager'
           ,  'jobq slave wait'
           ,  'Space Manager: slave idle wait'
           ,  'Streams AQ: qmn coordinator idle wait'
           ,  'Streams AQ: qmn slave idle wait'
           ,  'Streams AQ: qmn slave idle wait or cleanup tasks'
           ,  'Streams AQ: waiting for time management or cleanup tasks'
           ,  'VKRM Idle'
           ,  'VKTM Logical Idle Wait'
           ,  'DIAG idle wait')
     and sw.seconds_in_wait > 0
     and (    sw.inst_id = s.inst_id
              and sw.sid = s.sid)
order by event
/