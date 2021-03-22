--==============================================================================
-- GPI - Gunther Pippèrr
-- get the Oracle Home of a target
--==============================================================================
set verify off
set linesize 130 pagesize 300 recsep off

define TARGET_NAME  = '&1'

prompt
prompt Parameter 1 =  Target Name of the Oracle Home=> &&TARGET_NAME.
prompt

set verify off

set long 100

column property_name      format a11 heading "Property|Name"
column target_name        format a35 heading "Target|Name"
column home_dir           format a25 heading "OHome|Dir"
column target_dir         format a25 heading "Target|Dir"
column oracle_home_target format a60 heading "OHome |T-Name"
column target_guid        format a32 heading "Target|Guid"
column ENTITY_TYPE        format a16 heading "Target|Type"

  select  --  t.entity_guid target_guid
         -- ,
         t.ENTITY_TYPE
       ,  t.ENTITY_NAME as Target_name
       --, q.property_name
       --, ta.target_name as Target_name
       ,  rtrim (q.property_value, '/') target_dir
       ,  th.target_name as oracle_home_target
       ,  rtrim (p.property_value, '/') home_dir
    from em_manageable_entities t
       ,  mgmt_target_properties q
       ,  mgmt_assoc_instances i
       ,  em_manageable_entities h
       ,  mgmt_target_properties p
       ,  mgmt$target ta
       ,  mgmt$target th
   where     t.manage_status = 2
     and t.broken_reason = 0
     and ta.target_guid(+) = t.entity_guid
     and th.target_guid = h.entity_guid
     and t.emd_url is not null
     and t.entity_type != 'oracle_home'
     and t.entity_type != 'host'
     and t.entity_guid = q.target_guid
     and q.property_name = 'OracleHome'
     and i.source_me_guid = t.entity_guid
     and i.assoc_type = 'installed_at'
     and i.dest_me_guid = h.entity_guid
     and h.entity_type = 'oracle_home'
     and p.target_guid = h.entity_guid
     and p.property_name = 'INSTALL_LOCATION'
     and lower (th.target_name) like lower ('&&TARGET_NAME.%')
order by t.ENTITY_NAME
/
	