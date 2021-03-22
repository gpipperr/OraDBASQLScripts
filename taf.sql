--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   check TAF - Transparent Application Fail over Connects to a database
--
--==============================================================================
set verify off
set linesize 130 pagesize 300 

column inst_id         format 99    heading "Inst|ID"
column username        format a20   heading "DB User|name"
column machine         format a30   heading "Remote|pc/server"
column connect_count   format 9G999 heading "Con|count"
column failover_type   format a6    heading "Fail|type"
column failover_method format a6    heading "Fail|method"
column failed_over     format a6    heading "Fail|over"
column service_name    format a20     heading "Service|Name"
column status          format a10


break on report
compute sum of connect_count on report

--BREAK ON inst_id skip 2
--COMPUTE SUM OF connect_count ON inst_id

  select inst_id
       ,  service_name
       ,  machine
       ,  username
       ,  status
       ,  failover_type
       ,  failover_method
       ,  failed_over
       ,  count (*) as connect_count
    from gv$session
   where username not in ('SYS', 'DBSNMP')
group by inst_id
       ,  machine
       ,  username
       ,  status
       ,  failover_type
       ,  failover_method
       ,  failed_over
       ,  service_name
order by machine, username
/

clear break