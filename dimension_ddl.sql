--==============================================================================
-- GPI -  Gunther Pippèrr
-- Desc:   DB Links DDL
--==============================================================================
set linesize 250 pagesize 3000 

define USER_NAME = &1 

set long 1000000

ttitle left  "create DDL for all DIMENSION of this user &&USER_NAME. " skip 2

select '-- DIMENSION OWNER : '||owner||chr(10)||chr(13)||dbms_metadata.get_ddl('DIMENSION',object_name,owner ) ||';'||chr(10)||chr(13) as stmt
 from dba_objects 
where object_type='DIMENSION'
  and owner=upper('&&USER_NAME.')
 /

-- fix it to plsql block to use parameter
--  set the transformation attributes
--	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY',             true );
--	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR',      true );
--	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'REF_CONSTRAINTS',    false);
--	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'OID',                false);
--	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'SEGMENT_ATTRIBUTES', false);
--	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'TABLESPACE',         true );

ttitle off
