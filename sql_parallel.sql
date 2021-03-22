--==============================================================================
-- see also:
--  Oracle Support Document 444164.1 (Tracing Parallel Execution with _px_trace. Part I) 
--  can be found at: https://support.oracle.com/epmos/faces/DocumentDisplay?id=444164.1
--  https://docs.oracle.com/cd/E18283_01/server.112/e16541/parallel006.htm#CIHGJFFC
--==============================================================================
set verify off
set linesize 130 pagesize 300 

define SQL_ID='&1'

prompt
prompt Parameter 1 = SQL ID     => &&SQL_ID.
prompt

column username     format a12
column "QC SID"     format A6
column "SID"        format A6
column "QC/Slave"   format A8
column "Req. DOP"   format 9999
column "Actual DOP" format 9999
column "Slaveset"   format A8
column "Slave INST" format A9
column "QC INST"    format A6
column wait_event   format a30

ttitle left  "User and his Parallel sessions" skip 2


select decode (px.qcinst_id
               ,  null, username
               ,     ' - '
                  || lower (substr (pp.server_name
                                  ,    length (pp.server_name)
                                     - 4
                                  ,  4)))
            "Username"
       ,  decode (px.qcinst_id, null, 'QC', '(Slave)') "QC/Slave"
       ,  to_char (px.server_set) "SlaveSet"
       ,  to_char (s.sid) "SID"
       ,  to_char (px.inst_id) "Slave INST"
       ,  decode (sw.state, 'WAITING', 'WAIT', 'NOT WAIT') as state
       ,  case sw.state when 'WAITING' then substr (sw.event, 1, 30) else null end as wait_event
       ,  decode (px.qcinst_id, null, to_char (s.sid), px.qcsid) "QC SID"
       ,  to_char (px.qcinst_id) "QC INST"
       ,  px.req_degree "Req. DOP"
       ,  px.degree "Actual DOP"
       ,  s.sql_id
    from gv$px_session px
       ,  gv$session s
       ,  gv$px_process pp
       ,  gv$session_wait sw
   where     px.sid = s.sid(+)
         and px.serial# = s.serial#(+)
         and px.inst_id = s.inst_id(+)
         and px.sid = pp.sid(+)
         and px.serial# = pp.serial#(+)
         and sw.sid = s.sid
         and sw.inst_id = s.inst_id
         and s.sql_id like '&&SQL_ID.'
order by decode (px.qcinst_id, null, px.inst_id, px.qcinst_id)
       ,  px.qcsid
       ,  decode (px.server_group, null, 0, px.server_group)
       ,  px.server_set
       ,  px.inst_id
/


column wait_event format a30

ttitle left  "Waits  this SQL &&SQL_ID. " skip 2

select sw.sid as rcvsid
       ,  decode (pp.server_name, null, 'A QC', pp.server_name) as rcvr
       ,  sw.inst_id as rcvrinst
       ,  case sw.state when 'WAITING' then substr (sw.event, 1, 30) else null end as wait_event
       ,  decode (bitand (sw.p1, 65535), 65535, 'QC', 'P' || to_char (bitand (sw.p1, 65535), 'fm000')) as sndr
       ,    bitand (sw.p1, 16711680)
          - 65535
             as sndrinst
       ,  decode (bitand (sw.p1, 65535)
                ,  65535, ps.qcsid
                ,  (select sid
                      from gv$px_process
                     where     server_name = 'P' || to_char (bitand (sw.p1, 65535), 'fm000')
                           and inst_id =   bitand (sw.p1, 16711680)
                                         - 65535))
             as sndrsid
       ,  decode (sw.state, 'WAITING', 'WAIT', 'NOT WAIT') as state
    from gv$session_wait sw
       ,  gv$px_process pp
       ,  gv$px_session ps
       ,  gv$session s
   where     sw.sid = pp.sid(+)
         and sw.inst_id = pp.inst_id(+)
         and sw.sid = ps.sid(+)
         and sw.inst_id = ps.inst_id(+)
         and sw.p1text = 'sleeptime/senderid'
         and bitand (sw.p1, 268435456) = 268435456
         and s.sql_id like '&&SQL_ID.'
         and sw.sid = s.sid
         and sw.inst_id = s.inst_id
order by decode (ps.qcinst_id, null, ps.inst_id, ps.qcinst_id)
       ,  ps.qcsid
       ,  decode (ps.server_group, null, 0, ps.server_group)
       ,  ps.server_set
       ,  ps.inst_id
/


column "Username"       format a12 heading "Username"
column "QC/Slave"       format A8  heading "QCSlave"
column "Slaveset"       format A8  heading "Slave|set"
column "Slave INST"     format A9  heading "Slave|INST"
column "QC SID"         format A6  heading "QC|SID"
column "QC INST"        format A6  heading "QC|INST"
column "operation_name" format A25 heading "Operation|name"
column "target"         format A20 heading "Target"


ttitle left  "Long Ops for this SQL &&SQL_ID. " skip 2


select decode (px.qcinst_id
               ,  null, s.username
               ,     ' - '
                  || lower (substr (pp.server_name
                                  ,    length (pp.server_name)
                                     - 4
                                  ,  4)))
            "Username"
       ,  decode (px.qcinst_id, null, 'QC', '(Slave)') "QC/Slave"
       ,  to_char (px.server_set) "SlaveSet"
       ,  to_char (px.inst_id) "Slave INST"
       ,  substr (s.opname, 1, 30) operation_name
       ,  substr (s.target, 1, 30) target
       ,  s.sofar
       ,  s.totalwork
       ,    s.totalwork
          - s.sofar
             as openwork
       ,  s.units
       ,  s.start_time
       ,  s.timestamp
       ,  decode (px.qcinst_id, null, to_char (s.sid), px.qcsid) "QC SID"
       ,  to_char (px.qcinst_id) "QC INST"
    from gv$px_session px
       ,  gv$px_process pp
       ,  gv$session_longops s
       ,  gv$session se
   where     px.sid = s.sid
         and px.serial# = s.serial#
         and px.inst_id = s.inst_id
         and px.sid = pp.sid(+)
         and px.serial# = pp.serial#(+)
         and pp.inst_id = s.inst_id
         and se.sql_id like '&&SQL_ID.'
         and s.sid = se.sid
         and s.inst_id = se.inst_id
order by decode (px.qcinst_id, null, px.inst_id, px.qcinst_id)
       ,  px.qcsid
       ,  decode (px.server_group, null, 0, px.server_group)
       ,  px.server_set
       ,  px.inst_id
/

ttitle off
