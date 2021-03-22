--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: Query the Oracle Health Monitor
-- Work in progress
--==============================================================================
-- see http://www.pipperr.de/dokuwiki/doku.php?id=dba:oracle_health_monitor
--==============================================================================
set linesize 130 pagesize 300 

column name format a40

select name 
  from v$hm_check
 where internal_check='N'
/   

column check_name format a40
column parameter_name format a20
column description format a40
column type format a15
column default_value format a20 heading "Default|value"

select c.name check_name
     , p.name parameter_name
     , p.type
     , p.default_value
     , p.description
 from v$hm_check_param p, v$hm_check c
where p.check_id = c.id 
  and c.internal_check = 'N'
order by c.name
/

prompt ... Example for call
prompt ...
prompt ... BEGIN
prompt ... DBMS_HM.RUN_CHECK (
prompt ...   check_name   => 'Transaction Integrity Check',
prompt ...   run_name     => 'MY__RUN_NAME',
prompt ...   input_params => 'TXN_ID=8.66.2');
prompt ... END;
prompt ...


/*
    V$HM_RUN
    V$HM_FINDING
    V$HM_RECOMMENDATION
*/