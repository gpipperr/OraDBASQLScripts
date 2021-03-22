--==============================================================================
-- GPI - Gunther Pippèrr
-- get all Targets on a host
--==============================================================================
set verify off
set linesize 130 pagesize 300 recsep off

define HOST_NAME  = '&1'

prompt
prompt Parameter 1 =  Host Name => &&HOST_NAME.
prompt

set long 100


column target_name   format a53 heading "Target|Name"
column host_name     format a32 heading "Host|Name"
column entity_type   format a15 heading "Target|Type"
column manage_status format a10 heading "Mon|Status"
column location      format a40 heading "Install|OHome"

  select e.host_name
       ,  e.entity_name as target_name
       ,  e.entity_type
       ,  decode (e.manage_status,  1, '-> Candi.',  2, 'Monit.',  0, '-Disab.',  e.manage_status) as manage_status
       --, e.promote_status
       ,  nvl (p.property_value, p2.property_value) as location
    from mgmt$manageable_entities e, mgmt$target_properties p, mgmt$target_properties p2
   where     e.host_name like ('&&HOST_NAME.%')
         and p.property_name(+) = 'INSTALL_LOCATION'
         and p.target_guid(+) = e.ENTITY_GUID
         and p2.property_name(+) = 'OracleHome'
         and p2.target_guid(+) = e.ENTITY_GUID
-- and entity_type='oracle_home'
order by e.host_name
       ,  e.entity_type
       ,  e.entity_name
       ,  e.promote_status
       ,  e.manage_status
/