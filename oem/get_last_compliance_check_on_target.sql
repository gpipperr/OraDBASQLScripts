--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: get the times the compliance rules for a target are checked
--==============================================================================
set verify off
set linesize 130 pagesize 300 recsep off

define TARGET_NAME  = '&1'

prompt
prompt Parameter 1 =  TARGET_NAME => &&TARGET_NAME.
prompt

select root_cs_name "Compliance Standard"
       ,  parent_cs_name "Parent Compliance Standard"
       ,  rule_name "Rule Name"
       ,  root_target_name "Target Name"
       ,  root_target_type "Target Type"
       ,  compliance_score "Compliance Score"
       ,  last_evaluation_date "Last Evaluation Date"
    from mgmt$cs_rule_eval_summary
   where root_target_name = '&TARGET_NAME.'
order by last_evaluation_date desc
/