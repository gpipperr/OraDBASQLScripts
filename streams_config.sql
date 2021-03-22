--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: streams configuration
--==============================================================================
-- http://docs.oracle.com/cd/E11882_01/server.112/e10705/man_gen_rep.htm#STREP013
--==============================================================================
set verify off
set linesize 130 pagesize 300 

column capture_name             heading 'capture|process|name' format a20
column rule_set_owner           heading 'positive|rule owner'  format a15
column rule_set_name            heading 'positive|rule set'    format a15
column negative_rule_set_owner  heading 'negative|rule owner'  format a15
column negative_rule_set_name   heading 'negative|rule set'    format a15

column apply_name              heading 'apply|process|name'  format a20
column rule_set_owner          heading 'positive|rule owner' format a15
column rule_set_name           heading 'positive|rule set'   format a15
column negative_rule_set_owner heading 'negative|rule owner' format a15
column negative_rule_set_name  heading 'negative|rule set'   format a15


break on  capture_name

select capture_name
     ,  rule_set_owner
     ,  rule_set_name
     ,  negative_rule_set_owner
     ,  negative_rule_set_name
  from dba_capture
/

select * from dba_capture_parameters
/

select apply_name
     ,  rule_set_owner
     ,  rule_set_name
     ,  negative_rule_set_owner
     ,  negative_rule_set_name
  from dba_apply
/


column PARAMETER format a26
column VALUE     format a30
column SET_BY_USER format a3

break on  APPLY_NAME

select APPLY_NAME
     ,  PARAMETER
     ,  value
     ,  SET_BY_USER
  from dba_apply_parameters
/

clear break