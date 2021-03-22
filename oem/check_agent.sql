--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:  check the Agent Settings on DB side
--==============================================================================
-- docu
-- Database metrics, e.g.Tablespace Full(%), not clearing in Grid Control even though they are no longer present in dba_outstanding_alerts (Doc ID 455222.1)
--
--==============================================================================
set verify off
set linesize 130 pagesize 300 recsep off

set serveroutput on size 1000000

ttitle left "Check the rights to AQ for the OEM_MONITOR Role " skip 2

select GRANTOR
       ,  grantee
       ,  PRIVILEGE
       ,  table_name
    from DBA_TAB_PRIVS
   where     grantee like upper ('OEM_MONITOR')
         and GRANTOR = 'SYS'
         and table_name like '%Q%'
order by table_name
/

prompt ...
prompt ... check for ALERT_QUE ,  DBMS_AQ , DBMS_AQADM
prompt ... if not grant the rights to the OEM_MONITOR Role
prompt ...
prompt

ttitle left "Check the rights to this Role " skip 2

select grantee, default_role
  from dba_role_privs
 where granted_role = 'OEM_MONITOR'
/

prompt


ttitle left "Check the registered Agents to this database " skip 2

column AGENT_NAME format a40
column PROTOCOL format 999
column SPARE1 format a40

  select AGENT_NAME, PROTOCOL, nvl (SPARE1, 'null') as SPARE1
    from system.AQ$_INTERNET_AGENTS
order by 1
/

prompt ...
prompt ... check for agents with old severnames or old instance names
prompt ...
prompt

ttitle left "Check the Subscriber to the SYS.ALERT_QUE" skip 2

-- Auflisten der Subscriber für die Queues
--

declare
   subs    dbms_aqadm.aq$_subscriber_list_t;
   nsubs   binary_integer;
   i       binary_integer;
begin
   subs := dbms_aqadm.queue_subscribers (queue_name => 'SYS.ALERT_QUE');
   nsubs := subs.count;
   dbms_output.put_line ('Subscriber to the SYS.ALERT_QUE Queue:');
   dbms_output.put_line ('----------------');

   for i in 0 ..
              nsubs
            - 1
   loop
      dbms_output.put_line (rpad (subs (i).name, 30, ' ') || ' with adress : ' || subs (i).address);
   end loop;
end;
/

prompt ...
prompt ...  to unsubscribe use
prompt ...  set serveroutput on size 1000000
prompt ...  exec DBMS_AQADM.REMOVE_SUBSCRIBER (  queue_name =>'SYS.ALERT_QUE', subscriber  =>  SYS.AQ$_AGENT ('OLDSERVER_3872_<OLDDB>', NULL, NULL));
prompt
prompt
prompt ...
prompt ... to purge the queue use:
prompt ...
prompt  declare
prompt      v_po_t dbms_aqadm.aq$_purge_options_t;
prompt  begin
prompt     dbms_aqadm.purge_queue_table( queue_table =>'SYS.ALERT_QT', purge_condition => null, purge_options =>v_po_t );
prompt     commit;
prompt  end;
prompt ...
prompt



ttitle off