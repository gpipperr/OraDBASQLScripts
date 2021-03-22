--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: Resoruce Manager settings
--==============================================================================
-- http://docs.oracle.com/cd/E11882_01/server.112/e17120/dbrm.htm#ADMIN027
-- Script to monitor PX limits from Resource Manager for active sessions (Doc ID 240877.1)
--http://docs.oracle.com/cd/B28359_01/server.111/b28310/dbrm009.htm#ADMIN11906
--==============================================================================
set linesize 130 pagesize 300 

prompt .... Viewing Consumer Groups Granted to Users or Roles

select grantee
       ,  granted_group
       ,  grant_option
       ,  initial_group
    from dba_rsrc_consumer_group_privs
order by grantee
/

prompt .. Viewing Plan Schema Information

column plan          format a27 heading "Plan"
column status        format a10 heading "Status"
column comments      format a100 heading "Comment" word_wrapped
column cpu_method    format a10 heading "CPU_METHOD"
column mgmt_method   format a10 heading "CPU_METHOD"
column parallel      format a20 fold_after

select plan
       ,  status
       ,  cpu_method
       ,  mgmt_method
       ,  parallel_degree_limit_mth as parallel
       ,  comments
    from dba_rsrc_plans
order by status
/


prompt .. show user waiting with resource limit

select inst_id
     ,  sid
     ,  serial#
     ,  username
     ,  resource_consumer_group
  from gv$session
 where event like 'resmgr%'
/


prompt .. show user resource limits

select s.inst_id
       --, s.SID
       --, s.SERIAL#
       ,  count (*)
       ,  s.username
       ,  rpd.plan
       ,  s.RESOURCE_CONSUMER_GROUP
       ,  rpd.PARALLEL_DEGREE_LIMIT_P1
    from Gv$session s
       ,  DBA_RSRC_CONSUMER_GROUPS rcg
       ,  DBA_RSRC_PLAN_DIRECTIVES rpd
       ,  GV$RSRC_CONSUMER_GROUP vcg
   where     s.RESOURCE_CONSUMER_GROUP is not null
         and rcg.CONSUMER_GROUP = s.RESOURCE_CONSUMER_GROUP
         --and rcg.status = 'ACTIVE'
         and rpd.GROUP_OR_SUBPLAN = rcg.CONSUMER_GROUP
         --and rpd.status = 'ACTIVE'
         and vcg.name = s.RESOURCE_CONSUMER_GROUP
         and s.inst_id = vcg.inst_id
group by s.inst_id
       ,  s.username
       ,  rpd.plan
       ,  s.RESOURCE_CONSUMER_GROUP
       ,  rpd.PARALLEL_DEGREE_LIMIT_P1
order by 1, 3
/




	
	






