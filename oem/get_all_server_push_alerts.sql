--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: get all metrics that are DB server defined
--
--==============================================================================
set verify off
set linesize 130 pagesize 300 recsep off

select distinct met.column_label
  from (select distinct metric_guid
                      ,  target_type
                      ,  metric_name
                      ,  metric_column
                      ,  column_label
          from mgmt_metrics
         where target_type in ('oracle_database', 'rac_database')) met
     ,  mgmt_metric_thresholds thresh
     ,  mgmt_targets target
 where     thresh.metric_guid = met.metric_guid
       and target.target_guid = thresh.target_guid
       and thresh.is_push = 1;