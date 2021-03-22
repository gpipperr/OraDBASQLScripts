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

column orig_locatoin      format a25 heading "Orignal|OHome"
column target_name        format a56 heading "Target|Name"
column snap_location      format a25 heading "Snap|OHome"
column target_dir         format a25 heading "Target|Dir"
column is_current         format a2  heading "C|R"
column target_guid        format a32 heading "Target|Guid"
column start_timestamp    format a18 heading "Snap|Time"

select p.target_name
       ,  p1.property_value as orig_locatoin
       ,  i.location as snap_location
       ,  case when p1.property_value = i.location then 'OK' else 'WRONG' end as testresult
       ,  s.is_current
       ,  to_char (s.start_timestamp, 'dd.mm.yyyy hh24:mi') as start_timestamp
    from MGMT_LL_HOME_INFO i
       ,  mgmt$target_properties p
       ,  mgmt$target_properties p1
       ,  mgmt_ecm_gen_snapshot s
   where     p.property_name = 'HOME_GUID'
     and p.property_value = i.oui_home_guid
     and p1.property_name = 'INSTALL_LOCATION'
     and p1.target_guid = p.target_guid
     and s.snapshot_type = 'oracle_home_config'
     and s.snapshot_guid = i.ecm_snapshot_id
     and s.target_guid = p.target_guid
     and lower (p.target_name) like lower ('&&TARGET_NAME.%')
order by s.is_current, p.target_name
/

prompt Check over all targets

select *
    from (select p.target_name
               ,  p1.property_value as orig_locatoin
               ,  i.location as snap_location
               ,  case when p1.property_value = i.location then 'OK' else 'WRONG' end as testresult
               ,  s.is_current
               ,  to_char (s.start_timestamp, 'dd.mm.yyyy hh24:mi') as start_timestamp
            from MGMT_LL_HOME_INFO i
               ,  mgmt$target_properties p
               ,  mgmt$target_properties p1
               ,  mgmt_ecm_gen_snapshot s
           where     p.property_name = 'HOME_GUID'
             and p1.property_name = 'INSTALL_LOCATION'
             and p1.target_guid = p.target_guid
             and s.snapshot_type = 'oracle_home_config'
             and s.snapshot_guid = i.ecm_snapshot_id
             and s.target_guid = p.target_guid 
		  -- and lower(p.target_name) like lower('&&TARGET_NAME.%')
         )
   where testresult = 'WRONG'
order by is_current, target_name
/
