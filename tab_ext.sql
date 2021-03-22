--==============================================================================
-- GPI - Gunther Pippèrr
-- Show all external tables in the database
-- Must be run with dba privileges
--==============================================================================

set verify  off
set linesize 130 pagesize 300 

column  owner           format a20    heading "Owner"
column  table_name      format a20    heading "Table|Name"
column  location        format a30    heading "Location"
column  directory_owner format a3     heading "DO"
column  directory_name  format a20    heading "Directory|Name"

  select owner
       ,  table_name
       ,  location
       ,  directory_owner
       ,  directory_name
    from dba_external_locations
order by owner, table_name
/

prompt
prompt Details ...
prompt

column  reject_limit      format a20  heading "Reject|Limit"
column  access_type       format a20  heading "Access|Type"
column  property          format a10  heading "Property"
column  access_parameters format a80  heading "Access|Parameter" fold_before word_wrapped


break on row skip 2

ttitle 'Detail of the external Tables :'

set long 64000

  select table_name
       ,  reject_limit
       ,  access_type
       ,  property
       ,  access_parameters
    from dba_external_tables
order by owner, table_name
/


clear break

ttitle off