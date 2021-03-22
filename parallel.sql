--==============================================================================
-- Desc: parallel SQL informations
--==============================================================================
-- see also: 
--  Oracle Support Document 444164.1 (Tracing Parallel Execution with _px_trace. Part I) 
--  can be found at: https://support.oracle.com/epmos/faces/DocumentDisplay?id=444164.1
--  https://docs.oracle.com/cd/E18283_01/server.112/e16541/parallel006.htm#CIHGJFFC
--==============================================================================
set linesize 130 pagesize 300 


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
                  || lower (substr (pp.SERVER_NAME
                                  ,    length (pp.SERVER_NAME)
                                     - 4
                                  ,  4)))
            "Username"
       ,  decode (px.qcinst_id, null, 'QC', '(Slave)') "QC/Slave"
       ,  to_char (px.server_set) "SlaveSet"
       ,  to_char (s.sid) "SID"
       ,  to_char (px.inst_id) "Slave INST"
       ,  decode (sw.state, 'WAITING', 'WAIT', 'NOT WAIT') as STATE
       ,  case sw.state when 'WAITING' then substr (sw.event, 1, 30) else null end as wait_event
       ,  decode (px.qcinst_id, null, to_char (s.sid), px.qcsid) "QC SID"
       ,  to_char (px.qcinst_id) "QC INST"
       ,  px.req_degree "Req. DOP"
       ,  px.degree "Actual DOP"
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
order by decode (px.QCINST_ID, null, px.INST_ID, px.QCINST_ID)
       ,  px.QCSID
       ,  decode (px.SERVER_GROUP, null, 0, px.SERVER_GROUP)
       ,  px.SERVER_SET
       ,  px.INST_ID
/


column wait_event format a30

select sw.SID as RCVSID
       ,  decode (pp.server_name, null, 'A QC', pp.server_name) as RCVR
       ,  sw.inst_id as RCVRINST
       ,  case sw.state when 'WAITING' then substr (sw.event, 1, 30) else null end as wait_event
       ,  decode (bitand (p1, 65535), 65535, 'QC', 'P' || to_char (bitand (p1, 65535), 'fm000')) as SNDR
       ,    bitand (p1, 16711680)
          - 65535
             as SNDRINST
       ,  decode (bitand (p1, 65535)
                ,  65535, ps.qcsid
                ,  (select sid
                      from gv$px_process
                     where     server_name = 'P' || to_char (bitand (sw.p1, 65535), 'fm000')
                           and inst_id =   bitand (sw.p1, 16711680)
                                         - 65535))
             as SNDRSID
       ,  decode (sw.state, 'WAITING', 'WAIT', 'NOT WAIT') as STATE
    from gv$session_wait sw, gv$px_process pp, gv$px_session ps
   where     sw.sid = pp.sid(+)
         and sw.inst_id = pp.inst_id(+)
         and sw.sid = ps.sid(+)
         and sw.inst_id = ps.inst_id(+)
         and p1text = 'sleeptime/senderid'
         and bitand (p1, 268435456) = 268435456
order by decode (ps.QCINST_ID, null, ps.INST_ID, ps.QCINST_ID)
       ,  ps.QCSID
       ,  decode (ps.SERVER_GROUP, null, 0, ps.SERVER_GROUP)
       ,  ps.SERVER_SET
       ,  ps.INST_ID
/


column "Username"       format a12
column "QC/Slave"       format A8
column "Slaveset"       format A8
column "Slave INST"     format A9
column "QC SID"         format A6
column "QC INST"        format A6
column "operation_name" format A30
column "target"         format A30

select decode (px.qcinst_id
               ,  null, username
               ,     ' - '
                  || lower (substr (pp.SERVER_NAME
                                  ,    length (pp.SERVER_NAME)
                                     - 4
                                  ,  4)))
            "Username"
       ,  decode (px.qcinst_id, null, 'QC', '(Slave)') "QC/Slave"
       ,  to_char (px.server_set) "SlaveSet"
       ,  to_char (px.inst_id) "Slave INST"
       ,  substr (opname, 1, 30) operation_name
       ,  substr (target, 1, 30) target
       ,  sofar
       ,  totalwork
       ,  units
       ,  start_time
       ,  timestamp
       ,  decode (px.qcinst_id, null, to_char (s.sid), px.qcsid) "QC SID"
       ,  to_char (px.qcinst_id) "QC INST"
    from gv$px_session px, gv$px_process pp, gv$session_longops s
   where     px.sid = s.sid
         and px.serial# = s.serial#
         and px.inst_id = s.inst_id
         and px.sid = pp.sid(+)
         and px.serial# = pp.serial#(+)
order by decode (px.QCINST_ID, null, px.INST_ID, px.QCINST_ID)
       ,  px.QCSID
       ,  decode (px.SERVER_GROUP, null, 0, px.SERVER_GROUP)
       ,  px.SERVER_SET
       ,  px.INST_ID
/

ttitle off