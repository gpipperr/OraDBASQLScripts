--==============================================================================
-- GPI -  Gunther Pippèrr 
-- Desc:  Show the relation between job windows , job classes and resource plans
--===============================================================================
set linesize 130 pagesize 300 

column job_class_name    format a25
column job_class_service format a25
column resource_plan     format a28
column consumer_group    format a25
column job_window        format a20


select jc.job_class_name
       ,  jc.service as job_class_service
       ,  cg.consumer_group
       ,  pd.plan as resource_plan
       ,  sw.window_name as job_window
    from dba_scheduler_job_classes jc
       ,  dba_rsrc_consumer_groups cg
       ,  dba_rsrc_plan_directives pd
       ,  dba_scheduler_windows sw
       ,  DBA_RSRC_GROUP_MAPPINGS gm
   where     jc.resource_consumer_group = cg.consumer_group
         and cg.consumer_group = pd.group_or_subplan(+)
         and sw.resource_plan(+) = pd.group_or_subplan
order by 1
/


select jc.job_class_name
       ,  jc.service as job_class_service
       ,  pd.group_or_subplan
       ,  pd.plan as resource_plan
    from dba_scheduler_job_classes jc, dba_rsrc_plan_directives pd, DBA_RSRC_GROUP_MAPPINGS gm
   where     gm.CONSUMER_GROUP = pd.group_or_subplan
         and gm.ATTRIBUTE = 'SERVICE_NAME'
         and gm.value = jc.service
order by 1
/

select jc.job_class_name
       ,  jc.service as job_class_service
       ,  cg.consumer_group
       ,  p.plan as resource_plan
       ,  sw.window_name as job_window
    from dba_rsrc_consumer_groups cg
       ,  dba_rsrc_plan_directives pd
       ,  dba_rsrc_plans p
       ,  dba_scheduler_job_classes jc
       ,  dba_scheduler_windows sw
   where     jc.resource_consumer_group = cg.consumer_group
         and cg.consumer_group = pd.group_or_subplan
         and p.plan = pd.plan
         and pd.type = 'CONSUMER_GROUP'
         and sw.resource_plan(+) = p.plan
order by jc.job_class_name
/