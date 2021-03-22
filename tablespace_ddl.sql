--==============================================================================
-- GPI - Gunther Pippèrr
-- Desc: get the ddl of a tablespace, show default storage options!  
--       Parameter name of the tablespace
--==============================================================================
set verify  off
set linesize 130 pagesize 4000 

define TABLESPACE_NAME = '&1' 

prompt
prompt Parameter 1 = Tablespace Name => &&TABLESPACE_NAME.
prompt

set long 1000000;

column tab_ddl format a100 heading "Tablespace DDL" WORD_WRAPPED

select dbms_metadata.get_ddl('TABLESPACE','&&TABLESPACE_NAME.')  as tab_ddl 
  from dual
/

-- fix it to plsql block to use parameter
-- set the transformation attributes
--	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY',             true );
--	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR',      true );
--	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'REF_CONSTRAINTS',    false);
--	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'OID',                false);
--	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'SEGMENT_ATTRIBUTES', false);
--	dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'TABLESPACE',         true );

	