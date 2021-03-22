--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc:   DB Links DDL
--==============================================================================

set linesize 130 pagesize 300 

set long 1000000

ttitle left  "create DDL for all DB Links in the Database" skip 2

select '-- DBLINK OWNER : '||owner||chr(10)||chr(13)||dbms_metadata.get_ddl('DB_LINK',db_link,owner ) ||';'||chr(10)||chr(13) as stmt
  from dba_db_links 
--where upper(HOST) like '%GPI%'
/
 

 -- fix it to plsql block to use parameter
-- set the transformation attributes
--	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY',             true );
--	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR',      true );
--	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'REF_CONSTRAINTS',    false);
--	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'OID',                false);
--	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'SEGMENT_ATTRIBUTES', false);
--	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'TABLESPACE',         true );


 
ttitle off

