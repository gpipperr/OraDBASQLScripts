--==============================================================================
-- GPI - Gunther Pippèrr
-- desc get all deployed target types in the Repository
--==============================================================================
set verify off
set linesize 130 pagesize 300 recsep off

prompt
prompt get all target types in the OEM Repostiory with a target
prompt 

column target_type format a40 heading "Target Types"
column tg_count    format 9G999 heading "Count of|targets"

select target_type
     , count(*) as tg_count
 from sysman.em_targets 
 group by target_type
/

