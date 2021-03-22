--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:   version of the database
-- Date:   30.05.2019
--==============================================================================
set linesize 130 pagesize 300 


column VERSION_NO format a30 heading "APEX Version"

select version_no 
  from apex_release
/

column VERSION format a30 heading "APEX Version DB Registry"
column comp_name format a40
column status format a10

select version,comp_name,status 
  from dba_registry 
 where comp_name = 'Oracle Application Express'
/

column VERSION format a40 heading "ORDS Version"

select VERSION 
  from ORDS_METADATA.ords_version
/
