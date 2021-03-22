--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc:  Show the DB Properies of this database
-- Parameter 1: Name of the property
--
-- Must be run with dba privileges
-- 
--
--==============================================================================
set verify  off
set linesize 130 pagesize 300 

define PROP_NAME = '&1'


prompt
prompt Parameter 1 = Property Name          => &&PROP_NAME.
prompt

column property_name      format a30 heading "Property Name" 
column value              format a40 heading "Value"


select property_name
    , substr(property_value, 1, 40) value
 from database_properties
where property_name like '&&PROP_NAME'
order by property_name
 /
 
 
 